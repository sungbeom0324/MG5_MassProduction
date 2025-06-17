#!/bin/bash
# eg. ./transfer_files.sh TTW_DL /data2/sucho/HL-LHC/TTW_DL

# Usage
if [ $# -lt 2 ]; then
  echo "Usage: $0 <SKELETON> <REMOTE_TARGET_DIR> [PARALLEL_JOBS]"
  echo "Example: $0 TTW_DL /data2/sucho/HL-LHC/TTW_DL [3]"
  exit 1
fi

# Arguments
SKELETON=$1               # eg. TTW_DL
REMOTE_TARGET_DIR=$2      # eg. /data2/sucho/HL-LHC/TTW_DL
PARALLEL_JOBS=${3:-3}     # default 3 files in parallel.

# Set your path : From and To.
SE_BASE="/your_SE_path"
LOCAL_FULL_PATH="${SE_BASE}/${SKELETON}"

# Prepare a transfering list.
TRANSFER_LIST=".transfer_file_list_${SKELETON}.txt"
find "$LOCAL_FULL_PATH" -type f -name "*.hepmc.gz" > "$TRANSFER_LIST"

echo ">>> Creating remote directory on HYU if it doesn't exist"
ssh stiger97@210.117.210.34 "mkdir -p ${REMOTE_TARGET_DIR}"

# scp protocol.
echo ">>> Transferring files from $LOCAL_FULL_PATH to HYU:$REMOTE_TARGET_DIR with $PARALLEL_JOBS parallel jobs"

cat "$TRANSFER_LIST" | parallel -j "$PARALLEL_JOBS" --eta "
  SRC_FILE={}
  FILE_NAME=\$(basename \$SRC_FILE)
  scp \"\$SRC_FILE\" stiger97@210.117.210.34:${REMOTE_TARGET_DIR}/\$FILE_NAME \
    && echo \$SRC_FILE >> transfer_done_${SKELETON}.txt \
    || echo \$SRC_FILE >> transfer_failed_${SKELETON}.txt
"

echo ">>> Transfer complete."
echo "Check .transfer_done_${SKELETON}.txt and .transfer_failed_${SKELETON}.txt for logs."
