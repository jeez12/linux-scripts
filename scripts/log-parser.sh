#!/bin/bash
# This script takes a log file and prints a summary report
LOG_FILE=$1
echo "=== Log Summary Report ==="
echo "Total lines: $(wc -l < $LOG_FILE)"
echo "Errors: $(grep -c ERROR $LOG_FILE)"
echo "Warnings: $(grep -c WARNING $LOG_FILE)"
echo "Infos: $(grep -c INFO $LOG_FILE)"
echo "=== Error Messages ==="
grep ERROR $LOG_FILE | awk '{print $4, $5, $6,$7}'
echo "First entry: $(head -1 $LOG_FILE | cut -d' ' -f1,2)"
echo "Last entry: $(tail -1 $LOG_FILE | cut -d' ' -f1,2)"

