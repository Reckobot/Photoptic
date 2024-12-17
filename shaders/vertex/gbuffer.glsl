#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
in vec4 at_tangent;
out mat3 tbnmatrix;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;

	vec3 tangent = mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix * at_tangent.xyz);
	vec3 bitangent = mat3(gbufferModelViewInverse) * normalize(cross(tangent, normal) * at_tangent.w);
	normal = mat3(gbufferModelViewInverse) * normal;
	tbnmatrix = mat3(tangent, bitangent, normal);
}