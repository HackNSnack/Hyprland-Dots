#!/usr/bin/env bash
# Sync with upstream repository and handle conflicts
# Usage: ./scripts/sync-upstream.sh [--dry-run] [--claude]

set -e

# Colors
OK="$(tput setaf 2)[OK]$(tput sgr0)"
WARN="$(tput setaf 3)[WARN]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 4)[NOTE]$(tput sgr0)"
CYAN="$(tput setaf 6)"
RESET="$(tput sgr0)"

DRY_RUN=false
USE_CLAUDE=false

for arg in "$@"; do
    case $arg in
        --dry-run) DRY_RUN=true ;;
        --claude) USE_CLAUDE=true ;;
    esac
done

echo "$NOTE Fetching upstream changes..."
git fetch upstream

# Show what's new
UPSTREAM_COMMITS=$(git rev-list HEAD..upstream/main --count)
echo "$NOTE Upstream has $UPSTREAM_COMMITS new commits"

if [ "$UPSTREAM_COMMITS" -eq 0 ]; then
    echo "$OK Already up to date!"
    exit 0
fi

# Show summary of changes
echo ""
echo "$NOTE Upstream changes summary:"
git log HEAD..upstream/main --oneline | head -20
echo ""

# Show files that will be affected
echo "$NOTE Files changed in upstream:"
git diff --stat HEAD..upstream/main | tail -20
echo ""

if $DRY_RUN; then
    echo "$NOTE Dry run - checking for potential conflicts..."

    if git merge --no-commit --no-ff upstream/main 2>/dev/null; then
        echo "$OK No conflicts expected - merge would succeed"
        git merge --abort 2>/dev/null || true
    else
        echo "$WARN Potential conflicts detected in:"
        git diff --name-only --diff-filter=U 2>/dev/null || true
        git merge --abort 2>/dev/null || true
    fi
    exit 0
fi

echo "$NOTE Attempting merge..."
if git merge upstream/main -m "Merge upstream changes"; then
    echo "$OK Merge successful!"
    echo ""
    echo "$NOTE Next steps:"
    echo "  1. Run 'Hyprland --verify-config' to check for errors"
    echo "  2. Push with 'git push origin main'"
else
    CONFLICT_FILES=$(git diff --name-only --diff-filter=U)
    echo ""
    echo "$WARN Merge has conflicts in the following files:"
    echo "$CONFLICT_FILES"
    echo ""

    if $USE_CLAUDE; then
        echo "$NOTE Launching Claude Code to help resolve conflicts..."
        echo ""

        claude "I need help resolving merge conflicts in my Hyprland-Dots fork.

## Files with conflicts:
$CONFLICT_FILES

## My Customizations (DO NOT LOSE):
- UserConfigs/01-UserDefaults.conf: Qwant search, nvim, kitty
- UserConfigs/UserSettings.conf: Norwegian keyboard (kb_layout = no), Bibata cursor
- UserConfigs/UserKeybinds.conf: Super+Shift+V for Vivaldi
- UserConfigs/Startup_Apps.conf: ProtonVPN, RainbowBorders
- kitty.conf: Font size 14
- 0-shared-fonts.rasi: Smaller fonts

## Guidelines:
- UserConfigs/ ALWAYS takes priority
- configs/ can be updated from upstream
- Accept Hyprland compatibility fixes

Please read CLAUDE.md and help resolve each conflict."
    else
        echo "$NOTE Options to resolve:"
        echo ""
        echo "  ${CYAN}1. Manual resolution:${RESET}"
        echo "     Edit files, then: git add . && git commit"
        echo ""
        echo "  ${CYAN}2. Use Claude Code:${RESET}"
        echo "     ./scripts/sync-upstream.sh --claude"
        echo ""
        echo "  ${CYAN}3. Abort:${RESET} git merge --abort"
    fi
fi
