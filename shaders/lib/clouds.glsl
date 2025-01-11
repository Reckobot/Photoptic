#include "/lib/tonemap.glsl"
#include "/lib/settings.glsl"
#include "/lib/functions/common.glsl"
#include "/lib/distort.glsl"

float getCloud(vec3 pos){
    int framecount;
    if (frameCounter > 18000){
        framecount = 36000 - frameCounter;
    }else{
        framecount = frameCounter;
    }
    float e = (framecount*CLOUD_SPEED*0.5-(frameTime))*0.05;
    vec2 v = ((pos.xz)+vec2(e));
    float c = pNoise(v, 1, 500);
    c -= pNoise(v, 1, 250);
    c -= pNoise(v, 1, 50);

    c *= 1.5;

    return c;
}