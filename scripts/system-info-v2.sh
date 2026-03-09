#!/bin/bash

echo "=========================================="
echo "SYSTEM INFO - $(date)"
echo "=========================================="

#HOSTNAME
echo ""
echo "HOSTNAME:$(hostname)"

#OS INFO
echo ""
echo "OS INFO:$(uname -o) - $(uname -r)"

#CPU INFO
echo ""
echo "CPU:$(nproc) cores"

#MEMORY INFO
echo ""
echo "MEMORY:"
free  -h | awk 'NR==2 {print "Total: "$2" Used: "$3" Free:"$4}'

#DISK INFO 
echo ""
echo "DISK USAGE:"
df -h / | awk 'NR==2 {print "Total: "$2" Used: "$3" Free: "$4" Usage: "$5}'

#RUNNING PROCESS
echo ""
echo "RUNNING PROCESSES:"
echo "$(ps aux | wc -l) processes currently running"


#Check critical directories
echo ""
echo "DIRECTORY CHECK:"
for dir in ~/linux-scripts ~/ml-learning-journey; do
    if [ -d "$dir" ]; then
        echo "✓ $dir exists ✓"
    else
        echo "✗ $dir NOT FOUND ✗!!!!"
    fi
done

echo ""
echo "=============================="
echo " Check complete - $(date +%H:%M:%S)"
echo "=============================="