#!/usr/bin/env bash

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="$HOME/cron_manager.log"
BACKUP_DIR="$HOME/.cron_backups"

# Создаём папку для бэкапов
mkdir -p "$BACKUP_DIR"

# Функция логирования
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Функция показа текущих задач
show_cron() {
    echo -e "${BLUE} Текущие задачи cron:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if crontab -l 2>/dev/null; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Всего задач: $(crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$' | wc -l)"
    else
        echo -e "${YELLOW} Нет задач cron${NC}"
    fi
}

# Функция бэкапа
backup_cron() {
    local backup_file="$BACKUP_DIR/cron_backup_$(date +%Y-%m-%d_%H-%M-%S).txt"
    if crontab -l 2>/dev/null > "$backup_file"; then
        echo -e "${GREEN} Бэкап создан: $backup_file${NC}"
        log "Backup created: $backup_file"
    else
        echo -e "${YELLOW} Нет задач для бэкапа${NC}"
    fi
}

# Функция добавления задачи
add_cron() {
    echo ""
    echo -e "${BLUE} Добавление задачи cron${NC}"
    
    read -p "Введите расписание (например: 0 2 * * *): " schedule
    read -p "Введите команду: " command
    
    if [[ -z "$schedule" || -z "$command" ]]; then
        echo -e "${RED} Расписание и команда обязательны!${NC}"
        return 1
    fi
    
    # Проверяем, существует ли уже такая задача
    if crontab -l 2>/dev/null | grep -F "$command" > /dev/null; then
        echo -e "${YELLOW} Такая задача уже существует!${NC}"
        return 1
    fi
    
    # Добавляем задачу
    (crontab -l 2>/dev/null; echo "$schedule $command") | crontab -
    echo -e "${GREEN} Задача добавлена: $schedule $command${NC}"
    log "Added cron job: $schedule $command"
}

# Функция удаления задачи
delete_cron() {
    echo ""
    echo -e "${BLUE}🗑️ Удаление задачи${NC}"
    
    # Показываем задачи с номерами
    echo "Текущие задачи:"
    crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$' | nl
    
    read -p "Введите номер задачи для удаления (или 0 для отмены): " num
    
    if [[ "$num" == "0" ]]; then
        echo "Отмена"
        return 0
    fi
    
    # Удаляем задачу по номеру
    crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$' | sed "${num}d" | crontab -
    echo -e "${GREEN} Задача удалена${NC}"
    log "Cron job deleted"
}

# Функция восстановления из бэкапа
restore_cron() {
    echo ""
    echo -e "${BLUE} Восстановление из бэкапа${NC}"
    
    # Показываем доступные бэкапы
    echo "Доступные бэкапы:"
    ls -1 "$BACKUP_DIR" | nl
    
    read -p "Введите номер бэкапа: " num
    backup_file=$(ls -1 "$BACKUP_DIR" | sed -n "${num}p")
    
    if [[ -z "$backup_file" ]]; then
        echo -e "${RED} Неверный номер!${NC}"
        return 1
    fi
    
    crontab "$BACKUP_DIR/$backup_file"
    echo -e "${GREEN} Восстановлено из: $backup_file${NC}"
    log "Restored from backup: $backup_file"
}

# --- ГЛАВНОЕ МЕНЮ ---
echo -e "${BLUE} Менеджер задач cron${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "========== CRON MANAGER STARTED =========="

while true; do
    echo ""
    echo "Выберите действие:"
    echo "  1. Показать задачи"
    echo "  2. Добавить задачу"
    echo "  3. Удалить задачу"
    echo "  4. Сделать бэкап"
    echo "  5. Восстановить из бэкапа"
    echo "  0. Выход"
    echo ""
    read -p "Ваш выбор: " choice
    
    case "$choice" in
        1) show_cron ;;
        2) add_cron ;;
        3) delete_cron ;;
        4) backup_cron ;;
        5) restore_cron ;;
        0)
            echo -e "${GREEN} До свидания!${NC}"
            log "========== CRON MANAGER EXITED =========="
            exit 0
            ;;
        *)
            echo -e "${RED} Неверный выбор!${NC}"
            ;;
    esac
done
