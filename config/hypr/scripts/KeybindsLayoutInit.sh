#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Initialize J/K keybinds — uses movefocus for directional (cross-monitor) navigation

set -euo pipefail

# Reset and bind SUPER+J/K to directional focus (works across monitors)
hyprctl keyword unbind SUPER,J || true
hyprctl keyword unbind SUPER,K || true

hyprctl keyword bind SUPER,J,movefocus,d
hyprctl keyword bind SUPER,K,movefocus,u
