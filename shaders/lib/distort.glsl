#define SHADOW_RES 4096 //[128 256 512 1024 2048 4096 8192]

const int shadowMapResolution = SHADOW_RES;
const float shadowDistance = 100;

vec3 distortShadowClipPos(vec3 shadowClipPos){
    float distortionFactor = length(shadowClipPos.xy); // distance from the player in shadow clip space
    distortionFactor += 0.25; // very small distances can cause issues so we add this to slightly reduce the distortion

    shadowClipPos.xy /= distortionFactor;
    shadowClipPos.z *= 0.25; // increases shadow distance on the Z axis, which helps when the sun is very low in the sky
    return shadowClipPos;
}