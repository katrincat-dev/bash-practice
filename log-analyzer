#!/usr/bin/env bash

read -p "Enter path to the log-file " file < /dev/tty

if [[ -z "$file" ]]; then
    file="/var/log/syslog"
fi

if [[ ! -f "$file" ]]; then
    echo "Ошибка: файл '$file' не найден!"
    exit 1
fi
echo "═══════════════════════════════════════════════════════════"
echo "Анализ лог-файла: $file"
echo "═══════════════════════════════════════════════════════════"

total_lines=$(wc -l < "$file")
echo "Total quality of lines: $total_lines"
errors=$(grep -c "ERROR" "$file")
warnings=$(grep -c "WARNING" "$file")
info=$(grep -c "INFO" "$file")
debug=$(grep -c "DEBUG" "$file")
echo "Final report. Quantity of errors: $errors"
echo "Warnings: $warnings"
echo "Info: $info"
echo "Debug: $debug"
echo "═══════════════════════════════════════════════════════════"
top=$(grep "ERROR" "$file" | sort | uniq -c | sort -nr | head -5)
if [[ -z "$top" ]]; then
    echo "No errors"
else
    echo "Top-5 most common errors: $top"
fi

echo "═══════════════════════════════════════════════════════════"
ip_list=$(grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}" "$file" | sort | uniq -c | sort -nr | head -5)
echo "Ip-addresses: "
echo "═══════════════════════════════════════════════════════════"
if [[ -n "$ip_list" ]]; then
    echo "$ip_list" | while read count ip; do
        printf "   %3d  %s\n" "$count" "$ip"
    done
else
    echo "   IP-адреса не найдены"
fi

echo ""
