!/bin/bash

# AutoBASS - archive.sh
#
# Creates a timestamped compressed backup (.tar.gz) of a source directory.
#
# Supports:
# - CLI usage: ./archive.sh <source_dir> <target_dir>
# - Config fallback: archive.conf (SOURCE_DIR, TARGET_DIR) when args are not provided
# - Exclusions: .bassignore (checked in source dir first, then script dir)
# - Logging: stdout/stderr + archive.log (saved next to this script)
# - Dry-run: --dry-run / -d (logs what would happen, does not create an archive)
# - Help: --help / -h

LOG_FILE="$(dirname "$0")/archive.log"

timestamp() { date "+%Y-%m-%d %H:%M:%S"; }

log_info() {
  local msg="INFO: [$(timestamp)] $*"
  echo "$msg" | tee -a "$LOG_FILE"
}

log_error() {
  local msg="ERROR: [$(timestamp)] $*"
  echo "$msg" | tee -a "$LOG_FILE" >&2
}

show_help() {
  echo "usage: $0 <source_dir> <target_dir>"
  echo "creates a timestamped compressed backup (.tar.gz) in <target_dir> from <source_dir>."
  echo ""
  echo "Options:"
  echo "  -d, --dry-run   Simulate backup without creating an archive"
  echo "  -h, --help      Show this help message"
}

DRY_RUN=false
POSITIONAL=()

# Parse options while preserving positional args (source/target)
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
    --)
      shift
      break
      ;;
    -*)
      log_error "Unknown option: $1"
      show_help
      exit 1
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

# Restore positional args only (source/target)
set -- "${POSITIONAL[@]}"

log_info "archive script started."

# If fewer than 2 args, try archive.conf (SOURCE_DIR, TARGET_DIR)
if [[ $# -lt 2 ]]; then
  CONF_FILE="$(dirname "$0")/archive.conf"
  if [[ -f "$CONF_FILE" ]]; then
    # shellcheck disable=SC1090
    . "$CONF_FILE"
    if [[ -z "${SOURCE_DIR:-}" || -z "${TARGET_DIR:-}" ]]; then
      log_error "archive.conf is missing SOURCE_DIR and/or TARGET_DIR. Exiting."
      exit 1
    fi
  else
    log_error "No CLI arguments and archive.conf not found. Exiting."
    show_help
    exit 1
  fi
else
  SOURCE_DIR="$1"
  TARGET_DIR="$2"
fi

# Validate source directory
if [[ ! -d "$SOURCE_DIR" || ! -r "$SOURCE_DIR" ]]; then
  log_error "Source directory ($SOURCE_DIR) does not exist or is not readable. Exiting."
  exit 2
fi

# Ensure target directory exists or can be created
if ! mkdir -p "$TARGET_DIR"; then
  log_error "Target directory ($TARGET_DIR) does not exist or could not be created. Exiting."
  exit 3
fi

# Timestamped archive name
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
ARCHIVE_PATH="$TARGET_DIR/backup_${TIMESTAMP}.tar.gz"

# Exclusions via .bassignore (prefer source dir, else script dir)
EXCLUDE_FILE=""
if [[ -f "$SOURCE_DIR/.bassignore" ]]; then
  EXCLUDE_FILE="$SOURCE_DIR/.bassignore"
elif [[ -f "$(dirname "$0")/.bassignore" ]]; then
  EXCLUDE_FILE="$(dirname "$0")/.bassignore"
fi

TAR_EXCLUDES=()
if [[ -n "$EXCLUDE_FILE" ]]; then
  log_info "Using exclude file: $EXCLUDE_FILE"
  TAR_EXCLUDES+=( --exclude-from="$EXCLUDE_FILE" )
else
  log_info "No .bassignore found; including all files."
fi

log_info "Backing up from $SOURCE_DIR to $ARCHIVE_PATH."

# If dry-run, do not create the archive
if $DRY_RUN; then
  log_info "Dry-run enabled. No archive will be created."
  exit 0
fi

# Create compressed archive of everything inside SOURCE_DIR
# -c create, -z gzip, -f output file, -C change directory (so paths inside archive are clean)
if tar -czf "$ARCHIVE_PATH" -C "$SOURCE_DIR" "${TAR_EXCLUDES[@]}" .; then
  log_info "Backup completed successfully: $ARCHIVE_PATH"
else
  log_error "Backup failed during compression."
  exit 4
fi
