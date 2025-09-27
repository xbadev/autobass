#!/bin/bash

# archive.sh is an MVP backup script for AutoBASS
# how to use: ./archive.sh <source_dir> <target_dir>
# Options: -h, --help   to show instructions

show_help() {
  echo "usage: $0 <source_dir> <target_dir>"
  echo "creates a timestamped backup folder in <target_dir> and copies the files from <source_dir>."
  echo "-----------------------------------------------------------------"
  echo "Options:"
  echo "  -h, --help   Show this help message"
}

# check if help is needed
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
  exit 0
fi

# check for correct # of arguments
if [[ $# -lt 2 ]]; then
    echo "ERROR: Missing arguments."
    show_help
    exit 1
fi

SOURCE_DIR="$1"
TARGET_DIR="$2"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$TARGET_DIR/backup_$TIMESTAMP"

# create backup directory
mkdir -p "$BACKUP_DIR" || {
    echo "ERROR: Could not create target directory $BACKUP_DIR"
    exit 1
}

echo "Created backup directory: $BACKUP_DIR"

# copy files from source to backup directory
if command -v rsync >/dev/null 2>&1; then
    rsync -a "$SOURCE_DIR"/ "$BACKUP_DIR"/
else
    cp -r "$SOURCE_DIR"/* "$BACKUP_DIR"/
fi

echo "Backup completed successfully!"
