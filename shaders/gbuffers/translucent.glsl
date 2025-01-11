#version 330 compatibility
#extension GL_ARB_shader_storage_buffer_object : enable

#include "/lib/settings.glsl"
#include "/lib/functions/common.glsl"
#include "/lib/SSBO.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D normals;
uniform sampler2D specular;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
in mat3 tbnmatrix;
in vec4 ogPos;
flat in int isWater;
in vec3 worldPos;

/* RENDERTARGETS: 0,1,2,5,12 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;
layout(location = 3) out vec4 encodedSpecular;
layout(location = 4) out vec4 albedo;

vec3 getnormalmap(vec2 texcoord){
	vec3 normalmap = texture(normals, texcoord).rgb;
	normalmap = normalmap * 2 - 1;
	return tbnmatrix * normalmap;
}

void main() {
	#ifdef FANCY_WATER
	if (bool(isWater)){
		color = vec4(vec3(0.1), 0.75);
		albedo = color;
		color *= vec4(BSC(glcolor.rgb, 0.5, WATER_SATURATION, 1.0),1.0);
		color.a = clamp(color.a*1.1, 0.0, 1.0);
		color *= texture(lightmap, lmcoord);

		vec3 normalnoise = vec3(
		pNoise(((worldPos.xz)*(sin((frameCounter*3-(frameTime)+36000)*0.000005))), 1, 0.5),
		pNoise(((worldPos.xz)*(sin((frameCounter*3-(frameTime)+36000)*0.000005))), 1, 0.5),
		0)/8;

		normalnoise -= normalnoise/2;
		encodedNormal = vec4(mat3(gbufferModelViewInverse) * (normal+normalnoise) * 0.5 + 0.5, 1.0);
		encodedNormal.rgb += normalnoise;
	}else{
		color = texture(gtexture, texcoord) * glcolor / 2;
		color *= texture(lightmap, lmcoord);
		#ifdef LABPBR
		encodedNormal = vec4(getnormalmap(texcoord) * 1 + 0.5, 1.0);
		#else
		encodedNormal = vec4(mat3(gbufferModelViewInverse) * normal * 0.5 + 0.5, 1.0);
		#endif
	}
	#else
		color = texture(gtexture, texcoord) * glcolor;
		color.rgb *= 0.1;
		color *= texture(lightmap, lmcoord);
		#ifdef LABPBR
		encodedNormal = vec4(getnormalmap(texcoord) * 1 + 0.5, 1.0);
		#else
		encodedNormal = vec4(mat3(gbufferModelViewInverse) * normal * 0.5 + 0.5, 1.0);
		#endif
	#endif
	if (color.a < 0.1) {
		discard;
	}
	lightmapData = vec4(lmcoord, 0.0, 1.0);
	encodedSpecular = vec4(1.0);
}