#version 330 compatibility

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);
	color += color * texture(colortex7, texcoord);

	float depth = texture(depthtex1, texcoord).r;

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

	float dist = length(viewPos) / (far);
	float fogFactor = exp(-10 * (1.0 - dist));

	if (texture(colortex8, texcoord).rgb != vec3(1)){
		if (feetPlayerPos.y > 0){
			color.rgb = mix(color.rgb, (texture(colortex3, texcoord).rgb+texture(colortex4, texcoord).rgb)*clamp(1-(playerMood*16), 0.0, 1.0), clamp(fogFactor, 0.0, 1.0));
		}else{
			color.rgb = mix(color.rgb, texture(colortex3, texcoord).rgb*clamp(1-(playerMood*16), 0.0, 1.0), clamp(fogFactor, 0.0, 1.0));
		}
	}

	color.rgb = mix(color.rgb, texture(colortex8, texcoord).rgb, texture(colortex8, texcoord).a);
	color.rgb = mix(color.rgb, texture(colortex12, texcoord/CLOUD_RES).rgb, texture(colortex12, texcoord/CLOUD_RES).a);

	color.rgb = aces(color.rgb);
	color.rgb = BSC(color.rgb, BRIGHTNESS, SATURATION, CONTRAST);
}