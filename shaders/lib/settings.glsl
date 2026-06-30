#define SHADOW_MAP_RESOLUTION 1024 // Shadow map resolution. Higher is sharper but more expensive. [512 1024 1536 2048 4096]
#define PCF_RADIUS 1 // Shadow edge softness sample radius. [0 1 2 3]
#define PCF_SPREAD 0.75 // Shadow edge softness spread distance. [0.25 0.5 0.75 1.0 1.5 2.0]
#define COLORED_SHADOW_SATURATION 1.8 // Vividness of colored/translucent shadows. [1.0 1.2 1.4 1.6 1.8 2.0 2.5 3.0]

#define BLOOM_THRESHOLD 0.9 // Brightness needed before bloom kicks in. [0.5 0.6 0.7 0.8 0.9 1.0]
#define BLOOM_INTENSITY 0.6 // Overall bloom strength. [0.0 0.2 0.4 0.6 1.0 1.5 2.0 3.0]
#define BLOOM_BLUR_RADIUS_X 8 // Horizontal bloom spread. Raise for a smear effect. [2 4 8 12 16 24]
#define BLOOM_BLUR_RADIUS_Y 8 // Vertical bloom spread. Raise for a smear effect. [2 4 8 12 16 24]
#define BLOOM_DISTANCE_FADE_START 64.0 // Distance bloom starts fading out. [32.0 64.0 96.0 128.0]
#define BLOOM_DISTANCE_FADE_END 128.0 // Distance bloom is fully faded out. [96.0 128.0 192.0 256.0]

#define GODRAY_INTENSITY 0.3 // God ray brightness. [0.0 0.1 0.2 0.3 0.4 0.5]
#define GODRAY_SAMPLES 24 // God ray sample count. Higher is smoother but slower. [12 16 24 32]
#define GODRAY_DECAY 0.93 // How quickly god rays fade along their length. [0.85 0.9 0.93 0.95 0.96 0.98]
#define GODRAY_DENSITY 0.4 // God ray spread density. [0.2 0.3 0.4 0.5 0.7 1.0]

#define OUTLINE_STRENGTH 0.5 // Outline blend opacity. [0.0 0.2 0.4 0.5 0.6 0.8 1.0]
#define OUTLINE_BRIGHTNESS 3.5 // Outline color brightness. [1.0 2.0 3.0 3.5 4.0 5.0]
#define OUTLINE_BASE_THICKNESS 1 // Outline base thickness in pixels. [1 2 3 4]

#define EXPOSURE_SUNRISE 0.7 // Scene brightness at sunrise. [0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define EXPOSURE_NOON 1.3 // Scene brightness at noon. [0.8 1.0 1.1 1.2 1.3 1.5 1.8]
#define EXPOSURE_SUNSET 0.7 // Scene brightness at sunset. [0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define EXPOSURE_MIDNIGHT 0.18 // Scene brightness at midnight. [0.05 0.1 0.15 0.18 0.25 0.35]

#define GRADE_SATURATION 1.15 // Final image color saturation. [0.8 0.9 1.0 1.1 1.15 1.3 1.5]
#define GRADE_SHADOW_LIFT 0.92 // Lifts shadow detail, lower is softer. [0.8 0.85 0.9 0.92 0.95 1.0]
#define GRADE_CONTRAST 1.08 // Final image contrast. [0.9 1.0 1.05 1.08 1.15 1.2]

#define FOLIAGE_WAVE_STRENGTH 0.015 // Leaf and grass sway strength. [0.0 0.008 0.015 0.025 0.04]
#define WATER_WAVE_STRENGTH 0.05 // Water surface wave strength. [0.0 0.025 0.05 0.08 0.12]