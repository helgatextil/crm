#!/bin/bash

# --- Конфигурация ---
# Укажите имя пользователя на удаленном сервере
REMOTE_USER="root" 
REMOTE_HOST="terminal.cdto.life"
# Укажите путь к файлам на сервере, которые нужно скачивать
# Для BigBlueButton HTML5 клиента это часто: /usr/share/meteor/bundle/programs/web.browser/app/
# Или конфигурация: /etc/bigbluebutton/
REMOTE_PATH="/etc/bigbluebutton/" 
LOCAL_PATH="./imported_files"

# Путь к SSH ключу, сгенерированному в workspace
SSH_KEY="./ssh_keys/id_ed25519"

# --- Синхронизация ---
echo "Запуск синхронизации с $REMOTE_USER@$REMOTE_HOST..."

# Создаем локальную директорию, если нет
mkdir -p "$LOCAL_PATH"

# Используем scp для копирования файлов (так как rsync не установлен)
# -r: рекурсивно
# -i: указать ключ
scp -r -i "$SSH_KEY" -o StrictHostKeyChecking=no "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH" "$LOCAL_PATH"

if [ $? -eq 0 ]; then
    echo "Файлы успешно загружены."
    
    # --- Git фиксация ---
    git add "$LOCAL_PATH"
    
    # Проверяем, есть ли изменения для коммита
    if git diff --staged --quiet; then
        echo "Изменений нет."
    else
        TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
        git commit -m "Auto-sync from server: $TIMESTAMP"
        echo "Изменения зафиксированы в git."
    fi
else
    echo "Ошибка при синхронизации."
    exit 1
fi
