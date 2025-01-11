#version 330 compatibility
#include "/lib/tonemap.glsl"
#include "/lib/settings.glsl"
#include "/lib/functions/common.glsl"
#include "/lib/distort.glsl"

out vec2 texcoord;
out vec4 glcolor;

in vec2 mc_Entity;
flat out int isFoliage;
in vec4 at_midBlock;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;

	vec3 pos = distortShadowClipPos((gl_ModelViewProjectionMatrix * gl_Vertex).xyz);
	gl_Position.xyz = pos;

	if ((mc_Entity.x == 300)||(mc_Entity.x == 301)||(mc_Entity.x == 302)){
		isFoliage = 1;
	}else{
		isFoliage = 0;
	}

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
	float e = (framecount-(frameTime))*0.05;
	vec4 vertex = gl_Vertex;
	if (mc_Entity.x == 300){
		if ((pos.y - centerPosition.y) > 0.25){
			vertex.xz += sin(e*(worldPos.xz/100))/18;

			gl_Position.xyz = distortShadowClipPos((gl_ModelViewProjectionMatrix * vertex).xyz);
		}
	}
	#endif
}