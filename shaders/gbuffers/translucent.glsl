#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D normals;
uniform sampler2D specular;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
in mat3 tbnmatrix;

/* RENDERTARGETS: 0,1,2,5,12 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;
layout(location = 3) out vec4 encodedSpecular;
layout(location = 4) out vec4 albedo;

vec3 getnormalmap(vec2 texcoord){
	vec3 normalmap = texture(normals, texcoord).rgb;
	normalmap = normalmap * 2 - 1;
	normalmap.z = sqrt(1 - dot(normalmap.xy, normalmap.xy));
	return tbnmatrix * normalmap;
}

void main() {
	color = texture(gtexture, texcoord);
	albedo = color;
	albedo.a = 1;
	color *= vec4(BSC(glcolor.rgb, 0.25, 0.5, 1.0),1.0);
	color.a = clamp(color.a*1.1, 0.0, 1.0);
	color *= texture(lightmap, lmcoord);
	if (color.a < 0.1) {
		discard;
	}
	lightmapData = vec4(lmcoord, 0.0, 1.0);
	encodedNormal = vec4(getnormalmap(texcoord) * 1 + 0.5, 1.0);
	encodedSpecular = vec4(1.0);
}