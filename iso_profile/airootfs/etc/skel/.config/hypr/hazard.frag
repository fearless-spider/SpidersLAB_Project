// ╔══════════════════════════════════════════════════════════════════════╗
// ║  SPIDER'S LAB — Electrical Hazard Post-Processing Shader          ║
// ║                                                                    ║
// ║  Voltage spikes, static noise, indented corners.                  ║
// ║  The neon yellow flicker of a high-voltage warning sign.          ║
// ║  Swap with screen_shader to enter Hazard Mode.                    ║
// ║                                                                    ║
// ║  Uniform `time` (float, seconds) is provided by Hyprland ≥0.40   ║
// ║  via SHADER_TIME. If time stays 0, noise is spatial-only (safe). ║
// ╚══════════════════════════════════════════════════════════════════════╝

precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;       // seconds since compositor start (SHADER_TIME)

// ── Tuning Knobs ──
#define NOISE_INTENSITY     0.04
#define SPIKE_PROBABILITY   0.003
#define SPIKE_BRIGHTNESS    0.12
#define SPIKE_WIDTH         0.002
#define CORNER_SIZE         0.025
#define CORNER_INDENT       0.012
#define BORDER_THICKNESS    0.004
#define HAZARD_GOLD         vec3(0.686, 0.427, 0.976)
#define VIGNETTE_RADIUS     0.82
#define VIGNETTE_SOFTNESS   0.50
#define VIGNETTE_MIN        0.70

// ── Pseudo-random hash ──
float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// ── Get effective time — real or spatial fallback ──
// If time uniform is not bound (stays 0.0), derive pseudo-variation
// from UV coords so the noise is at least spatially varied.
float getTime(vec2 uv) {
    if (time > 0.001) return time;
    // Fallback: spatial pseudo-time so noise isn't frozen at a single value
    return hash(uv * 317.7) * 100.0;
}

// ── Animated hash (time-seeded) ──
float hash_t(vec2 p) {
    return hash(p + fract(time * 13.71));
}

// ── Detect if pixel is in the border zone ──
// Returns 0.0 in center, 1.0 at screen edge, smooth falloff
float borderMask(vec2 uv) {
    float dx = min(uv.x, 1.0 - uv.x);
    float dy = min(uv.y, 1.0 - uv.y);
    float d = min(dx, dy);
    return 1.0 - smoothstep(0.0, BORDER_THICKNESS * 8.0, d);
}

// ── Indented corners — darken/discard pixels at specific edge coords ──
float cornerMask(vec2 uv) {
    // Four corner zones: check diagonal distance from each corner
    vec2 corners[4];
    corners[0] = vec2(0.0, 0.0);
    corners[1] = vec2(1.0, 0.0);
    corners[2] = vec2(0.0, 1.0);
    corners[3] = vec2(1.0, 1.0);

    float mask = 1.0;
    for (int i = 0; i < 4; i++) {
        vec2 d = abs(uv - corners[i]);
        // Triangle indent: if both x and y are within CORNER_SIZE,
        // and their sum is less than CORNER_INDENT, darken
        if (d.x < CORNER_SIZE && d.y < CORNER_SIZE) {
            float indent = d.x + d.y;
            if (indent < CORNER_INDENT) {
                mask = 0.0;  // fully indented (black)
            } else if (indent < CORNER_INDENT + 0.008) {
                // Gold edge line at the indent boundary
                mask = -1.0; // signal: draw gold edge
            }
        }
    }
    return mask;
}

// ── Voltage spike — fast horizontal line that flashes bright ──
float voltageSpikeAt(vec2 uv, float t_eff) {
    // Create time-varying spike positions
    float t = floor(t_eff * 30.0); // 30 spikes per second sampling rate
    float spike_y = hash(vec2(t, 0.0));
    float spike_y2 = hash(vec2(t + 100.0, 50.0));
    float spike_y3 = hash(vec2(t + 200.0, 25.0));

    float spike = 0.0;

    // Only fire spikes probabilistically
    if (hash(vec2(t, 1.0)) < SPIKE_PROBABILITY * 30.0) {
        spike += smoothstep(SPIKE_WIDTH, 0.0, abs(uv.y - spike_y));
    }
    if (hash(vec2(t, 2.0)) < SPIKE_PROBABILITY * 15.0) {
        spike += smoothstep(SPIKE_WIDTH * 0.7, 0.0, abs(uv.y - spike_y2)) * 0.6;
    }
    if (hash(vec2(t, 3.0)) < SPIKE_PROBABILITY * 8.0) {
        spike += smoothstep(SPIKE_WIDTH * 1.5, 0.0, abs(uv.y - spike_y3)) * 0.3;
    }

    return spike;
}

void main() {
    vec2 uv = v_texcoord;

    // ── Sample base color ──
    vec3 color = texture2D(tex, uv).rgb;

    // ── Distance from center (for vignette) ──
    vec2 center = uv - 0.5;
    float dist = length(center);

    // ── Vignette — darkened edges ──
    float vignette = smoothstep(VIGNETTE_RADIUS, VIGNETTE_RADIUS - VIGNETTE_SOFTNESS, dist);
    vignette = mix(VIGNETTE_MIN, 1.0, vignette);
    color *= vignette;

    // ── Effective time (real or spatial fallback) ──
    float t_eff = getTime(uv);

    // ── Border zone mask ──
    float bm = borderMask(uv);

    // ── Static noise — concentrated on border area ──
    float noise = (hash_t(uv * 800.0) * 2.0 - 1.0) * NOISE_INTENSITY;
    // Full noise in border, 30% in interior
    float noiseWeight = mix(0.3, 1.0, bm);
    color += noise * noiseWeight;

    // ── Border glow — thin hazard gold line at screen edges ──
    float edgeDist = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
    float borderLine = smoothstep(BORDER_THICKNESS, BORDER_THICKNESS * 0.3, edgeDist);
    // Flicker the border
    float flicker = 0.7 + 0.3 * sin(t_eff * 3.0 + sin(t_eff * 7.0) * 2.0);
    color = mix(color, HAZARD_GOLD * flicker, borderLine * 0.6);

    // ── Voltage spikes — horizontal bright flashes ──
    float spike = voltageSpikeAt(uv, t_eff);
    // Spikes are gold-tinted and strongest in border zone
    float spikeWeight = mix(0.4, 1.0, bm);
    color += HAZARD_GOLD * spike * SPIKE_BRIGHTNESS * spikeWeight;

    // ── Indented corners ──
    float cm = cornerMask(uv);
    if (cm == 0.0) {
        // Fully indented — black void
        color = vec3(0.0);
    } else if (cm < 0.0) {
        // Gold edge at indent boundary
        color = HAZARD_GOLD * flicker * 0.8;
    }

    // ── Scanline overlay — subtle horizontal lines ──
    float scanline = sin(uv.y * 1200.0) * 0.5 + 0.5;
    scanline = mix(1.0, 0.96, scanline * bm * 0.5);
    color *= scanline;

    // ── Clamp & output ──
    color = clamp(color, 0.0, 1.0);
    gl_FragColor = vec4(color, 1.0);
}
