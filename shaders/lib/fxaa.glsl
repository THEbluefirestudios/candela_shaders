#if ANTIALIASING == 1

#define EDGE_THRESHOLD_MIN 0.01
#define EDGE_THRESHOLD_MAX 1.1
#define FXAA_ITERATIONS 12u
#define SUBPIXEL_QUALITY 0.75

const float fxaaQuality[12] = float[12](1.0, 1.0, 1.0, 1.0, 1.0, 1.5, 2.0, 2.0, 2.0, 2.0, 4.0, 8.0);

vec3 textureFXAA(in sampler2D tex, in vec2 uv, in vec2 texelSize){
    vec3 colorCenter = texture(tex, uv).rgb;
    float lumaCenter = sumOf(colorCenter);

    float lumaTop = sumOf(texture(tex, uv + vec2(0.0, texelSize.y)).rgb);
    float lumaBottom = sumOf(texture(tex, uv - vec2(0.0, texelSize.y)).rgb);
    float lumaLeft = sumOf(texture(tex, uv - vec2(texelSize.x, 0.0)).rgb);
    float lumaRight = sumOf(texture(tex, uv + vec2(texelSize.x, 0.0)).rgb);

    float lumaMin = min(lumaCenter, min(min(lumaBottom, lumaTop), min(lumaLeft, lumaRight)));
    float lumaMax = max(lumaCenter, max(max(lumaBottom, lumaTop), max(lumaLeft, lumaRight)));
    float lumaRange = lumaMax - lumaMin;

    const float edgeThresholdMin = EDGE_THRESHOLD_MIN * 3.0;
    if(lumaRange < max(edgeThresholdMin, lumaMax * EDGE_THRESHOLD_MAX)) return colorCenter;

    float lumaTopRight = sumOf(texture(tex, uv + vec2(texelSize.x, texelSize.y)).rgb);
    float lumaBottomLeft = sumOf(texture(tex, uv - vec2(texelSize.x, texelSize.y)).rgb);
    float lumaTopLeft = sumOf(texture(tex, uv + vec2(-texelSize.x, texelSize.y)).rgb);
    float lumaBottomRight = sumOf(texture(tex, uv + vec2(texelSize.x, -texelSize.y)).rgb);

    float lumaBottomTop = lumaBottom + lumaTop;
    float lumaLeftRight = lumaLeft + lumaRight;

    float lumaLeftCorners = lumaBottomLeft + lumaTopLeft;
    float lumaBottomCorners = lumaBottomLeft + lumaBottomRight;
    float lumaRightCorners = lumaBottomRight + lumaTopRight;
    float lumaTopCorners = lumaTopRight + lumaTopLeft;

    float edgeHorizontal = abs(lumaLeftCorners - 2.0 * lumaLeft) + abs(lumaBottomTop - 2.0 * lumaCenter) * 2.0 + abs(lumaRightCorners - 2.0 * lumaRight);
    float edgeVertical = abs(lumaTopCorners - 2.0 * lumaTop) + abs(lumaLeftRight - 2.0 * lumaCenter) * 2.0 + abs(lumaBottomCorners - 2.0 * lumaBottom);

    bool isHorizontal = edgeHorizontal >= edgeVertical;

    float luma1 = isHorizontal ? lumaBottom : lumaLeft;
    float luma2 = isHorizontal ? lumaTop : lumaRight;
    float gradient1 = luma1 - lumaCenter;
    float gradient2 = luma2 - lumaCenter;
    bool isSteepest = abs(gradient1) >= abs(gradient2);
    float gradientScaled = 0.25 * max(abs(gradient1), abs(gradient2));

    float stepLength = isHorizontal ? texelSize.y : texelSize.x;
    float lumaLocalAverage = lumaCenter;

    if(isSteepest){
        stepLength = -stepLength;
        lumaLocalAverage += luma1;
    } else {
        lumaLocalAverage += luma2;
    }
    lumaLocalAverage *= 0.5;

    float halfStepLength = stepLength * 0.5;
    vec2 currentUv = uv;
    if(isHorizontal) currentUv.y += halfStepLength;
    else currentUv.x += halfStepLength;

    vec2 offset = isHorizontal ? vec2(texelSize.x, 0.0) : vec2(0.0, texelSize.y);

    vec2 uv1 = currentUv - offset;
    vec2 uv2 = currentUv + offset;

    float lumaEnd1 = sumOf(texture(tex, uv1).rgb) - lumaLocalAverage;
    float lumaEnd2 = sumOf(texture(tex, uv2).rgb) - lumaLocalAverage;

    bool reached1 = abs(lumaEnd1) >= gradientScaled;
    bool reached2 = abs(lumaEnd2) >= gradientScaled;
    bool reachedBoth = reached1 && reached2;

    if(!reached1) uv1 -= offset;
    if(!reached2) uv2 += offset;

    if(!reachedBoth){
        for(uint i = 2u; i < FXAA_ITERATIONS; i++){
            if(!reached1) lumaEnd1 = sumOf(texture(tex, uv1).rgb) - lumaLocalAverage;
            if(!reached2) lumaEnd2 = sumOf(texture(tex, uv2).rgb) - lumaLocalAverage;

            reached1 = abs(lumaEnd1) >= gradientScaled;
            reached2 = abs(lumaEnd2) >= gradientScaled;
            reachedBoth = reached1 && reached2;

            if(!reached1) uv1 -= offset * fxaaQuality[i];
            if(!reached2) uv2 += offset * fxaaQuality[i];

            if(reachedBoth) break;
        }
    }

    float distance1 = isHorizontal ? (uv.x - uv1.x) : (uv.y - uv1.y);
    float distance2 = isHorizontal ? (uv2.x - uv.x) : (uv2.y - uv.y);

    bool isDirection1 = distance1 < distance2;
    float distanceFinal = min(distance1, distance2);
    float edgeThickness = distance1 + distance2;
    float pixelOffset = 0.5 - distanceFinal / edgeThickness;

    bool isLumaCenterSmaller = lumaCenter < lumaLocalAverage;
    bool correctVariation = (isDirection1 ? lumaEnd1 : lumaEnd2) < 0 != isLumaCenterSmaller;

    float lumaAverage = (2.0 * (lumaBottomTop + lumaLeftRight) + lumaLeftCorners + lumaRightCorners) * 0.08333333;
    float subPixelOffset = smoothen(saturate(abs(lumaAverage - lumaCenter) / lumaRange));
    float subPixelOffsetFinal = squared(subPixelOffset) * SUBPIXEL_QUALITY;

    float finalOffset = correctVariation ? max(pixelOffset, subPixelOffsetFinal) : subPixelOffsetFinal;
    finalOffset *= stepLength;

    vec2 finalUv = uv;
    if(isHorizontal) finalUv.y += finalOffset;
    else finalUv.x += finalOffset;

    return texture(tex, finalUv).rgb;
}

#endif

vec3 applyFXAA(in sampler2D tex, in vec2 uv, in vec2 texelSize){
    #if ANTIALIASING == 1
        return textureFXAA(tex, uv, texelSize);
    #else
        return texture(tex, uv).rgb;
    #endif
}
