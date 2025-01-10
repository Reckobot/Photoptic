uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
uniform sampler2D colortex9;
uniform sampler2D colortex10;
uniform sampler2D colortex11;
uniform sampler2D colortex12;
uniform sampler2D colortex13;
uniform sampler2D colortex14;
uniform sampler2D colortex15;

uniform sampler2D noisetex;

uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

uniform vec3 shadowLightPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform float viewWidth;
uniform float viewHeight;

uniform int frameCounter;
uniform float frameTime;
uniform float far;
uniform float playerMood;
uniform float constantMood;

uniform vec3 skyColor;
uniform vec3 fogColor;
uniform vec3 cameraPosition;
uniform int renderStage;

uniform int worldTime;
uniform int biome_category;