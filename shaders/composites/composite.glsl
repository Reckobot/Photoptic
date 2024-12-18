#version 330 compatibility

in vec2 texcoord;

/* RENDERTARGETS: 0,7,9,10 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 fresnelbuffer;
layout(location = 2) out vec4 lightbuffer;
layout(location = 3) out vec4 reflbuffer;

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(skyColor, (mix(fogColor, vec3(1.75, 1.5, 1.0), 0.75)*1.25)*clamp(getBrightness(skyColor*2), 0.0, 1.0), fogify(max(upDot+0.375, 0.0), 0.25));
}

vec3 getShadow(vec3 shadowScreenPos){
	float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r); // sample the shadow map containing everything
	if(transparentShadow == 1.0){
	return vec3(1.0);
	}
	float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r); // sample the shadow map containing only opaque stuff
	if(opaqueShadow == 0.0){
	return vec3(0.0);
	}
	vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);
	return shadowColor.rgb * 2.0;
}

vec3 getSoftShadow(vec4 shadowClipPos, float bias){
	const float range = 8.0;
	const float increment = 4.0;

	float noise = IGN(texcoord, frameCounter, vec2(shadowMapResolution));

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

	vec3 sunlight = (vec3(SUN_R, SUN_G, SUN_B)*SUN_INTENSITY) * lightmap.g;
	float diffuse = clamp(dot(normal, worldLightVector), 0.0, 1.0);

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	vec3 shadow = getSoftShadow(shadowClipPos, exp(length(viewPos)/16)*SHADOW_RES*0.00000005);


	vec3 lightDir = worldLightVector;
	vec3 viewDir = mat3(gbufferModelViewInverse) * -normalize(projectAndDivide(gbufferProjectionInverse, vec3(texcoord.xy, 0) * 2.0 - 1.0));
	vec3 halfwayDir = normalize(lightDir + viewDir);
	float roughness = getRoughness(texcoord, depthtex1, depth);
	float fresnel = getFresnel(texcoord, viewDir, normal);
	float spec = pow(max(dot(normal, halfwayDir), 0.5), roughness) + 0.25;
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
	#ifdef SSR
	float dist = SSR_DIST;
	if (depth != texture(depthtex1, texcoord).r){
		dist *= 10;
	}
	vec3 reflection = vec3(0);
	float refl = texture(colortex5, texcoord).g;
	bool reflective = false;
	if (refl >= 0.1+(230/255)){
		reflective = true;
		vec3 reflectRay = reflect(normalize(viewPos), vnormal);
		int steps = SSR_STEPS;

		for (int i = 3; i < steps; i++){
			vec3 rayPos = viewPos + (reflectRay*dist*(i*4));
			vec3 rayscreenPos = viewtoscreen(rayPos);
			vec2 raycoord = rayscreenPos.xy;
			vec3 rayogPos = projectAndDivide(gbufferProjectionInverse, (vec3(raycoord, texture(depthtex0, raycoord).r) * 2.0 - 1.0));
			
			vec3 raypbr = texture(colortex5, raycoord).rgb;

			vec3 newrayPos;
			if (distance(rayPos, rayogPos) <= (dist * 3)){
				if ((bool(lessThanEqual(raycoord, vec2(1,1)))&&bool(greaterThanEqual(raycoord, vec2(0,0))))){
					if (distance(rayPos, viewPos) > (dist * 2)){	
						newrayPos = rayogPos;
						rayscreenPos = viewtoscreen(newrayPos);
						raycoord = rayscreenPos.xy;

						vec3 sampl = texture(colortex0, raycoord).rgb;

						reflection.rgb = sampl.rgb;
						break;
					}
				}
			}
			if (reflection.rgb == vec3(0)){
				vec3 skyPos = reflectRay;
				reflection.rgb = calcSkyColor(skyPos);
				float skyBrightness = clamp(getBrightness(skyColor)*2, 0.0, 1.0);
				reflection.rgb *= skyBrightness;
			}
		}
	}
	#endif

	vec3 ambient = (vec3(AMBIENT_R, AMBIENT_G, AMBIENT_B)*AMBIENT_INTENSITY);

	float brdfspecular = (fresnel * spec * geometric)/(4*dot(normal, lightDir)*dot(normal, viewDir));
	float brdfdiffuse = (1.0 - fresnel) * diffuse;
	float brdf = brdfdiffuse + brdfspecular;

	vec3 lighting = sunlight;
	lighting *= clamp(getBrightness(skyColor*2), 0.25, 1.0);
	lighting *= brdf;
	lighting *= shadow * clamp(diffuse*8, 0.0, 1.0);
	lighting += ambient;

	if (texture(colortex8, texcoord) == vec4(0)){
		lightbuffer.rgb = lighting;
		reflbuffer.rgb = color.rgb * mix((color.rgb*diffuse), reflection, clamp(fresnel, 0.0, 1.0));
	}else{
		lightbuffer.rgb = vec3(clamp(getBrightness(skyColor*2), 0.25, 1.0));
	}
}