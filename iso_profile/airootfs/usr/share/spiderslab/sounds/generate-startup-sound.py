#!/usr/bin/env python3
"""
Spider's LAB — Startup Sound Generator
Generates a cyberpunk boot chime: three ascending tones with reverb tail.
Output: startup.wav (16-bit PCM, 44100Hz, mono)
"""

import struct
import math
import os

SAMPLE_RATE = 44100
OUTPUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "startup.wav")


def generate_tone(freq, duration, volume=0.3, fade_out=True):
    """Generate a sine wave tone with optional fade-out."""
    samples = []
    num_samples = int(SAMPLE_RATE * duration)
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Base sine wave
        val = math.sin(2 * math.pi * freq * t)
        # Add slight harmonics for electronic feel
        val += 0.15 * math.sin(2 * math.pi * freq * 2 * t)
        val += 0.08 * math.sin(2 * math.pi * freq * 3 * t)
        # Apply volume
        val *= volume
        # Fade out
        if fade_out:
            fade_start = 0.6
            progress = i / num_samples
            if progress > fade_start:
                val *= 1.0 - ((progress - fade_start) / (1.0 - fade_start))
        # Fade in (click prevention)
        if i < 200:
            val *= i / 200.0
        # Clamp
        val = max(-1.0, min(1.0, val))
        samples.append(int(val * 32767))
    return samples


def write_wav(filename, samples):
    """Write samples to a WAV file."""
    num_samples = len(samples)
    data_size = num_samples * 2  # 16-bit = 2 bytes per sample
    with open(filename, 'wb') as f:
        # RIFF header
        f.write(b'RIFF')
        f.write(struct.pack('<I', 36 + data_size))
        f.write(b'WAVE')
        # fmt chunk
        f.write(b'fmt ')
        f.write(struct.pack('<I', 16))       # chunk size
        f.write(struct.pack('<H', 1))        # PCM
        f.write(struct.pack('<H', 1))        # mono
        f.write(struct.pack('<I', SAMPLE_RATE))
        f.write(struct.pack('<I', SAMPLE_RATE * 2))  # byte rate
        f.write(struct.pack('<H', 2))        # block align
        f.write(struct.pack('<H', 16))       # bits per sample
        # data chunk
        f.write(b'data')
        f.write(struct.pack('<I', data_size))
        for s in samples:
            f.write(struct.pack('<h', s))


# Three ascending tones: E4 → A4 → E5 (cyberpunk power-up)
tones = [
    (329.63, 0.18, 0.25),   # E4 — low
    (440.00, 0.18, 0.30),   # A4 — mid
    (659.25, 0.40, 0.35),   # E5 — high (longer, louder)
]

all_samples = []
gap = [0] * int(SAMPLE_RATE * 0.06)  # 60ms gap between tones

for i, (freq, dur, vol) in enumerate(tones):
    all_samples.extend(generate_tone(freq, dur, vol))
    if i < len(tones) - 1:
        all_samples.extend(gap)

# Reverb tail — quiet echo of final tone
all_samples.extend([0] * int(SAMPLE_RATE * 0.1))
all_samples.extend(generate_tone(659.25, 0.3, 0.08))

write_wav(OUTPUT, all_samples)
print(f"[+] startup.wav generated ({len(all_samples) / SAMPLE_RATE:.2f}s)")
