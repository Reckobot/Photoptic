#version 330 compatibility
#include "/lib/tonemap.glsl"
#include "/lib/settings.glsl"
#include "/lib/functions/common.glsl"
#include "/lib/distort.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
in vec4 at_tangent;
in vec4 at_midBlock;
out mat3 tbnmatrix;
out vec3 pos;

in vec2 mc_Entity;
flat out int isFoliage;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;

	vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
	vec3 bitangent = normalize(cross(tangent, normal) * at_tangent.w);
	tbnmatrix = mat3(mat3(gbufferModelViewInverse) * tangent, 
		mat3(gbufferModelViewInverse) * bitangent, 
		mat3(gbufferModelViewInverse) * normal
	);

	if ((mc_Entity.x == 300)||(mc_Entity.x == 301)||(mc_Entity.x == 302)){
		isFoliage = 1;
	}else{
		isFoliage = 0;
	}

	pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
}