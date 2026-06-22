#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
# Shrug — type the shrug ASCII art via wtype
#
# Types: ¯\_(ツ)_/¯
# Requires wtype (install via your package manager)
#
# Usage:
#   ./Shrug.sh
#   bindd = $mainMod, D, shrug, exec, $UserScripts/Shrug.sh

if ! command -v wtype &>/dev/null; then
  # fallback: pipe to ydotool or use wl-clipboard + paste
  if command -v wl-copy &>/dev/null && command -v wtype &>/dev/null; then
    # prefer wtype
    wtype "¯\_(ツ)_/¯"
  elif command -v wl-copy &>/dev/null; then
    # clipboard paste fallback (needs wl-paste or similar paste mechanism)
    wl-copy "¯\_(ツ)_/¯"
    wtype -M ctrl v
  else
    notify-send -u low "Shrug" "¯\_(ツ)_/¯ (copied to clipboard)"
    wl-copy "¯\_(ツ)_/¯"
  fi
else
  wtype "¯\_(ツ)_/¯"
fi
