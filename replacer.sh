#!/usr/bin/env bash

read -p "Enter path to the folder: " path < /dev/tty
read -p "Enter text to find: " text < /dev/tty
read -p "Enter text to replace with: " replace < /dev/tty

if [[ -z "$path" ]]; then
    path="$(pwd)"
fi

if [[ ! -d "$path" ]]; then
    echo "Error: directory '$path' not found!"
    exit 1
fi

if [[ -z "$text" ]]; then
    echo "Error: text no found!"
    exit 1
fi

echo ""
echo "Current folder: $path"
echo "Found: '$text'"
echo "Replace: '$replace'"
echo ""

files_changed=0
total_replacements=0

while IFS= read -r -d '' file; do
    [[ -f "$file" ]] || continue

    # Проверяем, есть ли искомый текст в файле
    if grep -q "$text" "$file" 2>/dev/null; then
        # Считаем количество замен
        count=$(grep -o "$text" "$file" 2>/dev/null | wc -l)

        # Делаем бэкап и заменяем
        sed -i.bak "s/$text/$replace/g" "$file"

        # Показываем прогресс
        echo " ${file##*/}: $count replaces"

        ((files_changed++))
        ((total_replacements += count))
    fi
done < <(find "$path" -type f -print0 2>/dev/null)
