#!/bin/bash

# 🎨 SDDM Theme Collection "sm1tee" - Установщик
# Made with ❤️ by Sm1tee

# Цвета для красивого вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Эмодзи
CHECK="✅"
CROSS="❌"
INFO="ℹ️"
WARNING="⚠️"
QUESTION="❓"

# Глобальные переменные для отчета
ACTIONS_PERFORMED=()
ACTIONS_SKIPPED=()
BACKUP_FILES=()
INSTALLED_PACKAGES=()
CHECK_ONLY=false

# Функция для красивого заголовка
print_header() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${WHITE}                     🎨 SDDM Theme sm1tee                     ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${WHITE}                         Установщик                           ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Функция для заголовка шага
print_step_header() {
    local step_title="$1"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}🔹 $step_title${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Функция для запроса подтверждения
ask_confirmation() {
    local action="$1"
    local details="$2"
    local default="${3:-n}"
    
    echo -e "${CYAN}${QUESTION} ${action}${NC}"
    if [ -n "$details" ]; then
        echo -e "${WHITE}$details${NC}"
    fi
    echo ""
    
    local prompt="Выполнить это действие? [y/N]: "
    if [ "$default" = "y" ]; then
        prompt="Выполнить это действие? [Y/n]: "
    fi
    
    while true; do
        if [ -t 0 ]; then
            # Если stdin доступен, читаем оттуда
            read -p "$prompt" choice
        else
            # Если stdin недоступен (pipe), пытаемся читать с /dev/tty
            if [ -c /dev/tty ]; then
                read -p "$prompt" choice < /dev/tty
            else
                # Если /dev/tty недоступен, используем значение по умолчанию
                echo "Автоматически выбрано: $default"
                choice="$default"
            fi
        fi
        
        case $choice in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            "" ) 
                if [ "$default" = "y" ]; then
                    return 0
                else
                    return 1
                fi
                ;;
            * ) echo "Пожалуйста, ответьте y (да) или n (нет)." ;;
        esac
    done
}

# Функция для добавления в отчет
add_to_report() {
    local action="$1"
    local status="$2"
    
    case $status in
        "performed")
            ACTIONS_PERFORMED+=("$action")
            ;;
        "skipped")
            ACTIONS_SKIPPED+=("$action")
            ;;
    esac
}

# Функция для определения дистрибутива
detect_distro() {
    print_step_header "ШАГ 1: Определение системы                                    "
    
    echo -e "${BLUE}Определяю ваш дистрибутив Linux для выбора правильных команд установки...${NC}"
    echo ""
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        echo -e "${GREEN}${CHECK} Обнаружен дистрибутив: $DISTRO${NC}"
        return 0
    else
        echo -e "${RED}${CROSS} Не удалось определить дистрибутив Linux${NC}"
        return 1
    fi
}

# Функция для проверки зависимостей
check_system_dependencies() {
    echo -e "${BLUE}Проверяю наличие необходимых системных утилит...${NC}"
    echo ""
    
    local missing_deps=()
    command -v git >/dev/null 2>&1 || missing_deps+=("git")
    command -v sudo >/dev/null 2>&1 || missing_deps+=("sudo")
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}${CROSS} Отсутствуют необходимые зависимости: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}${WARNING} Установите их и запустите скрипт снова${NC}"
        return 1
    fi
    
    echo -e "${GREEN}${CHECK} Все системные зависимости найдены${NC}"
    return 0
}

# Функция для проверки установлен ли пакет
is_package_installed() {
    local package="$1"
    
    case $DISTRO in
        "arch"|"manjaro"|"endeavouros"|"cachyos"|"artix"|"arcolinux"|"garuda"|"crystal"|"rebornos")
            pacman -Qi "$package" &>/dev/null
            ;;
        "fedora"|"rhel"|"centos"|"rocky"|"almalinux"|"nobara")
            rpm -q "$package" &>/dev/null
            ;;
        "opensuse"|"opensuse-leap"|"opensuse-tumbleweed"|"suse")
            rpm -q "$package" &>/dev/null
            ;;
        "ubuntu"|"debian"|"pop"|"elementary"|"linuxmint"|"zorin"|"mx"|"kali"|"parrot"|"deepin"|"lmde")
            dpkg -l "$package" 2>/dev/null | grep -q "^ii"
            ;;
        "void")
            xbps-query "$package" &>/dev/null
            ;;
        "gentoo"|"funtoo")
            equery list "$package" &>/dev/null
            ;;
        "solus")
            eopkg list-installed "$package" &>/dev/null
            ;;
        "nixos")
            nix-env -q "$package" &>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Функция для установки зависимостей
install_dependencies() {
    print_step_header "ШАГ 2: Проверка и установка зависимостей SDDM                "
    
    local packages=""
    local install_cmd=""
    local explanation=""
    local missing_packages=()
    local installed_packages=()
    
    case $DISTRO in
        "arch"|"manjaro"|"endeavouros"|"cachyos"|"artix"|"arcolinux"|"garuda"|"crystal"|"rebornos")
            packages="sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg imagemagick"
            install_cmd="sudo pacman -S --needed --noconfirm"
            explanation="Эти пакеты нужны для работы SDDM с темами Qt6:
• sddm - менеджер дисплея (экран входа)
• qt6-svg - поддержка SVG иконок в интерфейсе
• qt6-virtualkeyboard - виртуальная клавиатура на экране
• qt6-multimedia-ffmpeg - воспроизведение видео фонов
• imagemagick - обработка аватаров"
            ;;
        "fedora"|"rhel"|"centos"|"rocky"|"almalinux"|"nobara")
            packages="sddm qt6-qtsvg qt6-qtvirtualkeyboard qt6-qtmultimedia ImageMagick"
            install_cmd="sudo dnf install -y"
            explanation="Эти пакеты нужны для работы SDDM с темами Qt6:
• sddm - менеджер дисплея (экран входа)
• qt6-qtsvg - поддержка SVG иконок в интерфейсе
• qt6-qtvirtualkeyboard - виртуальная клавиатура на экране
• qt6-qtmultimedia - воспроизведение видео фонов
• ImageMagick - обработка аватаров"
            ;;
        "opensuse"|"opensuse-leap"|"opensuse-tumbleweed"|"suse")
            packages="sddm-qt6 libQt6Svg6 qt6-virtualkeyboard qt6-virtualkeyboard-imports qt6-multimedia qt6-multimedia-imports ImageMagick"
            install_cmd="sudo zypper install -y"
            explanation="Эти пакеты нужны для работы SDDM с темами Qt6:
• sddm-qt6 - менеджер дисплея с поддержкой Qt6
• libQt6Svg6 - библиотека для SVG иконок
• qt6-virtualkeyboard - виртуальная клавиатура
• qt6-multimedia - воспроизведение видео фонов
• ImageMagick - обработка аватаров"
            ;;
        "ubuntu"|"debian"|"pop"|"elementary"|"linuxmint"|"zorin"|"mx"|"kali"|"parrot"|"deepin"|"lmde")
            packages="sddm qml6-module-qtquick-virtualkeyboard qml6-module-qtmultimedia qt6-svg-dev imagemagick"
            install_cmd="sudo apt install -y"
            explanation="Эти пакеты нужны для работы SDDM с темами Qt6:
• sddm - менеджер дисплея (экран входа)
• qt6-svg-dev - поддержка SVG иконок в интерфейсе
• qml6-module-qtquick-virtualkeyboard - виртуальная клавиатура на экране
• qml6-module-qtmultimedia - воспроизведение видео фонов
• imagemagick - обработка аватаров"
            ;;
        "void")
            packages="sddm qt6-svg qt6-virtualkeyboard qt6-multimedia ImageMagick"
            install_cmd="sudo xbps-install -y"
            explanation="Эти пакеты нужны для работы SDDM с темами Qt6:
• sddm - менеджер дисплея (экран входа)
• qt6-svg - поддержка SVG иконок в интерфейсе
• qt6-virtualkeyboard - виртуальная клавиатура на экране
• qt6-multimedia - воспроизведение видео фонов
• ImageMagick - обработка аватаров"
            ;;
        "gentoo"|"funtoo")
            packages="x11-misc/sddm dev-qt/qtsvg dev-qt/qtvirtualkeyboard dev-qt/qtmultimedia media-gfx/imagemagick"
            install_cmd="sudo emerge --ask=n"
            explanation="Эти пакеты нужны для работы SDDM с темами Qt6:
• x11-misc/sddm - менеджер дисплея (экран входа)
• dev-qt/qtsvg - поддержка SVG иконок в интерфейсе
• dev-qt/qtvirtualkeyboard - виртуальная клавиатура на экране
• dev-qt/qtmultimedia - воспроизведение видео фонов
• media-gfx/imagemagick - обработка аватаров"
            ;;
        "solus")
            packages="sddm qt6-svg qt6-virtualkeyboard qt6-multimedia imagemagick"
            install_cmd="sudo eopkg install -y"
            explanation="Эти пакеты нужны для работы SDDM с темами Qt6:
• sddm - менеджер дисплея (экран входа)
• qt6-svg - поддержка SVG иконок в интерфейсе
• qt6-virtualkeyboard - виртуальная клавиатура на экране
• qt6-multimedia - воспроизведение видео фонов
• imagemagick - обработка аватаров"
            ;;
        "nixos")
            packages="sddm qt6.qtsvg qt6.qtvirtualkeyboard qt6.qtmultimedia imagemagick"
            install_cmd="nix-env -iA nixos."
            explanation="Эти пакеты нужны для работы SDDM с темами Qt6:
• sddm - менеджер дисплея (экран входа)
• qt6.qtsvg - поддержка SVG иконок в интерфейсе
• qt6.qtvirtualkeyboard - виртуальная клавиатура на экране
• qt6.qtmultimedia - воспроизведение видео фонов
• imagemagick - обработка аватаров
ВНИМАНИЕ: Для NixOS рекомендуется использовать configuration.nix"
            ;;
        *)
            echo -e "${YELLOW}${WARNING} Неизвестный дистрибутив: $DISTRO${NC}"
            echo -e "${RED}${CROSS} Автоматическая установка зависимостей невозможна${NC}"
            echo ""
            echo -e "${BLUE}Необходимо установить следующие пакеты вручную:${NC}"
            echo "• sddm - менеджер дисплея"
            echo "• qt6-svg - поддержка SVG иконок"
            echo "• qt6-virtualkeyboard - виртуальная клавиатура"
            echo "• qt6-multimedia - воспроизведение видео"
            echo "• ImageMagick/magick - обработка аватаров"
            echo ""
            echo -e "${YELLOW}Используйте пакетный менеджер вашего дистрибутива для установки.${NC}"
            echo -e "${YELLOW}Например:${NC}"
            echo "  • Arch/Manjaro/CachyOS: sudo pacman -S sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg imagemagick"
            echo "  • Fedora/RHEL: sudo dnf install sddm qt6-qtsvg qt6-qtvirtualkeyboard qt6-qtmultimedia ImageMagick"
            echo "  • Ubuntu/Debian: sudo apt install sddm qt6-svg-dev qml6-module-qtquick-virtualkeyboard qml6-module-qtmultimedia imagemagick"
            echo "  • openSUSE: sudo zypper install sddm-qt6 libQt6Svg6 qt6-virtualkeyboard qt6-multimedia ImageMagick"
            echo "  • Void: sudo xbps-install sddm qt6-svg qt6-virtualkeyboard qt6-multimedia ImageMagick"
            echo "  • Gentoo: sudo emerge x11-misc/sddm dev-qt/qtsvg dev-qt/qtvirtualkeyboard dev-qt/qtmultimedia media-gfx/imagemagick"
            echo "  • Solus: sudo eopkg install sddm qt6-svg qt6-virtualkeyboard qt6-multimedia imagemagick"
            echo ""
            
            echo -e "${RED}${CROSS} Автоматическая установка невозможна для дистрибутива: $DISTRO${NC}"
            add_to_report "Установка зависимостей (пропущена - неизвестный дистрибутив: $DISTRO)" "skipped"
            return 1
            ;;
    esac
    
    echo -e "${BLUE}Проверяю установленные пакеты...${NC}"
    echo ""
    
    # Проверяем каждый пакет
    for package in $packages; do
        if is_package_installed "$package"; then
            echo -e "${GREEN}${CHECK} $package - уже установлен${NC}"
            installed_packages+=("$package")
        else
            echo -e "${YELLOW}${WARNING} $package - не установлен${NC}"
            missing_packages+=("$package")
        fi
    done
    
    echo ""
    
    # Если все пакеты установлены
    if [ ${#missing_packages[@]} -eq 0 ]; then
        echo -e "${GREEN}${CHECK} Все необходимые зависимости уже установлены${NC}"
        add_to_report "Проверка зависимостей (все установлены)" "performed"
        return 0
    fi
    
    # Если есть недостающие пакеты
    echo -e "${explanation}"
    echo ""
    echo -e "${YELLOW}Необходимо установить следующие пакеты:${NC}"
    for package in "${missing_packages[@]}"; do
        echo -e "  ${YELLOW}•${NC} $package"
    done
    echo ""
    echo -e "${YELLOW}Команда для установки:${NC} $install_cmd ${missing_packages[*]}"
    echo ""
    
    if ask_confirmation "Установить недостающие пакеты?" "Без них тема не будет работать корректно" "y"; then
        echo -e "${BLUE}${INFO} Выполняется установка...${NC}"
        
        # Для Debian/Ubuntu сначала обновляем список пакетов
        if [[ "$DISTRO" =~ ^(ubuntu|debian|pop|elementary|linuxmint|zorin|mx|kali|parrot|deepin|lmde)$ ]]; then
            echo -e "${BLUE}${INFO} Обновление списка пакетов...${NC}"
            if ! sudo apt update; then
                echo -e "${RED}${CROSS} Ошибка при обновлении списка пакетов${NC}"
                return 1
            fi
        fi
        
        # Устанавливаем недостающие пакеты
        if $install_cmd "${missing_packages[@]}"; then
            echo ""
            echo -e "${BLUE}${INFO} Проверяю успешность установки...${NC}"
            
            local failed_packages=()
            for package in "${missing_packages[@]}"; do
                if is_package_installed "$package"; then
                    echo -e "${GREEN}${CHECK} $package - успешно установлен${NC}"
                    INSTALLED_PACKAGES+=("$package")
                else
                    echo -e "${RED}${CROSS} $package - не удалось установить${NC}"
                    failed_packages+=("$package")
                fi
            done
            
            if [ ${#failed_packages[@]} -eq 0 ]; then
                echo ""
                echo -e "${GREEN}${CHECK} Все зависимости успешно установлены${NC}"
                add_to_report "Установка зависимостей: ${missing_packages[*]}" "performed"
                return 0
            else
                echo ""
                echo -e "${RED}${CROSS} Не удалось установить некоторые пакеты: ${failed_packages[*]}${NC}"
                echo -e "${YELLOW}${WARNING} Установите недостающие пакеты вручную и запустите скрипт снова${NC}"
                add_to_report "Установка зависимостей (частично: ${INSTALLED_PACKAGES[*]})" "performed"
                return 1
            fi
        else
            echo -e "${RED}${CROSS} Ошибка при установке зависимостей${NC}"
            echo -e "${YELLOW}${WARNING} Попробуйте установить пакеты вручную:${NC}"
            echo -e "${YELLOW}$install_cmd ${missing_packages[*]}${NC}"
            add_to_report "Установка зависимостей (ошибка)" "skipped"
            return 1
        fi
    else
        echo -e "${YELLOW}${WARNING} Установка зависимостей отклонена${NC}"
        echo -e "${RED}${CROSS} Невозможно продолжить без установки зависимостей${NC}"
        add_to_report "Установка зависимостей" "skipped"
        return 1
    fi
}

# Функция для выбора типа установки
choose_installation_type() {
    print_step_header "ШАГ 3: Выбор типа установки                                  "
    
    echo -e "${BLUE}Выберите как вы хотите установить темы:${NC}"
    echo ""
    echo -e "${CYAN}1)${NC} ${GREEN}Полная установка${NC} - все 25+ тем сразу"
    echo -e "   Плюсы: все темы доступны, можно легко переключаться"
    echo -e "   Минусы: размер загрузки будет определен при скачивании"
    echo ""
    echo -e "${CYAN}2)${NC} ${YELLOW}Установка одной темы${NC} - только выбранная тема"
    echo -e "   Плюсы: быстрая загрузка, экономия места и трафика"
    echo -e "   Минусы: только одна тема, для смены нужна переустановка"
    echo ""
    
    while true; do
        if [ -t 0 ]; then
            # Если stdin доступен, читаем оттуда
            read -p "Ваш выбор (1-2): " install_choice
        else
            # Если stdin недоступен (pipe), пытаемся читать с /dev/tty
            if [ -c /dev/tty ]; then
                read -p "Ваш выбор (1-2): " install_choice < /dev/tty
            else
                # Если /dev/tty недоступен, используем значение по умолчанию
                echo "Автоматически выбрана полная установка (по умолчанию)"
                install_choice=1
            fi
        fi
        
        case $install_choice in
            1)
                INSTALL_TYPE="full"
                echo -e "${GREEN}${CHECK} Выбрана полная установка${NC}"
                break
                ;;
            2)
                INSTALL_TYPE="single"
                echo -e "${GREEN}${CHECK} Выбрана установка одной темы${NC}"
                break
                ;;
            *)
                echo -e "${RED}${CROSS} Неверный выбор! Введите 1 или 2${NC}"
                ;;
        esac
    done
}

# Функция для показа доступных тем
show_available_themes() {
    echo -e "${WHITE}Доступные темы (всего 59):${NC}"
    echo ""
    echo "abyss, apocalypse, astronaut, berserk, bones, calmness, cliffside,"
    echo "crimson, crown_of_thorns, cyber, dark_knight_storm, demon, demon2,"
    echo "eclipse, ember, explosion, fallen_knight, frost, gargantua, gate,"
    echo "gate2, goku, greenhouse, halloween, harley, harry, hends,"
    echo "hollow, horizon, horror, house, house2, house3, house4,"
    echo "house5, itachi, jinwoo_daggers, jinwoo_monarch, knight_bonfire,"
    echo "pikachu, queen, queen2, ryomen, sakura, samurai, samurai2,"
    echo "samurai3, samurai4, sanctuary, solder, space, space2, tree,"
    echo "warrior, window, window2, witcher, wizard, wraith_king"
    echo ""
}

# Функция для выбора темы из пронумерованного списка
select_theme_from_list() {
    local themes=(
        "abyss" "apocalypse" "astronaut" "berserk" "bones" "calmness" "cliffside"
        "crimson" "crown_of_thorns" "cyber" "dark_knight_storm" "demon" "demon2"
        "eclipse" "ember" "explosion" "fallen_knight" "frost" "gargantua" "gate"
        "gate2" "goku" "greenhouse" "halloween" "harley" "harry" "hends"
        "hollow" "horizon" "horror" "house" "house2" "house3" "house4"
        "house5" "itachi" "jinwoo_daggers" "jinwoo_monarch" "knight_bonfire"
        "pikachu" "queen" "queen2" "ryomen" "sakura" "samurai" "samurai2"
        "samurai3" "samurai4" "sanctuary" "solder" "space" "space2" "tree"
        "warrior" "window" "window2" "witcher" "wizard" "wraith_king"
    )
    
    echo -e "${WHITE}Доступные темы (всего ${#themes[@]}):${NC}"
    echo ""
    
    # Показываем аккуратный список в две колонки
    for ((i=0; i<${#themes[@]}; i+=2)); do
        local n1=$((i + 1))
        local t1="${themes[i]}"
        local col1=$(printf "${CYAN}%2d)${NC} %-26s" "$n1" "$t1")
        if [ $((i + 1)) -lt ${#themes[@]} ]; then
            local n2=$((i + 2))
            local t2="${themes[i+1]}"
            local col2=$(printf "${CYAN}%2d)${NC} %-26s" "$n2" "$t2")
            echo -e "  $col1 $col2"
        else
            echo -e "  $col1"
        fi
    done
    echo ""
    
    while true; do
        if [ -t 0 ]; then
            read -p "Выберите номер темы (1-${#themes[@]}): " theme_choice
        else
            if [ -c /dev/tty ]; then
                read -p "Выберите номер темы (1-${#themes[@]}): " theme_choice < /dev/tty
            else
                echo "Автоматически выбрана тема: witcher (по умолчанию)"
                selected_theme="witcher"
                return 0
            fi
        fi
        
        # Проверяем, что введено число
        if [[ "$theme_choice" =~ ^[0-9]+$ ]]; then
            # Проверяем, что число в допустимом диапазоне
            if [ "$theme_choice" -ge 1 ] && [ "$theme_choice" -le "${#themes[@]}" ]; then
                local index=$((theme_choice - 1))
                selected_theme="${themes[index]}"
                echo -e "${GREEN}${CHECK} Выбрана тема: $selected_theme${NC}"
                return 0
            else
                echo -e "${RED}${CROSS} Неверный номер! Введите число от 1 до ${#themes[@]}${NC}"
            fi
        else
            echo -e "${RED}${CROSS} Введите корректный номер темы (число от 1 до ${#themes[@]})${NC}"
        fi
    done
}

# Функция для загрузки репозитория
download_repository() {
    print_step_header "ШАГ 4: Загрузка всех тем с GitHub                            "
    
    local repo_url="https://github.com/Sm1tee/Sm1tee-sddm-themes.git"
    local target_dir="Sm1tee-sddm-themes"
    
    echo -e "${BLUE}Буду загружать все темы из репозитория GitHub.${NC}"
    echo -e "Репозиторий: $repo_url"
    echo -e "Папка для загрузки: $target_dir"
    echo ""
    echo -e "${YELLOW}Команда для загрузки:${NC} git clone $repo_url $target_dir"
    echo ""
    
    if [ -d "$target_dir" ]; then
        echo -e "${YELLOW}${WARNING} Папка $target_dir уже существует${NC}"
        echo -e "${YELLOW}Команда для удаления:${NC} rm -rf $target_dir"
        if ask_confirmation "Удалить существующую папку?" "Все содержимое будет потеряно"; then
            rm -rf "$target_dir"
            add_to_report "Удаление существующей папки $target_dir" "performed"
        else
            echo -e "${RED}${CROSS} Невозможно продолжить с существующей папкой${NC}"
            return 1
        fi
    fi
    
    if ask_confirmation "Загрузить все темы?" "Будет выполнено клонирование репозитория"; then
        echo -e "${BLUE}${INFO} Загрузка репозитория...${NC}"
        if git clone --depth 1 "$repo_url" "$target_dir"; then
            echo -e "${GREEN}${CHECK} Репозиторий успешно загружен${NC}"
            add_to_report "Загрузка репозитория" "performed"
            return 0
        else
            echo -e "${RED}${CROSS} Ошибка при загрузке репозитория${NC}"
            return 1
        fi
    else
        add_to_report "Загрузка репозитория" "skipped"
        return 1
    fi
}

# Функция для загрузки одной темы
download_single_theme() {
    local theme_name="$1"
    print_step_header "ШАГ 4: Загрузка темы '$theme_name' с GitHub                   "
    
    local repo_url="https://github.com/Sm1tee/Sm1tee-sddm-themes.git"
    local target_dir="Sm1tee-sddm-themes"
    
    echo -e "${BLUE}Буду загружать только файлы для темы '$theme_name'.${NC}"
    echo -e "Это сэкономит время и трафик, загрузив только нужные файлы."
    echo ""
    echo -e "${YELLOW}Команды которые будут выполнены:${NC}"
    echo -e "git clone --filter=blob:none --sparse $repo_url $target_dir"
    echo -e "git sparse-checkout set --no-cone [файлы темы $theme_name]"
    echo ""
    
    if [ -d "$target_dir" ]; then
        echo -e "${YELLOW}${WARNING} Папка $target_dir уже существует${NC}"
        echo -e "${YELLOW}Команда для удаления:${NC} rm -rf $target_dir"
        if ask_confirmation "Удалить существующую папку?" "Все содержимое будет потеряно"; then
            rm -rf "$target_dir"
            add_to_report "Удаление существующей папки $target_dir" "performed"
        else
            echo -e "${RED}${CROSS} Невозможно продолжить с существующей папкой${NC}"
            return 1
        fi
    fi
    
    if ask_confirmation "Загрузить тему '$theme_name'?" "Будет выполнено частичное клонирование"; then
        echo -e "${BLUE}${INFO} Создание структуры репозитория...${NC}"
        if git clone --filter=blob:none --sparse "$repo_url" "$target_dir"; then
            cd "$target_dir" || { echo -e "${RED}${CROSS} Ошибка: не удалось войти в папку $target_dir${NC}"; return 1; }
            
            echo -e "${BLUE}${INFO} Настройка загрузки файлов темы...${NC}"
            git sparse-checkout set --no-cone \
                "/README.md" \
                "themes/sm1tee/components/" \
                "themes/sm1tee/fonts/" \
                "themes/sm1tee/icons/" \
                "/themes/sm1tee/Main.qml" \
                "/themes/sm1tee/metadata.desktop" \
                "/themes/sm1tee/qmldir" \
                "/themes/sm1tee/configs/${theme_name}.conf" \
                "/themes/sm1tee/backgrounds/${theme_name}.mp4" \
                "/themes/sm1tee/backgrounds/${theme_name}.png"
            
            # Проверяем существование файлов темы
            if [ ! -f "themes/sm1tee/configs/${theme_name}.conf" ]; then
                echo -e "${RED}${CROSS} Тема '$theme_name' не найдена в репозитории!${NC}"
                cd ..
                return 1
            fi
            
            echo -e "${GREEN}${CHECK} Тема '$theme_name' успешно загружена${NC}"
            add_to_report "Загрузка темы $theme_name" "performed"
            cd ..
            return 0
        else
            echo -e "${RED}${CROSS} Ошибка при загрузке темы${NC}"
            return 1
        fi
    else
        add_to_report "Загрузка темы $theme_name" "skipped"
        return 1
    fi
}

# Функция для копирования файлов темы
install_theme_files() {
    print_step_header "ШАГ 5: Установка файлов темы в систему                       "
    
    local source_dir="Sm1tee-sddm-themes/themes/sm1tee"
    if [ ! -d "$source_dir" ] && [ -d "themes/sm1tee" ]; then
        source_dir="themes/sm1tee"
    elif [ ! -d "$source_dir" ] && [ -d "sddm-theme/themes/sm1tee" ]; then
        source_dir="sddm-theme/themes/sm1tee"
    fi
    local target_dir="/usr/share/sddm/themes/sm1tee"
    
    echo -e "${BLUE}Буду копировать файлы темы в системную папку SDDM.${NC}"
    echo -e "Откуда: $source_dir"
    echo -e "Куда: $target_dir"
    echo ""
    echo -e "${YELLOW}Команда для копирования:${NC} sudo cp -r $source_dir $target_dir"
    echo ""
    
    if [ ! -d "$source_dir" ]; then
        echo -e "${RED}${CROSS} Исходная папка темы не найдена: $source_dir${NC}"
        return 1
    fi
    
    local warning_text="Требуются права администратора"
    if [ -d "$target_dir" ]; then
        warning_text="ВНИМАНИЕ: Папка $target_dir уже существует и будет перезаписана. Требуются права администратора"
    fi
    
    if ask_confirmation "Скопировать файлы темы?" "$warning_text"; then
        if [ -d "$target_dir" ]; then
            if sudo rm -rf "$target_dir"; then
                add_to_report "Удаление старой темы" "performed"
            else
                echo -e "${RED}${CROSS} Ошибка при удалении старой темы${NC}"
                return 1
            fi
        fi
        echo -e "${BLUE}${INFO} Копирование файлов темы...${NC}"
        if sudo cp -r "$source_dir" "$target_dir"; then
            echo -e "${GREEN}${CHECK} Файлы темы успешно установлены${NC}"
            add_to_report "Установка файлов темы в $target_dir" "performed"
            return 0
        else
            echo -e "${RED}${CROSS} Ошибка при копировании файлов темы${NC}"
            return 1
        fi
    else
        add_to_report "Установка файлов темы" "skipped"
        return 1
    fi
}

# Функция для установки шрифтов
install_fonts() {
    print_step_header "ШАГ 6: Установка шрифтов темы                                "
    
    local source_dir="Sm1tee-sddm-themes/themes/sm1tee/fonts"
    if [ ! -d "$source_dir" ] && [ -d "themes/sm1tee/fonts" ]; then
        source_dir="themes/sm1tee/fonts"
    elif [ ! -d "$source_dir" ] && [ -d "sddm-theme/themes/sm1tee/fonts" ]; then
        source_dir="sddm-theme/themes/sm1tee/fonts"
    fi
    local target_dir="/usr/share/fonts"
    
    if [ ! -d "$source_dir" ]; then
        echo -e "${YELLOW}${WARNING} Папка шрифтов не найдена: $source_dir${NC}"
        add_to_report "Установка шрифтов (папка не найдена)" "skipped"
        return 0
    fi
    
    local font_count=$(find "$source_dir" -name "*.ttf" -o -name "*.otf" | wc -l)
    echo -e "${BLUE}Буду устанавливать кастомные шрифты для красивого отображения тем.${NC}"
    echo -e "Найдено шрифтов: $font_count"
    echo -e "Откуда: $source_dir"
    echo -e "Куда: $target_dir"
    echo ""
    echo -e "${YELLOW}Команды которые будут выполнены:${NC}"
    echo -e "sudo cp -r $source_dir/* $target_dir/"
    echo -e "sudo fc-cache -fv"
    echo ""
    
    if ask_confirmation "Установить шрифты?" "Шрифты нужны для корректного отображения тем"; then
        echo -e "${BLUE}${INFO} Копирование шрифтов...${NC}"
        if sudo cp -r "$source_dir"/* "$target_dir"/; then
            echo -e "${BLUE}${INFO} Обновление кэша шрифтов...${NC}"
            if sudo fc-cache -fv > /dev/null 2>&1; then
                echo -e "${GREEN}${CHECK} Шрифты успешно установлены и кэш обновлен${NC}"
                add_to_report "Установка шрифтов ($font_count файлов)" "performed"
                return 0
            else
                echo -e "${YELLOW}${WARNING} Шрифты скопированы, но ошибка при обновлении кэша${NC}"
                add_to_report "Установка шрифтов (с предупреждением)" "performed"
                return 0
            fi
        else
            echo -e "${RED}${CROSS} Ошибка при копировании шрифтов${NC}"
            return 1
        fi
    else
        add_to_report "Установка шрифтов" "skipped"
        return 0
    fi
}

# Функция для настройки темы
configure_theme() {
    local theme_name="$1"
    print_step_header "ШАГ 7: Настройка активной темы                               "
    
    local metadata_file="/usr/share/sddm/themes/sm1tee/metadata.desktop"
    
    echo -e "${BLUE}Буду настраивать тему '$theme_name' как активную.${NC}"
    echo -e "Файл конфигурации: $metadata_file"
    echo -e "Будет изменена строка: ConfigFile=configs/${theme_name}.conf"
    echo ""
    echo -e "${YELLOW}Команда для настройки:${NC} sudo sed -i \"s|^ConfigFile=.*|ConfigFile=configs/${theme_name}.conf|\" $metadata_file"
    echo ""
    
    if [ ! -f "$metadata_file" ]; then
        echo -e "${RED}${CROSS} Файл метаданных не найден: $metadata_file${NC}"
        return 1
    fi
    
    if ask_confirmation "Настроить тему '$theme_name'?" "Это сделает её активной по умолчанию"; then
        if sudo sed -i "s|^ConfigFile=.*|ConfigFile=configs/${theme_name}.conf|" "$metadata_file"; then
            echo -e "${GREEN}${CHECK} Тема '$theme_name' успешно настроена${NC}"
            add_to_report "Настройка темы $theme_name" "performed"
            return 0
        else
            echo -e "${RED}${CROSS} Ошибка при настройке темы${NC}"
            return 1
        fi
    else
        add_to_report "Настройка темы $theme_name" "skipped"
        return 1
    fi
}

# Функция для настройки SDDM
configure_sddm() {
    print_step_header "ШАГ 8: Настройка конфигурации SDDM                          "

    local config_file="/etc/sddm.conf"

    # Определяем текущий курсор
    local cursor_theme=""
    if [ -f "$HOME/.icons/default/index.theme" ]; then
        cursor_theme=$(grep -i "^Inherits=" "$HOME/.icons/default/index.theme" 2>/dev/null | cut -d= -f2)
    fi
    if [ -z "$cursor_theme" ] && command -v gsettings &>/dev/null; then
        cursor_theme=$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null | tr -d "'")
    fi
    if [ -z "$cursor_theme" ]; then
        cursor_theme="default"
    fi

    # Определяем display server
    local display_server="wayland"
    if [ "$XDG_SESSION_TYPE" = "x11" ]; then
        display_server="x11"
    fi

    echo -e "${BLUE}Буду настраивать SDDM для использования установленной темы.${NC}"
    echo -e "Файл конфигурации: $config_file"
    echo ""
    echo -e "${YELLOW}Содержимое новой конфигурации:${NC}"
    echo -e "${CYAN}[Theme]${NC}"
    echo -e "${CYAN}Current=sm1tee${NC}"
    echo -e "${CYAN}CursorTheme=$cursor_theme${NC}"
    echo -e "${CYAN}CursorSize=30${NC}"
    echo ""
    echo -e "${CYAN}[General]${NC}"
    echo -e "${CYAN}DisplayServer=$display_server${NC}"
    echo -e "${CYAN}GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/sm1tee/components/,QT_IM_MODULE=qtvirtualkeyboard${NC}"
    echo -e "${CYAN}Numlock=on${NC}"
    echo -e "${CYAN}InputMethod=qtvirtualkeyboard${NC}"
    echo ""

    if ask_confirmation "Создать конфигурацию SDDM?" "Файл $config_file будет создан/перезаписан"; then
        # Бэкап существующего конфига
        if [ -f "$config_file" ]; then
            local backup_path="${config_file}.bak.$(date +%Y%m%d_%H%M%S)"
            if sudo cp "$config_file" "$backup_path"; then
                echo -e "${GREEN}${CHECK} Резервная копия создана: $backup_path${NC}"
                BACKUP_FILES+=("$backup_path")
                add_to_report "Резервная копия $config_file -> $backup_path" "performed"
            fi
        fi

        if sudo tee "$config_file" > /dev/null << EOF
[Theme]
Current=sm1tee
CursorTheme=$cursor_theme
CursorSize=30

[General]
DisplayServer=$display_server
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/sm1tee/components/,QT_IM_MODULE=qtvirtualkeyboard
Numlock=on
InputMethod=qtvirtualkeyboard
EOF
        then
            echo -e "${GREEN}${CHECK} Конфигурация SDDM успешно создана${NC}"
            add_to_report "Настройка конфигурации SDDM" "performed"
            return 0
        else
            echo -e "${RED}${CROSS} Ошибка при создании конфигурации SDDM${NC}"
            return 1
        fi
    else
        add_to_report "Настройка конфигурации SDDM" "skipped"
        return 1
    fi
}

# Функция для установки аватара
has_magick() {
    command -v magick >/dev/null 2>&1
}

get_user_home() {
    local username="$1"
    getent passwd "$username" | cut -d: -f6
}

find_default_avatar_source() {
    local candidates=(
        "/usr/share/sddm/themes/sm1tee/icons/user-default.png"
        "themes/sm1tee/icons/user-default.png"
        "Sm1tee-sddm-themes/themes/sm1tee/icons/user-default.png"
        "sddm-theme/themes/sm1tee/icons/user-default.png"
    )

    for candidate in "${candidates[@]}"; do
        if [ -f "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

process_avatar_image() {
    local source_path="$1"
    local output_path="$2"

    if ! has_magick; then
        echo -e "${RED}${CROSS} Команда magick не найдена. Установите ImageMagick.${NC}"
        return 1
    fi

    if [ ! -f "$source_path" ]; then
        echo -e "${RED}${CROSS} Файл не найден: $source_path${NC}"
        return 1
    fi

    if ! magick "$source_path" -auto-orient -resize '512x512^' -gravity center -extent 512x512 PNG32:"$output_path"; then
        echo -e "${RED}${CROSS} Не удалось обработать изображение: $source_path${NC}"
        return 1
    fi

    local dimensions
    dimensions=$(magick identify -format '%wx%h' "$output_path" 2>/dev/null || true)
    if [ "$dimensions" != "512x512" ]; then
        echo -e "${RED}${CROSS} Ошибка обработки аватара: получился размер $dimensions вместо 512x512${NC}"
        return 1
    fi
}

accountsservice_avatar_exists_for_user() {
    local username="$1"
    local account_icon="/var/lib/AccountsService/icons/$username"
    local account_config="/var/lib/AccountsService/users/$username"

    if sudo test -s "$account_icon" 2>/dev/null; then
        return 0
    fi

    if sudo test -r "$account_config" 2>/dev/null && sudo grep -q '^Icon=' "$account_config" 2>/dev/null; then
        return 0
    fi

    return 1
}

update_accountsservice_user_config() {
    local username="$1"
    local icon_path="/var/lib/AccountsService/icons/$username"
    local account_config="/var/lib/AccountsService/users/$username"
    local temp_file
    temp_file=$(mktemp)

    if sudo test -f "$account_config" 2>/dev/null; then
        if ! sudo cat "$account_config" > "$temp_file"; then
            rm -f "$temp_file"
            return 1
        fi
    else
        : > "$temp_file"
    fi

    if grep -q '^Icon=' "$temp_file"; then
        awk -v icon="$icon_path" '{ if ($0 ~ /^Icon=/) print "Icon=" icon; else print }' "$temp_file" > "$temp_file.new"
    elif grep -q '^\[User\]$' "$temp_file"; then
        awk -v icon="$icon_path" '{ print; if ($0 == "[User]") print "Icon=" icon }' "$temp_file" > "$temp_file.new"
    else
        cp "$temp_file" "$temp_file.new"
        {
            [ -s "$temp_file.new" ] && echo ""
            echo "[User]"
            echo "Icon=$icon_path"
        } >> "$temp_file.new"
    fi

    if sudo install -m 644 "$temp_file.new" "$account_config"; then
        rm -f "$temp_file" "$temp_file.new"
        return 0
    fi

    rm -f "$temp_file" "$temp_file.new"
    return 1
}

install_default_avatar_if_needed() {
    local username="$1"
    local user_home="$2"

    if accountsservice_avatar_exists_for_user "$username"; then
        echo -e "${GREEN}${CHECK} У пользователя уже есть системный аватар. Дефолтный аватар не устанавливаю.${NC}"
        add_to_report "Установка дефолтного аватара (системный аватар уже есть)" "skipped"
        return 0
    fi

    local avatar_source
    if [ -s "$user_home/.face.icon" ]; then
        avatar_source="$user_home/.face.icon"
        echo -e "${BLUE}${INFO} Найден пользовательский .face.icon. Закрепляю его через AccountsService.${NC}"
    elif ! avatar_source=$(find_default_avatar_source); then
        echo -e "${YELLOW}${WARNING} Дефолтный аватар темы не найден. Установка аватара пропущена.${NC}"
        add_to_report "Установка дефолтного аватара (файл не найден)" "skipped"
        return 0
    fi

    local temp_default_avatar
    temp_default_avatar=$(mktemp --suffix=.png)
    if ! process_avatar_image "$avatar_source" "$temp_default_avatar"; then
        rm -f "$temp_default_avatar"
        add_to_report "Установка дефолтного аватара (ошибка обработки)" "skipped"
        return 0
    fi

    if install_avatar_files "$temp_default_avatar" "$username" "$user_home"; then
        rm -f "$temp_default_avatar"
        echo -e "${GREEN}${CHECK} Аватар установлен для пользователя $username${NC}"
        add_to_report "Установка аватара для $username" "performed"
        return 0
    fi

    rm -f "$temp_default_avatar"
    return 1
}

install_avatar_files() {
    local processed_avatar="$1"
    local username="$2"
    local user_home="$3"
    local home_icon="$user_home/.face.icon"
    local account_icon="/var/lib/AccountsService/icons/$username"

    if [ -z "$user_home" ] || [ ! -d "$user_home" ]; then
        echo -e "${RED}${CROSS} Не удалось определить домашнюю папку пользователя $username${NC}"
        return 1
    fi

    if ! sudo install -m 644 "$processed_avatar" "$home_icon"; then
        echo -e "${RED}${CROSS} Не удалось установить $home_icon${NC}"
        return 1
    fi
    sudo chown "$username:$username" "$home_icon" 2>/dev/null || sudo chown "$username" "$home_icon"

    if ! sudo mkdir -p "/var/lib/AccountsService/icons" "/var/lib/AccountsService/users"; then
        echo -e "${RED}${CROSS} Не удалось создать папки AccountsService${NC}"
        return 1
    fi

    if ! sudo install -m 644 "$processed_avatar" "$account_icon"; then
        echo -e "${RED}${CROSS} Не удалось установить $account_icon${NC}"
        return 1
    fi

    if ! update_accountsservice_user_config "$username"; then
        echo -e "${RED}${CROSS} Не удалось обновить AccountsService для пользователя $username${NC}"
        return 1
    fi
}

setup_avatar() {
    print_step_header "ШАГ 9: Установка пользовательского аватара (опционально)     "

    local username="${SUDO_USER:-$(whoami)}"
    local user_home
    user_home=$(get_user_home "$username")

    echo -e "${BLUE}Можно установить аватар для экрана входа.${NC}"
    echo -e "Поддерживаются PNG, JPG и JPEG. Установщик сам обрежет картинку в квадрат, уменьшит до 512x512 и сохранит как PNG."
    echo ""

    if ! has_magick; then
        echo -e "${YELLOW}${WARNING} Команда magick не найдена. Установка аватара пропущена.${NC}"
        echo -e "${YELLOW}Установите ImageMagick и запустите установщик снова, если хотите обработку аватаров.${NC}"
        add_to_report "Установка аватара (magick не найден)" "skipped"
        return 0
    fi

    if [ -z "$user_home" ] || [ ! -d "$user_home" ]; then
        echo -e "${RED}${CROSS} Не удалось определить домашнюю папку пользователя $username${NC}"
        add_to_report "Установка аватара (домашняя папка не найдена)" "skipped"
        return 0
    fi

    if ask_confirmation "Установить свой аватар?" "Если отказаться, дефолтный аватар темы будет установлен только если у пользователя ещё нет аватара"; then
        while true; do
            echo ""
            if [ -t 0 ]; then
                read -r -p "Введите полный путь к файлу аватара (PNG/JPG/JPEG): " avatar_path
            else
                if [ -c /dev/tty ]; then
                    read -r -p "Введите полный путь к файлу аватара (PNG/JPG/JPEG): " avatar_path < /dev/tty
                else
                    echo "Пропуск установки аватара (автоматический режим)"
                    install_default_avatar_if_needed "$username" "$user_home"
                    return $?
                fi
            fi

            if [ -z "$avatar_path" ]; then
                echo -e "${YELLOW}${WARNING} Путь не может быть пустым${NC}"
                continue
            fi

            if [ ! -f "$avatar_path" ]; then
                echo -e "${RED}${CROSS} Файл не найден: $avatar_path${NC}"
                if ask_confirmation "Попробовать другой файл?" ""; then
                    continue
                else
                    install_default_avatar_if_needed "$username" "$user_home"
                    return $?
                fi
            fi

            local temp_avatar
            temp_avatar=$(mktemp --suffix=.png)
            if ! process_avatar_image "$avatar_path" "$temp_avatar"; then
                rm -f "$temp_avatar"
                if ask_confirmation "Попробовать другой файл?" ""; then
                    continue
                else
                    install_default_avatar_if_needed "$username" "$user_home"
                    return $?
                fi
            fi

            echo ""
            echo -e "${BLUE}Буду устанавливать аватар:${NC}"
            echo -e "Откуда: $avatar_path"
            echo -e "Формат после обработки: PNG 512x512"
            echo -e "Куда: $user_home/.face.icon"
            echo -e "Куда: /var/lib/AccountsService/icons/$username"
            echo -e "Пользователь: $username"
            echo ""

            if ask_confirmation "Установить обработанный аватар?" "Требуются права администратора"; then
                if install_avatar_files "$temp_avatar" "$username" "$user_home"; then
                    rm -f "$temp_avatar"
                    echo -e "${GREEN}${CHECK} Аватар успешно установлен для пользователя $username${NC}"
                    add_to_report "Установка аватара для $username" "performed"
                    return 0
                else
                    rm -f "$temp_avatar"
                    return 1
                fi
            else
                rm -f "$temp_avatar"
                install_default_avatar_if_needed "$username" "$user_home"
                return $?
            fi
        done
    fi

    install_default_avatar_if_needed "$username" "$user_home"
    return $?
}

# Функция для предварительного просмотра
preview_theme() {
    print_step_header "ШАГ 10: Предварительный просмотр темы (опционально)          "
    
    echo -e "${BLUE}Можно запустить предварительный просмотр темы без перезагрузки системы.${NC}"
    echo -e "Откроется окно с темой SDDM в тестовом режиме."
    echo ""
    echo -e "${YELLOW}Команда для запуска:${NC} QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sm1tee"
    echo ""
    
    if ! command -v sddm-greeter-qt6 &> /dev/null; then
        echo -e "${YELLOW}${WARNING} sddm-greeter-qt6 не найден${NC}"
        echo -e "${BLUE}${INFO} Предварительный просмотр недоступен${NC}"
        add_to_report "Предварительный просмотр (недоступен)" "skipped"
        return 0
    fi
    
    if ask_confirmation "Запустить предварительный просмотр?" "Для выхода закройте окно предварительного просмотра"; then
        echo -e "${BLUE}${INFO} Запуск предварительного просмотра...${NC}"
        if QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sm1tee 2>/dev/null; then
            echo -e "${GREEN}${CHECK} Предварительный просмотр завершен${NC}"
            add_to_report "Предварительный просмотр темы" "performed"
        else
            echo -e "${YELLOW}${WARNING} Предварительный просмотр завершился с предупреждениями${NC}"
            add_to_report "Предварительный просмотр (с предупреждениями)" "performed"
        fi
    else
        add_to_report "Предварительный просмотр" "skipped"
    fi
}



# Функция для показа итогового отчета
show_final_report() {
    print_step_header "ИТОГОВЫЙ ОТЧЕТ УСТАНОВКИ                                     "
    
    if [ ${#ACTIONS_PERFORMED[@]} -gt 0 ]; then
        echo -e "${GREEN}${CHECK} Выполненные действия:${NC}"
        for action in "${ACTIONS_PERFORMED[@]}"; do
            echo -e "  ${GREEN}•${NC} $action"
        done
        echo ""
    fi
    
    if [ ${#ACTIONS_SKIPPED[@]} -gt 0 ]; then
        echo -e "${YELLOW}${WARNING} Пропущенные действия:${NC}"
        for action in "${ACTIONS_SKIPPED[@]}"; do
            echo -e "  ${YELLOW}•${NC} $action"
        done
        echo ""
    fi
    
    if [ ${#INSTALLED_PACKAGES[@]} -gt 0 ]; then
        echo -e "${BLUE}${INFO} Установленные пакеты:${NC}"
        for package in "${INSTALLED_PACKAGES[@]}"; do
            echo -e "  ${BLUE}•${NC} $package"
        done
        echo ""
    fi
    
    if [ ${#BACKUP_FILES[@]} -gt 0 ]; then
        echo -e "${CYAN}${INFO} Созданные резервные копии:${NC}"
        for backup in "${BACKUP_FILES[@]}"; do
            echo -e "  ${CYAN}•${NC} $backup"
        done
        echo ""
    fi
    
    echo -e "${BLUE}${INFO} Что дальше:${NC}"
    echo -e "  ${CYAN}•${NC} Перезагрузите систему: ${YELLOW}sudo reboot${NC}"
    echo -e "  ${CYAN}•${NC} Или перезапустите SDDM: ${YELLOW}sudo systemctl restart sddm${NC}"
    echo ""
    
    echo -e "${BLUE}${INFO} Полезные команды:${NC}"
    echo -e "  ${CYAN}•${NC} Предварительный просмотр: ${YELLOW}QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sm1tee${NC}"
    echo -e "  ${CYAN}•${NC} Смена темы: ${YELLOW}sudo nano /usr/share/sddm/themes/sm1tee/metadata.desktop${NC}"
    echo ""
    
    echo -e "${PURPLE}Made with ❤️  by Sm1tee${NC}"
    echo -e "${BLUE}GitHub: https://github.com/Sm1tee/Sm1tee-sddm-themes${NC}"
}

# Основная функция
main() {
    # Проверка аргументов командной строки
    if [[ "$1" == "--check" ]]; then
        CHECK_ONLY=true
    fi
    
    print_header
    
    # Проверка системных зависимостей
    if ! check_system_dependencies; then
        exit 1
    fi
    
    # Определение дистрибутива
    if ! detect_distro; then
        exit 1
    fi
    
    # Если только проверка
    if [ "$CHECK_ONLY" = true ]; then
        echo -e "${GREEN}${CHECK} Проверка системы завершена успешно${NC}"
        echo -e "${BLUE}${INFO} Система готова для установки SDDM темы${NC}"
        exit 0
    fi
    
    # Установка зависимостей
    if ! install_dependencies; then
        echo -e "${RED}${CROSS} Установка зависимостей не выполнена${NC}"
        echo -e "${YELLOW}${WARNING} Установите зависимости вручную и запустите скрипт снова${NC}"
        exit 1
    fi
    
    # Выбор типа установки
    choose_installation_type
    
    # Загрузка файлов
    case $INSTALL_TYPE in
        "full")
            if download_repository; then
                cd Sm1tee-sddm-themes
                select_theme_from_list
                cd ..
            else
                echo -e "${RED}${CROSS} Не удалось загрузить репозиторий${NC}"
                exit 1
            fi
            ;;
        "single")
            select_theme_from_list
            if ! download_single_theme "$selected_theme"; then
                echo -e "${RED}${CROSS} Не удалось загрузить тему${NC}"
                exit 1
            fi
            ;;
    esac
    
    # Установка файлов
    install_theme_files
    install_fonts
    
    # Очистка временных файлов
    for tmp_dir in "Sm1tee-sddm-themes" "sddm-theme"; do
        if [ -d "$tmp_dir" ]; then
            echo -e "${BLUE}${INFO} Удаление временной папки $tmp_dir...${NC}"
            rm -rf "$tmp_dir"
            echo -e "${GREEN}${CHECK} Временная папка $tmp_dir удалена${NC}"
            add_to_report "Очистка временных файлов" "performed"
        fi
    done
    
    # Настройка
    configure_theme "$selected_theme"
    configure_sddm
    
    # Дополнительные опции
    setup_avatar
    preview_theme
    
    # Итоговый отчет
    show_final_report
}

# Обработка сигналов
trap 'echo -e "\n${RED}${CROSS} Установка прервана пользователем${NC}"; exit 1' INT TERM

# Запуск
main "$@"
