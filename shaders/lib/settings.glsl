#define Photoptic 0 //[0]
#define Version 0 //[0]

#define SUN_R 1.75 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define SUN_G 1.25 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define SUN_B 1.0 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define SUN_INTENSITY 2.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0]

#define AMBIENT_R 1.0 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define AMBIENT_G 1.5 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define AMBIENT_B 1.75 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
#define AMBIENT_INTENSITY 0.3 //[0.0 0.1 0.2 0.25 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define BRIGHTNESS 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SATURATION 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define CONTRAST 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define SSR
#define SSR_STEPS 128 //[128 256 512 1024 2048 4096 8192]
#define SSR_DIST 0.005 //[0.005 0.01 0.05 0.075 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5]

const float sunPathRotation = 45;

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