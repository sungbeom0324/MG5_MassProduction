#!/usr/bin/env bash
# setup_runs.sh
# Usage: ./setup_runs.sh <SKELETON> <N_COPIES>

# Usage
if [ $# -ne 2 ]; then
  echo "Usage: $0 <SKELETON> <Number of copies>"
  exit 1
fi

SOURCE_DIR="$1"
N_COPIES="$2"
DESTINATINON="/your_MG5_path/SKELETON_X"

# Check if there exists <SKELETON>
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: '$SOURCE_DIR' No such directory."
  exit 1
fi

# Copy SKELETON and change iseed.
for (( i=0; i< N_COPIES; i++ )); do
  DEST="${DESTINATINON}/$(basename ${SOURCE_DIR})_${i}"

  if [ -d "$DEST" ]; then
    echo "[$i] '$DEST' Already exist — pass."
    continue
  fi

  echo "[$i] Copied → $DEST"
  mkdir -p "$DEST"
  cp -r "${SOURCE_DIR}/." "$DEST/"

  CARD="$DEST/Cards/run_card.dat"
  if [ -f "$CARD" ]; then
    SEED=$(( (i+1) * 10000 ))   # You may customize this iseed rule.
    sed -i -E \
      "s|^[[:space:]]*[0-9]+[[:space:]]*=[[:space:]]*iseed.*|  ${SEED} = iseed   ! rnd seed|" \
      "$CARD"
    echo "    iseed → $SEED"
  else
    echo "    Warning: '$CARD' No such run_card..!"
  fi
done

echo "${N_COPIES} copies to → ${DESTINATINON}/"
