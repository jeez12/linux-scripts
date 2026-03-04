# Linux Permissions & Processes

Notes from Day 2 — Week 1 — MLOps Roadmap  
Source: linuxjourney.com — Permissions + Processes chapters

---

## Permissions

Every file and directory in Linux has three permission groups:

| Group | Symbol | Meaning |
|-------|--------|---------|
| Owner | `u` | The user who created the file |
| Group | `g` | A group of users |
| Others | `o` | Everyone else |

Each group has three permission types:

| Permission | Symbol | Numeric Value |
|------------|--------|---------------|
| Read | `r` | 4 |
| Write | `w` | 2 |
| Execute | `x` | 1 |
| None | `-` | 0 |

### Reading Permission Strings

```
-rwxr-xr--
```

| Part | Meaning |
|------|---------|
| `-` | File type: `-` = file, `d` = directory |
| `rwx` | Owner: read + write + execute = 7 |
| `r-x` | Group: read + execute = 5 |
| `r--` | Others: read only = 4 |

### Common Permission Numbers

| Number | String | Use Case |
|--------|--------|----------|
| `755` | rwxr-xr-x | Standard for executable scripts |
| `644` | rw-r--r-- | Standard for config files |
| `600` | rw------- | Sensitive files — .env, private keys |
| `700` | rwx------ | Private executable scripts |
| `777` | rwxrwxrwx | Everyone full access — **never use in production** |

---

## chmod — Change Permissions

### Numeric Mode

```bash
chmod 755 script.sh       # standard script permissions
chmod 644 config.yaml     # read-only config for others
chmod 600 .env            # sensitive file — owner only
chmod 600 ~/.ssh/id_ed25519  # SSH private key — must be 600
```

### Symbolic Mode

```bash
chmod +x script.sh        # add execute for everyone
chmod u+x script.sh       # add execute for owner only
chmod go-w config.yaml    # remove write from group and others
chmod a-x file.txt        # remove execute from all
```

### Symbolic Reference

| Symbol | Meaning |
|--------|---------|
| `u` | user/owner |
| `g` | group |
| `o` | others |
| `a` | all (u+g+o) |
| `+` | add permission |
| `-` | remove permission |
| `=` | set exactly |

---

## chown — Change Ownership

```bash
chown ahmad:ahmad file.txt          # change owner and group
sudo chown ahmad:ahmad file.txt     # most chown needs sudo
sudo chown -R ahmad:ahmad folder/   # recursive — folder and all contents
```

### MLOps Use Case
Docker containers often create files as root. When your pipeline
script can't read a model output file, it's usually an ownership
problem. Fix with:

```bash
sudo chown -R ahmad:ahmad /path/to/output/
```

---

## sudo — Superuser Do

```bash
sudo command          # run command as root
sudo chmod 600 .env   # change permissions as root
sudo chown ...        # change ownership as root
```

**Rule:** Only use sudo when necessary. Never run your entire
pipeline or application as root.

---

## Processes

A process is any running program. Every process has a unique
**PID (Process ID)**.

### ps — Process Snapshot

```bash
ps aux                        # show all running processes
ps aux | grep python          # find all Python processes
ps aux | grep training.py     # check if training job is running
```

Output columns:

| Column | Meaning |
|--------|---------|
| `USER` | Who is running the process |
| `PID` | Process ID — needed for kill |
| `%CPU` | CPU usage percentage |
| `%MEM` | Memory usage percentage |
| `COMMAND` | The command that started it |

### top — Live Process Monitor

```bash
top         # open live process view
```

Inside top:
- Processes sorted by CPU usage by default
- Press `M` to sort by memory usage
- Press `q` to quit
- Press `k` then enter PID to kill a process

**MLOps use case:** Run `top` when a training job seems to be
consuming too many resources or when the server feels slow.

### kill — Terminate a Process

```bash
kill PID          # send termination signal — process can ignore
kill -9 PID       # force kill — process cannot ignore this
kill -15 PID      # graceful shutdown (default signal)
```

### MLOps Workflow: Kill a Hung Training Job

```bash
# Step 1 — find the process ID
ps aux | grep training.py

# Output example:
# ahmad  12345  99.0  45.0  python training.py

# Step 2 — force kill it
kill -9 12345
```

---

## Bash Syntax Reference

# Capture command output
VARIABLE=$(command)

# Check if directory exists
if [ -d "$dir" ]; then
  echo "exists"
fi

# Loop through list
for item in one two three; do
  echo "$item"
done

# Check if file exists
if [ -f "$file" ]; then
  echo "file found"
fi



## Job Control

Run long processes without keeping the terminal locked.

```bash
Ctrl+Z          # pause a running process — sends to background
fg              # bring paused process back to foreground
bg              # keep paused process running in background
jobs            # list all background jobs
nohup command & # run command that survives terminal close
```

### MLOps Use Case
Training jobs take hours. Instead of keeping a terminal open:

```bash
# Start training in background
python train.py &

# Check it's running
jobs

# Bring it back if needed
fg
```

---

## Key Rules

- SSH private key must always be `chmod 600` — SSH refuses to work otherwise
- Never use `chmod 777` in production — it gives everyone full access
- Always `sort` before `uniq`
- `ps aux` = snapshot, `top` = live view
- `kill -9` is the force kill — use when process is completely stuck
- Docker-created files are often owned by root — fix with `chown -R`
