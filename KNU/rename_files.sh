#!/bin/bash
# Usage : ./rename_files.sh <OUTDIR>
# You may modify the number of expected sub_directories. Check bottom of this code.

MODE="rename"
if [ "$1" == "--dry-run" ]; then
  MODE="dry-run"
  shift
elif [ "$1" == "--undo" ]; then
  MODE="undo"
  shift
fi

if [ $# -ne 1 ]; then
  echo "Usage:"
  echo "  $0 <base_directory_prefix>"
  echo "  $0 --dry-run <base_directory_prefix>"
  echo "  $0 --undo <base_directory_prefix>"
  exit 1
fi

BASE=$1
SE_DIR="/u/user/sucho/SE_UserHome/$BASE"
LOGFILE="/u/user/sucho/MG5_aMC_v3_5_8/rename_log_${BASE}.txt"

cd "$SE_DIR" || { echo "Cannot cd to $SE_DIR"; exit 1; }

# ─────────────────────────── Undo mode
if [ "$MODE" == "undo" ]; then
  if [ ! -f "$LOGFILE" ]; then
    echo "No log file found for undo: $LOGFILE"
    exit 1
  fi

  echo "[Undo Mode] Reading from $LOGFILE"
  while IFS="|" read -r old_path new_path; do
    if [[ "$old_path" =~ ^\[.*\] || "$old_path" =~ ^==.* ]]; then
      continue
    fi

    if [ -f "$new_path" ]; then
      mv "$new_path" "$old_path"
      echo "Restored: $new_path → $old_path"
    else
      echo "Skip (missing): $new_path"
    fi
  done < "$LOGFILE"
  echo "[Undo Complete] Logfile used: $LOGFILE"
  exit 0
fi

# ─────────────────────────── Rename or Dry-run
if [ "$MODE" == "rename" ]; then
  > "$LOGFILE"
fi

declare -A SUBDIR_COUNTS

for dir in ${BASE}_*/Events; do
  [ -d "$dir" ] || continue
  parent_dir=$(basename "$(dirname "$dir")")

  n_subdirs=$(find "$dir" -mindepth 1 -maxdepth 1 -type d | wc -l)
  echo "[${parent_dir}] Events contains ${n_subdirs} subdirectories" | tee -a "$LOGFILE"
  SUBDIR_COUNTS["$parent_dir"]=$n_subdirs

  for hepmc_path in "$dir"/run_*_decayed_*/*.hepmc.gz; do
    [ -f "$hepmc_path" ] || continue

    run_dir=$(basename "$(dirname "$hepmc_path")")
    run_id=${run_dir%%_decayed_1}
    new_path="$(dirname "$hepmc_path")/${parent_dir}_${run_id}.hepmc.gz"

    if [ "$MODE" == "dry-run" ]; then
      echo "[Dry-run] Would rename: $hepmc_path → $new_path"
    elif [ "$MODE" == "rename" ]; then
      if [ "$hepmc_path" != "$new_path" ]; then
        mv "$hepmc_path" "$new_path"
        echo "Renamed: $hepmc_path → $new_path" | tee -a "$LOGFILE"
        echo "$hepmc_path|$new_path" >> "$LOGFILE"
      else
        echo "Skipped (already renamed): $hepmc_path" | tee -a "$LOGFILE"
      fi
    fi
  done
done

# ─────────────────────────── Seed check
echo "" >> "$LOGFILE"
echo "== Seed check ==" >> "$LOGFILE"

TMPFILE=$(mktemp)
for dir in "$SE_DIR"/${BASE}_*/Events/run_*_decayed_*; do
  [ -d "$dir" ] || continue

  parent_dir=$(basename "$(dirname "$(dirname "$dir")")")
  run_name=$(basename "$dir")
  base_run=${run_name%%_decayed_1}
  banner_file="$dir/${run_name}_tag_1_banner.txt"

  if [ ! -f "$banner_file" ]; then
    echo "WARNING: Banner file not found: $banner_file" >> "$LOGFILE"
    continue
  fi

  seed=$(grep -E '^[[:space:]]*[0-9]+[[:space:]]*=[[:space:]]*iseed' "$banner_file" | awk '{print $1}')
  if [ -z "$seed" ]; then
    echo "WARNING: Seed not found in $banner_file" >> "$LOGFILE"
    continue
  fi

  echo "${parent_dir},${base_run},${seed}" >> "$LOGFILE"
  echo "$seed" >> "$TMPFILE"
done

total=$(wc -l < "$TMPFILE")
unique=$(sort "$TMPFILE" | uniq | wc -l)
duplicates=$((total - unique))

echo ""
echo "== Seed summary =="
if [ "$duplicates" -eq 0 ]; then
  echo "All $total seeds are unique."
else
  echo "!!! Found $duplicates duplicated seed(s):"
  sort "$TMPFILE" | uniq -d
fi

{
  echo ""
  echo "== Seed summary =="
  echo "Total seeds: $total"
  echo "Unique seeds: $unique"
  if [ "$duplicates" -eq 0 ]; then
    echo "All seeds are unique."
  else
    echo "Duplicated seeds: $duplicates"
    sort "$TMPFILE" | uniq -d
  fi
} >> "$LOGFILE"

rm "$TMPFILE"

# ─────────────────────────── Subdir inconsistency summary (only if any)
# specify maximum queue (99) or sub-run number (3).
echo "" >> "$LOGFILE"
echo "== Missing run_01_X_decayed_1 directories ==" | tee -a "$LOGFILE"

# LO
for i in $(seq 0 249); do
  for j in $(seq 0 1); do
    d="${BASE}_${i}/Events/run_01_${j}_decayed_1"
    if [ ! -d "$SE_DIR/$d" ]; then
      echo "❌ Missing: $d" | tee -a "$LOGFILE"
    fi
  done
done

# NLO
'''
for i in $(seq 0 99); do
    d="${BASE}_${i}/Events/run_01_decayed_1"
    if [ ! -d "$SE_DIR/$d" ]; then
      echo "❌ Missing: $d" | tee -a "$LOGFILE"
    fi
done
'''

# Finished
echo ""
echo "[Done] Logfile saved to: $(realpath "$LOGFILE")"

