#version 330 compatibility
#extension GL_ARB_shader_storage_buffer_object : enable
#include "/lib/tonemap.glsl"
#include "/lib/settings.glsl"
#include "/lib/functions/common.glsl"
#include "/lib/distort.glsl"
#include "/lib/SSBO.glsl"

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

	#ifdef WAVING_FOLIAGE
	vec3 centerPosition = pos + at_midBlock.xyz/64.0;
	vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	vec3 ftplPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 worldPos = ftplPos + cameraPosition;

	int framecount;
	if (frameCounter > 18000){
		framecount = 36000 - frameCounter;
	}else{
		framecount = frameCounter;
	}
	float e = (deltaTime*FOLIAGE_SPEED)*0.00075;
	vec4 vertex = gl_Vertex;
	if (mc_Entity.x == 300){
		if ((pos.y - centerPosition.y) > 0.25){
			vertex.xz += sin(e*(worldPos.xz/100))/18;

			gl_Position = (gl_ModelViewProjectionMatrix * vertex);
			pos = (gl_ModelViewMatrix * vertex).xyz;
		}
	}else if(mc_Entity.x == 301){
		vertex.xz += sin(e*(worldPos.xz/100))/18;

		gl_Position = (gl_ModelViewProjectionMatrix * vertex);
		pos = (gl_ModelViewMatrix * vertex).xyz;
	}
	#endif
}