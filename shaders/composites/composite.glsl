#version 330 compatibility
#extension GL_ARB_shader_storage_buffer_object : enable
#include "/lib/SSBO.glsl"
#include "/lib/clouds.glsl"

in vec2 texcoord;

/* RENDERTARGETS: 0,13 */
layout(location = 0) out vec4 color;

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(skyColor, (mix(fogColor, vec3(1.75, 1.5, 1.0), 0.75)*1.25)*clamp(getBrightness(skyColor*2), 0.0, 1.0), fogify(max(upDot+0.375, 0.0), 0.25));
}

vec3 getShadow(vec3 shadowScreenPos){
	vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);
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
	color = texture(colortex0, texcoord);
	vec4 original = color;

	float depth = texture(depthtex0, texcoord).r;

	if (depth >= 1){
		color.rgb *= 2.0;
	}

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	vec2 lightmap = texture(colortex1, texcoord).rg;
	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);

	vec3 sunlight = (vec3(SUN_R, SUN_G, SUN_B));

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 ftplPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 worldPos = ftplPos + cameraPosition;
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	vec3 shadow = getSoftShadow(shadowClipPos, clamp(exp(length(viewPos)/16)*SHADOW_RES*0.00000005, 0.001, 1.0));

	#ifdef CLOUD_SHADOWS
	#ifdef FANCY_CLOUDS
	float cloudshadow = 0;
	
	for (int i = 0; i < 16; i++){
		vec3 pos = (worldPos + (normalize(worldLightVector)*i*6));
		if ((pos.y > 125)&&(pos.y < 175)){
			cloudshadow += getCloud(pos);
		}
	}

	shadow *= shadow - clamp(cloudshadow*4, 0.0, 1.0);
	#endif
	#endif
	shadow = clamp(shadow, 0.0, 1.0);

	float NoL = dot(normal, worldLightVector);

	vec3 lightDir = worldLightVector;
	vec3 viewDir = mat3(gbufferModelViewInverse) * -normalize(projectAndDivide(gbufferProjectionInverse, vec3(texcoord.xy, 0) * 2.0 - 1.0));
	vec3 halfwayDir = normalize(lightDir + viewDir);
	float roughness = getRoughness(texcoord, depthtex1, depth);
	float fresnel = getFresnel(texture(colortex5, texcoord).g, viewDir, normal);
	float spec = pow(max(dot(normal, halfwayDir), 0.5), roughness)*shadow.r;
	float geometric = min(
		(2*dot(halfwayDir, normal)*dot(normal, viewDir))
		/
		dot(viewDir, halfwayDir),

		(2*dot(halfwayDir, normal)*dot(normal, lightDir))
		/
		dot(viewDir, halfwayDir)
		)
	;
	vec3 vnormal = mat3(gbufferModelView) * normal;

//ssr
	vec3 reflection = vec3(0);
	#ifdef SSR
	float dist = SSR_DIST;
	int init = 3;
	if (depth != texture(depthtex1, texcoord).r){
		dist *= 16;
	}
	float refl = texture(colortex5, texcoord).g;
	bool reflective = false;
	if (refl >= 0.1+(230/255)){
		reflective = true;
		vec3 reflectRay = reflect(normalize(viewPos), vnormal);
		if (depth != texture(depthtex1, texcoord).r){
			reflectRay.y += clamp(length(viewPos)/1000, 0.0, 0.05);
		}
		int steps = SSR_STEPS;

		for (int i = init; i < steps; i++){
			vec3 rayPos = viewPos + (reflectRay*dist*(i*4));
			vec3 rayscreenPos = viewtoscreen(rayPos);
			vec2 raycoord = clamp(rayscreenPos.xy, vec2(0), vec2(1));
			vec3 rayogPos = projectAndDivide(gbufferProjectionInverse, (vec3(raycoord, texture(depthtex0, raycoord).r) * 2.0 - 1.0));
			
			vec3 raypbr = texture(colortex5, raycoord).rgb;
			bool valid = ((distance(rayPos, rayogPos) <= (dist * 3))&&(texture(depthtex0, raycoord).r == texture(depthtex1, raycoord).r));

			vec3 newrayPos;
			if (valid){
				if (distance(rayPos, viewPos) > (dist * 2)){	
					newrayPos = rayogPos;
					rayscreenPos = viewtoscreen(newrayPos);
					raycoord = clamp(rayscreenPos.xy, vec2(0), vec2(1));

					vec3 sampl = texture(colortex0, raycoord).rgb;

					reflection.rgb = sampl.rgb;
					break;
				}
			}
			if (reflection.rgb == vec3(0)){
				vec3 skyPos = reflectRay;
				reflection.rgb = calcSkyColor(skyPos);
				float skyBrightness = clamp(getBrightness(skyColor)*2, 0.0, 1.0);
				reflection.rgb *= skyBrightness;
				reflection.rgb = BSC(reflection.rgb, 1.0, 2.0, 2.0);
				
				vec3 cloudpos = reflectRay;
				rayscreenPos = viewtoscreen(cloudpos);
				raycoord = clamp(rayscreenPos.xy, vec2(0), vec2(1));
				vec2 c = raycoord/4;
				if (((raycoord.y > 0)&&(raycoord.y < 1))&&((raycoord.x > 0)&&(raycoord.x < 1))){
					reflection.rgb = mix(reflection.rgb, texture(colortex12, c).rgb, texture(colortex12, c).a);
				}
			}

			if (rayPos.y > 125){
				vec4 sampl = texture(colortex12, raycoord);

				reflection.rgb = mix(reflection.rgb, sampl.rgb, sampl.a);
			}
		}
		reflection = BSC(reflection, 1.0, 1.0, 1.0);
	}

	#endif

	sunlight *= (shadow * clamp(NoL, 0.0, 1.0));
	sunlight *= SUN_INTENSITY;

	float timeDay = clamp(getBrightness(skyColor), 0.05, 1.0);
	if (depth == texture(depthtex1, texcoord).r){
		sunlight.b *= 1+(1-(timeDay*2));
	}else{
		sunlight = vec3(1);
	}
	vec3 ambient = (vec3(AMBIENT_R, AMBIENT_G, AMBIENT_B)*AMBIENT_INTENSITY);

	float NoV = dot(normal, viewDir);
	vec3 brdfspecular = ((fresnel * spec * geometric * NoL)/(4*NoL*NoV)) * sunlight;
	vec3 brdfdiffuse = color.rgb * ((NoL) * sunlight);
	vec3 brdf = clamp(brdfspecular + brdfdiffuse, 0.0, 1.0);
	brdf *= timeDay;
	brdf += texture(colortex0, texcoord).rgb * ambient;

	reflection *= lightmap.g * clamp(shadow, 0.9, 1.0) * clamp(NoL, 0.9, 1.0);

	color.rgb = brdf;
	reflection = color.rgb * reflection;

	if (reflection == vec3(0)){
		reflection = color.rgb;
	}

	if (depth != texture(depthtex1, texcoord).r){
		fresnel = getFresnel(0.25, viewDir, normal);
		reflection = BSC(reflection, 8, 1.0, 1.0);
	}

	color.rgb = mix(color.rgb, reflection, fresnel);
	color.rgb += texture(colortex0, texcoord).rgb * (lightmap.r/16);

	#ifdef SSS

	float sssFactor = 1.25;

	if ((texture(colortex5, texcoord).b >= 65/255)&&(texture(colortex5, texcoord).b <= 1)){
		sssFactor += (texture(colortex5, texcoord).b)/8;
	}

	if (texture(colortex15, texcoord).rgb != vec3(0)){
		if (length(texture(colortex15, texcoord).rgb) <= length(viewPos)){
			color.rgb = mix(BSC(color.rgb, sssFactor, 1.2, 1.0), color.rgb, 1-shadow);
		}
	}
	#endif

	float emissive = texture(colortex5, texcoord).a;

	if ((emissive <= 254.5/255)&&(emissive != 0)){
		color.rgb *= original.rgb * (1+emissive*50*EMISSIVE_STRENGTH);
	}
}