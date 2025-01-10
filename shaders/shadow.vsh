#version 330 compatibility
#include "/lib/distort.glsl"

out vec2 texcoord;
out vec4 glcolor;

in vec2 mc_Entity;
flat out int isFoliage;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;

	gl_Position = ftransform();
	gl_Position.xyz = distortShadowClipPos(gl_Position.xyz);

	if (mc_Entity.x == 300){
		isFoliage = 1;
	}else{
		isFoliage = 0;
	}
}