  GNU nano 6.2                                                                                      ping_sites.sh
#!/usr/bin/env bash

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
LOG_FILE="$HOME/ping.log"

# Список сайтов по умолчанию
DEFAULT_SITES=("google.com" "github.com" "yandex.ru" "stackoverflow.com")

# Если аргументов нет — используем DEFAULT_SITES
if [[ $# -eq 0 ]]; then
    SITES=("${DEFAULT_SITES[@]}")
else
    SITES=("$@")
fi

# Функция проверки одного сайта
check_site() {
    local site="$1"

    # Делаем ping
    if ping -c 1 -W 2 "$site" > /dev/null 2>&1; then
        # Пинг работает, теперь проверим скорость через curl (если это http(s))
        if [[ "$site" =~ ^https?:// ]]; then
            time=$(curl -s -o /dev/null -w "%{time_total}" "$site" 2>/dev/null)
            time_ms=$(echo "$time * 1000 / 1" | bc 2>/dev/null)
            if [[ -z "$time_ms" ]]; then
                time_ms=0
            fi
        else
            # Для не-http сайтов просто отмечаем как доступный
            time_ms=0
        fi

        # Определяем цвет в зависимости от скорости
        if [[ $time_ms -gt 500 ]]; then
            color="$YELLOW"
            status="доступен (${time_ms}ms)Медленно!"
        else
            color="$GREEN"
            status="доступен (${time_ms}ms)"
        fi

        echo -e "${color}${site} — ${status}${NC}"
                echo "$(date) - $site - OK (${time_ms}ms)" >> "$LOG_FILE"
    else
        echo -e "${RED} ${site} — НЕДОСТУПЕН!${NC}"
        echo "$(date) - $site - FAILED" >> "$LOG_FILE"
    fi
}

echo "Проверка доступности сайтов..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Запускаем проверки параллельно
for site in "${SITES[@]}"; do
    check_site "$site" &
done

# Ждём завершения всех фоновых процессов
wait

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Лог сохранён: $LOG_FILE"
