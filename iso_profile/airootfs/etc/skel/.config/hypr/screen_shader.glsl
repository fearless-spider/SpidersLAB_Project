// ╔══════════════════════════════════════════════════════════════════════╗
// ║  SPIDER'S LAB — Neural Optic Post-Processing Shader               ║
// ║                                                                    ║
// ║  Night City aesthetic: chromatic aberration, vignette, and         ║
// ║  fine digital film grain. No CRT scanlines — this is 2077.        ║
// ║  Negligible performance cost on RTX 3060.                          ║
// ╚══════════════════════════════════════════════════════════════════════╝

precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

// ── Tuning Knobs ──
#define ABERRATION_STRENGTH 0.0006
#define VIGNETTE_RADIUS     0.85
#define VIGNETTE_SOFTNESS   0.45
#define VIGNETTE_MIN        0.75
#define GRAIN_INTENSITY     0.025

// ── Pseudo-random hash (digital noise) ──
float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void main() {
    vec2 uv = v_texcoord;

    // ── Distance from center ──
    vec2 center = uv - 0.5;
    float dist = length(center);

    // ── Chromatic Aberration ──
    // Quadratic edge-weighted RGB split: zero at center, subtle at edges.
    // R shifts outward, B shifts inward — cyberpunk lens distortion.
    float aberration = dist * dist * ABERRATION_STRENGTH;
    vec2 dir = normalize(center + 0.0001);

    float r = texture2D(tex, uv + dir * aberration).r;
    float g = texture2D(tex, uv).g;
    float b = texture2D(tex, uv - dir * aberration).b;

    vec3 color = vec3(r, g, b);

    // ── Vignette ──
    // Smooth darkened edges — like looking through augmented optics.
    float vignette = smoothstep(VIGNETTE_RADIUS, VIGNETTE_RADIUS - VIGNETTE_SOFTNESS, dist);
    vignette = mix(VIGNETTE_MIN, 1.0, vignette);
    color *= vignette;

    // ── Digital Film Grain ──
    // Ultra-fine static noise — neural optic feed texture.
    // Uses UV-based seed for spatial variation.
    float grain = hash(uv * 1000.0 + fract(uv.x * 7.13 + uv.y * 17.71) * 100.0) * 2.0 - 1.0;
    color += grain * GRAIN_INTENSITY;

    // ── Clamp & Output ──
    color = clamp(color, 0.0, 1.0);
    gl_FragColor = vec4(color, 1.0);
}
