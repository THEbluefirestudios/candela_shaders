#version 330 compatibility

#include "/lib/shadowDistort.glsl"
#include "/lib/colorUtil.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;

uniform float viewWidth;
uniform float viewHeight;
uniform int worldTime;

#include "/lib/settings.glsl"

/*
const int colortex0Format = RGB16;
*/

const int shadowMapResolution = SHADOW_MAP_RESOLUTION;

uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

const vec3 sunlightColorSunrise  = vec3(1.0, 0.65, 0.25);
const vec3 sunlightColorNoon     = vec3(1.0, 0.97, 0.93);
const vec3 sunlightColorSunset   = vec3(1.0, 0.55, 0.2);
const vec3 sunlightColorMidnight = vec3(0.12, 0.16, 0.4);

const vec3 ambientColorSunrise  = vec3(0.02, 0.018, 0.018);
const vec3 ambientColorNoon     = vec3(0.025);
const vec3 ambientColorSunset   = vec3(0.022, 0.016, 0.02);
const vec3 ambientColorMidnight = vec3(0.02, 0.022, 0.035);

const vec3 skylightColorSunrise  = vec3(0.18, 0.12, 0.15);
const vec3 skylightColorNoon     = vec3(0.1, 0.25, 0.45);
const vec3 skylightColorSunset   = vec3(0.2, 0.1, 0.18);
const vec3 skylightColorMidnight = vec3(0.015, 0.03, 0.08);

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

void getTimeOfDayColors(out vec3 sunCol, out vec3 ambCol, out vec3 skyCol){
	float t = float(worldTime) / 24000.0;

	vec3 sunA, sunB, ambA, ambB, skyA, skyB;
	float blend;

	if (t < 0.25){
		sunA = sunlightColorSunrise; sunB = sunlightColorNoon;
		ambA = ambientColorSunrise; ambB = ambientColorNoon;
		skyA = skylightColorSunrise; skyB = skylightColorNoon;
		blend = t / 0.25;
	} else if (t < 0.5){
		sunA = sunlightColorNoon; sunB = sunlightColorSunset;
		ambA = ambientColorNoon; ambB = ambientColorSunset;
		skyA = skylightColorNoon; skyB = skylightColorSunset;
		blend = (t - 0.25) / 0.25;
	} else if (t < 0.75){
		sunA = sunlightColorSunset; sunB = sunlightColorMidnight;
		ambA = ambientColorSunset; ambB = ambientColorMidnight;
		skyA = skylightColorSunset; skyB = skylightColorMidnight;
		blend = (t - 0.5) / 0.25;
	} else {
		sunA = sunlightColorMidnight; sunB = sunlightColorSunrise;
		ambA = ambientColorMidnight; ambB = ambientColorSunrise;
		skyA = skylightColorMidnight; skyB = skylightColorSunrise;
		blend = (t - 0.75) / 0.25;
	}

	sunCol = mix(sunA, sunB, blend);
	ambCol = mix(ambA, ambB, blend);
	skyCol = mix(skyA, skyB, blend);
}

float getTimeOfDayExposure(){
	float t = float(worldTime) / 24000.0;

	float expSunrise = EXPOSURE_SUNRISE;
	float expNoon = EXPOSURE_NOON;
	float expSunset = EXPOSURE_SUNSET;
	float expMidnight = EXPOSURE_MIDNIGHT;

	float a, b, blend;

	if (t < 0.25){
		a = expSunrise; b = expNoon;
		blend = t / 0.25;
	} else if (t < 0.5){
		a = expNoon; b = expSunset;
		blend = (t - 0.25) / 0.25;
	} else if (t < 0.75){
		a = expSunset; b = expMidnight;
		blend = (t - 0.5) / 0.25;
	} else {
		a = expMidnight; b = expSunrise;
		blend = (t - 0.75) / 0.25;
	}

	return mix(a, b, blend);
}

vec3 getShadow(vec3 shadowScreenPos){
	const float COLORED_SHADOW_SATURATIN = COLORED_SHADOW_SATURATION;//ITS NOT A TYPO...
	const int PCF_RAD = PCF_RADIUS;
	const float PCF_SPR = PCF_SPREAD;

	vec2 texelSize = PCF_SPR / vec2(shadowMapResolution);

	vec3 result = vec3(0.0);
	float sampleCount = 0.0;

	for (int x = -PCF_RAD; x <= PCF_RAD; x++){
		for (int y = -PCF_RAD; y <= PCF_RAD; y++){
			vec2 offset = vec2(x, y) * texelSize;
			vec2 sampleCoord = shadowScreenPos.xy + offset;

			float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, sampleCoord).r);

			if (transparentShadow == 1.0){
				result += vec3(1.0);
				sampleCount += 1.0;
				continue;
			}

			float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, sampleCoord).r);

			if (opaqueShadow == 0.0){
				result += vec3(0.0);
				sampleCount += 1.0;
				continue;
			}

			vec4 shadowColor = texture(shadowcolor0, sampleCoord);
			vec3 tintedShadow = shadowColor.rgb * (1.0 - shadowColor.a);
			tintedShadow = mix(vec3(dot(tintedShadow, vec3(0.299, 0.587, 0.114))), tintedShadow, COLORED_SHADOW_SATURATIN);

			result += tintedShadow;
			sampleCount += 1.0;
		}
	}

	return result / sampleCount;
}

vec3 findNearbySourceColor(vec2 centerTexcoord){
	const int SOURCE_SEARCH_RADIUS = 1;

	vec3 brightestColor = vec3(0.0);
	float maxBrightness = 0.0;

	for (int x = -SOURCE_SEARCH_RADIUS; x <= SOURCE_SEARCH_RADIUS; x++){
		for (int y = -SOURCE_SEARCH_RADIUS; y <= SOURCE_SEARCH_RADIUS; y++){
			vec2 offset = vec2(x, y) / vec2(viewWidth, viewHeight);
			vec3 sampleColor = pow(texture(colortex0, centerTexcoord + offset).rgb, vec3(2.2));
			float brightness = max(sampleColor.r, max(sampleColor.g, sampleColor.b));

			if (brightness > maxBrightness){
				maxBrightness = brightness;
				brightestColor = sampleColor;
			}
		}
	}

	return brightestColor;
}

void main() {
	vec2 lightmap = texture(colortex1, texcoord).xy;
	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);
	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	color = texture(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));

	float depth = texture(depthtex0, texcoord).r;
	if (depth == 1.0)
	{
		return;
	}

	vec3 ndcPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	shadowClipPos.z -= 0.001;
	shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz);
	vec3 shadowNdcPos = shadowClipPos.xyz / shadowClipPos.w;
	vec3 shadowScreenPos = shadowNdcPos * 0.5 + 0.5;

	vec3 shadow = getShadow(shadowScreenPos);

	vec3 sunlightColor, ambientColor, skylightColor;
	getTimeOfDayColors(sunlightColor, ambientColor, skylightColor);
	float exposure = getTimeOfDayExposure();

	vec3 nearbySourceColor = findNearbySourceColor(texcoord);
	vec3 baseBlocklightColor = vec3(1.0, 0.5, 0.08);
	vec3 normalizedSourceColor = normalize(nearbySourceColor + 0.001) * length(baseBlocklightColor);
	float sourceColorInfluence = smoothstep(0.2, 0.6, lightmap.x);
	vec3 fakedSourceColor = mix(baseBlocklightColor, normalizedSourceColor, sourceColorInfluence);
	vec3 blocklight = pow(lightmap.x, 2.0) * fakedSourceColor;

	vec3 skylight = lightmap.y * skylightColor;
	vec3 ambient = ambientColor;
	vec3 sunlight = sunlightColor * clamp(dot(worldLightVector, normal), 0.0, 1.0) * shadow;

	vec3 totalLight = (skylight + ambient + sunlight) * exposure + blocklight;
	color.rgb *= totalLight;
}