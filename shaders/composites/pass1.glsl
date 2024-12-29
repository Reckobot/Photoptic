#version 330 compatibility

in vec2 texcoord;

/* RENDERTARGETS: 6 */
layout(location = 0) out vec4 blur;

void main() {
    blur.rgb = blurPixelX(colortex0, texcoord, 50);
}