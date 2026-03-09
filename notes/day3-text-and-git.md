# Linux for MLOps
### Text Processing, Shell Scripting & Git Branching
*Study Notes — Ahmad*

---

## Table of Contents
1. [grep — Search for Patterns](#1-grep--search-for-patterns)
2. [awk — Field-Based Line Processing](#2-awk--field-based-line-processing)
3. [sed — Stream Editor (Find & Replace)](#3-sed--stream-editor-find--replace)
4. [cut — Slice Out Specific Fields](#4-cut--slice-out-specific-fields)
5. [Pipes — Chaining Commands Together](#5-pipes--chaining-commands-together)
6. [log-parser.sh — Built from Scratch](#6-log-parsersh--built-from-scratch)
7. [Git Branching — Create, Switch, Merge](#7-git-branching--create-switch-merge)
8. [Merge Conflicts — Resolve Manually](#8-merge-conflicts--resolve-manually)
9. [Quick Reference Cheat Sheet](#quick-reference-cheat-sheet)

---

## 1. `grep` — Search for Patterns

`grep` (Global Regular Expression Print) scans each line of a file (or stdin) and prints lines that match a pattern. It is your go-to tool for digging through logs, config files, and any text data.

### Basic Syntax

```bash
grep [OPTIONS] PATTERN [FILE...]
```

### Core Flags

| Flag | What it does |
|------|-------------|
| `-c` | Print a **count** of matching lines, not the lines themselves |
| `-i` | **Case-insensitive** match (`Error` and `error` treated the same) |
| `-n` | Prefix each matching line with its **line number** |
| `-v` | **Invert** the match — print lines that do NOT match |
| `-E` | Enable **Extended Regular Expressions** (same as `egrep`) |

### Examples

```bash
# Count how many lines contain 'ERROR'
grep -c 'ERROR' app.log

# Case-insensitive search
grep -i 'warning' app.log

# Show line numbers
grep -n 'timeout' app.log

# Show lines that are NOT blank
grep -v '^$' config.txt

# Extended regex: match ERROR or WARN
grep -E 'ERROR|WARN' app.log

# Combine flags: count case-insensitive matches
grep -ci 'error' app.log
```

### Useful Extras

- `-r` — recursive search through all files in a directory
- `-l` — list only file names that contain a match
- `-A N` / `-B N` — show N lines **A**fter / **B**efore the match (context)

> 💡 **MLOps tip:** You will grep through model training logs constantly. Master `-E` so you can match multiple patterns (e.g., `'epoch|loss|accuracy'`) in one command.

---

## 2. `awk` — Field-Based Line Processing

`awk` is a mini programming language designed to process columnar text. Every line it reads is automatically split into fields (`$1`, `$2`, … `$NF`). Think of it as a lightweight SQL for the terminal.

### Mental Model

```
awk 'CONDITION { ACTION }' file

$0  = entire current line
$1  = first field    $2 = second field    $NF = last field
NR  = current line number    FS = field separator (default: whitespace)
```

### Common Patterns

```bash
# Print specific columns from a CSV
awk -F',' '{print $1, $3}' data.csv

# Print lines where column 2 is greater than 100
awk '$2 > 100' results.txt

# Sum a column
awk '{sum += $3} END {print "Total:", sum}' metrics.txt

# Print line number alongside the line
awk '{print NR": "$0}' app.log

# Use : as field separator (e.g., /etc/passwd)
awk -F':' '{print $1, $6}' /etc/passwd
```

### BEGIN and END Blocks

`awk` supports optional `BEGIN` (runs before any lines) and `END` (runs after all lines) blocks:

```bash
awk 'BEGIN { print "--- Start ---" }
     { print $1 }
     END { print "--- Done ---" }' file.txt
```

> 💡 **MLOps tip:** Use `awk` to pull epoch numbers, loss values, or timestamps out of training logs. Pair with `sort` and `uniq` for quick statistics without Python.

---

## 3. `sed` — Stream Editor (Find & Replace)

`sed` reads a file line by line, applies transformations, and writes to stdout. The most common use case is substitution, but it can also delete lines, insert text, and more.

### Substitution Syntax

```bash
sed 's/PATTERN/REPLACEMENT/FLAGS' file

# Flags:
#   (none)  = replace only the first match per line
#   g       = replace ALL matches per line (global)
#   i       = case-insensitive match
#   2       = replace only the 2nd occurrence
```

### Common Examples

```bash
# Replace 'foo' with 'bar' (first occurrence per line)
sed 's/foo/bar/' file.txt

# Replace ALL occurrences on every line
sed 's/foo/bar/g' file.txt

# Edit file in-place (overwrites the original)
sed -i 's/localhost/0.0.0.0/g' config.yaml

# In-place with automatic backup (.bak file created)
sed -i.bak 's/localhost/0.0.0.0/g' config.yaml

# Delete lines matching a pattern (remove comment lines)
sed '/^#/d' config.txt

# Delete blank lines
sed '/^$/d' file.txt

# Print only lines 5 through 10
sed -n '5,10p' app.log
```

> 💡 **Warning:** `sed -i` is powerful but destructive. Always use `sed -i.bak` to auto-create a backup before editing config files in place.

---

## 4. `cut` — Slice Out Specific Fields

`cut` extracts sections from each line based on a delimiter or character position. It is simpler than `awk` for straightforward column extraction.

### Syntax

```bash
cut -d DELIMITER -f FIELD_LIST file
cut -c CHARACTER_RANGE file
```

### Examples

```bash
# Extract the first and third CSV columns
cut -d',' -f1,3 data.csv

# Extract a range of columns (2 through 4)
cut -d',' -f2-4 data.csv

# Extract characters 1–8 from each line
cut -c1-8 timestamps.log

# Get just the username from /etc/passwd (colon-delimited)
cut -d':' -f1 /etc/passwd

# Get running process names only
ps aux | cut -c65-
```

### `cut` vs `awk` — When to Use Which

| Tool | Use when… |
|------|-----------|
| `cut` | Simple column extraction with a fixed delimiter. Faster, less syntax. |
| `awk` | Any logic, math, conditionals, or multiple operations on fields. |

---

## 5. Pipes — Chaining Commands Together

The pipe operator `|` passes the stdout of one command directly into the stdin of the next. This is the Unix philosophy: build complex behaviour from small, focused tools.

### How a Pipe Works

```
command1 | command2 | command3

stdout of command1  →  stdin of command2  →  stdin of command3
```

### Practical Pipeline Examples

```bash
# Count how many lines contain ERROR
cat app.log | grep 'ERROR' | wc -l

# Top 5 most frequent IP addresses in an access log
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -5

# Extract HTTP status codes and count each
grep '"GET' access.log | cut -d' ' -f9 | sort | uniq -c | sort -rn

# Find the 3 largest files in current directory
du -sh * | sort -rh | head -3

# Live-filter a log as it streams
tail -f app.log | grep --line-buffered 'ERROR'
```

### Redirection vs Pipes

| Operator | What it does |
|----------|-------------|
| `\|` | Connects two commands: `cmd1 \| cmd2` |
| `>` | Redirect stdout to a file (overwrites): `cmd > file.txt` |
| `>>` | Append stdout to a file: `cmd >> file.txt` |
| `2>` | Redirect stderr to a file: `cmd 2> errors.txt` |
| `2>&1` | Merge stderr into stdout: `cmd > out.txt 2>&1` |
| `tee` | Write to file AND pass stdout onward: `cmd \| tee file.txt \| next` |

> 💡 **MLOps tip:** You will chain `grep + awk + sort + uniq` constantly when doing post-training log analysis or debugging data ingestion issues.

---

## 6. `log-parser.sh` — Built from Scratch

This script demonstrates how to combine `grep`, `awk`, `cut`, and pipes to produce a readable report from raw log files.

### The Script

```bash
#!/bin/bash
# log-parser.sh — summarise an application log file
# Usage: ./log-parser.sh <logfile>

set -euo pipefail            # exit on error, unset vars, pipe failures

LOG_FILE="${1:-app.log}"    # use first argument or default to app.log

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: file '$LOG_FILE' not found" >&2
    exit 1
fi

echo "============================"
echo " Log Report: $LOG_FILE"
echo "============================"

echo ""
echo "[1] Total lines:"
wc -l < "$LOG_FILE"

echo ""
echo "[2] ERROR count:"
grep -c 'ERROR' "$LOG_FILE" || echo "0"

echo ""
echo "[3] WARN count:"
grep -c 'WARN' "$LOG_FILE" || echo "0"

echo ""
echo "[4] Last 5 ERROR lines:"
grep 'ERROR' "$LOG_FILE" | tail -5

echo ""
echo "[5] Unique error types:"
grep 'ERROR' "$LOG_FILE" | awk '{print $4}' | sort | uniq -c | sort -rn

echo ""
echo "[6] Timestamps of first and last entry:"
head -1 "$LOG_FILE" | cut -d' ' -f1,2
tail -1 "$LOG_FILE" | cut -d' ' -f1,2
```

### Key Patterns Used

| Pattern | Why it matters |
|---------|---------------|
| `set -euo pipefail` | Safe scripting defaults — always include this |
| `${1:-app.log}` | Parameter with a default value |
| `[[ ! -f ... ]]` | Check if a file exists before using it |
| `grep ... \|\| echo '0'` | Gracefully handle zero matches (`grep` exits 1 when nothing found) |

---

## 7. Git Branching — Create, Switch, Merge

Branches let you develop features or experiments in isolation without touching `main`. In MLOps you will create branches for each experiment, new pipeline feature, or infrastructure change.

### Core Commands

| Command | What it does |
|---------|-------------|
| `git branch` | List all local branches (`*` marks current) |
| `git branch <name>` | Create a new branch (does NOT switch to it) |
| `git switch <name>` | Switch to an existing branch |
| `git switch -c <name>` | Create AND switch to a new branch in one step |
| `git merge <name>` | Merge named branch INTO your current branch |
| `git branch -d <name>` | Delete a branch (safe — blocks if unmerged) |
| `git branch -D <name>` | Force-delete a branch (unmerged commits lost) |

### Typical Feature Branch Workflow

```bash
# 1. Start from main, ensure it's up to date
git switch main
git pull origin main

# 2. Create and switch to your feature branch
git switch -c feature/add-mlflow-tracking

# 3. Work, stage, commit
# ... edit files ...
git add .
git commit -m 'feat: add MLflow experiment tracking'

# 4. Push branch to GitHub
git push -u origin feature/add-mlflow-tracking

# 5. When ready to merge back to main
git switch main
git merge feature/add-mlflow-tracking

# 6. Clean up
git branch -d feature/add-mlflow-tracking
git push origin --delete feature/add-mlflow-tracking
```

### Viewing Branch State

```bash
git log --oneline --graph --all   # visual branch tree
git diff main..feature/my-branch  # see what changed
git branch -v                     # last commit on each branch
```

> 💡 **Naming convention for MLOps:** Use prefixes like `feat/`, `fix/`, `experiment/`, `infra/` so branches self-document their purpose in `git log`.

---

## 8. Merge Conflicts — Resolve Manually

A conflict happens when the same part of a file was changed differently on two branches. Git cannot automatically decide which version is correct, so it asks **you** to resolve it.

### What a Conflict Looks Like in a File

```
<<<<<<< HEAD                         ← your current branch (e.g. main)
learning_rate = 0.001
=======                              ← dividing line
learning_rate = 0.01
>>>>>>> feature/tune-lr              ← incoming branch being merged
```

### Step-by-Step Resolution

```bash
# Step 1: trigger the merge (this is where the conflict appears)
git switch main
git merge feature/tune-lr
# → CONFLICT (content): Merge conflict in config.py

# Step 2: see which files are conflicted
git status
# → both modified: config.py

# Step 3: open the file and edit it manually
# Remove ALL marker lines and keep the version you want:
#   <<<<<<< HEAD
#   =======
#   >>>>>>> feature/tune-lr
# Leave only the final, correct code.

# Step 4: stage the resolved file
git add config.py

# Step 5: complete the merge
git commit -m 'merge: resolve learning_rate conflict'
```

### Aborting a Merge

```bash
# If things go wrong and you want to start over:
git merge --abort
```

### Resolving in VS Code

- VS Code highlights conflicts with labels: **Current Change** (your branch) and **Incoming Change** (branch being merged).
- Click **Accept Current Change**, **Accept Incoming Change**, or **Accept Both Changes** above the conflict block.
- After accepting, the file is cleaned automatically. Then run `git add` and `git commit` as normal.

> 💡 **MLOps reality check:** Conflicts often arise in `requirements.txt`, config YAML files, and Dockerfiles. Practice resolving them — it is a daily reality when collaborating on pipelines.

---

## Quick Reference Cheat Sheet

### grep
```bash
grep -c 'ERROR' file         # count matches
grep -i 'warn' file          # case-insensitive
grep -n 'fail' file          # show line numbers
grep -v '^#' file            # exclude comment lines
grep -E 'ERROR|WARN' file    # multiple patterns (extended regex)
```

### awk
```bash
awk '{print $1}' file                 # print column 1
awk -F',' '{print $2}' file           # comma-delimited
awk '$3 > 50 {print}' file            # conditional filter
awk '{sum+=$2} END{print sum}' file   # sum a column
```

### sed
```bash
sed 's/old/new/' file           # replace first match per line
sed 's/old/new/g' file          # replace all matches
sed -i.bak 's/old/new/g' file   # in-place with backup
sed '/pattern/d' file           # delete matching lines
```

### cut
```bash
cut -d',' -f1,3 file          # columns 1 and 3, CSV
cut -d':' -f1 /etc/passwd     # first field, colon-separated
cut -c1-10 file               # first 10 characters per line
```

### Git Branching
```bash
git switch -c feat/name           # create & switch to branch
git merge feat/name               # merge into current branch
git branch -d feat/name           # delete branch
git log --oneline --graph --all   # visualise full branch history
```

---

*— End of Notes —*
