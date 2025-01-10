#version 330 compatibility
#extension GL_ARB_shader_storage_buffer_object : enable

#include "/lib/SSBO.glsl"

#include "/lib/settings.glsl"
#include "/lib/functions/common.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
out mat3 tbnmatrix;
flat out int isWater;
out vec4 ogPos;
out vec3 worldPos;

in vec4 at_tangent;
in vec2 mc_Entity;

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

	if (mc_Entity.y == 1){
		isWater = 1;
	}else{
		isWater = 0;
	}

	vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	vec3 ftplPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	worldPos = ftplPos + cameraPosition;

	if (mc_Entity.y == 1){
	#ifdef FANCY_WATER
	ogPos = gl_Position;
	ogPos.y -= 1;

	if ((biome_category == CAT_OCEAN)||(biome_category == CAT_BEACH)){
		biomeMult += frameTime/(100*TRANSITION_TIME);
	}else{
		biomeMult -= frameTime/(100*TRANSITION_TIME);
	}

	biomeMult = clamp(biomeMult, 1.0, 4.0);

	int iterations = 8;
	int increment = 1;
	for (int i = 0; i < iterations; i += increment){
		float addition = (sin(worldTime*0.001))*(WAVE_SPEED/20)*100000*(WAVE_SPEED)/(WAVYNESS*100);
		float height = pNoise((worldPos.xz+vec2(addition, addition*1.5)+(rand(vec2(i))))/100, 1, 0.01);
		gl_Position.y += height/(12/WAVYNESS/biomeMult);
	}
	gl_Position.y -= (0.075*biomeMult);
	#endif

	glcolor.rgb = BSC(glcolor.rgb, 
		4.0,
		1.0,
		1.0);
	}
}