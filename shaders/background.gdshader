shader_type canvas_item;

/* -- Palette & global controls -- */
uniform vec3 color_a : source_color = vec3(0.027, 0.09, 0.16);   // deep base
uniform vec3 color_b : source_color = vec3(0.47, 0.76, 0.94);    // highlight
uniform float global_brightness : hint_range(0.0, 2.0) = 1.0;
uniform float contrast : hint_range(0.0, 4.0) = 1.0;

/* -- Blobs / shapes -- */
uniform int blob_count : hint_range(1, 12) = 5;
uniform float blob_scale : hint_range(0.4, 3.0) = 1.0;
uniform float blob_speed : hint_range(0.0, 4.0) = 0.4;
uniform float blob_softness : hint_range(0.01, 1.0) = 0.35;

/* -- Fine noise / grain -- */
uniform float noise_strength : hint_range(0.0, 1.0) = 0.12;
uniform float noise_scale : hint_range(0.5, 8.0) = 3.0;

/* -- Glow / vignette -- */
uniform float vignette : hint_range(0.0, 2.0) = 0.8;
uniform float glow : hint_range(0.0, 3.0) = 1.1;

/* built-in time */
float t() { return TIME * blob_speed; }

/* 2D hash / noise helpers */
float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    // four corners
    float a = hash21(i + vec2(0.0,0.0));
    float b = hash21(i + vec2(1.0,0.0));
    float c = hash21(i + vec2(0.0,1.0));
    float d = hash21(i + vec2(1.0,1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
    float v = 0.0;
    float amp = 0.5;
    mat2 m = mat2(vec2(1.6, 1.2), vec2(-1.2, 1.6));
    for (int i = 0; i < 5; i++) {
        v += amp * noise(p);
        p = m * p * 1.9;
        amp *= 0.5;
    }
    return v;
}

/* Smooth circle (soft-edged blob) */
float soft_circle(vec2 uv, vec2 center, float radius, float softness) {
    float d = length(uv - center);
    return smoothstep(radius + softness, radius - softness, d);
}

void fragment() {
    vec2 uv = SCREEN_UV; // normalized 0..1 across the viewport
    // center origin
    vec2 p = uv - 0.5;
    p.x *= (1.0 / SCREEN_PIXEL_SIZE.x) / (1.0 / SCREEN_PIXEL_SIZE.y); // preserve aspect ratio

    // accumulate blobs
    float accum = 0.0;
    for (int i = 0; i < blob_count; i++) {
        float fi = float(i);
        // seed positions that drift differently
        vec2 seed = vec2(hash21(vec2(fi, fi*7.7)), hash21(vec2(fi*3.1, fi*5.2)));
        // make them move in nice orbits
        vec2 pos = vec2(
            0.35 * cos(t()*0.4 + fi*1.9 + seed.x*6.28),
            0.25 * sin(t()*0.6 + fi*2.3 + seed.y*6.28)
        ) * blob_scale;
        // size varies by index/seed
        float radius = mix(0.15, 0.35, hash21(vec2(fi*2.1, fi*9.3))) * (1.0 / blob_scale);
        // combine with soft circle
        float c = soft_circle(p, pos, radius, blob_softness);
        // weight by gentle per-blob factor & a small flicker
        float weight = 0.7 + 0.3 * sin(TIME * (0.5 + fi*0.13) + fi);
        accum += c * weight;
    }

    // background base gradient
    float gradient = uv.y; // top->bottom
    vec3 base = mix(color_a, color_b, pow(gradient, 1.2));

    // add accum as light source + color mixing
    vec3 blob_color = mix(color_a, color_b * 1.1, clamp(accum, 0.0, 1.0));
    vec3 col = mix(base, blob_color, smoothstep(0.0, 1.0, accum) * glow);

    // add FBM texture for organic motion
    float n = fbm((p + vec2(TIME*0.03, TIME*0.02)) * noise_scale);
    col += (n - 0.5) * noise_strength;

    // vignette
    float dist = length(p);
    float vig = smoothstep(0.7 + vignette*0.1, 0.95, dist);
    col *= (1.0 - vig);

    // contrast & brightness
    col = pow(col * global_brightness, vec3(1.0 / max(0.0001, 1.0 - contrast * 0.25)));

    COLOR = vec4(col, 1.0);
}