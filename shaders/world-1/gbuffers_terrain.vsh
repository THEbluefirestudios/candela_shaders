#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;

attribute vec4 mc_Entity;

void main() {
	vec4 position = gl_Vertex;

	if (mc_Entity.x == 10001.0) {
		float wave = sin(position.x * 0.8 + frameTimeCounter * 2.0) * 0.04
		           + sin(position.z * 0.6 + frameTimeCounter * 1.7) * 0.04;
		position.x += wave;
		position.z += wave * 0.5;
	}

	gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * position;

	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	normal = gl_NormalMatrix * gl_Normal;
	normal = mat3(gbufferModelViewInverse) * normal;
}