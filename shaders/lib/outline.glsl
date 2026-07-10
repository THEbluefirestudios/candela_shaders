// ok, to avoid legal schemeckadoo (add that word to your dictionaries FAST), im rewrote outlines, by myself ;)

float getOutline(in ivec2 iUv, in float depthOrigin) 
{
    float isCloud = texelFetch(colortex1, iUv, 0).z; // clouds looked weird with outlines (strange lines on faraway clouds, so disabling it here)
    if(isCloud > 0.5) return 0.0;

    float linearDepth = near / (1.0 - depthOrigin);
    float scaleFactor = clamp(1.0 - linearDepth * 0.002, 0.2, 1.0);

    ivec2 offset = max(ivec2(vec2(OUTLINE_PIXEL_SIZE) * scaleFactor), ivec2(1, 1));

    #if OUTLINES == 1
        float sampleNW = near / (1.0 - texelFetch(depthtex0, iUv + ivec2(-offset.x,  offset.y), 0).x);
        float sampleSE = near / (1.0 - texelFetch(depthtex0, iUv + ivec2( offset.x, -offset.y), 0).x);
        float sampleSW = near / (1.0 - texelFetch(depthtex0, iUv + ivec2(-offset.x, -offset.y), 0).x);
        float sampleNE = near / (1.0 - texelFetch(depthtex0, iUv + ivec2( offset.x,  offset.y), 0).x);

        float totalDepthDifference = (sampleNW + sampleSE + sampleSW + sampleNE) - (4.0 * linearDepth);
        return saturate(totalDepthDifference);
    #else
        float sampleNW = 64.0 / (1.0 - texelFetch(depthtex0, iUv + ivec2(-offset.x,  offset.y), 0).x);
        float sampleSE = 64.0 / (1.0 - texelFetch(depthtex0, iUv + ivec2( offset.x, -offset.y), 0).x);
        float sampleSW = 64.0 / (1.0 - texelFetch(depthtex0, iUv + ivec2(-offset.x, -offset.y), 0).x);
        float sampleNE = 64.0 / (1.0 - texelFetch(depthtex0, iUv + ivec2( offset.x,  offset.y), 0).x);

        float combinedSamples = sampleNW + sampleSE + sampleSW + sampleNE;
        return saturate((1.0 - depthOrigin) * combinedSamples - 256.0);
    #endif
}
