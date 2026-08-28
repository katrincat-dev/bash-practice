#!/usr/bin/env bash

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

LOG_FILE="$HOME/user_manager.log"

# Функция для записи в лог
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}❌ Этот скрипт должен быть запущен от root!${NC}"
    echo "Используй: sudo ./user_manager.sh"
    exit 1
fi

# Проверка аргументов
COMMAND="$1"

if [[ -z "$COMMAND" ]]; then
    echo "Использование: $0 {add|del|list}"
    echo "  add   - создать нового пользователя"
    echo "  del   - удалить пользователя"
    echo "  list  - показать всех пользователей"
    exit 1
fi

echo -e "${YELLOW}👤 Управление пользователями${NC}"
echo "─────────────────────────────────"

case "$COMMAND" in
    add)
        echo "Команда: add"
        echo ""
        
        read -p "Введите имя пользователя: " username
        
        # Проверка, существует ли пользователь
        if id "$username" &>/dev/null; then
            echo -e "${RED}❌ Пользователь $username уже существует!${NC}"
            exit 1
        fi
        
        read -s -p "Введите пароль: " password
        echo
        read -s -p "Повторите пароль: " password2
        echo
        
        if [[ "$password" != "$password2" ]]; then
            echo -e "${RED}❌ Пароли не совпадают!${NC}"
            exit 1
        fi
        
        # Создаём пользователя
        useradd -m -s /bin/bash "$username"
        echo "$username:$password" | chpasswd
        
        # Добавляем в группу sudo
        usermod -aG sudo "$username"
        
        echo -e "${GREEN}✅ Пользователь $username создан${NC}"
        echo "   Домашняя папка: /home/$username"
        echo "   Группы: $(groups $username)"
        
        log "Пользователь $username создан"
        ;;
        
    del)
        echo "Команда: del"
        echo ""
        
        read -p "Введите имя пользователя для удаления: " username
        
        if ! id "$username" &>/dev/null; then
            echo -e "${RED}❌ Пользователь $username не найден!${NC}"
            exit 1
        fi
        
        read -p "Удалить домашнюю папку /home/$username? (y/n): " confirm
        
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            userdel -r "$username"
            echo -e "${GREEN}✅ Пользователь $username удалён вместе с домашней папкой${NC}"
        else
            userdel "$username"
            echo -e "${GREEN}✅ Пользователь $username удалён (домашняя папка сохранена)${NC}"
        fi
        
        log "Пользователь $username удалён"
        ;;
        
    list)
        echo "Команда: list"
        echo ""
        echo -e "${YELLOW}👤 Список пользователей:${NC}"
        echo "─────────────────────────────────"
        echo "Имя          UID   Домашняя папка"
        echo "─────────────────────────────────"
        
        awk -F: '$3 >= 1000 && $1 != "nobody" {printf "%-12s %-5s %s\n", $1, $3, $6}' /etc/passwd
        ;;
        
    *)
        echo -e "${RED}❌ Неизвестная команда: $COMMAND${NC}"
        echo "Используй: add, del или list"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Готово!${NC}"
