#version 330 compatibility
#include "/lib/distort.glsl"

uniform sampler2D gtexture;
uniform int renderStage;

in vec2 texcoord;
in vec4 glcolor;
flat in int isFoliage;

layout(location = 0) out vec4 shadowcolor0;
layout(location = 1) out vec4 shadowcolor1;

void main() {
	shadowcolor0 = texture(gtexture, texcoord) * glcolor;

	if(shadowcolor0.a < 0.1){
		discard;
	}

	if (bool(isFoliage)){
		shadowcolor1.rgb = vec3(1);
	}else{
		shadowcolor1.rgb = vec3(0);
	}
}