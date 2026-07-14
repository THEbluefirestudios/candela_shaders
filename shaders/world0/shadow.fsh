#version 330 compatibility

uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;
uniform int renderStage;

#include "/lib/settings.glsl"

in vec2 texcoord;
in vec4 glcolor;

const int shadowMapResolution = SHADOW_MAP_RESOLUTION;
const float shadowDistance = SHADOW_DISTANCE;

/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 color;

void main() {
    if(renderStage == MC_RENDER_STAGE_TERRAIN_TRANSLUCENT){
        discard;
    }

    color = texture(gtexture, texcoord) * glcolor;
    if (color.a < alphaTestRef) {
        discard;
    }
}