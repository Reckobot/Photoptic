#include "/lib/variables/uniforms.glsl"

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
    vec4 homPos = projectionMatrix * vec4(position, 1.0);
    return homPos.xyz / homPos.w;
}

vec3 viewToFtPl(vec3 view){
	return (gbufferModelViewInverse * vec4(view, 1.0)).xyz;
}

vec3 depthToView(vec2 texcoord, float depth){
	return projectAndDivide(gbufferProjectionInverse,(vec3(texcoord.xy, depth) * 2.0 - 1.0));
}

float IGN(vec2 coord, int frame, vec2 res)
{
    float x = float(coord.x * res.x) + 5.588238 * float(frame);
    float y = float(coord.y * res.y) + 5.588238 * float(frame);
    return mod(52.9829189 * mod(0.06711056*float(x) + 0.00583715*float(y), 1.0), 1.0);
}

float bayer(float grayscale, vec2 coord){
    int matrix[16] = int[16](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
    int i = (int(coord.x*viewWidth) % 4) + (int(coord.y*viewHeight) % 4) * 4;
    return grayscale > (float(matrix[i]) + 0.5) / 16.0 ? 1.0 : 0.0;
}

vec3 BSC(vec3 color, float brt, float sat, float con)
{
	// Increase or decrease theese values to adjust r, g and b color channels seperately
	const float AvgLumR = 0.5;
	const float AvgLumG = 0.5;
	const float AvgLumB = 0.5;
	
	const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);
	
	vec3 AvgLumin  = vec3(AvgLumR, AvgLumG, AvgLumB);
	vec3 brtColor  = color * brt;
	vec3 intensity = vec3(dot(brtColor, LumCoeff));
	vec3 satColor  = mix(intensity, brtColor, sat);
	vec3 conColor  = mix(AvgLumin, satColor, con);
	
	return conColor;
}

float getBrightness(vec3 color){
	return (color.r + color.g + color.b)/3;
}

float getFresnel(vec2 coord, vec3 dir, vec3 norm){
	float f0 = texture(colortex5, coord).g;
	float fresnel = pow(f0 + (1 - f0) * (1-dot(dir, norm)), 5);
    return fresnel;
}

float getRoughness(vec2 coord, sampler2D depthtex, float depth){
	float roughness = pow(1 - texture(colortex5, coord).r, 2);

	if (depth != texture(depthtex, coord).r){
		roughness = 0.01;
	}

	roughness = (2/roughness)-2;

    return roughness;
}

vec3 viewtoscreen(vec3 input){
	vec4 cPos = gbufferProjection * vec4(input, 1);
	vec3 nPos = cPos.xyz / cPos.w;
	vec3 sPos = nPos * 0.5 + 0.5;
	return sPos;
}

vec3 blurPixelY(sampler2D colortex, vec2 coord, int radius){
	vec3 final = vec3(0);
	int dividend = radius*2+1;
	for (int y = int(coord.y*viewHeight) - radius; y < int(coord.y*viewHeight) + radius; y++){
		final += texture(colortex, vec2(coord.x, y/viewHeight)).rgb;
	}
	final /= dividend;
	return final;
}

vec3 blurPixelX(sampler2D colortex, vec2 coord, int radius){
	vec3 final = vec3(0);
	int dividend = radius*2+1;
	for (int x = int(coord.x*viewWidth) - radius; x < int(coord.x*viewWidth) + radius; x++){
		final += texture(colortex, vec2(x/viewWidth, coord.y)).rgb;
	}
	final /= dividend;
	return final;
}