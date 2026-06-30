// this is slightly edited version of the outline.glsl lib in my favourite shader: super duper vannilla, i just added some depth scaling for the outlines, otherwise, credits to them!

float getOutline(in ivec2 iUv, in float depthOrigin){
    float linearDepthOrigin = near / (1.0 - depthOrigin);
    float depthScale = clamp(1.0 - linearDepthOrigin * 0.002, 0.2, 1.0);
    ivec2 scaledOffset = max(ivec2(vec2(OUTLINE_PIXEL_SIZE) * depthScale), ivec2(1, 1));
    ivec2 topRightCorner = iUv - scaledOffset;
    ivec2 bottomLeftCorner = iUv + scaledOffset;

    #if OUTLINES == 1
        float depth0 = near / (1.0 - texelFetch(depthtex0, topRightCorner, 0).x);
        float depth1 = near / (1.0 - texelFetch(depthtex0, bottomLeftCorner, 0).x);
        float depth2 = near / (1.0 - texelFetch(depthtex0, ivec2(topRightCorner.x, bottomLeftCorner.y), 0).x);
        float depth3 = near / (1.0 - texelFetch(depthtex0, ivec2(bottomLeftCorner.x, topRightCorner.y), 0).x);

        float sumDepth = depth0 + depth1 + depth2 + depth3;

        return saturate(sumDepth - (near * 4.0) / (1.0 - depthOrigin));
    #else
        float depth0 = 64.0 / (1.0 - texelFetch(depthtex0, topRightCorner, 0).x);
        float depth1 = 64.0 / (1.0 - texelFetch(depthtex0, bottomLeftCorner, 0).x);
        float depth2 = 64.0 / (1.0 - texelFetch(depthtex0, ivec2(topRightCorner.x, bottomLeftCorner.y), 0).x);
        float depth3 = 64.0 / (1.0 - texelFetch(depthtex0, ivec2(bottomLeftCorner.x, topRightCorner.y), 0).x);

        float sumDepth = depth0 + depth1 + depth2 + depth3;

        return saturate((1.0 - depthOrigin) * sumDepth - 256.0);
    #endif
}