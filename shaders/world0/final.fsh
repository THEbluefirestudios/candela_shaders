#version 330 compatibility

#define OUTLINE_PIXEL_SIZE ivec2(1, 1)
#define OUTLINES 1

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex3;
uniform sampler2D colortex5;
uniform int isEyeInWater;
uniform vec3 shadowLightPosition;
uniform sampler2D depthtex0;
uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;
uniform int worldTime;

#include "/lib/common.glsl"
#include "/lib/outline.glsl"
#include "/lib/settings.glsl"
#include "/lib/fxaa.glsl"

in vec2 texcoord;

layout(location = 0) out vec4 color;

const vec3 underwaterTint = vec3(0.0, 0.3, 0.6);
const float underwaterTintStrength = 0.8;

vec3 myColorGrade(vec3 col) {
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(vec3(luma), col, GRADE_SATURATION);

	col = pow(col, vec3(GRADE_SHADOW_LIFT));

	vec3 blueTint = vec3(0.07, 0.0, 0.07);   // was gna make this blue... didnt hit the dreamy feel i was going for so i made it purple
	col += blueTint;						 // aint changing the var name tho

	col = col * 1.08 - 0.015;

	return clamp(col, 0.0, 1.0);
}

void main() {
	vec2 texelSize = 1.0 / vec2(viewWidth, viewHeight);

	color = vec4(applyFXAA(colortex0, texcoord, texelSize), 1.0);

	if (isEyeInWater == 1) {
		color.rgb = mix(color.rgb, underwaterTint * color.rgb, underwaterTintStrength);
	}

	vec3 bloom = texture(colortex3, texcoord).rgb;
	color.rgb += bloom * BLOOM_INTENSITY;

	float lightHeight = dot(normalize(shadowLightPosition), vec3(0.0, 1.0, 0.0));

	float t = float(worldTime) / 24000.0;
	float godrayStrength = (t < 0.5) ? 1.0 : 0.0;

	vec3 godrays = texture(colortex5, texcoord).rgb;
	vec3 godrayTint = mix(vec3(0.5, 0.6, 1.0), vec3(1.0, 0.85, 0.6), step(0.0, lightHeight));
	color.rgb += godrays * godrayTint * GODRAY_INTENSITY * godrayStrength;

	ivec2 iUv = ivec2(texcoord * vec2(viewWidth, viewHeight));
	float depthOrigin = texture(depthtex0, texcoord).r;
	float outlineAmount = getOutline(iUv, depthOrigin);
	vec3 outlineColor = color.rgb * OUTLINE_BRIGHTNESS;
	color.rgb = mix(color.rgb, outlineColor, outlineAmount * OUTLINE_STRENGTH);
	color.rgb = pow(color.rgb, vec3(1.0 / 2.2));

	color.rgb = myColorGrade(color.rgb);
}
