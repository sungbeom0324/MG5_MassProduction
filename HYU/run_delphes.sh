#!/bin/bash
# This script submits run_delphes.slurm.
# eg. ./run_delphes.sh TTW_DL

if [ $# -ne 1 ]; then
  echo "Usage: $0 <process_directory>"
  exit 1
fi

PROCDIR=$1
INPUT_DIR="${PROCDIR}"
OUTPUT_DIR="${PROCDIR}/delphes"
SLURM_SCRIPT="run_delphes.slurm"
ARRAY_LIMIT=200  # Maximum job in parallel.

NUM_FILES=$(ls ${INPUT_DIR}/*.hepmc 2>/dev/null | wc -l)
if [ "$NUM_FILES" -eq 0 ]; then
  echo "[ERROR] No .hepmc files found in ${INPUT_DIR}"
  exit 1
fi

MAX_INDEX=$((NUM_FILES - 1))

mkdir -p "${OUTPUT_DIR}"
mkdir -p delphes_batch_logs

echo "[INFO] Submitting ${NUM_FILES} Delphes jobs (1 file per job)"
sbatch --export=PROCDIR=${PROCDIR} --array=0-${MAX_INDEX}%${ARRAY_LIMIT} ${SLURM_SCRIPT}
