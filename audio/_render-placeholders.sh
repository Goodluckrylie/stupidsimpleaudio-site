#!/usr/bin/env bash
# Generates 66 placeholder demo clips (22 plugins × 3 sources) using ffmpeg
# filter approximations. Outputs are named <plugin>-<source>.mp3.
#
# Sources used:
#   vocal.mp3 — your "Call My Bluff" acapella (first 13s)
#   drums.mp3 — Cali Swag drum break
#   piano.mp3 — Silver and Gold Piano loop
#
# Run from website/audio/:   ./_render-placeholders.sh
# Takes ~30 seconds. Re-run any time you swap any of the three sources.

set -euo pipefail
cd "$(dirname "$0")"

for src in vocal drums piano; do
    [[ -f "${src}.mp3" ]] || { echo "ERROR: ${src}.mp3 not found in $(pwd)" >&2; exit 1; }
done

SOURCES=("vocal" "drums" "piano")

# render <output_basename> "<simple filter chain>"
render() {
    local name="$1"; local filter="$2"
    for src in "${SOURCES[@]}"; do
        ffmpeg -y -i "${src}.mp3" -af "$filter" -b:a 192k "${name}-${src}.mp3" 2>/dev/null
    done
    echo "  ✓ $name (vocal, drums, piano)"
}

# render_complex <output_basename> "<filter_complex string>"
render_complex() {
    local name="$1"; local filter="$2"
    for src in "${SOURCES[@]}"; do
        ffmpeg -y -i "${src}.mp3" -filter_complex "$filter" -b:a 192k "${name}-${src}.mp3" 2>/dev/null
    done
    echo "  ✓ $name (vocal, drums, piano) [complex]"
}

echo "Rendering 22 plugins × 3 sources = 66 placeholder files..."
echo ""

# ---- Time ----
render delay     "aecho=0.7:0.6:300|600:0.5|0.3"
# Reverb (more in your face): higher wet output on every echo stage, beefier
# tail decays, slightly brighter lowpass + final volume boost so it pops.
render reverb    "chorus=0.6:0.7:20|45:0.4|0.5:0.25|0.35:1.5|2.0,aecho=0.8:0.85:13|19|27|39|55|77:0.7|0.6|0.5|0.42|0.36|0.3,aecho=0.75:0.85:103|143|199|277|389:0.55|0.45|0.38|0.32|0.25,aecho=0.7:0.85:541|761|1069|1499|2099:0.42|0.32|0.25|0.18|0.12,lowpass=f=7500,highpass=f=85,volume=1.35"

# ---- Modulation ----
render wobbler   "tremolo=f=5:d=0.7"
render filter    "lowpass=f=1200"
render panner    "apulsator=hz=1.2:amount=0.85"

# ---- Stereo / pitch ----
render wide      "extrastereo=m=2.8"
render double    "adelay=22|0,aecho=1.0:0.6:14:0.5"
render voice     "asetrate=44100*1.5,atempo=0.6667,aresample=44100"

# ---- Tone ----
render warmer    "equalizer=f=180:t=q:w=1:g=4,equalizer=f=8000:t=q:w=1:g=-3,acompressor=threshold=-18dB:ratio=2:attack=20:release=100"
render tone      "equalizer=f=80:t=q:w=1:g=3,equalizer=f=2500:t=q:w=1:g=-3,equalizer=f=10000:t=q:w=1:g=4"
render deesser   "equalizer=f=6500:t=q:w=2:g=-10"

# ---- Dynamics ----
render squeeze   "acompressor=threshold=-22dB:ratio=4:attack=8:release=100,volume=1.4"
render brick     "alimiter=level_in=1.8:level_out=0.9:limit=0.85"

# ---- Distortion ----
render crunch    "volume=3.5,acompressor=threshold=-3dB:ratio=20:attack=1:release=10,equalizer=f=4000:t=q:w=2:g=4"
render smasher   "volume=2.2,acompressor=threshold=-15dB:ratio=8:attack=2:release=30,equalizer=f=200:t=q:w=1:g=3"
render heat      "volume=1.8,acompressor=threshold=-10dB:ratio=3:attack=15:release=60,equalizer=f=120:t=q:w=1:g=2"

# ---- Creative ----
render stutter   "aecho=0.8:0.9:120|240|360|480:0.7|0.6|0.5|0.4"
# Tape Stop: vocal/drum/piano plays normally for 11.5s, then slows piecewise.
render_complex tapestop "
  [0:a]atrim=0:11.5,asetpts=PTS-STARTPTS[normal];
  [0:a]atrim=11.5:11.8,asetrate=44100*0.9,asetpts=PTS-STARTPTS[s1];
  [0:a]atrim=11.8:12.1,asetrate=44100*0.7,asetpts=PTS-STARTPTS[s2];
  [0:a]atrim=12.1:12.4,asetrate=44100*0.5,asetpts=PTS-STARTPTS[s3];
  [0:a]atrim=12.4:12.7,asetrate=44100*0.3,asetpts=PTS-STARTPTS[s4];
  [0:a]atrim=12.7:12.95,asetrate=44100*0.15,asetpts=PTS-STARTPTS[s5];
  [normal][s1][s2][s3][s4][s5]concat=n=6:v=0:a=1,aresample=44100,afade=t=out:st=14:d=0.6
"
# Freeze: original audio continues; a 0.5s slice from t=4.5 sustains over the top.
render_complex freeze "
  [0:a]asplit=2[a1][a2];
  [a1]atrim=4.5:5,asetpts=PTS-STARTPTS[slice];
  [slice]aloop=loop=-1:size=22050,atrim=0:8,afade=t=in:d=0.4,afade=t=out:st=6.5:d=1.5,volume=0.55[pad];
  [pad]adelay=4500|4500[delayed];
  [a2][delayed]amix=inputs=2:duration=first
"
render reverse   "areverse"
render glitch    "aresample=5500,aresample=44100,aphaser=in_gain=0.7:out_gain=0.8:delay=2.5:decay=0.7:speed=2,vibrato=f=7:d=0.6,acrusher=bits=4:samples=2:mode=log"
render wow       "vibrato=f=3.5:d=0.85,chorus=0.6:0.9:50:0.4:0.25:2,lowpass=f=9000"

echo ""
COUNT=$(ls -1 *-vocal.mp3 *-drums.mp3 *-piano.mp3 2>/dev/null | wc -l | tr -d ' ')
echo "Done — $COUNT wet files generated. Expected 66."
