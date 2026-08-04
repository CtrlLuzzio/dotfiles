#!/usr/bin/env bash

SUPPORTED_TERMINALS="foot alacritty kitty konsole gnome-terminal xfce4-terminal"
OPENSUSE_ROLLING=("opensuse-tumbleweed" "opensuse-slowroll")
UPDATE_COMMAND=""
NIX_UPDATE_COMMAND=""
TXT_CLOSE="Press Enter to close the terminal..."
TXT_STARTING_UPDATES="Starting Updates..."
TXT_RUNNING="Running"
TXT_NO_TERMINAL="No supported terminal found"
TXT_FALLBACK_WARN="Running in the first supported terminal found"
TXT_FALLBACK_LIST="Supported terminal emulators:"
TXT_FALLBACK_HINT="To use a specific one, define the \$TERMINAL enviroment variable or configure xdg-terminal-exec"
TXT_PLEASE_USE="Please download one of the following terminal emulators"
TXT_NOT_FOUND="System package manager update command not found"
FLATPAK_UPDATES="Searching Flatpak updates..."
UNKNOWN_ZYPPER_DISTRO="Unknown Zypper-based distro. Not updating system packages for safety."
TXT_RESTART_SRV="Checking for services that need to be restarted..."
TXT_KERNEL_WARN="[!] The Kernel was updated. A system reboot is recommended."
TXT_ASK_REBOOT="Do you want to reboot now? [y/N]: "
TXT_CACHE_SIZE="Current package cache size:"
TXT_CACHE_PROMPT="Do you want to clean the package cache? [y/N]: "
TXT_ASK_ORPHANS="[i] Orphaned packages take up space and are no longer needed."
TXT_ORPHANS_PROMPT="Do you want to check and remove them? [y/N]: "
TXT_ZYPPER_WARN="[i] In openSUSE, orphans are managed automatically by enabling 'solver.cleandepsOnRemove = on' in /etc/zypp/zypp.conf.\n    You can list unneeded packages manually with: zypper packages --unneeded"
FORMATTED_LIST="\n  - ${SUPPORTED_TERMINALS// /\\n  - }"
SYS_LANG="${LANG:0:2}"

case "$SYS_LANG" in
    es)
        TXT_CLOSE="Presiona Enter para cerrar la terminal..."
        TXT_STARTING_UPDATES="Iniciando actualizaciones..."
        FLATPAK_UPDATES="Buscando actualizaciones de Flatpak..."
        TXT_RUNNING="Ejecutando"
        TXT_NO_TERMINAL="No se encontró una terminal soportada por el script"
        TXT_PLEASE_USE="Por favor descargue uno de los siguientes emuladores de terminal:"
        TXT_NOT_FOUND="Comando de actualización del manejador de paquetes del sistema no encontrado"
        TXT_FALLBACK_WARN="Ejecutando en la primera terminal compatible encontrada"
        TXT_FALLBACK_HINT="Para usar una específica, define la variable de entorno \$TERMINAL o configura xdg-terminal-exec"
        TXT_FALLBACK_LIST="Emuladores de terminal soportados"
        UNKNOWN_ZYPPER_DISTRO="Distro basada en Zypper desconocida. No se actualizarán los paquetes del sistema por seguridad."
        TXT_RESTART_SRV="Buscando servicios que requieren reinicio..."
        TXT_KERNEL_WARN="[!] El Kernel ha sido actualizado. Se recomienda reiniciar el sistema."
        TXT_ASK_REBOOT="¿Deseas reiniciar ahora? [s/N]: "
        TXT_CACHE_SIZE="Tamaño actual de la caché de paquetes:"
        TXT_CACHE_PROMPT="¿Deseas limpiar la caché de paquetes? [s/N]: "
        TXT_ASK_ORPHANS="[i] Los paquetes huérfanos ocupan espacio y ya no son necesarios."
        TXT_ORPHANS_PROMPT="¿Deseas eliminarlos? [s/N]: "
        TXT_ZYPPER_WARN="[i] En openSUSE, los huérfanos se gestionan automáticamente activando 'solver.cleandepsOnRemove = on' en /etc/zypp/zypp.conf.\n    Puedes listar paquetes innecesarios manualmente con: zypper packages --unneeded"
        ;;
esac

get_package_manager() {
    if command -v zypper &> /dev/null; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                "opensuse-tumbleweed"|"opensuse-slowroll") UPDATE_COMMAND="sudo zypper dup" ;;
                "opensuse-leap") UPDATE_COMMAND="sudo zypper up" ;;
                *) TXT_NOT_FOUND="$UNKNOWN_ZYPPER_DISTRO" ;;
            esac
        fi
    elif command -v dnf &> /dev/null; then
        UPDATE_COMMAND="sudo dnf upgrade"
    elif command -v apt &> /dev/null; then
        UPDATE_COMMAND="sudo apt update && sudo apt upgrade"
    elif command -v pacman &> /dev/null; then
        if command -v paru &> /dev/null; then UPDATE_COMMAND="paru -Syu"
        elif command -v yay &> /dev/null; then UPDATE_COMMAND="yay -Syu"
        elif command -v pikaur &> /dev/null; then UPDATE_COMMAND="pikaur -Syu"
        else UPDATE_COMMAND="sudo pacman -Syu"
        fi
    fi
    if command -v nix &> /dev/null || command -v nix-env &> /dev/null; then
        TARGET_FLAKE="${FLAKE_DIR:-/etc/nixos}"
        if [ -d "$TARGET_FLAKE" ] && [ -f "$TARGET_FLAKE/flake.nix" ]; then
            if command -v nixos-rebuild &> /dev/null; then
                HOST=$(hostname)
                REBUILD_CMD="sudo nixos-rebuild switch --flake $FLAKE_DIR#$HOST"
            elif command -v home-manager &> /dev/null; then
                REBUILD_CMD="home-manager switch --flake ."
            else
                REBUILD_CMD="nix profile upgrade '.*'"
            fi
            if [ -w "$TARGET_FLAKE/flake.nix" ]; then
                NIX_UPDATE_COMMAND="cd \"$TARGET_FLAKE\" && nix flake update && $REBUILD_CMD"
            else
                NIX_UPDATE_COMMAND="cd \"$TARGET_FLAKE\" && sudo nix flake update && $REBUILD_CMD"
            fi
        else
            if command -v nixos-rebuild &> /dev/null; then
                NIX_UPDATE_COMMAND="sudo nix-channel --update && sudo nixos-rebuild switch"
            elif command -v nix-env &> /dev/null; then
                NIX_UPDATE_COMMAND="nix-channel --update && nix-env -u"
            fi
        fi
    fi
}

check_reboot() {
    local REBOOT_NEEDED=0

    if [ -f /var/run/reboot-required ]; then
        REBOOT_NEEDED=1
    elif [ ! -d "/lib/modules/$(uname -r)" ] && [ ! -d "/usr/lib/modules/$(uname -r)" ]; then
        REBOOT_NEEDED=1
    elif command -v dnf &> /dev/null && command -v needs-restarting &> /dev/null && ! needs-restarting -r &> /dev/null; then
        REBOOT_NEEDED=1
    fi

    if [ $REBOOT_NEEDED -eq 1 ]; then
        echo -e "\n\e[31m$TXT_KERNEL_WARN\e[0m"
        read -p "$TXT_ASK_REBOOT" REBOOT_ANS
        if [[ "$REBOOT_ANS" =~ ^[SsYy]$ ]]; then
            systemctl reboot
            exit 0
        fi
    fi

    if command -v needrestart &> /dev/null; then
        echo -e "\n\e[36m$TXT_RESTART_SRV\e[0m"
        sudo needrestart -u interactive
    fi
}

clean_cache() {
    local CACHE_CMD=""
    local CACHE_DIR=""

    if command -v paccache &> /dev/null; then
        CACHE_CMD="paccache -r"
        CACHE_DIR="/var/cache/pacman/pkg"
    elif command -v pacman &> /dev/null; then
        CACHE_CMD="sudo pacman -Sc --noconfirm"
        CACHE_DIR="/var/cache/pacman/pkg"
    elif command -v apt &> /dev/null; then
        CACHE_CMD="sudo apt autoclean"
        CACHE_DIR="/var/cache/apt/archives"
    elif command -v dnf &> /dev/null; then
        CACHE_CMD="sudo dnf clean packages"
        CACHE_DIR="/var/cache/dnf"
    elif command -v zypper &> /dev/null; then
        CACHE_CMD="sudo zypper clean"
        CACHE_DIR="/var/cache/zypp/packages"
    fi

    if [ -n "$CACHE_CMD" ] && [ -d "$CACHE_DIR" ]; then
        local CACHE_SIZE=$(sudo du -sh "$CACHE_DIR" 2>/dev/null | awk '{print $1}')

        if [ -n "$CACHE_SIZE" ] && [ "$CACHE_SIZE" != "0" ]; then
            echo -e "\n\e[33m[i] $TXT_CACHE_SIZE \e[1;33m$CACHE_SIZE\e[0m"
            read -p "$TXT_CACHE_PROMPT" CACHE_ANS

            if [[ "$CACHE_ANS" =~ ^[SsYy]$ ]]; then
                echo -e "\e[34m$TXT_RUNNING:\e[0m $CACHE_CMD"
                eval "$CACHE_CMD"

                if command -v flatpak &> /dev/null; then
                    echo -e "\e[34m$TXT_RUNNING:\e[0m flatpak uninstall --unused"
                    flatpak uninstall --unused --noninteractive
                fi
            fi
        fi
    fi
}

remove_orphans() {
    local ORPHANS_CMD=""

    if command -v pacman &> /dev/null; then
        local ORPHANS=$(pacman -Qtdq 2>/dev/null)
        if [ -n "$ORPHANS" ]; then
            if command -v paru &> /dev/null; then ORPHANS_CMD="paru -c"
            elif command -v yay &> /dev/null; then ORPHANS_CMD="yay -Yc"
            else ORPHANS_CMD="sudo pacman -Rns $ORPHANS"
            fi
        fi
    elif command -v apt &> /dev/null; then
        ORPHANS_CMD="sudo apt autoremove"
    elif command -v dnf &> /dev/null; then
        ORPHANS_CMD="sudo dnf autoremove"
    elif command -v zypper &> /dev/null; then
        echo -e "\n\e[33m$TXT_ZYPPER_WARN\e[0m"
    fi

    if [ -n "$ORPHANS_CMD" ]; then
        echo -e "\n\e[33m$TXT_ASK_ORPHANS\e[0m"
        read -p "$TXT_ORPHANS_PROMPT" ORPHAN_ANS
        if [[ "$ORPHAN_ANS" =~ ^[SsYy]$ ]]; then
            echo -e "\e[34m$TXT_RUNNING:\e[0m $ORPHANS_CMD"
            eval "$ORPHANS_CMD"
        fi
    fi
}

run_payload() {
    local USED_TERM="$1"

    if [ "$USED_TERM" != "$TERMINAL" ] && [ "$USED_TERM" != "xdg-terminal-exec" ]; then
        echo -e "\e[33m$TXT_FALLBACK_WARN ($USED_TERM).\e[0m"
        echo -e "\e[33m$TXT_FALLBACK_LIST$FORMATTED_LIST\e[0m\n"
        echo -e "\e[33m$TXT_FALLBACK_HINT\e[0m\n"
    fi

    get_package_manager
    echo -e "\e[1;32m$TXT_STARTING_UPDATES\e[0m\n"

    if [ -n "$UPDATE_COMMAND" ]; then
        echo -e "\e[34m$TXT_RUNNING:\e[0m $UPDATE_COMMAND\n"
        eval "$UPDATE_COMMAND"
        echo ""
    elif [ -z "$NIX_UPDATE_COMMAND" ]; then
        echo -e "\e[31m$TXT_NOT_FOUND\e[0m\n"
    fi

    if [ -n "$NIX_UPDATE_COMMAND" ]; then
        echo -e "\e[34m$TXT_RUNNING:\e[0m $NIX_UPDATE_COMMAND\n"
        eval "$NIX_UPDATE_COMMAND"
        echo ""
    fi

    if command -v flatpak &> /dev/null; then
        if [ $(flatpak remote-ls --updates 2>/dev/null | wc -l) -gt 0 ]; then
            echo -e "\e[34m$FLATPAK_UPDATES\e[0m\n"
            flatpak update
            echo ""
        fi
    fi

    remove_orphans
    clean_cache
    check_reboot

    echo ""
    read -p "$TXT_CLOSE"
}

if [ "$1" = "--run-payload" ]; then
    run_payload "$2"
    exit 0
fi

get_terminal() {
    if [ -n "$TERMINAL" ] && command -v "$TERMINAL" &> /dev/null; then
        echo "$TERMINAL"
        return
    fi
    if command -v xdg-terminal-exec &> /dev/null; then
        echo "xdg-terminal-exec"
        return
    fi
    for term in $SUPPORTED_TERMINALS; do
        if command -v "$term" &> /dev/null; then
            echo "$term"
            return
        fi
    done
}

TERM_EXEC=$(get_terminal)

if [ -z "$TERM_EXEC" ]; then
    if command -v notify-send &> /dev/null; then
        notify-send -u critical -i utilities-terminal "$TXT_NO_TERMINAL" "$(echo -e "$TXT_PLEASE_USE:$FORMATTED_LIST")"
    fi
    exit 1
fi

SCRIPT_PATH=$(realpath "$0")

if [ "$TERM_EXEC" = "xdg-terminal-exec" ]; then
    $TERM_EXEC bash -c "\"$SCRIPT_PATH\" --run-payload \"$TERM_EXEC\""
else
    $TERM_EXEC -e bash -c "\"$SCRIPT_PATH\" --run-payload \"$TERM_EXEC\""
fi
