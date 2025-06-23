#!/usr/bin/env bash
set -euo pipefail

# Path to the list of backup targets
TARGET_LIST="/home/revxngedev/Desktop/backup_targets.txt"
# Directory where .tar.zst archives and the log will be stored
DEST_DIR="/home/revxngedev/Desktop/backups"
TIMESTAMP=$(date +'%Y%m%d-%H%M%S')
LOG_FILE="$DEST_DIR/backup_zstd.log"

mkdir -p "$DEST_DIR"
echo "=== Backup started: $TIMESTAMP ===" >> "$LOG_FILE"

while IFS= read -r SOURCE; do
  # skip empty lines and comments
  [[ -z "$SOURCE" || "$SOURCE" =~ ^# ]] && continue

  # if the path doesn't exist, warn and skip
  if [ ! -e "$SOURCE" ]; then
    echo "WARNING: $SOURCE does not exist, skipping." >> "$LOG_FILE"
    continue
  fi

  BASENAME=$(basename "$SOURCE" | tr ' /' '_')
  ARCHIVE="$DEST_DIR/${BASENAME}_$TIMESTAMP.tar.zst"
  echo "Backing up $SOURCE → $ARCHIVE" >> "$LOG_FILE"

  tar -cf - "$SOURCE" | zstd -q -o "$ARCHIVE"
done < "$TARGET_LIST"

echo "=== Backup finished: $TIMESTAMP ===" >> "$LOG_FILE"
