#!/usr/bin/env bash
# Auto-captures screenshots of every plugin's Standalone .app and saves
# them to website/screenshots/<name>.png — used by the plugin detail modal.
#
# Run from anywhere:   bash _capture-screenshots.sh
# Takes ~90 seconds (22 plugins × ~4s each).
#
# Requirements: macOS, the project must be built (cmake --build build).
# If a plugin's window doesn't appear within 3 seconds, that one is skipped.

set -u

SHOTS="$(dirname "$0")/previews"
mkdir -p "$SHOTS"

BUILD_BASE="$(cd "$(dirname "$0")/.." && pwd)/build"

# display_name : output_filename
PLUGINS=(
  "Delay:delay"
  "Reverb:reverb"
  "De-Esser:deesser"
  "Warmer:warmer"
  "Wobbler:wobbler"
  "Filter:filter"
  "Panner:panner"
  "Wide:wide"
  "Smasher:smasher"
  "Tone:tone"
  "Voice:voice"
  "Double:double"
  "Squeeze:squeeze"
  "Brick:brick"
  "Crunch:crunch"
  "Stutter:stutter"
  "Tape Stop:tapestop"
  "Freeze:freeze"
  "Reverse:reverse"
  "Glitch:glitch"
  "Wow:wow"
  "Heat:heat"
)

# Helper: get the Quartz (CGWindow) ID for the main editor window of an app
# via a tiny Swift script (uses Cocoa/Quartz natively, no extra install).
get_wid() {
    local owner="$1"
    swift "$(dirname "$0")/_get-wid.swift" "$owner" 2>/dev/null
}

echo "Capturing 22 plugin screenshots → $SHOTS"
echo ""

ok=0; missing=0; nowin=0

for entry in "${PLUGINS[@]}"; do
    display_name="${entry%%:*}"
    fname="${entry##*:}"

    APP=$(find "$BUILD_BASE" -name "Stupid Simple $display_name.app" -type d 2>/dev/null | head -1)
    if [[ -z "$APP" ]]; then
        echo "  $display_name → MISSING APP"
        ((missing++))
        continue
    fi

    open "$APP"

    # Wait up to 3s for the window to appear
    APP_NAME=$(basename "$APP" .app)
    WID=""
    for _ in 1 2 3 4 5 6; do
        sleep 0.5
        WID=$(get_wid "$APP_NAME")
        [[ -n "$WID" ]] && break
    done

    if [[ -z "$WID" ]]; then
        echo "  $display_name → NO WINDOW (skipped)"
        osascript -e "tell application \"$APP_NAME\" to quit" 2>/dev/null
        ((nowin++))
        continue
    fi

    # Capture: -l = window-id, -o = no shadow, -x = no sound, -t png
    screencapture -l"$WID" -o -x -t png "$SHOTS/$fname.png"
    osascript -e "tell application \"$APP_NAME\" to quit" 2>/dev/null
    sleep 0.3

    if [[ -f "$SHOTS/$fname.png" ]]; then
        size=$(stat -f "%z" "$SHOTS/$fname.png")
        echo "  $display_name → ${fname}.png (${size}B)"
        ((ok++))
    else
        echo "  $display_name → CAPTURE FAILED"
    fi
done

echo ""
echo "Done — $ok captured, $missing missing apps, $nowin no-window"
echo ""
ls -la "$SHOTS"
