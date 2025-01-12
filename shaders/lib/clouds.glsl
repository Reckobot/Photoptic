#include "/lib/tonemap.glsl"
#include "/lib/settings.glsl"
#include "/lib/functions/common.glsl"
#include "/lib/distort.glsl"
#include "/lib/SSBO.glsl"

float getCloud(vec3 pos){
    float e = ((deltaTime)*CLOUD_SPEED*0.5)*0.001;
    vec2 v = ((pos.xz)+vec2(e));
    float c = pNoise(v, 1, 500);
    c -= pNoise(v, 1, 250);
    c -= pNoise(v, 1, 50);

    c *= 1.5;

    c += rainStrength/1.25;

    return c;
}