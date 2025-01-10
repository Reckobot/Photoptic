#include "/lib/tonemap.glsl"
#include "/lib/settings.glsl"
#include "/lib/functions/common.glsl"
#include "/lib/distort.glsl"

float getCloud(vec3 pos){
    float c = pNoise(((pos.xz)*(sin((frameCounter*3-(frameTime)+36000)*0.000005))), 1, 50);
    c -= pNoise(((pos.xz)*(sin((frameCounter*3-(frameTime)+36000)*0.000005))), 1, 25);
    c -= pNoise(((pos.xz)*(sin((frameCounter*3-(frameTime)+36000)*0.000005))), 1, 5);

    return c;
}