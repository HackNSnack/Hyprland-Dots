# Summary of Hyprland-Dots Customizations

This document summarizes all customizations made to this fork of JaKooLit/Hyprland-Dots.

---

## Repository Overview

| Repository | URL |
|------------|-----|
| **Upstream** | https://github.com/JaKooLit/Hyprland-Dots |
| **Fork** | https://github.com/HackNSnack/Hyprland-Dots |
| **Related: NixOS-Hyprland** | https://github.com/HackNSnack/NixOS-Hyprland |
| **Related: Waybar Config** | https://github.com/HackNSnack/waybar_configs |
| **Related: Neovim Config** | https://github.com/HackNSnack/nvim2 |

---

## Part 1: Configuration Architecture

### 1.1 Two-Tier Configuration System

The upstream uses a layered config approach that we leverage for customizations:

```
config/hypr/
├── configs/                    # UPSTREAM DEFAULTS (updated from upstream)
│   ├── Keybinds.conf          # Default keybindings
│   ├── Settings.conf          # Default Hyprland settings
│   ├── Startup_Apps.conf      # Default startup applications
│   ├── ENVariables.conf       # Environment variables
│   ├── WindowRules.conf       # Window rules
│   └── ...
│
└── UserConfigs/               # USER OVERRIDES (our customizations)
    ├── 01-UserDefaults.conf   # Default apps, search engine
    ├── UserSettings.conf      # Input, layout, misc settings
    ├── UserKeybinds.conf      # Custom keybindings
    ├── Startup_Apps.conf      # Custom startup apps
    └── ...
```

**How it works:** The main `hyprland.conf` sources BOTH:
```conf
source = $configs/Settings.conf       # Upstream defaults first
source = $UserConfigs/UserSettings.conf   # User overrides second (takes priority)
```

This allows upstream updates without losing customizations.

---

## Part 2: UserConfigs Customizations

### 2.1 01-UserDefaults.conf

**Purpose:** Default applications and search engine

| Setting | Upstream Default | Fork Value |
|---------|------------------|------------|
| Editor | `nano` | `nvim` |
| Terminal | `kitty` | `kitty` |
| File Manager | `thunar` | `thunar` |
| Search Engine | Google | **Qwant** |

```conf
env = EDITOR,nvim
$edit=${EDITOR:-nano}
$term = kitty
$files = thunar
$Search_Engine = "https://www.qwant.com/?q={}"
```

---

### 2.2 UserSettings.conf

**Purpose:** Hyprland input, layout, and misc settings

#### Input Settings (Norwegian Keyboard)

| Setting | Upstream Default | Fork Value |
|---------|------------------|------------|
| `kb_layout` | `us` | **`no`** |
| `repeat_rate` | 25 | **50** |
| `repeat_delay` | 600 | **300** |
| `numlock_by_default` | false | **true** |
| `follow_mouse` | 1 | 1 |

```conf
input {
  kb_layout = no
  repeat_rate = 50
  repeat_delay = 300
  numlock_by_default = true

  touchpad {
    disable_while_typing = true
    natural_scroll = true
    tap-to-click = true
  }
}
```

#### Layout Settings

```conf
dwindle {
  pseudotile = true
  preserve_split = true
  special_scale_factor = 0.8
}

master {
  new_status = master
  new_on_top = 1
  mfact = 0.5
}

general {
  resize_on_border = true
  layout = dwindle
}
```

#### Misc Settings

```conf
misc {
  disable_hyprland_logo = true
  disable_splash_rendering = true
  vfr = true
  vrr = 2
  mouse_move_enables_dpms = true
  middle_click_paste = false
}
```

#### Cursor Settings

```conf
cursor {
  sync_gsettings_theme = true
  no_hardware_cursors = 2
  enable_hyprcursor = true
  warp_on_change_workspace = 2
  no_warps = true
}
```

#### Removed: Gestures Block

The `gestures` block was **removed** because these options were deprecated in recent Hyprland versions. Gesture settings are now in `input:touchpad`.

```conf
# OLD (removed):
gestures {
  workspace_swipe = true
  workspace_swipe_fingers = 3
  ...
}

# NEW (comment only):
# Gestures now configured in input:touchpad
# Workspace swipe is enabled by default
```

---

### 2.3 UserKeybinds.conf

**Purpose:** Custom keybindings beyond upstream defaults

| Keybind | Action | Notes |
|---------|--------|-------|
| `Super+Shift+V` | Open Vivaldi | Custom browser shortcut |

```conf
bindd = $mainMod SHIFT, V, Open Vivaldi browser, exec, vivaldi
```

**Note:** Most keybindings use upstream defaults. The new `bindd` format (descriptive binds) is used for better documentation in keybind search menus.

---

### 2.4 Startup_Apps.conf (UserConfigs)

**Purpose:** Personal startup applications

| Application | Purpose |
|-------------|---------|
| `protonvpn-app` | VPN client |
| `RainbowBorders.sh` | Animated border colors |

```conf
exec-once = protonvpn-app
exec-once = $UserScripts/RainbowBorders.sh
```

---

## Part 3: Other Configuration Changes

### 3.1 configs/ENVariables.conf

**Change:** Enabled Bibata-Modern-Ice cursor theme

| Setting | Upstream | Fork |
|---------|----------|------|
| Bibata cursor | Commented out | **Enabled** |

---

### 3.2 configs/Startup_Apps.conf

**Changes:** NixOS-specific additions at end of file

```conf
exec-once = $scriptsDir/Polkit-NixOS.sh
exec-once = blueman-applet
exec-once = ags
exec-once = qs
exec-once = $scriptsDir/KeybindsLayoutInit.sh
```

---

### 3.3 config/kitty/kitty.conf

**Change:** Reduced font size

| Setting | Upstream | Fork |
|---------|----------|------|
| `font_size` | 16.0 | **14.0** |

---

### 3.4 config/rofi/0-shared-fonts.rasi

**Change:** Smaller font sizes for rofi menus

| Setting | Upstream | Fork |
|---------|----------|------|
| Main font | 15 | **13** |
| Element font | 13 | **11** |

---

## Part 4: Files Summary

### Files Modified from Upstream

| File | Type of Change |
|------|----------------|
| `config/hypr/UserConfigs/01-UserDefaults.conf` | Qwant search, nvim editor |
| `config/hypr/UserConfigs/UserSettings.conf` | Norwegian keyboard, input settings, removed gestures |
| `config/hypr/UserConfigs/UserKeybinds.conf` | Vivaldi keybind |
| `config/hypr/UserConfigs/Startup_Apps.conf` | ProtonVPN, RainbowBorders |
| `config/hypr/configs/ENVariables.conf` | Bibata cursor enabled |
| `config/hypr/configs/Startup_Apps.conf` | NixOS-specific apps |
| `config/kitty/kitty.conf` | Font size 14 |
| `config/rofi/0-shared-fonts.rasi` | Smaller fonts |

### Files Added

| File | Purpose |
|------|---------|
| `scripts/sync-upstream.sh` | Upstream merge helper with Claude integration |
| `CLAUDE.md` | Context file for Claude Code merge assistance |
| `SUMMARY.md` | This file |

### Files NOT Modified (Use Upstream)

These files use upstream defaults and can be safely updated:
- `config/hypr/hyprland.conf` - Main config (just sources other files)
- `config/hypr/configs/Keybinds.conf` - Default keybindings
- `config/hypr/configs/Settings.conf` - Default settings
- `config/hypr/scripts/*` - Utility scripts
- `config/waybar/*` - Waybar themes (we use separate repo)
- `copy.sh` - Installation script

---

## Part 5: Differences from Upstream

### What's Different (Summary Table)

| Area | Upstream | Fork |
|------|----------|------|
| **Keyboard** | US layout | Norwegian (`no`) |
| **Search Engine** | Google | Qwant |
| **Editor** | nano | nvim |
| **Cursor** | Default | Bibata-Modern-Ice |
| **Font Sizes** | Larger | Smaller (kitty: 14, rofi: 13/11) |
| **Input Repeat** | Slower (25/600) | Faster (50/300) |
| **Numlock** | Off | On by default |
| **VPN** | None | ProtonVPN auto-start |
| **Gestures Block** | Present | Removed (deprecated) |
| **Custom Keybinds** | None | Super+Shift+V → Vivaldi |

### Architectural Approach

| Aspect | Approach |
|--------|----------|
| **Customizations** | All in `UserConfigs/` (separate from upstream defaults) |
| **Upstream Updates** | Safe to merge `configs/` files |
| **Keybinds** | Use upstream defaults + add custom in UserKeybinds |
| **Startup Apps** | Use upstream defaults + add custom in UserConfigs |

---

## Part 6: Merge Conflict Guidelines

### Files to ALWAYS Preserve (Never Overwrite)

- `config/hypr/UserConfigs/*` - All user customizations
- `config/kitty/kitty.conf` - Font size preference
- `config/rofi/0-shared-fonts.rasi` - Font size preferences

### Files Safe to Update from Upstream

- `config/hypr/configs/*` - Upstream defaults
- `config/hypr/scripts/*` - Utility scripts
- `copy.sh` - Installation script
- Documentation files

### Common Conflict Patterns

1. **Hyprland option deprecations**
   - Upstream removes/renames options for new Hyprland versions
   - Resolution: Accept upstream, check `Hyprland --verify-config`

2. **Keybind format changes**
   - Upstream switched to `bindd` (descriptive binds)
   - Resolution: Accept new format, re-add custom binds

3. **Startup apps**
   - Upstream changes defaults
   - Resolution: Accept in `configs/`, keep custom in `UserConfigs/`

### Verification Commands

```bash
# Check for config errors
Hyprland --verify-config

# Reload config (from within Hyprland)
hyprctl reload

# Sync with upstream
./scripts/sync-upstream.sh --dry-run  # Preview
./scripts/sync-upstream.sh            # Merge
./scripts/sync-upstream.sh --claude   # With Claude help
```

---

## Part 7: Related Repositories

### NixOS-Hyprland (System Config)

The NixOS-Hyprland repository installs this dotfiles repo via `install.sh`:

```bash
git clone https://github.com/HackNSnack/Hyprland-Dots ~/Hyprland-Dots
cd ~/Hyprland-Dots && ./copy.sh
```

### Waybar Config (Separate Repo)

Waybar configuration is maintained in a separate repository:
- **Repo:** https://github.com/HackNSnack/waybar_configs
- **Cloned to:** `~/.config/waybar`

This keeps waybar customizations independent from Hyprland-Dots.

### Neovim Config (Separate Repo)

Neovim configuration is maintained separately:
- **Repo:** https://github.com/HackNSnack/nvim2
- **Cloned to:** `~/.config/nvim`

---

## Part 8: Quick Reference

### Key Customizations at a Glance

```
Keyboard:     Norwegian (no)
Search:       Qwant
Editor:       nvim
Terminal:     kitty
Browser Key:  Super+Shift+V → Vivaldi
Cursor:       Bibata-Modern-Ice
VPN:          ProtonVPN (auto-start)
Borders:      Rainbow (animated)
```

### Git Remotes

```bash
origin   → https://github.com/HackNSnack/Hyprland-Dots.git (fork)
upstream → https://github.com/JaKooLit/Hyprland-Dots.git (original)
```

### Useful Commands

```bash
# Verify config
Hyprland --verify-config

# Reload without restart
hyprctl reload

# Check what's in upstream
./scripts/sync-upstream.sh --dry-run

# Merge upstream with Claude help
./scripts/sync-upstream.sh --claude
```
