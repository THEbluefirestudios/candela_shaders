#version 330 compatibility

uniform sampler2D colortex3;
uniform float viewWidth;

#include "/lib/settings.glsl"

in vec2 texcoord;

const int BLUR_RADIUS = BLOOM_BLUR_RADIUS_X;

float gaussianWeight(float x, float sigma) {
	return exp(-(x * x) / (2.0 * sigma * sigma));
}

/* RENDERTARGETS: 4 */
layout(location = 0) out vec4 color;

void main() {
	vec3 result = vec3(0.0);
	float totalWeight = 0.0;
	float sigma = float(BLUR_RADIUS) * 0.4;
	float texel = 1.0 / viewWidth;

	for (int x = -BLUR_RADIUS; x <= BLUR_RADIUS; x++) {
		float weight = gaussianWeight(float(x), sigma);
		vec2 sampleCoord = texcoord + vec2(float(x) * texel, 0.0);
		result += texture(colortex3, sampleCoord).rgb * weight;
		totalWeight += weight;
	}

	color = vec4(result / totalWeight, 1.0);
}