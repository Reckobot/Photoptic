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
	if (bool(isWater)){
		color = vec4(vec3(0.1), 0.75);
		albedo = color;
		color *= vec4(BSC(glcolor.rgb, 0.5, WATER_SATURATION, 1.0),1.0);
		color.a = clamp(color.a*1.1, 0.0, 1.0);
		color *= texture(lightmap, lmcoord);
	}else{
		color = texture(gtexture, texcoord) * glcolor / 2;
		color *= texture(lightmap, lmcoord);
	}
	if (color.a < 0.1) {
		discard;
	}
	lightmapData = vec4(lmcoord, 0.0, 1.0);
	#ifdef LABPBR
	#ifdef WATER_TEXTURE
	encodedNormal = vec4(getnormalmap(texcoord) * 1 + 0.5, 1.0);
	#else
	encodedNormal = vec4(mat3(gbufferModelViewInverse) * normal * 0.5 + 0.5, 1.0);
	#endif
	#else
	encodedNormal = vec4(mat3(gbufferModelViewInverse) * normal * 0.5 + 0.5, 1.0);
	#endif
	encodedSpecular = vec4(1.0);

	#ifdef WATER_FOAM
	if (bool(isWater)){
		for (int i = 0; i < 8; i ++){
			float nois = pNoise((worldPos.xz*i+(sin(worldTime*0.0001)*200))/1000, 1000, 0.05);

			float foam = clamp(
				nois*2 + (nois * (sin(worldTime*0.01)/8)), 
				0.22, 
				0.28)*4.5
			;

			color.rgb *= foam;
		}
	}
	#endif
}