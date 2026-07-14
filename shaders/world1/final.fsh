#version 330 compatibility

#define OUTLINE_PIXEL_SIZE ivec2(1, 1)
#define OUTLINES 1

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex3;
uniform int isEyeInWater;
uniform sampler2D depthtex0;
uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;

#include "/lib/common.glsl"
#include "/lib/outline.glsl"
#include "/lib/settings.glsl"
#include "/lib/fxaa.glsl"

in vec2 texcoord;

layout(location = 0) out vec4 color;

const vec3 underwaterTint = vec3(0.0, 0.3, 0.6);
const float underwaterTintStrength = 0.8;

void main() {
	vec2 texelSize = 1.0 / vec2(viewWidth, viewHeight);

	color = vec4(applyFXAA(colortex0, texcoord, texelSize), 1.0);

	if (isEyeInWater == 1) {
		color.rgb = mix(color.rgb, underwaterTint * color.rgb, underwaterTintStrength);
	}

	vec3 bloom = texture(colortex3, texcoord).rgb;
	color.rgb += bloom * BLOOM_INTENSITY;

	ivec2 iUv = ivec2(texcoord * vec2(viewWidth, viewHeight));
	float depthOrigin = texture(depthtex0, texcoord).r;
	float outlineAmount = getOutline(iUv, depthOrigin);
	vec3 outlineColor = color.rgb * OUTLINE_BRIGHTNESS;
	color.rgb = mix(color.rgb, outlineColor, outlineAmount * OUTLINE_STRENGTH);

	color.rgb = pow(color.rgb, vec3(1.0 / 2.2));
}