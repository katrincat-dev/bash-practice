#!/usr/bin/env bash

read -p "Enter path to the folder" path > /dev/tty

if [[ -z "$path" ]]; then
    path="$(pwd)"
fi

if [[ ! -d "$path" ]]; then
    echo "Error: folder not foune"
    exit 1
fi

find "$path" -type f -name "*.log" -mtime +7 -print0 | tar -czf archive_$(date +%Y-%m-%d).tar.gz --null -T -
find "$path" -type f -name "*.log" -mtime +7 -delete
mv archive_$(date +%Y-%m-%d).tar.gz ~/archives
find ~/archives -name "logs_*.tar.gz" -mtime +30 -delete
