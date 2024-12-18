#version 330 compatibility

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);

	color *= texture(colortex9, texcoord);
	float depth = texture(depthtex0, texcoord).r;
	vec4 reflection = texture(colortex10, texcoord);

	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);
	vec3 viewDir = mat3(gbufferModelViewInverse) * -normalize(projectAndDivide(gbufferProjectionInverse, vec3(texcoord.xy, 0) * 2.0 - 1.0));
	float fresnel = getFresnel(texture(colortex5, texcoord).g, viewDir, normal);
	if (depth != texture(depthtex1, texcoord).r){
		fresnel = getFresnel(0, viewDir, normal);
	}

	color = mix(color, reflection, clamp(fresnel, 0.0, 1.0));
}