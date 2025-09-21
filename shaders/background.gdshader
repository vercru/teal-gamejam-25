shader_type canvas_item;

/* Palette & global controls */
uniform vec3 color_a : source_color = vec3(0.027, 0.09, 0.16);
uniform vec3 color_b : source_color = vec3(0.47, 0.76, 0.94);
uniform float global_brightness : hint_range(0.0, 2.0) = 1.0;
uniform float contrast : hint_range(0.0, 4.0) = 1.0;

/* Blobs */
uniform int blob_count : hint_range(1, 8) = 5; // capped for mobile
uniform float blob_scale : hint_range(0.4, 3.0) = 1.0;
uniform float blob_speed : hint_range(0.0, 4.0) = 0.4;
uniform float blob_softness : hint_range(0.01, 1.0) = 0.35;

/* Noise / grain */
uniform float noise_strength : hint_range(0.0, 1.0) = 0.1;
uniform float noise_scale : hint_range(0.5, 8.0) = 2.0;

/* Glow */
uniform float glow : hint_range(0.0, 3.0) = 1.0;

float t() { return TIME * blob_speed; }

/* Hash (cheap version for mobile) */
float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898,78.233))) * 43758.5453);
}

/* Simple noise (2D value noise, 2 samples instead of 4) */
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

/* FBM with fewer octaves (lighter) */
float fbm(vec2 p) {
    float v = 0.0;
    float amp = 0.5;
    for (int i = 0; i < 3; i++) { // 3 octaves only
        v += amp * noise(p);
        p *= 1.7;
        amp *= 0.5;
    }
    return v;
}

/* Smooth blob */
float soft_circle(vec2 uv, vec2 center, float radius, float softness) {
    float d = length(uv - center);
    return smoothstep(radius + softness, radius - softness, d);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 p = uv - 0.5;
    p.x *= (1.0 / SCREEN_PIXEL_SIZE.x) / (1.0 / SCREEN_PIXEL_SIZE.y);

    float accum = 0.0;

    // fixed max loop for WebGL
    const int MAX_BLOBS = 8;
    for (int i = 0; i < MAX_BLOBS; i++) {
        if (i >= blob_count) break;

        float fi = float(i);
        vec2 seed = vec2(hash21(vec2(fi, fi*7.7)), hash21(vec2(fi*3.1, fi*5.2)));

        vec2 pos = vec2(
            0.35 * cos(t()*0.4 + fi*1.9 + seed.x*6.28),
            0.25 * sin(t()*0.6 + fi*2.3 + seed.y*6.28)
        ) * blob_scale;

        float radius = mix(0.15, 0.35, hash21(vec2(fi*2.1, fi*9.3))) * (1.0 / blob_scale);
        float c = soft_circle(p, pos, radius, blob_softness);
        float weight = 0.7 + 0.3 * sin(TIME * (0.5 + fi*0.13) + fi);
        accum += c * weight;
    }

    float gradient = uv.y;
    vec3 base = mix(color_a, color_b, pow(gradient, 1.2));

    vec3 blob_color = mix(color_a, color_b * 1.1, clamp(accum, 0.0, 1.0));
    vec3 col = mix(base, blob_color, smoothstep(0.0, 1.0, accum) * glow);

    float n = fbm((p + vec2(TIME*0.03, TIME*0.02)) * noise_scale);
    col += (n - 0.5) * noise_strength;

    col = pow(col * global_brightness, vec3(1.0 / max(0.0001, 1.0 - contrast * 0.25)));

    COLOR = vec4(col, 1.0);
}