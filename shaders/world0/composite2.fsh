#version 330 compatibility

#include "/lib/shadowDistort.glsl"

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

#include "/lib/settings.glsl"

in vec2 texcoord;

const float BLOOM_THRESH = BLOOM_THRESHOLD;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

/* RENDERTARGETS: 3,5 */
layout(location = 0) out vec4 brightColor;
layout(location = 1) out vec4 godrayMask;

void main() {
	vec3 col = texture(colortex0, texcoord).rgb;
	float depth = texture(depthtex0, texcoord).r;

	if (depth >= 0.9999) {
		brightColor = vec4(0.0, 0.0, 0.0, 1.0);
		godrayMask = vec4(1.0, 1.0, 1.0, 1.0);
		return;
	}

	vec3 ndcPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);

	float dist = length(viewPos);
	float bloomDistanceFade = 1.0 - smoothstep(BLOOM_DISTANCE_FADE_START, BLOOM_DISTANCE_FADE_END, dist);

	float brightness = max(col.r, max(col.g, col.b));
	float excess = max(brightness - BLOOM_THRESH, 0.0) * bloomDistanceFade;
	brightColor = vec4(col * excess * 2.0, 1.0);

	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz);
	vec3 shadowNdcPos = shadowClipPos.xyz / shadowClipPos.w;
	vec3 shadowScreenPos = shadowNdcPos * 0.5 + 0.5;

	float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r);

	if (opaqueShadow == 0.0) {
		vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);
		godrayMask = vec4(shadowColor.rgb * (1.0 - shadowColor.a), 1.0);
	} else {
		godrayMask = vec4(0.0, 0.0, 0.0, 1.0);
	}
}