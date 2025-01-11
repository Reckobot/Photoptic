#define Photoptic 0 //[0]
#define Version 0 //[0]

#define SUN_R 1.75 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define SUN_G 1.25 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define SUN_B 1.0 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define SUN_INTENSITY 1.5 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0]

#define AMBIENT_R 1.0 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define AMBIENT_G 1.0 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define AMBIENT_B 1.0 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define AMBIENT_INTENSITY 0.6 //[0.0 0.1 0.2 0.25 0.3 0.4 0.5 0.6 0.7 0.75 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define BRIGHTNESS 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SATURATION 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define CONTRAST 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define SSR
#define SSR_STEPS 128 //[64 128 256 512 1024 2048 4096 8192]
#define SSR_DIST 0.01 //[0.005 0.0075 0.01 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5]

#define FANCY_CLOUDS
#define CLOUD_STEPS 256 //[32 64 80 128 256 512 1024 2048 4096 8192]
#define CLOUD_RES 4 //[1 2 3 4]
#define CLOUD_SPEED 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define CLOUD_SHADOWS

#define WAVING_FOLIAGE

#define SSS
#define BLOOM
#define LABPBR

#define FANCY_WATER
//#define WATER_TEXTURE
#define TRANSITION_TIME 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.75 0.8 0.9 1.0 1.25 1.5 1.75 2.0 3.0 4.0 5.0 10.0 15.0]
#define WAVYNESS 1.0 //[0.0 0.1 0.2 0.25 0.3 0.35 0.4 0.5 0.6 0.7 0.75 0.8 0.9 1.0 1.25 1.5 1.75 2.0 3.0 4.0 5.0 10.0 15.0]
#define WAVE_SPEED 0.75 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.75 0.8 0.9 1.0 1.25 1.5 1.75 2.0 3.0 4.0 5.0 10.0 15.0]
#define WATER_SATURATION 0.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define SUN_ROTATION 45 //[-90 -85 -80 -75 -70 -65 -60 -55 -50 -45 -40 -35 -30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90]

const float sunPathRotation = SUN_ROTATION;

const int RGBA16F = 0;
const int RGBA32F = 0;
const int colortex0Format = RGBA16F;
const int colortex1Format = RGBA16F;
const int colortex2Format = RGBA16F;
const int colortex3Format = RGBA16F;
const int colortex4Format = RGBA16F;
const int colortex5Format = RGBA16F;
const int colortex6Format = RGBA16F;
const int colortex7Format = RGBA16F;
const int colortex8Format = RGBA16F;
const int colortex9Format = RGBA16F;
const int colortex10Format = RGBA16F;
const int colortex11Format = RGBA16F;
const int colortex12Format = RGBA16F;
const int colortex13Format = RGBA16F;
const int colortex14Format = RGBA16F;
const int colortex15Format = RGBA16F;

const bool shadowHardwareFiltering = true;