#!/usr/bin/env bash

TOOLTIP_EXTRA=""
TOTAL=0
DISTRO_ICON=""

SYS_LANG="${LANG:0:2}"

TXT_UPTODATE="System up to date "
TXT_UPDATEAVAILABLE="Updates available"

case "$SYS_LANG" in
    es)
        TXT_UPTODATE="Sistema al día "
        TXT_UPDATEAVAILABLE="Actualizaciones disponibles"
        ;;
esac

if [ -f /etc/os-release ]; then
    . /etc/os-release

    case "$ID" in
        opensuse*|suse*) DISTRO_ICON="" ;;
        arch)            DISTRO_ICON="" ;;
        endeavouros)     DISTRO_ICON="" ;;
        manjaro)         DISTRO_ICON="" ;;
        fedora)          DISTRO_ICON="" ;;
        nobara)          DISTRO_ICON="" ;;
        debian)          DISTRO_ICON="" ;;
        ubuntu)          DISTRO_ICON="" ;;
        linuxmint)       DISTRO_ICON="" ;;
        pop)             DISTRO_ICON="" ;;
        nixos)           DISTRO_ICON="" ;;
    esac
fi

if command -v zypper &> /dev/null; then
    ICON=${DISTRO_ICON:-""}
    ZYPPER=$(zypper -q -x lu | grep -c '<update ')
    if [ "$ZYPPER" -gt 0 ]; then
        TOTAL=$((TOTAL + ZYPPER))
        TOOLTIP_EXTRA+="$ICON Zypper: $ZYPPER\n"
    fi
elif command -v dnf &> /dev/null; then
    ICON=${DISTRO_ICON:-""}
    DNF=$(dnf check-update -q | grep -v '^$' | wc -l)
    if [ "$DNF" -gt 0 ]; then
        TOTAL=$((TOTAL + DNF))
        TOOLTIP_EXTRA+="$ICON DNF: $DNF\n"
    fi
elif command -v apt &> /dev/null; then
    ICON=${DISTRO_ICON:-""}
    APT=$(LC_ALL=C apt list --upgradable 2>/dev/null | grep -c 'upgradable')
    if [ "$APT" -gt 0 ]; then
        TOTAL=$((TOTAL + APT))
        TOOLTIP_EXTRA+="$ICON APT: $APT\n"
    fi
elif command -v pacman &> /dev/null; then
    PACMAN=0
    ICON=${DISTRO_ICON:-""}
    if command -v checkupdates &> /dev/null; then
        PACMAN=$(checkupdates 2>/dev/null | wc -l)
    elif command -v fakeroot &> /dev/null; then
        TEMP_DB="${TMPDIR:-/tmp}/waybar-pacman-db-${UID}"
        DBPath="$(pacman-conf DBPath 2>/dev/null)"
        if [[ -z "$DBPath" ]] || [[ ! -d "$DBPath" ]]; then
            DBPath="/var/lib/pacman/"
        fi
        rm -rf "$TEMP_DB"
        mkdir -p "$TEMP_DB"
        ln -s "${DBPath}/local" "$TEMP_DB" &> /dev/null
        if fakeroot -- pacman -Sy --disable-sandbox-filesystem --dbpath "$TEMP_DB" --logfile /dev/null &> /dev/null; then
            PACMAN=$(pacman -Qu --dbpath "$TEMP_DB" 2>/dev/null | wc -l)
        fi
    else
        PACMAN=$(pacman -Qu 2>/dev/null | wc -l)
    fi

    if [ "$PACMAN" -gt 0 ]; then
        TOTAL=$((TOTAL + PACMAN))
        TOOLTIP_EXTRA+="$ICON Pacman: $PACMAN\n"
    fi
    AUR=0
    if command -v paru &> /dev/null; then
        AUR=$(paru -Qua 2>/dev/null | wc -l)
    elif command -v yay &> /dev/null; then
        AUR=$(yay -Qua 2>/dev/null | wc -l)
    elif command -v pikaur &> /dev/null; then
        AUR=$(pikaur -Qua 2>/dev/null | wc -l)
    fi
    if [ "$AUR" -gt 0 ]; then
        TOTAL=$((TOTAL + AUR))
        TOOLTIP_EXTRA+=" AUR: $AUR\n"
    fi
fi

if command -v nix &> /dev/null || command -v nix-env &> /dev/null; then
    NIX_ICON=""
    NIX_TOTAL=0
    TARGET_FLAKE="${FLAKE_DIR:-/etc/nixos}"

    if [ -d "$TARGET_FLAKE" ] && [ -f "$TARGET_FLAKE/flake.nix" ]; then
        TEMP_DIR="${TMPDIR:-/tmp}/waybar-nix-flake-${UID}"
        mkdir -p "$TEMP_DIR"

        if command -v rsync &> /dev/null; then
            rsync -a --exclude='.git' "$TARGET_FLAKE/" "$TEMP_DIR/"
        else
            cp -r "$TARGET_FLAKE/"* "$TEMP_DIR/" 2>/dev/null
        fi

        FLAKE_UP=$(cd "$TEMP_DIR" && nix flake update 2>&1 | grep -Ec 'Updated input|Added input')

        if [ "$FLAKE_UP" -gt 0 ]; then
            NIX_TOTAL=$((NIX_TOTAL + FLAKE_UP))
            TOOLTIP_EXTRA+="$NIX_ICON Nix Flake: $FLAKE_UP\n"
        fi
        rm -rf "$TEMP_DIR"
    else
        if command -v nix-env &> /dev/null; then
            ENV_UP=$(nix-env -u --dry-run 2>&1 | grep -c 'upgrading')
            if [ "$ENV_UP" -gt 0 ]; then
                NIX_TOTAL=$((NIX_TOTAL + ENV_UP))
                TOOLTIP_EXTRA+="$NIX_ICON Nix Env: $ENV_UP\n"
            fi
        fi
    fi

    if [ "$NIX_TOTAL" -gt 0 ]; then
        TOTAL=$((TOTAL + NIX_TOTAL))
    fi
fi

if command -v flatpak &> /dev/null; then
    FLATPAK=$(flatpak remote-ls --updates 2>/dev/null | wc -l)
    if [ "$FLATPAK" -gt 0 ]; then
        TOTAL=$((TOTAL + FLATPAK))
        TOOLTIP_EXTRA+=" Flatpak: $FLATPAK\n"
    fi
fi

if [ "$TOTAL" -eq 0 ]; then
    TOOLTIP="$TXT_UPTODATE"
else
    TOOLTIP_EXTRA=${TOOLTIP_EXTRA%\\n}
    TOOLTIP="$TOTAL $TXT_UPDATEAVAILABLE\n$TOOLTIP_EXTRA"
fi

printf '{"text": "%s", "tooltip": "%s"}\n' "$TOTAL" "$TOOLTIP"
