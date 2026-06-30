#version 330 compatibility

uniform sampler2D gtexture;

#include "/lib/settings.glsl"
// the abscence of the above line caused pain, terror, caffeine overdose, some bad poisoning and a nuclear reactor exploding, just coz i forgot it, rip my sanity (2012-2026)

in vec2 texcoord;
in vec4 glcolor;

const int shadowMapResolution = SHADOW_MAP_RESOLUTION;

const float shadowDistance = 72.0;

layout(location = 0) out vec4 color;

void main() {
    color = texture(gtexture, texcoord) * glcolor;
    if (color.a < 0.1){
        discard;
    }
}