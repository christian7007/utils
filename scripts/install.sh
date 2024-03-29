#!/bin/bash

# Create a link at $2 (link name) pointing to $1 (target). The original content of $2 is stored
# as $2.orig.
function link_and_save() {
    link_name="$2"
    target="$1"

    if [ -e "$link_name" ]; then
        mv "$link_name" "$link_name".orig
    else
        # Ensure path exists if file is not already in place
        mkdir -p "$(dirname "$link_name")"
    fi

    ln -s "$target" "$link_name"
}

set -e -o pipefail

if [ "$USER" != "christian" ]; then
    echo "The script must be executed as christian user"
    exit 255
fi

SCRIPT_PATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"
REPO_PATH="$(dirname "$SCRIPT_PATH")"

while getopts pyizcxnov flag
do
    case "${flag}" in
        p) AVOID_PACMAN="YES";;
        y) AVOID_YAY="YES";;
        i) AVOID_I3="YES";;
        z) AVOID_ZSH="YES";;
        c) AVOID_CMDS="YES";;
        x) AVOID_X11="YES";;
        o) AVOID_OTHERS="YES";;
        v) AVOID_VSCODE="YES";;
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
                 rofi \
                 code"

    sudo pacman -Syu $(echo "$PACMAN_PKGS" | tr -s '[:space:]' ' ')

    read -p "Press enter to continue"
fi

if [ "$AVOID_YAY" != "YES" ]; then
    YAY_PKGS="google-chrome \
              spotify"

    yay -Syu $(echo "$YAY_PKGS" | tr -s '[:space:]' ' ')

    read -p "Press enter to continue"
fi

# Includes any configuration related to the desktop environment
if [ "$AVOID_I3" != "YES" ]; then
    link_and_save "$REPO_PATH/files/.i3" /home/christian/.i3
    link_and_save "$REPO_PATH/files/.i3status.conf" /home/christian/.i3status.conf

    # rofi configuration files
    link_and_save "$REPO_PATH/files/rofi" /home/christian/.config/rofi

    # nitrogen configuration files
    link_and_save "$REPO_PATH/files/nitrogen" /home/christian/.config/nitrogen

    # Switch from alsa to pulse audio
    install_pulse

    read -p "Press enter to continue"
fi

# Includes any configuration related to the terminal
if [ "$AVOID_ZSH" != "YES" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    if [ ! -e "$REPO_PATH/files/.zsh_history" ]; then
        echo ".zsh_history not available. Please copy it manually into $REPO_PATH/files (avoid commiting it as it might contains passwords)." 1>&2
        read -p "Press enter to continue"

        if [ -e "$REPO_PATH/files/.zsh_history" ]; then
            mv -f "$REPO_PATH/files/.zsh_history" /home/christian/.zsh_history
        fi
    fi

    link_and_save "$REPO_PATH/files/.zshrc" /home/christian/.zshrc

    link_and_save "$REPO_PATH/files/terminator_config" /home/christian/.config/terminator/config

    read -p "Press enter to continue"
fi

if [ "$AVOID_CMDS" != "YES" ]; then
    INSTALL_PATH="/usr/bin"

    for FILE in $REPO_PATH/commands; do
        NAME="$(basename "$FILE")"

        if [ -e "$INSTALL_PATH/$NAME" ]; then
            echo "$INSTALL_PATH/$NAME already exists" 1>&2
        fi

        sudo ln -s "$FILE" "/usr/bin/$NAME"
    done

    read -p "Press enter to continue"
fi

if [ "$AVOID_X11" != "YES" ]; then
    sudo mv /etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf.orig
    sudo mv "$REPO_PATH/files/xorg.conf.d/30-touchpad.conf" /etc/X11/xorg.conf.d/30-touchpad.conf

    read -p "Press enter to continue"
fi

if [ "$AVOID_VSCODE" != "YES" ]; then
    EXTENSIONS="streetsidesoftware.code-spell-checker \
                waderyan.gitblame \
                ybaumes.highlight-trailing-white-spaces \
                arcticicestudio.nord-visual-studio-code \
                timonwong.shellcheck \
                redhat.vscode-yaml"

    for EXT in $EXTENSIONS; do
        code --install-extension $(echo "$EXT" | tr -s '[:space:]' ' ')
    done
fi

if [ "$AVOID_OTHERS" != "YES" ]; then
    link_and_save "$REPO_PATH/files/.vimrc" /home/christian/.vimrc
    link_and_save "$REPO_PATH/files/.warprc" /home/christian/.warprc
    link_and_save "$REPO_PATH/files/.gdbinit" /home/christian/.gdbinit
fi