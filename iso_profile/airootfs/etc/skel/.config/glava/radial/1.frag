/* ╔══════════════════════════════════════════════════════════════════════╗
   ║  SPIDER'S LAB — Radial Sonar Shader                               ║
   ║  Tactical ping visualization. Die Hard 4.0 meets Hackers.         ║
   ╚══════════════════════════════════════════════════════════════════════╝ */

/* Center of the sonar — bottom-right quadrant of screen */
#define C_X    0.80
#define C_Y    0.75

/* Sonar radius range */
#define INNER  0.05
#define OUTER  0.35

/* Visual tuning */
#define RING_COUNT    80
#define RING_WIDTH    2.0
#define GLOW_STRENGTH 1.8
#define ROTATION_SPEED 0.4

/* Colors — Spider-Red core, Electric Cyan outer rings */
#define COLOR_BASE  vec4(0.0, 1.0, 1.0, 0.6)
#define COLOR_PEAK  vec4(1.0, 0.0, 0.0, 0.9)
#define COLOR_GRID  vec4(0.0, 1.0, 1.0, 0.04)
#define COLOR_SWEEP vec4(0.0, 1.0, 1.0, 0.12)

/* GLava uniforms */
in vec4 gl_FragCoord;
out vec4 fragColor;

uniform int SAMPLE_SIZE;
uniform float audio_l[SAMPLE_SIZE];
uniform float audio_r[SAMPLE_SIZE];
uniform float time;

#define PI 3.14159265359

void main() {
    vec2 uv = gl_FragCoord.xy / vec2(1920.0, 1080.0);
    vec2 center = vec2(C_X, C_Y);
    vec2 delta = uv - center;

    float dist = length(delta);
    float angle = atan(delta.y, delta.x);
    float norm_angle = (angle + PI) / (2.0 * PI);

    fragColor = vec4(0.0);

    /* Outside sonar range — discard */
    if (dist < INNER || dist > OUTER) return;

    /* Grid rings — concentric circles */
    float ring_pos = (dist - INNER) / (OUTER - INNER);
    float grid_ring = fract(ring_pos * 6.0);
    if (grid_ring < 0.02 || grid_ring > 0.98) {
        fragColor += COLOR_GRID;
    }

    /* Grid spokes — 12 radial lines */
    float spoke = fract(norm_angle * 12.0);
    if (spoke < 0.005 || spoke > 0.995) {
        fragColor += COLOR_GRID;
    }

    /* Sweep line — rotating radar arm */
    float sweep_angle = fract(time * ROTATION_SPEED);
    float sweep_diff = abs(norm_angle - sweep_angle);
    sweep_diff = min(sweep_diff, 1.0 - sweep_diff);
    float sweep_fade = exp(-sweep_diff * 40.0);
    fragColor += COLOR_SWEEP * sweep_fade;

    /* Audio-reactive rings */
    int sample_idx = int(norm_angle * float(SAMPLE_SIZE));
    sample_idx = clamp(sample_idx, 0, SAMPLE_SIZE - 1);

    float amplitude = (audio_l[sample_idx] + audio_r[sample_idx]) * 0.5;
    amplitude = clamp(amplitude * GLOW_STRENGTH, 0.0, 1.0);

    float audio_radius = INNER + amplitude * (OUTER - INNER) * 0.8;

    if (dist < audio_radius) {
        float intensity = 1.0 - (dist - INNER) / (audio_radius - INNER);
        intensity = pow(intensity, 2.0);
        vec4 color = mix(COLOR_BASE, COLOR_PEAK, amplitude);
        color.a *= intensity * 0.5;
        fragColor += color;
    }

    /* Ping echo — fading ring that expands outward */
    float ping = fract(time * 0.3);
    float ping_radius = INNER + ping * (OUTER - INNER);
    float ping_diff = abs(dist - ping_radius);
    if (ping_diff < 0.004) {
        float ping_fade = 1.0 - ping;
        fragColor += vec4(0.0, 1.0, 1.0, 0.3 * ping_fade);
    }

    /* Clamp alpha */
    fragColor.a = clamp(fragColor.a, 0.0, 0.8);
}
