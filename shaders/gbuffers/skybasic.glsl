#version 330 compatibility

uniform int renderStage;

in vec4 glcolor;

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(skyColor, (mix(fogColor, vec3(1.75, 1.5, 1.0), 0.75)*1.25)*clamp(getBrightness(skyColor*2), 0.0, 1.0), fogify(max(upDot+0.375, 0.0), 0.25));
}

vec3 screenToView(vec3 screenPos) {
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndcPos;
	return tmp.xyz / tmp.w;
}

/* RENDERTARGETS: 0,3 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 skybuffer;

void main() {
	if (renderStage == MC_RENDER_STAGE_STARS) {
		color = glcolor;
	} else {
		vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
		color += vec4(calcSkyColor(normalize(pos)), 1.0);
	}
	color = vec4(pow(color.rgb, vec3(2.5)), 1);
	skybuffer = color;
}
