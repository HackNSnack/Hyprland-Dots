# Claude Code Context for Hyprland-Dots

## Overview

This is a **personal fork** of [JaKooLit/Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots), containing Hyprland dotfiles and configurations.

**Owner**: HackNSnack
**Upstream**: https://github.com/JaKooLit/Hyprland-Dots
**Fork**: https://github.com/HackNSnack/Hyprland-Dots

## Two-Tier Configuration System

The upstream uses a layered config approach:

```
config/hypr/
├── configs/           # UPSTREAM DEFAULTS (don't modify heavily)
│   ├── Keybinds.conf
│   ├── Settings.conf
│   ├── Startup_Apps.conf
│   └── ...
└── UserConfigs/       # USER OVERRIDES (our customizations go here)
    ├── 01-UserDefaults.conf
    ├── UserSettings.conf
    ├── UserKeybinds.conf
    ├── Startup_Apps.conf
    └── ...
```

The main `hyprland.conf` sources BOTH:
```
source = $configs/Settings.conf      # Upstream defaults
source = $UserConfigs/UserSettings.conf  # User overrides
```

## Personal Customizations

### UserConfigs/01-UserDefaults.conf
- Search engine: Qwant (`https://www.qwant.com/?q={}`)
- Editor: nvim
- Terminal: kitty
- File manager: thunar

### UserConfigs/UserSettings.conf
- **Keyboard**: Norwegian layout (`kb_layout = no`)
- **Input**: Custom repeat rate (50), numlock enabled
- **Touchpad**: Natural scroll, tap-to-click
- **Cursor**: Bibata-Modern-Ice theme
- **Misc**: VRR enabled, no Hyprland logo

### UserConfigs/UserKeybinds.conf
- `Super+Shift+V` → Vivaldi browser
- Most keybinds use upstream defaults (new `bindd` format)

### UserConfigs/Startup_Apps.conf
- ProtonVPN auto-start
- RainbowBorders enabled

### Other Customizations
- `config/kitty/kitty.conf` - Font size 14
- `config/rofi/0-shared-fonts.rasi` - Smaller font sizes
- `config/hypr/configs/ENVariables.conf` - Bibata cursor enabled

## Files That Should NEVER Be Overwritten

These contain personal customizations:
- `config/hypr/UserConfigs/*` - All user config files
- `config/kitty/kitty.conf` - Font preferences
- `config/rofi/0-shared-fonts.rasi` - Font sizes

## Files Safe to Update from Upstream

- `config/hypr/configs/*` - Upstream defaults (merge carefully)
- `config/hypr/scripts/*` - Utility scripts
- `copy.sh` - Installation script
- `config/waybar/*` - Waybar themes (we have separate waybar repo)
- Documentation files

## Merge Conflict Resolution Strategy

### Priority Rules
1. **UserConfigs/ always takes priority** - these are personal overrides
2. **configs/ can be updated** but check for renamed/removed options
3. **Scripts can be updated** but verify they still work with NixOS

### Common Conflict Patterns

1. **Hyprland option changes**
   - Upstream updates for new Hyprland versions
   - Resolution: Accept upstream changes to configs/, update UserConfigs/ if needed
   - Watch for: Deprecated options (like old `gestures` block)

2. **Keybind format changes**
   - Upstream moved to `bindd` (descriptive binds)
   - Resolution: Accept new format, re-add custom binds in UserKeybinds.conf

3. **Startup apps**
   - Upstream changes default apps
   - Resolution: Accept in configs/Startup_Apps.conf, keep custom apps in UserConfigs/Startup_Apps.conf

4. **Script updates**
   - Upstream fixes bugs or adds features
   - Resolution: Usually safe to accept

## Useful Commands

```bash
# Verify Hyprland config
Hyprland --verify-config

# Apply config changes (from Hyprland)
hyprctl reload

# Check for deprecated options
Hyprland --verify-config 2>&1 | grep -i "error\|warning"
```

## Related Repositories

- **NixOS-Hyprland**: ~/NixOS-Hyprland (installs this dotfiles repo)
- **Waybar config**: https://github.com/HackNSnack/waybar_configs.git (separate repo)
- **Neovim config**: https://github.com/HackNSnack/nvim2.git
