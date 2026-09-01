#!/usr/bin/env bash

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="$HOME/process_monitor.log"

# Функция логирования
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Функция завершения
cleanup() {
    echo -e "\n${YELLOW}⏹️  Останавливаю мониторинг...${NC}"
    log "Monitoring stopped"
    exit 0
}
trap cleanup SIGINT SIGTERM

# Проверка аргументов
PROCESS_NAME="$1"

if [[ -z "$PROCESS_NAME" ]]; then
    echo "Использование: $0 <имя_процесса>"
    echo "Пример: $0 nginx"
    echo ""
    echo "Или введи имя процесса:"
    read -p "Имя процесса: " PROCESS_NAME
fi

if [[ -z "$PROCESS_NAME" ]]; then
    echo -e "${RED}❌ Имя процесса не указано!${NC}"
    exit 1
fi

echo -e "${BLUE}📊 Мониторинг процесса: $PROCESS_NAME${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "Started monitoring: $PROCESS_NAME"

# Функция проверки процесса
check_process() {
    echo -e "${BLUE}📊 Проверка: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    
    # Проверяем, запущен ли процесс
    if pgrep -x "$PROCESS_NAME" > /dev/null; then
        # Процесс запущен — показываем информацию
        echo -e "${GREEN}✅ Процесс '$PROCESS_NAME' запущен${NC}"
        
        # Получаем PID
        PID=$(pgrep -x "$PROCESS_NAME" | head -1)
        echo "   PID: $PID"
        
        # Информация о процессе
        ps -p "$PID" -o %cpu,%mem,etime,cmd 2>/dev/null | tail -1 | while read cpu mem time cmd; do
            echo "   CPU: $cpu%"
            echo "   Memory: $mem%"
            echo "   Время работы: $time"
        done
        echo ""
        
        log "Process $PROCESS_NAME is running (PID: $PID)"
    else
        # Процесс НЕ запущен
        echo -e "${RED}❌ Процесс '$PROCESS_NAME' НЕ запущен!${NC}"
        log "WARNING: Process $PROCESS_NAME is NOT running"
        
        # Пытаемся перезапустить
        echo "🔄 Попытка перезапуска..."
        if systemctl start "$PROCESS_NAME" 2>/dev/null; then
            echo -e "${GREEN}✅ Перезапущен через systemctl${NC}"
            log "Process $PROCESS_NAME restarted via systemctl"
        elif command -v "$PROCESS_NAME" > /dev/null; then
            "$PROCESS_NAME" &
            echo -e "${GREEN}✅ Перезапущен напрямую (PID: $!)${NC}"
            log "Process $PROCESS_NAME restarted directly (PID: $!)"
        else
            echo -e "${RED}❌ Не удалось перезапустить!${NC}"
            log "ERROR: Failed to restart $PROCESS_NAME"
        fi
    fi
    
    # --- ТОП-5 процессов по CPU ---
    echo ""
    echo -e "${BLUE}📊 ТОП-5 процессов по CPU:${NC}"
    ps aux --sort=-%cpu 2>/dev/null | head -6 | tail -5 | while read line; do
        echo "  $line"
    done
    
    # --- ТОП-5 процессов по памяти ---
    echo ""
    echo -e "${BLUE}📊 ТОП-5 процессов по памяти:${NC}"
    ps aux --sort=-%mem 2>/dev/null | head -6 | tail -5 | while read line; do
        echo "  $line"
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Бесконечный цикл мониторинга
while true; do
    check_process
    echo "🔄 Следующая проверка через 30 секунд (Ctrl+C для выхода)"
    sleep 30
done
