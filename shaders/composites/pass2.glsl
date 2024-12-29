#version 330 compatibility

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 blur;

void main() {
    blur.rgb = mix(texture(colortex0, texcoord).rgb, blurPixelY(colortex6, texcoord, 50), 0.25);
}