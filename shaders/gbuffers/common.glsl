#version 330 compatibility
#include "/lib/settings.glsl"
#include "/lib/functions/common.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D normals;
uniform sampler2D specular;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
in mat3 tbnmatrix;
flat in int isFoliage;
in vec3 pos;

/* RENDERTARGETS: 0,1,2,5,12,15,13 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;
layout(location = 3) out vec4 encodedSpecular;
layout(location = 4) out vec4 albedo;
layout(location = 5) out vec4 foliage;
layout(location = 6) out vec4 specularRaw;

vec3 getnormalmap(vec2 texcoord){
	vec3 normalmap = texture(normals, texcoord).rgb;
	normalmap = normalmap * 2 - 1;
	return tbnmatrix * normalmap;
}

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	albedo = color;
	albedo.a = 1;
	color *= texture(lightmap, lmcoord);
	if (color.a < 0.1) {
		discard;
	}
	lightmapData = vec4(lmcoord, 0.0, 1.0);
	
	#ifdef LABPBR
	encodedNormal = vec4(getnormalmap(texcoord) * 1 + 0.5, 1.0);
	#else
	encodedNormal = vec4(mat3(gbufferModelViewInverse) * normal * 0.5 + 0.5, 1.0);
	#endif

	encodedSpecular = texture(specular, texcoord);
	encodedSpecular.a = 1;
	specularRaw = texture(specular, texcoord);

	if ((bool(isFoliage))||(renderStage == MC_RENDER_STAGE_ENTITIES)){
		foliage.rgb = pos;
	}else{
		foliage.rgb = vec3(0);
	}
}