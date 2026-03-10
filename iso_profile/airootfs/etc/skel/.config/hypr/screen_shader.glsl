// ╔══════════════════════════════════════════════════════════════════════╗
// ║  SPIDER'S LAB — CRT Post-Processing Shader                        ║
// ║                                                                    ║
// ║  Hackers (1995) aesthetic: scanlines, chromatic aberration,        ║
// ║  vignette. Three texture lookups + simple math.                    ║
// ║  Negligible performance cost on RTX 3060.                          ║
// ╚══════════════════════════════════════════════════════════════════════╝

precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

#define PI 3.14159265359

void main() {
    vec2 uv = v_texcoord;

    // ── Distance from center (for vignette + chromatic aberration) ──
    vec2 center = uv - 0.5;
    float dist = length(center);

    // ── Chromatic Aberration ──
    // Quadratic edge-weighted RGB split: zero at center, ~1.5px at edges.
    // R shifts outward, B shifts inward, G stays put.
    float aberration = dist * dist * 0.0008;
    vec2 dir = normalize(center);

    float r = texture2D(tex, uv + dir * aberration).r;
    float g = texture2D(tex, uv).g;
    float b = texture2D(tex, uv - dir * aberration).b;

    vec3 color = vec3(r, g, b);

    // ── CRT Scanlines ──
    // 4% intensity horizontal bands at native 1080p frequency.
    // Subtle enough for daily use, visible on solid backgrounds.
    float scanline = sin(v_texcoord.y * 1080.0 * PI);
    color *= 1.0 - 0.04 * scanline * scanline;

    // ── Vignette ──
    // Darkened corners, clamped to 70% minimum brightness.
    float vignette = smoothstep(0.9, 0.4, dist);
    vignette = max(vignette, 0.7);
    color *= vignette;

    gl_FragColor = vec4(color, 1.0);
}
