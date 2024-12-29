#version 330 compatibility

in vec2 texcoord;

/* RENDERTARGETS: 6 */
layout(location = 0) out vec4 blur;

void main() {
    #ifdef BLOOM
    blur.rgb = blurPixelX(colortex0, texcoord, 25, 2);
    #else
    blur = texture(colortex0, texcoord);
    #endif
}