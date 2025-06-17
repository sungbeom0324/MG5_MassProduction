#!/bin/bash
#SBATCH --job-name=delphes_batch
#SBATCH --output=delphes_batch_logs/delphes_%A_%a.out
#SBATCH --error=delphes_batch_logs/delphes_%A_%a.err
#SBATCH --partition=cpu,high_cpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=10:00:00

cd "$SLURM_SUBMIT_DIR" || exit 1
WORKDIR=$(pwd)
INPUT_DIR="${WORKDIR}/${PROCDIR}"
OUTPUT_DIR="${INPUT_DIR}/delphes"
CARD_DIR="${WORKDIR}/Cards"

mkdir -p "${OUTPUT_DIR}"
mkdir -p "${PROCDIR}_logs"

# One delphes job per one SLURM_ARRAY_TASK_ID
FILE_LIST=($(ls "${INPUT_DIR}"/*.hepmc | sort))
INPUT_FILE=${FILE_LIST[$SLURM_ARRAY_TASK_ID]}
BASENAME=$(basename "${INPUT_FILE}")
OUTPUT_FILE="${OUTPUT_DIR}/${BASENAME%.hepmc}.root"

echo "[INFO] Processing: ${INPUT_FILE}"
/your_delphes_path/DelphesHepMC2 "${CARD_DIR}/your_delphes_card.tcl" "${OUTPUT_FILE}" "${INPUT_FILE}"

if [ $? -ne 0 ]; then
    echo "[ERROR] Failed on ${INPUT_FILE}"
    exit 1
else
    echo "[SUCCESS] Done with ${INPUT_FILE}"
fi
