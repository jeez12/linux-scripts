# Linux Commands Reference

Personal reference for MLOps engineering work.
Built during Month 1 of MLOps training roadmap.

---

## Navigation

| Command | Description |
|---------|-------------|
| `pwd` | Print current directory |
| `ls` | List files in current directory |
| `ls -la` | List all files including hidden, with permissions and sizes |
| `cd ~` | Jump to home directory from anywhere |
| `cd ..` | Go up one directory level |
| `cd /path` | Navigate to specific path |
| `mkdir folder` | Create a directory |
| `mkdir -p a/b/c` | Create nested directories in one command |

---

## File Operations

| Command | Description |
|---------|-------------|
| `touch file.txt` | Create an empty file |
| `cp source dest` | Copy a file |
| `mv old new` | Rename or move a file |
| `rm file.txt` | Delete a file — no undo |
| `rm -r folder/` | Delete a folder and its contents |
| `cat file.txt` | Print file contents to terminal |

---

## Writing & Redirecting

| Command | Description |
|---------|-------------|
| `echo "text" > file.txt` | Write text to file — overwrites |
| `echo "text" >> file.txt` | Append text to file — keeps existing content |

---

## Reading Files

| Command | Description |
|---------|-------------|
| `head -n 5 file.txt` | Show first 5 lines |
| `head -n 1 file.txt` | Show only the header row |
| `tail -n 5 file.txt` | Show last 5 lines |
| `tail -f file.txt` | Follow file live as it updates — Ctrl+C to stop |

---

## Text Processing

| Command | Description |
|---------|-------------|
| `wc -l file.txt` | Count lines in a file |
| `wc -w file.txt` | Count words in a file |
| `sort file.txt` | Sort lines alphabetically A→Z |
| `sort -r file.txt` | Sort lines Z→A |
| `sort -n file.txt` | Sort numerically |
| `sort -rn file.txt` | Sort numerically highest first |
| `uniq` | Remove adjacent duplicate lines — always sort first |
| `uniq -c` | Count occurrences of each unique line |
| `tr 'a-z' 'A-Z'` | Convert lowercase to uppercase |
| `tr ':' ','` | Replace one character with another |

---

## Search & Pipes

| Command | Description |
|---------|-------------|
| `grep "word" file.txt` | Find lines containing a word |
| `grep "word" file.txt \| wc -l` | Count lines matching a word |
| `\|` | Pipe — sends output of one command into the next |

---

## Power Combinations
```bash
# Find errors and count them
grep "ERROR" app.log | wc -l

# Deduplicate a list
sort list.txt | uniq

# Frequency count — most common entries first
sort list.txt | uniq -c | sort -rn

# Count Python files in a directory
ls -la | grep ".py" | wc -l

# Watch live log for errors only
tail -f app.log | grep "ERROR"
```

---

## Vim

| Command | Description |
|---------|-------------|
| `vim file.txt` | Open file in vim |
| `i` | Enter insert mode — start typing |
| `Esc` | Return to normal mode |
| `:w` | Save file |
| `:q` | Quit vim |
| `:wq` | Save and quit |
| `:q!` | Quit without saving — force exit |

---

## Key Rules

- `>` overwrites. `>>` appends. Never confuse them.
- `rm` has no undo. Always double check before deleting.
- `sort` before `uniq` — always. uniq only removes adjacent duplicates.
- `tr` reads from stdin — always pipe into it with `cat file | tr`.
- `tail -f` is your best friend for watching live logs in production.