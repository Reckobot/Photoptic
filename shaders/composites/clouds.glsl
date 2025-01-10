#version 330 compatibility
#extension GL_ARB_shader_storage_buffer_object : enable
#include "/lib/SSBO.glsl"

in vec2 texcoord;

/* RENDERTARGETS: 12 */
layout(location = 0) out vec4 cloudbuffer;

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(skyColor, (mix(fogColor, vec3(1.75, 1.5, 1.0), 0.75)*1.25)*clamp(getBrightness(skyColor*2), 0.0, 1.0), fogify(max(upDot+0.375, 0.0), 0.25));
}

vec3 getShadow(vec3 shadowScreenPos){
	vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);
	if (texture(shadowcolor1, shadowScreenPos.xy).rgb == vec3(1)){
	return shadowColor.rgb;
	}
	float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r); // sample the shadow map containing everything
	if(transparentShadow == 1.0){
	return vec3(1.0);
	}
	float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r); // sample the shadow map containing only opaque stuff
	if(opaqueShadow == 0.0){
	return vec3(0.0);
	}
	return shadowColor.rgb * 2.0;
}

vec3 getSoftShadow(vec4 shadowClipPos, float bias){
	const float range = 1.0;
	const float increment = 0.5;

	float noise = IGN(texcoord, frameCounter, vec2(viewWidth, viewHeight));

	float theta = noise * radians(360.0);
	float cosTheta = cos(theta);
	float sinTheta = sin(theta);

	mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);

	vec3 shadowAccum = vec3(0.0);
	int samples = 0;

	for(float x = -range; x <= range; x += increment){
		for (float y = -range; y <= range; y+= increment){
			vec2 offset = rotation * vec2(x, y) / shadowMapResolution;
			vec4 offsetShadowClipPos = shadowClipPos + vec4(offset, 0.0, 0.0);
      		offsetShadowClipPos.z -= bias;
      		offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
      		vec3 shadowNDCPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w;
      		vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
      		shadowAccum += getShadow(shadowScreenPos);
      		samples++;
    	}
  	}

  	return shadowAccum / float(samples);
}

void main() {
	if ((texcoord.x > 1)||(texcoord.y > 1)){
		discard;
	}

    float depth = texture(depthtex0, texcoord).r;
	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 ftplPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
    vec3 viewDir = mat3(gbufferModelViewInverse) * -normalize(projectAndDivide(gbufferProjectionInverse, vec3(texcoord.xy, 0) * 2.0 - 1.0));

    float timeDay = clamp(getBrightness(skyColor), 0.0, 1.0);

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	#ifdef FANCY_CLOUDS
	
	vec3 cloudcolor = vec3(0);

	float cloud = 0;
	vec3 firstpos = vec3(0);

	int count = 0;

	vec3 startpos = viewDir;

	for (int i = 0; i < 32; i++){
		vec3 rayPos = (viewDir - (normalize(viewDir)*i));

		if ((rayPos.y+cameraPosition.y) >= 125){
			startpos = rayPos;
			break;
		}
	}

	for (int i = 0; i < CLOUD_STEPS; i++){
		vec3 rayPos = (startpos - (normalize(viewDir)*i));

		if (count == 0){
			firstpos = rayPos;
		}

		if (length(rayPos) <= length(ftplPos)){
			float c = pNoise(((rayPos.xz+cameraPosition.xz)*(sin(worldTime*0.01/50)))/250, 1, 1);
			c -= pNoise(((rayPos.xz+cameraPosition.xz)*(sin(worldTime*0.01/50)))/75, 1, 1);
			c -= pNoise(((rayPos.xz+cameraPosition.xz)*(sin(worldTime*0.01/50)))/25, 1, 1);
			if (((rayPos.y+cameraPosition.y) > 125)&&((rayPos.y+cameraPosition.y) < 125+(c*64))){

				cloud += c;

				vec3 particlecolor = vec3(1);

				for (int e = 0; e < 16; e++){
					vec3 lightpos = rayPos + (-worldLightVector*e);

					particlecolor += c/64;
				}

				cloudcolor += particlecolor;
			}
		}
		count++;
	}

	cloudcolor /= count;

	cloudbuffer = vec4(mix(vec3(1.0)/1.45, vec3(1.75, 1.5, 1.0)*1.1, cloudcolor), clamp(cloud, 0.0, 1.0));

	cloudbuffer.rgb *= timeDay*1.25;
	cloudbuffer.rgb = BSC(cloudbuffer.rgb, 0.9, 2.0, 4.0);

	cloudbuffer.rgb = mix(texture(colortex3, texcoord).rgb, cloudbuffer.rgb, cloudbuffer.a);
	cloudbuffer.rgb = clamp(cloudbuffer.rgb, 0.05, 10.0);
	cloudbuffer.rgb = mix(cloudbuffer.rgb, skyColor, 0.25);

	#endif
}