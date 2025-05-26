#!/usr/bin/env bash
# setup_runs_scratch.sh
# Usage: ./setup_runs_scratch.sh <SOURCE_DIR> <N_COPIES>

# ── A) 입력 인자 확인
if [ $# -ne 2 ]; then
  echo "Usage: $0 <원본_디렉터리> <복사_개수>"
  exit 1
fi

SOURCE_DIR="$1"
N_COPIES="$2"
SCRATCH_BASE="/d0/scratch/sucho"

# ── B) 원본 디렉터리 존재 확인
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: '$SOURCE_DIR' 디렉터리가 없습니다."
  exit 1
fi

# ── C) 복사 및 시드 설정
for (( i=0; i< N_COPIES; i++ )); do
  DEST="${SCRATCH_BASE}/$(basename ${SOURCE_DIR})_${i}"

  if [ -d "$DEST" ]; then
    echo "[$i] '$DEST' 이미 존재 — 건너뜁니다."
    continue
  fi

  echo "[$i] 복사 → $DEST"
  mkdir -p "$DEST"
  cp -r "${SOURCE_DIR}/." "$DEST/"

  CARD="$DEST/Cards/run_card.dat"
  if [ -f "$CARD" ]; then
    SEED=$(( (i+1) * 10000 ))
    sed -i -E \
      "s|^[[:space:]]*[0-9]+[[:space:]]*=[[:space:]]*iseed.*|  ${SEED} = iseed   ! rnd seed|" \
      "$CARD"
    echo "    iseed → $SEED"
  else
    echo "    Warning: '$CARD' 없음 — 시드 설정 생략"
  fi
done

# ── D) 완료 메시지
echo "스크래치에 ${N_COPIES}개 복사 완료 → ${SCRATCH_BASE}/"

