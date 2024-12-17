#version 330 compatibility

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);

	float depth = texture(depthtex0, texcoord).r;

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

	float dist = length(viewPos) / (far*0.85);
	float fogFactor = exp(-5 * (1.0 - dist));

	if (feetPlayerPos.y > 0){
		color.rgb = mix(color.rgb, (texture(colortex3, texcoord).rgb+texture(colortex4, texcoord).rgb)*clamp(1-(playerMood*16), 0.0, 1.0), clamp(fogFactor, 0.0, 1.0));
	}else{
		color.rgb = mix(color.rgb, texture(colortex3, texcoord).rgb*clamp(1-(playerMood*16), 0.0, 1.0), clamp(fogFactor, 0.0, 1.0));
	}

	color.rgb = BSC(color.rgb, BRIGHTNESS, SATURATION, CONTRAST);

	color.rgb = aces(color.rgb);

	color.rgb *= BSC(vec3(IGN(texcoord, frameCounter, vec2(viewWidth, viewHeight))), 1.0, 1.0, 0.1)*2;
}