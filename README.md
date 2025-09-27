# AutoBASS – Automated Backup Script

AutoBASS is a Bash script (`archive.sh`) for creating compressed backups with logging, config file defaults, and file exclusion support.  
It was developed as part of the ISE 337 AutoBASS assignment.

---

## Features
- Timestamped `.tar.gz` backups
- Logs to both stdout/stderr and `archive.log` with timestamps
- Config file fallback (`archive.conf`) for default directories
- `.bassignore` file support for exclusions
- `--dry-run` option to simulate without writing an archive
- Help flag `-h` or `--help`

---

## Installation
Clone the repository and make the script executable:
git clone <your-repo-url>
cd autobass
chmod +x archive.sh

---

## Usage
Run with explicit arguments:
./archive.sh <source_dir> <target_dir>

Or use defaults from `archive.conf` if no CLI args are given:
./archive.sh

---

## Config File (archive.conf)
The script can read default directories from `archive.conf`:

SOURCE_DIR=/home/bader/mysource
TARGET_DIR=/home/bader/mybackup

CLI args will always override config file values.

---

## Exclusions (.bassignore)
You can exclude files or folders from being archived by listing patterns in `.bassignore`.

Example `.bassignore`:
node_modules/
*.log
*.tmp

- If `.bassignore` exists in the source directory, it will be used.  
- Otherwise, the script looks for `.bassignore` in the repo root.

---

## Options
- `-h`, `--help` → Show help message  
- `-d`, `--dry-run` → Simulate backup without creating archive  

---

## Examples

Run backup with CLI args:
./archive.sh ~/mysource ~/mybackup

Run with config file:
./archive.sh

Dry-run simulation:
./archive.sh -d ~/mysource ~/mybackup

Using help:
./archive.sh -h

---

## Logging
All runs append logs to:
archive.log

Example log entries:
INFO: [2025-09-26 23:38:48] archive script started.
INFO: [2025-09-26 23:38:48] Backup completed successfully: /home/bader/mybackup/backup_20250926_233848.tar.gz

---

## Versioning
- v1.0 – MVP release
  - timestamped `.tar.gz` backups  
  - stdout/stderr + archive.log logging  
  - config file fallback  
  - `.bassignore` exclusions  
  - `--dry-run` simulation  

---

## Author
Bader Alansari – ISE 337 AutoBASS Assignment

