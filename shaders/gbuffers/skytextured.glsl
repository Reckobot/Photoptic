#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

/* RENDERTARGETS: 0,1,2,4 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;
layout(location = 3) out vec4 skytextured;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	color *= texture(lightmap, lmcoord);
	if (color.a < 0.1) {
		discard;
	}
	lightmapData = vec4(lmcoord, 0.0, 1.0);
	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
	skytextured = color;
}