#version 330 compatibility

uniform sampler2D colortex5;
uniform vec3 shadowLightPosition;
uniform mat4 gbufferProjection;

#include "/lib/settings.glsl"

in vec2 texcoord;

const int GODRAY_SAMP = GODRAY_SAMPLES;
const float GODRAY_DEC = GODRAY_DECAY;
const float GODRAY_DENS = GODRAY_DENSITY;

/* RENDERTARGETS: 5 */
layout(location = 0) out vec4 color;

void main() {
	vec3 lightViewPos = normalize(shadowLightPosition);
	vec4 lightClipPos = gbufferProjection * vec4(lightViewPos * 100.0, 1.0);
	vec2 lightScreenPos = (lightClipPos.xy / lightClipPos.w) * 0.5 + 0.5;

	vec3 viewDir = vec3(0.0, 0.0, -1.0);
	float lightFacing = dot(lightViewPos, viewDir);
	float edgeFade = smoothstep(-0.1, 0.3, lightFacing);
	float distFromCenter = length(lightScreenPos - vec2(0.5));
	float offscreenFade = 1.0 - smoothstep(0.7, 1.2, distFromCenter);
	edgeFade *= offscreenFade;
	if (edgeFade <= 0.0) {
		color = vec4(0.0, 0.0, 0.0, 1.0);
		return;
	}

	vec2 deltaCoord = (texcoord - lightScreenPos) * GODRAY_DENS / float(GODRAY_SAMP);
	vec2 sampleCoord = texcoord;
	float illuminationDecay = 1.0;
	vec3 result = vec3(0.0);

	for (int i = 0; i < GODRAY_SAMP; i++) {
		sampleCoord -= deltaCoord;
		vec3 sampleColor = texture(colortex5, sampleCoord).rgb * illuminationDecay;
		result += sampleColor;
		illuminationDecay *= GODRAY_DEC;
	}

	color = vec4((result / float(GODRAY_SAMP)) * edgeFade, 1.0);
}