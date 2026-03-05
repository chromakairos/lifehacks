#!/bin/bash

# ─────────────────────────────────────────────
# Instagram Reel / Feed Post Generator
# • Canvas: 9:16 (1080x1920) for native Reels
# • Content safe zone: 4:5 (1080x1350) centered
# • Background: your brand image, scaled to fill
# • Images float on background (no black bars)
# • Timing: 0.4s ± 0.15s per image (randomized)
# • Transitions: hard cut
#
# Usage:
#   ./make_reel.sh /path/to/image/folder /path/to/background.jpg
# ─────────────────────────────────────────────

INPUT_DIR="${1:-.}"
BG_IMAGE="${2:-background.jpg}"
OUTPUT="reel_output.mp4"

CANVAS_W=1080
CANVAS_H=1920
SAFE_W=1080
SAFE_H=1350
SAFE_Y=$(( (CANVAS_H - SAFE_H) / 2 ))
FPS=25
BASE_DURATION=0.5
VARIANCE=0.2

# ── Collect images ────────────────────────────
IMAGES=()
while IFS= read -r -d '' f; do
  IMAGES+=("$f")
done < <(find "$INPUT_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | sort -z)

if [ ${#IMAGES[@]} -eq 0 ]; then
  echo "No images found in: $INPUT_DIR"
  exit 1
fi

echo "Found ${#IMAGES[@]} images. Building video..."

# ── Generate random durations ─────────────────
DURATIONS=()
TOTAL=0
for i in "${!IMAGES[@]}"; do
  RAND=$(python3 -c "import random; print(round(random.uniform($BASE_DURATION - $VARIANCE, $BASE_DURATION + $VARIANCE), 3))")
  DURATIONS+=("$RAND")
  TOTAL=$(python3 -c "print($TOTAL + $RAND)")
done

# ── Build ffmpeg inputs ───────────────────────
INPUTS=()
INPUTS+=(-loop 1 -t "$TOTAL" -i "$BG_IMAGE")
for i in "${!IMAGES[@]}"; do
  INPUTS+=(-loop 1 -t "${DURATIONS[$i]}" -i "${IMAGES[$i]}")
done

# ── Build filter_complex ──────────────────────
FILTER=""

# Normalize background once
FILTER+="[0:v]scale=${CANVAS_W}:${CANVAS_H}:force_original_aspect_ratio=increase,crop=${CANVAS_W}:${CANVAS_H},setsar=1,fps=${FPS},format=yuv420p[bg_norm];"

# Split bg into N streams
N=${#IMAGES[@]}
FILTER+="[bg_norm]split=${N}"
for i in "${!IMAGES[@]}"; do
  FILTER+="[bgsplit${i}]"
done
FILTER+=";"

# For each image: scale to fit within safe zone (no padding), overlay centered on bg
for i in "${!IMAGES[@]}"; do
  IDX=$((i + 1))
  DUR="${DURATIONS[$i]}"

  FILTER+="[bgsplit${i}]trim=duration=${DUR},setpts=PTS-STARTPTS[bg${i}];"

  # Scale image to fit within SAFE_W x SAFE_H, no padding
  FILTER+="[${IDX}:v]scale='if(gt(iw/ih,${SAFE_W}/${SAFE_H}),${SAFE_W},-2)':'if(gt(iw/ih,${SAFE_W}/${SAFE_H}),-2,${SAFE_H})',setsar=1,fps=${FPS},format=yuv420p[img${i}];"

  # Overlay centered within the safe zone
  # x = (CANVAS_W - img_w) / 2, y = SAFE_Y + (SAFE_H - img_h) / 2
  FILTER+="[bg${i}][img${i}]overlay=x=(${CANVAS_W}-overlay_w)/2:y=${SAFE_Y}+(${SAFE_H}-overlay_h)/2:shortest=1,setpts=PTS-STARTPTS[frame${i}];"
done

# Concatenate
CONCAT=""
for i in "${!IMAGES[@]}"; do
  CONCAT+="[frame${i}]"
done
FILTER+="${CONCAT}concat=n=${N}:v=1:a=0[out]"

# ── Run ffmpeg ────────────────────────────────
ffmpeg -y \
  "${INPUTS[@]}" \
  -filter_complex "$FILTER" \
  -map "[out]" \
  -c:v libx264 \
  -pix_fmt yuv420p \
  -movflags +faststart \
  "$OUTPUT"

echo ""
echo "✓ Done → $OUTPUT"
echo "  Canvas: ${CANVAS_W}x${CANVAS_H} (9:16)"
echo "  Safe zone: ${SAFE_W}x${SAFE_H} (4:5) centered"
echo "  Images: ${N}"