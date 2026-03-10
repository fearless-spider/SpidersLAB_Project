#!/bin/sh
# Toggle between normal and hazard screen shaders
NORMAL="$HOME/.config/hypr/screen_shader.glsl"
HAZARD="$HOME/.config/hypr/hazard.frag"
STATE_FILE="/tmp/.hazard-shader-active"

if [ -f "$STATE_FILE" ]; then
    # Switch back to normal
    hyprctl keyword decoration:screen_shader "$NORMAL"
    rm -f "$STATE_FILE"
else
    # Engage hazard mode
    hyprctl keyword decoration:screen_shader "$HAZARD"
    touch "$STATE_FILE"
fi
