#!/usr/bin/env bash
# Usage: run_TTW_DL.sh <JOB_INDEX>
# launch MG5 multi-run and store output in scratch_dir.

if [ $# -ne 1 ]; then
  echo "Usage: $0 <JOB_INDEX>"
  exit 1
fi

JOB_INDEX=$1

# Configuration
export PATH=/u/user/sucho/gcc-13.2.0-install/bin:$PATH
export LD_LIBRARY_PATH=/u/user/sucho/gcc-13.2.0-install/lib64:$LD_LIBRARY_PATH
MG5_BASE=/u/user/sucho/MG5_aMC_v3_5_8

# Scratch working directory
SCRATCH_BASE=/d0/scratch/sucho
JOBDIR="${SCRATCH_BASE}/TTW_DL_${JOB_INDEX}"

# Move to scratch and run MG5. You can change multi_run "N".
cd "$JOBDIR" || { echo "Error: cd to scratch failed"; exit 1; }
echo ">>> Running MG5 in scratch: ${JOBDIR}"
${MG5_BASE}/bin/mg5_aMC <<EOF
launch . -i
multi_run 4
launch
EOF

echo ">>> Done. Events are in ${JOBDIR}/Events/"
# You should transfer output .hepmc files to SE or HYU within 1 month.
# Scratch_dir will remove it automatically.
