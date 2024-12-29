#version 330 compatibility

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 blur;

void main() {
    #ifdef BLOOM
    blur.rgb = mix(texture(colortex0, texcoord).rgb, blurPixelY(colortex6, texcoord, 25, 2), 0.25);
    #else
    blur = texture(colortex0, texcoord);
    #endif
}