#!/usr/bin/env bash
# /* ---- Matrix Lock Screen with Video Background ---- */
# Plays a matrix video behind hyprlock with transparent overlay
# Based on: https://github.com/Jack02134x/hyprlock-mp4-guide
#
# Dependencies: mpvpaper (preferred) or mpv, ffmpeg, cmatrix (for video generation)
# Usage: ./MatrixLockVideo.sh [generate|test|lock]
#
# IMPORTANT: Add this to your hyprland.conf for transparency to work:
#   misc {
#       session_lock_xray = true
#   }

SCRIPT_DIR="$HOME/.config/hypr/UserScripts"
MATRIX_VIDEO="$SCRIPT_DIR/matrix-background.mp4"
MATRIX_CONF="$SCRIPT_DIR/hyprlock-matrix.conf"
VIDEO_DURATION=60  # seconds of video to generate

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check dependencies
check_deps() {
    local missing=()

    # Check for mpvpaper (preferred) or mpv (fallback)
    if ! command -v mpvpaper &>/dev/null; then
        if ! command -v mpv &>/dev/null; then
            missing+=("mpvpaper or mpv")
        fi
    fi
    command -v hyprlock &>/dev/null || missing+=("hyprlock")

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing[*]}"
        log_info "Install mpvpaper: nix-shell -p mpvpaper"
        return 1
    fi
    return 0
}

check_video_deps() {
    local missing=()

    command -v ffmpeg &>/dev/null || missing+=("ffmpeg")
    command -v cmatrix &>/dev/null || missing+=("cmatrix")

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing video generation dependencies: ${missing[*]}"
        log_info "Install with: nix-shell -p ffmpeg cmatrix"
        return 1
    fi
    return 0
}

# Generate matrix video using cmatrix + ffmpeg
generate_video() {
    log_info "Generating matrix video (${VIDEO_DURATION}s)..."
    log_info "This may take a minute..."

    if ! check_video_deps; then
        return 1
    fi

    # Get screen resolution
    local resolution
    resolution=$(hyprctl monitors -j | jq -r '.[0] | "\(.width)x\(.height)"' 2>/dev/null)
    if [[ -z "$resolution" || "$resolution" == "nullxnull" ]]; then
        resolution="1920x1080"
        log_warn "Could not detect resolution, using $resolution"
    fi
    log_info "Using resolution: $resolution"

    local width height
    width=$(echo "$resolution" | cut -d'x' -f1)
    height=$(echo "$resolution" | cut -d'x' -f2)

    # Method 1: Use script + ffmpeg to record cmatrix
    # This creates a pseudo-terminal and records cmatrix output

    local tmp_dir
    tmp_dir=$(mktemp -d)
    local fifo="$tmp_dir/cmatrix.fifo"
    mkfifo "$fifo"

    log_info "Recording cmatrix output..."

    # Run cmatrix in a pseudo-terminal and capture with ffmpeg
    # Using lavfi to create the matrix effect directly with ffmpeg
    ffmpeg -y \
        -f lavfi -i "color=c=black:s=${resolution}:r=30,format=rgb24" \
        -vf "
            drawtext=fontfile=/run/current-system/sw/share/X11/fonts/misc/10x20.pcf.gz:
            text='%{eif\\:random(0)*94+33\\:d\\:0}%{eif\\:random(0)*94+33\\:d\\:0}%{eif\\:random(0)*94+33\\:d\\:0}%{eif\\:random(0)*94+33\\:d\\:0}%{eif\\:random(0)*94+33\\:d\\:0}':
            fontcolor=0x00ff00:fontsize=20:x=random(0)*${width}:y=random(0)*${height}:
            reload=1,
            format=yuv420p
        " \
        -t "$VIDEO_DURATION" \
        -c:v libx264 \
        -preset fast \
        -crf 23 \
        "$MATRIX_VIDEO" 2>/dev/null

    # If that didn't work well, try a simpler approach
    if [[ ! -s "$MATRIX_VIDEO" ]]; then
        log_warn "Complex method failed, trying simple matrix generation..."

        # Generate a simple green-on-black animation
        ffmpeg -y \
            -f lavfi -i "color=c=black:s=${resolution}:r=30" \
            -f lavfi -i "color=c=0x00ff00:s=${resolution}:r=30" \
            -filter_complex "
                [0:v][1:v]blend=all_mode=screen:all_opacity=0.1,
                noise=alls=20:allf=t+u,
                eq=brightness=-0.1:contrast=1.2
            " \
            -t "$VIDEO_DURATION" \
            -c:v libx264 \
            -preset fast \
            -crf 23 \
            "$MATRIX_VIDEO" 2>/dev/null
    fi

    rm -rf "$tmp_dir"

    if [[ -s "$MATRIX_VIDEO" ]]; then
        log_info "Video generated: $MATRIX_VIDEO"
        log_info "Size: $(du -h "$MATRIX_VIDEO" | cut -f1)"
        return 0
    else
        log_error "Failed to generate video"
        return 1
    fi
}

# Alternative: Download a pre-made matrix video
download_video() {
    log_info "Downloading matrix video..."

    # You can replace this URL with any matrix loop video
    # This is a placeholder - user should provide their own video
    local video_url=""

    if [[ -z "$video_url" ]]; then
        log_warn "No download URL configured."
        log_info "Options:"
        log_info "  1. Run '$0 generate' to create a video"
        log_info "  2. Manually download a matrix video and save to:"
        log_info "     $MATRIX_VIDEO"
        log_info ""
        log_info "Good sources for matrix videos:"
        log_info "  - YouTube (search 'matrix code loop' and use yt-dlp)"
        log_info "  - Pexels.com (free stock videos)"
        log_info "  - pixabay.com/videos"
        return 1
    fi

    curl -L -o "$MATRIX_VIDEO" "$video_url"
}

# Test mpv video playback without locking
test_video() {
    if [[ ! -f "$MATRIX_VIDEO" ]]; then
        log_error "Matrix video not found: $MATRIX_VIDEO"
        log_info "Run '$0 generate' first, or add your own video"
        return 1
    fi

    log_info "Testing video playback (press 'q' to quit)..."
    mpv --fullscreen \
        --loop-file=inf \
        --no-audio \
        --no-osc \
        --osd-level=0 \
        "$MATRIX_VIDEO"
}

# Run the matrix lock screen
run_lock() {
    if ! check_deps; then
        exit 1
    fi

    # Check if already locked
    if pgrep -x hyprlock &>/dev/null; then
        log_warn "hyprlock is already running"
        exit 0
    fi

    # Check for video
    if [[ ! -f "$MATRIX_VIDEO" ]]; then
        log_warn "Matrix video not found: $MATRIX_VIDEO"
        log_info "Falling back to regular hyprlock..."
        exec hyprlock
    fi

    # Check for config
    if [[ ! -f "$MATRIX_CONF" ]]; then
        log_error "Matrix hyprlock config not found: $MATRIX_CONF"
        exec hyprlock
    fi

    log_info "Starting matrix lock screen on all monitors..."

    # Kill any existing video wallpaper instances
    pkill mpvpaper 2>/dev/null
    pkill -f "mpv.*matrix-background" 2>/dev/null

    # Use mpvpaper if available (preferred - proper Wayland layer support)
    # Based on: https://github.com/Jack02134x/hyprlock-mp4-guide
    if command -v mpvpaper &>/dev/null; then
        log_info "Using mpvpaper (recommended)"

        # mpvpaper with overlay layer - this is the key to making it work!
        # "ALL" targets all connected monitors
        # --layer overlay = places video above desktop but below lock screen
        mpvpaper -o "no-audio loop" --layer overlay ALL "$MATRIX_VIDEO" &
        PLAYER_PID=$!
        PLAYER_CMD="mpvpaper"
    else
        log_warn "mpvpaper not found, using mpv (may not layer correctly)"
        log_info "Install mpvpaper for better results: nix-shell -p mpvpaper"

        # Fallback to mpv
        mpv --fullscreen \
            --loop-file=inf \
            --no-audio \
            --no-osc \
            --no-osd-bar \
            --osd-level=0 \
            --no-input-default-bindings \
            --input-vo-keyboard=no \
            --vo=gpu \
            --gpu-context=wayland \
            --hwdec=auto \
            --really-quiet \
            "$MATRIX_VIDEO" &
        PLAYER_PID=$!
        PLAYER_CMD="mpv"
    fi

    # Give video player time to start
    sleep 0.3

    # Check if player started successfully
    if ! kill -0 $PLAYER_PID 2>/dev/null; then
        log_error "$PLAYER_CMD failed to start"
        exec hyprlock
    fi

    # Run hyprlock with transparent matrix config
    # The video shows through because of session_lock_xray = true
    hyprlock -c "$MATRIX_CONF"
    LOCK_EXIT=$?

    # Clean up: kill video player when hyprlock exits
    pkill mpvpaper 2>/dev/null
    kill $PLAYER_PID 2>/dev/null
    wait $PLAYER_PID 2>/dev/null

    log_info "Unlocked successfully"
    exit $LOCK_EXIT
}

# Check if session_lock_xray is enabled
check_xray_setting() {
    if ! grep -q "session_lock_xray.*=.*true" ~/.config/hypr/hyprland.conf 2>/dev/null && \
       ! grep -q "session_lock_xray.*=.*true" ~/.config/hypr/UserConfigs/*.conf 2>/dev/null; then
        log_warn "session_lock_xray may not be enabled!"
        log_info "Add this to your hyprland.conf or UserSettings.conf:"
        echo ""
        echo "  misc {"
        echo "      session_lock_xray = true"
        echo "  }"
        echo ""
        log_info "Without this, the video won't show through the lock screen."
        return 1
    fi
    return 0
}

# Show help
show_help() {
    echo "Matrix Lock Screen for Hyprland"
    echo "================================"
    echo "Based on: https://github.com/Jack02134x/hyprlock-mp4-guide"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  lock      - Run the matrix lock screen (default)"
    echo "  generate  - Generate matrix video using ffmpeg"
    echo "  test      - Test video playback without locking"
    echo "  download  - Show instructions for downloading a video"
    echo "  check     - Check if required settings are configured"
    echo "  help      - Show this help"
    echo ""
    echo "Files:"
    echo "  Video:  $MATRIX_VIDEO"
    echo "  Config: $MATRIX_CONF"
    echo ""
    echo "First time setup:"
    echo "  1. Add 'session_lock_xray = true' to misc{} in hyprland.conf"
    echo "  2. Install mpvpaper: nix-shell -p mpvpaper (or add to config)"
    echo "  3. $0 generate    # Create a matrix video (or download one)"
    echo "  4. $0 test        # Verify video playback"
    echo "  5. $0 lock        # Try the full lock screen"
    echo ""
    echo "For best video quality, download from YouTube:"
    echo "  yt-dlp -f 'bestvideo[height<=1080][ext=mp4]' '<url>' -o matrix-background.mp4"
    echo "  Search: 'matrix code rain loop 4k'"
}

# Main
case "${1:-lock}" in
    lock)
        run_lock
        ;;
    generate)
        generate_video
        ;;
    test)
        test_video
        ;;
    download)
        download_video
        ;;
    check)
        echo "Checking configuration..."
        echo ""
        check_deps && log_info "Dependencies: OK" || log_error "Dependencies: MISSING"
        check_xray_setting && log_info "session_lock_xray: OK" || log_warn "session_lock_xray: NOT FOUND"
        [[ -f "$MATRIX_VIDEO" ]] && log_info "Video file: OK ($MATRIX_VIDEO)" || log_warn "Video file: NOT FOUND"
        [[ -f "$MATRIX_CONF" ]] && log_info "Config file: OK" || log_warn "Config file: NOT FOUND"
        command -v mpvpaper &>/dev/null && log_info "mpvpaper: INSTALLED (recommended)" || log_warn "mpvpaper: NOT INSTALLED (using mpv fallback)"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
