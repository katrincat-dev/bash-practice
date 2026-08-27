#!/usr/bin/env bash

# Цвета
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_NAME="$1"

if [[ -z "$PROJECT_NAME" ]]; then
    read -p "Enter project's name: " PROJECT_NAME < /dev/tty
fi

if [[ -z "$PROJECT_NAME" ]]; then
    echo "Error: project name cannot be simple!"
    exit 1
fi

PROJECT_DIR="$HOME/projects/$PROJECT_NAME"

if [[ -d "$PROJECT_DIR" ]]; then
    echo "Error: project '$PROJECT_NAME' already existing!"
    exit 1
fi

echo -e "${BLUE} Creating folder: $PROJECT_NAME${NC}"
echo "Folder: $PROJECT_DIR"
echo ""

# --- Создаём структуру ---
mkdir -p "$PROJECT_DIR"/{src,logs,config,backups}
echo -e "${GREEN}Folder structure has been created${NC}"

# --- Создаём README.md ---
cat > "$PROJECT_DIR/README.md" << EOF
# Проект: $PROJECT_NAME

- Date: $(date '+%Y-%m-%d %H:%M:%S')
- Author: $(whoami)
- Description: (добавьте описание проекта)

## Структура
- \`src/\` — source code
- \`logs/\` — application logs
- \`config/\` — config files
- \`backups/\` — backups
EOF
# --- Создаём .env.example ---
cat > "$PROJECT_DIR/.env.example" << EOF
# Переменные окружения для проекта $PROJECT_NAME
# Скопируйте этот файл в .env и заполните значения

DB_HOST=localhost
DB_PORT=5432
DB_USER=user
DB_PASSWORD=password
DB_NAME=$PROJECT_NAME
LOG_LEVEL=info
EOF
echo -e "${GREEN} .env.example${NC} created"

# --- Инициализация Git ---
cd "$PROJECT_DIR"
git init > /dev/null 2>&1
git add . > /dev/null 2>&1
git commit -m "Initial commit: project structure" > /dev/null 2>&1
echo -e "${GREEN}Git initialized and the first commit created${NC}"

# --- Вывод статистики ---
echo ""
echo "Final report:"
echo "Project has been created: $PROJECT_DIR"
echo "Folders: $(find "$PROJECT_DIR" -type d | wc -l)"
echo "Files: $(find "$PROJECT_DIR" -type f | wc -l)"
echo "   Git: инициализирован"

echo ""
echo -e "${BLUE} The project is ready for operation !${NC}"
