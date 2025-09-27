#!/bin/bash

# archive.sh is an MVP backup script for AutoBASS
# how to use: ./archive.sh <source_dir> <target_dir>
# Options: -h, --help   to show instructions

# Compression & logging issue 1

#logging helpers :-
LOG_FILE="$(dirname "$0")/archive.log"

timestamp() { date "+%Y-%m-%d %H:%M:%S"; }

log_info() {
    local msg="INFO: [$(timestamp)] $*"
    # print to stdout and append to log
    echo "$msg" | tee -a "$LOG_FILE"
}

log_error() {
    local msg="ERROR: [$(timestamp)] $*"
    # print to stderr and append to log
    echo "$msg" | tee -a "$LOG_FILE" >&2
}
# -------------------------------------------------------------------------------------------------------------


show_help() {
  echo "usage: $0 <source_dir> <target_dir>"
  echo "creates a timestamped backup folder in <target_dir> and copies the files from <source_dir>."
  echo "-----------------------------------------------------------------"
  echo "Options:"
  echo "  -h, --help   Show this help message"
}

# --- option parsing (dry-run, help) ---
DRY_RUN=false
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    --) # end of options
      shift
      break
      ;;
    -*) # unknown option
      log_error "Unknown option: $1"
      show_help
      exit 1
      ;;
    *)  # positional (source/target)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

# restore only the positional args (so your existing config-fallback block still works)
set -- "${POSITIONAL[@]}"


# check if help is needed
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
  exit 0
fi

# Start log early
log_info "archive script started."

# If fewer than 2 args, try archive.conf
if [[ $# -lt 2 ]]; then
    # Look for config file next to this script
    CONF_FILE="$(dirname "$0")/archive.conf"
    if [[ -f "$CONF_FILE" ]]; then
        # shellcheck disable=SC1090
        . "$CONF_FILE"
        if [[ -z "$SOURCE_DIR" || -z "$TARGET_DIR" ]]; then
            log_error "archive.conf is missing SOURCE_DIR and/or TARGET_DIR. Exiting."
            exit 1
        fi
    else
        log_error "No CLI arguments and archive.conf not found. Exiting."
        show_help
        exit 1
    fi
else
    # Use CLI arguments (override config)
    SOURCE_DIR="$1"
    TARGET_DIR="$2"
fi


#validate source directory
if [[ ! -d "$SOURCE_DIR" || ! -r "$SOURCE_DIR" ]]; then
  log_error "Source directory ($SOURCE_DIR) does not exist or is not readable. Exiting."
  exit 2
fi


# Generate timestamp (already present)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Ensure target directory exists or can be created
if ! mkdir -p "$TARGET_DIR"; then
  log_error "Target directory ($TARGET_DIR) does not exist or could not be created. Exiting."
  exit 3
fi


# Path for the archive file
ARCHIVE_PATH="$TARGET_DIR/backup_${TIMESTAMP}.tar.gz"

# --- exclusions via .bassignore ---
# Prefer a .bassignore inside the source; fall back to script directory
EXCLUDE_FILE=""
if [[ -f "$SOURCE_DIR/.bassignore" ]]; then
  EXCLUDE_FILE="$SOURCE_DIR/.bassignore"
elif [[ -f "$(dirname "$0")/.bassignore" ]]; then
  EXCLUDE_FILE="$(dirname "$0")/.bassignore"
fi

TAR_EXCLUDES=()
if [[ -n "$EXCLUDE_FILE" ]]; then
  log_info "Using exclude file: $EXCLUDE_FILE"
  # tar will read one pattern per line
  TAR_EXCLUDES+=( --exclude-from="$EXCLUDE_FILE" )
else
  log_info "No .bassignore found; including all files."
fi


log_info "Backing up from $SOURCE_DIR to $ARCHIVE_PATH."

# Confirmation message (already required by the spec)
log_info "Backing up from ${SOURCE_DIR} to ${ARCHIVE_PATH}."

# If dry-run, do not create the archive
if $DRY_RUN; then
  log_info "Dry-run enabled. Simulating backup."
  # Nothing else to do — exit successfully
  exit 0
fi


# Create compressed archive of EVERYTHING inside source
# -c = create, -z = gzip, -f = filename, -C = change dir before adding files
if tar -czf "$ARCHIVE_PATH" -C "$SOURCE_DIR" "${TAR_EXCLUDES[@]}" .; then
    log_info "Backup completed successfully: $ARCHIVE_PATH"
else
    log_error "Backup failed during compression."
    exit 4
fi



