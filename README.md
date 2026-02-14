# AutoBASS

Bash CLI tool for creating compressed, timestamped `.tar.gz` backups — with config-file defaults, pattern-based exclusions, and dry-run support.

---

## Why AutoBASS?

I kept running manual `tar` commands to back up project directories and forgetting flags, overwriting old copies, or missing files I meant to exclude. AutoBASS wraps that into a single repeatable command — with config defaults so it can run unattended via cron, `.bassignore` so I stop archiving `node_modules/`, and dry-run so I can verify before committing to disk.

## Quick Start

```bash
git clone https://github.com/xbadev/autobass.git
cd autobass
chmod +x archive.sh
```

```bash
# View usage instructions
./archive.sh --help

# Run with explicit paths
./archive.sh ~/mysource ~/mybackup

# Run with defaults from archive.conf
./archive.sh

# Simulate without writing anything
./archive.sh --dry-run ~/mysource ~/mybackup
```

## How It Works

[`archive.sh`](archive.sh) parses CLI arguments (or falls back to [`archive.conf`](archive.conf)), validates the source directory, loads exclusion patterns from [`.bassignore`](.bassignore), and compresses the source into a timestamped `.tar.gz` in the target directory. Every step is logged to both the terminal and `archive.log`.

```
CLI args or archive.conf → Validate source → Load .bassignore → tar -czf backup_TIMESTAMP.tar.gz → Log result
```

## Options

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show usage instructions |
| `-d`, `--dry-run` | Log what would happen without creating an archive |


## Configuration

[`archive.conf`](archive.conf) provides default paths when no CLI args are given:

```bash
SOURCE_DIR="/path/to/source"
TARGET_DIR="/path/to/backup"
```

CLI arguments always override config values.


## Exclusions

[`.bassignore`](.bassignore) works like `.gitignore` — one pattern per line, passed to `tar --exclude-from`:

```
*.tmp
*.log
node_modules/
.cache/
```

Lookup order: `.bassignore` in source directory → `.bassignore` in script directory → no exclusions.


## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success or dry-run completed |
| `1` | Invalid option or missing config |
| `2` | Source directory missing or unreadable |
| `3` | Target directory could not be created |
| `4` | Compression failed |


## Repo Structure

```
├── archive.sh        # Backup script
├── archive.conf      # Default source/target paths
├── .bassignore       # Exclusion patterns
├── .gitignore        # Git-tracked exclusions
└── LICENSE           # MIT
```

---

## Author

**Bader Alansari** — [@xbadev](https://github.com/xbadev)
