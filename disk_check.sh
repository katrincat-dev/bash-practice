#!/usr/bin/env bash

read -p "Какой раздел смотрим?" partition < /dev/tty
read -p "Какой порог занятой памяти?" max_memory < /dev/tty

if [[ ! -d "$partition" ]]; then
    echo "Ошибка: раздел '$partition' не найден!"
    exit 1
fi

if [[ -z "$max_memory" ]]; then
    max_memory=80
fi

if [[ -z "$partition" ]]; then
    partition="$(pwd)"
fi

percent=$(df -h "$partition" | awk 'NR==2 {print $5}' | sed 's/%//')
echo "Процент занятого места: $percent"
top=$(du -h "$partition"/* --max-depth=0 2>/dev/null | sort -rh | head -5)

if [[ "$percent" -gt "$max_memory" ]]; then
    echo "Процент памяти раздела $partition больше чем предельно допустимое значение $max_memory"
    logger "WARNING: Disk usage on / is ${percent}%"
    echo "5 самых больших папок в $partition : $top"
else
    echo "Все в порядке"
fi
