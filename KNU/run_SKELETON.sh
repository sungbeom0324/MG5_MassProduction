#!/usr/bin/env bash
# Usage: run_SKELETON.sh <JOB_INDEX>
# Copy this file and modify SKELETON. (vim command mode, :%s/SKELETON/TTW_DL/g)
# Condor will transfer SKELETON_X/SKELETON_<JOB_INDEX> directory to temp and run MG5 using this shell. 
# Results will be copied to knu_SE. https://t2-cms.knu.ac.kr/wiki/index.php/Storage_Element_Tutorial.

if [ $# -ne 1 ]; then
  echo "Usage: $0 <JOB_INDEX>"
  exit 1
fi

JOB_INDEX=$1
JOBDIR="SKELETON_${JOB_INDEX}"
MG5_BASE=/your_path_to/MG5_aMC_v3_5_8  # MODIFY 

# debug
echo ">>> Hostname: $(hostname)"
echo ">>> Current directory: $(pwd)"
echo ">>> Job directory: ${JOBDIR}"
echo ">>> Listing contents:"
ls -l

# Move to working directory
cd "${JOBDIR}" || { echo "Error: Cannot cd into ${JOBDIR}"; exit 1; }

# Execute MG5 multi-run mode. Modify multi_run "N"
echo ">>> Running MG5 for ${JOBDIR}"
${MG5_BASE}/bin/mg5_aMC <<EOF
launch . -i
multi_run 2
launch
EOF

cd ..

# Copy results to knu_SE.
mkdir -p /your_SE/SKELETON  # MODIFY
DESTINATION="/your_SE/SKELETON/${JOBDIR}" # MODIFY 
cp -r "${JOBDIR}" "${DESTINATION}" && \
  echo ">>> Successfully copied to SE: ${DESTINATION}" || \
  echo ">>> SE copy failed!"
