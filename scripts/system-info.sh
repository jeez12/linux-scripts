#!/bin/bash

# system-info.sh
# Shows system resources before running MLOPS workloads
# Usage: ./scripts/system-info.sh

echo "=========================="
echo " SYSTEM INFO - $(date)"
echo "=========================="

# Hostname
echo ""
echo "HOSTNAME: $(hostname)"

# OS info
echo ""
echo "OS: $(uname -o) - $(uname -r)"

# CPU
echo ""
echo "CPU:"
echo " $(nproc) cores"

# Memory
echo ""
echo "MEMORY:"
free -h | awk 'NR==2 {print "  Total: "$2" Used: "$3" Free: "$4}'

# Disk
echo ""
echo "DISK USAGE:"
df -h / | awk 'NR==2 {print " Total: "$2" Used: "$3" Free: "$4" Usage: "$5}'

# Running processes
echo ""
echo "RUNNING PROCESSES:"
echo " $(ps aux | wc -l) processes currently running"

# Check critical directories
echo ""
echo "DIRECTORY CHECK:"
for dir in ~/linux-scripts ~/ml-learning-journey; do
  if [ -d "$dir" ]; then
    echo "  ✓ $dir exists"
  else
    echo "  ✗ $dir NOT FOUND"
  fi
done

echo ""
echo "=============================="
echo " Check complete - $(date +%H:%M:%S)"
echo "=============================="