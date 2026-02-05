#!/usr/bin/env bash
# /* ---- Matrix Lock Screen ---- */
# Uses swaylock-plugin with cmatrix for a matrix-style animated lock screen

# Configuration
TERMINAL="kitty"
MATRIX_CMD="cmatrix -ab -u 2 -C green"  # -a async, -b bold, -u update delay, -C color

# Run swaylock-plugin with cmatrix as the background
# The terminal runs cmatrix fullscreen behind the transparent lock overlay
swaylock-plugin \
    --indicator-radius 100 \
    --indicator-thickness 10 \
    --inside-color 00000088 \
    --ring-color 00ff00ff \
    --key-hl-color 00ff00ff \
    --line-color 00000000 \
    --separator-color 00000000 \
    --text-color 00ff00ff \
    --inside-clear-color 00000088 \
    --ring-clear-color ffff00ff \
    --inside-ver-color 00000088 \
    --ring-ver-color 0000ffff \
    --inside-wrong-color 00000088 \
    --ring-wrong-color ff0000ff \
    --command "$TERMINAL --class swaylock-bg -e sh -c '$MATRIX_CMD'"
