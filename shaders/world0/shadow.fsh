#version 330 compatibility

uniform sampler2D gtexture;

#include "/lib/settings.glsl" 

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