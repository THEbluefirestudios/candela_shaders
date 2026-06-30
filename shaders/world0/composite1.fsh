#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform float far;
uniform int worldTime;

in vec2 texcoord;

const float FOG_DENSITY = 7.0;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
    vec4 homPos = projectionMatrix * vec4(position, 1.0);
    return homPos.xyz / homPos.w;
}

float getTimeOfDayExposure(){
	float t = float(worldTime) / 24000.0;

	float expSunrise = 0.7;
	float expNoon = 1.3;
	float expSunset = 0.7;
	float expMidnight = 0.08;

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

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    color = texture(colortex0, texcoord);

    float depth = texture(depthtex0, texcoord).r;
    if (depth == 1.0){
        return;
    }

    vec3 ndcPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
    vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);

    float dist = length(viewPos) / far;
    float fogFactor = exp(-FOG_DENSITY * (1.0 - dist));

    float exposure = getTimeOfDayExposure();
    vec3 adjustedFogColor = pow(fogColor, vec3(2.2)) * exposure;

    color.rgb = mix(color.rgb, adjustedFogColor, clamp(fogFactor, 0.0, 1.0));
}