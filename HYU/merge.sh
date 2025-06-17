#!/usr/bin/env bash
set -euo pipefail

# Usage: merge.sh <base_dir> <sub_dir> <prefix> <group_size>

BASE_DIR="$1"      # e.g. TEST
SUB_DIR="$2"       # e.g. ttbb
PREFIX="$3"        # e.g. TTBB_DL
GROUP_SIZE="$4"    # e.g. 100

# move to TARGET_DIR
TARGET_DIR="${BASE_DIR}/${SUB_DIR}"
cd "${TARGET_DIR}" || { echo "Error: Directory not found: ${TARGET_DIR}"; exit 1; }

# create merged/ directory
mkdir -p merged

# 3. collect file list.
files=( ${PREFIX}*.root )
total=${#files[@]}
echo "Found $total files in ${TARGET_DIR}."

# 4. merge files per group.
index=0
group=0
while [ $index -lt $total ]; do
  remaining=$(( total - index ))
  if [ "$remaining" -lt "$GROUP_SIZE" ]; then
    echo "Only $remaining files remaining (< $GROUP_SIZE), skipping merge for these."
    break
  fi

  out_file="${PREFIX}_merged_${group}.root"
  echo "Merging files $index to $(( index + GROUP_SIZE - 1 )) → merged/${out_file}"
  hadd -f "merged/${out_file}" "${files[@]:index:GROUP_SIZE}"

  index=$(( index + GROUP_SIZE ))
  group=$(( group + 1 ))
done

# 5. prompt output result.
echo "Done. Created $group merged file(s) in merged/:"
ls -1 merged/${PREFIX}_merged_*.root

