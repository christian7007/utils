#!/bin/bash

set -e -o pipefail

SCRIPT_PATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"
REPO_PATH="$(dirname "$SCRIPT_PATH")"

while getopts p:y:i:z:c:x:n:o: flag
do
    case "${flag}" in
        p) AVOID_PACMAN="YES";;
        y) AVOID_YAY="YES";;
        i) AVOID_I3="YES";;
        z) AVOID_ZSH="YES";;
        c) AVOID_CMDS="YES";;
        x) AVOID_X11="YES";;
        o) AVOID_OTHERS="YES";;
        *) echo "Not supported option: ${OPTARG}" 1>&2;;
    esac
done

# Ensure config file is created
mkdir -p /home/christian/.config

if [ "$AVOID_PACMAN" != "YES" ]; then
    PACMAN_PKGS="zsh \
                 yay \
                 terminator \
                 xclip \
                 tree \
                 rofi"

    sudo pacman -Syu "$PACMAN_PKGS"

    read -p "Press enter to continue"
fi

if [ "$AVOID_YAY" != "YES" ]; then
    YAY_PKGS="google-chrome"

    yay -Syu "$YAY_PKGS"

    read -p "Press enter to continue"
fi

# Includes any configuration related to the desktop environment
if [ "$AVOID_I3" != "YES" ]; then
    ln -s "$REPO_PATH/files/.i3" /home/christian
    ln -s "$REPO_PATH/files/.i3status.conf" /home/christian/.i3status.conf

    # rofi configuration files
    ln -s "$REPO_PATH/files/rofi" /home/christian/.config

    # nitrogen configuration files
    ln -s "$REPO_PATH/files/nitrogen" /home/christian/.config

    read -p "Press enter to continue"
fi

# Includes any configuration related to the terminal
if [ "$AVOID_ZSH" != "YES" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    if [ ! -e "$REPO_PATH/files/.zsh_history" ]; then
        echo ".zsh_history not available. Please copy it manually (avoid commiting it as it might contains passwords." 1>&2
    fi

    ln -s "$REPO_PATH/files/.zshrc" /home/christian/.zshrc

    mkdir -p /home/christian/.config/terminator/config
    ln -s "$REPO_PATH/files/terminator_config" /home/christian/.config/terminator/config

    # Switch from alsa to pulse audio
    install_pulse

    read -p "Press enter to continue"
fi

if [ "$AVOID_CMDS" != "YES" ]; then
    INSTALL_PATH="/usr/bin"
    for FILE in $REPO_PATH/commands; do
        if [ -e "$INSTALL_PATH/$FILE" ]; then
            echo "$INSTALL_PATH/$FILE already exists" 1>&2
        fi

        ln -s "$REPO_PATH/files/terminator_config" "/usr/bin/$FILE"
    done

    read -p "Press enter to continue"
fi

if [ "$AVOID_X11" != "YES" ]; then
    mv /etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf.orig
    mv "$REPO_PATH/files/xorg.conf.d/30-touchpad.conf" /etc/X11/xorg.conf.d/30-touchpad.conf

    read -p "Press enter to continue"
fi

if [ "$AVOID_OTHERS" != "YES" ]; then
    ln -s "$REPO_PATH/files/.vimrc" /home/christian/.vimrc
    ln -s "$REPO_PATH/files/.warprc" /home/christian/.warprc
    ln -s "$REPO_PATH/files/.gdbinit" /home/christian/.gdbinit
fi