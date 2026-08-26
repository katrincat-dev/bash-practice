#!/usr/bin/env bash

read -p "Путь к папке, которую архивируем?" way < /dev/tty

if [[ -z "$way" ]]; then
    way="$(pwd)"
fi

if [[ ! -d "$way" ]]; then
    echo "Ошибка: папка '$way' не найдена!"
    exit 1
fi

echo "Организую: $way"

mkdir -p "$way"/{images,documents,archives,other}

images=0
documents=0
archives=0
other=0

for file in "$way"/*; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        extension="${filename##*.}"

        case "$extension" in
            jpg|jpeg|png|gif|bmp|svg)
                mv "$file" "$way/images/"
                ((images++))
                ;;
            pdf|doc|docx|txt|md)
                mv "$file" "$way/documents/"
                ((documents++))
                ;;
            zip|tar|gz|rar)
                mv "$file" "$way/archives/"
                ((archives++))
                ;;
            *)
                mv "$file" "$way/other/"
                ((other++))
                ;;
        esac
    fi
done

echo ""
echo "Перемещено:"
echo "images: $images файлов"
echo "documents: $documents файлов"
echo "archives: $archives файлов"
echo "other: $other файлов"
