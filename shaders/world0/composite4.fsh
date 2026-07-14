#version 330 compatibility

uniform sampler2D colortex4;
uniform float viewHeight;

#include "/lib/settings.glsl"
in vec2 texcoord;

const int BLUR_RADIUS = BLOOM_BLUR_RADIUS_Y;

float gaussianWeight(float x, float sigma) {
	return exp(-(x * x) / (2.0 * sigma * sigma));
}

/* RENDERTARGETS: 3 */
layout(location = 0) out vec4 color;

void main() {
	vec3 result = vec3(0.0);
	float totalWeight = 0.0;
	float sigma = float(BLUR_RADIUS) * 0.4;
	float texel = 1.0 / viewHeight;

	for (int y = -BLUR_RADIUS; y <= BLUR_RADIUS; y++) {
		float weight = gaussianWeight(float(y), sigma);
		vec2 sampleCoord = texcoord + vec2(0.0, float(y) * texel);
		result += texture(colortex4, sampleCoord).rgb * weight;
		totalWeight += weight;
	}

	color = vec4(result / totalWeight, 1.0);
}