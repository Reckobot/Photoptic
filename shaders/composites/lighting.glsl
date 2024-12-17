#version 330 compatibility

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);

	color *= texture(colortex9, texcoord);
	float depth = texture(depthtex0, texcoord).r;
	vec4 reflection = texture(colortex10, texcoord);
	color += reflection;
}