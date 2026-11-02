#!/usr/bin/env bash
# Скрипт для быстрого тестирования любой темы SDDM без перезагрузки

THEME_NAME="${1:-wraith_king}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$REPO_DIR/themes/sm1tee"
CONF_FILE="$THEME_DIR/configs/${THEME_NAME}.conf"

if [ ! -f "$CONF_FILE" ]; then
    echo "❌ Ошибка: Конфиг '$CONF_FILE' не найден!"
    echo "Доступные темы:"
    ls -1 "$THEME_DIR/configs" | sed 's/\.conf$//' | column -c 80
    exit 1
fi

echo "🚀 Переключаю тему на: $THEME_NAME"
sed -i "s|^ConfigFile=configs/.*\.conf|ConfigFile=configs/${THEME_NAME}.conf|" "$THEME_DIR/metadata.desktop"

echo "👀 Запуск SDDM в тестовом режиме (для закрытия нажмите Esc или закройте окно)..."
sddm-greeter-qt6 --test-mode --theme "$THEME_DIR"
