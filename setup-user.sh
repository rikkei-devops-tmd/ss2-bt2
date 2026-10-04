#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="devops"

if id "$TARGET_USER" &>/dev/null; then
    echo "User $TARGET_USER already exists."
else
    adduser --disabled-password --gecos "" "$TARGET_USER"
    usermod -aG sudo "$TARGET_USER"
fi

mkdir -p "/home/$TARGET_USER/.ssh"
if [ -f "/root/.ssh/authorized_keys" ]; then
    cp "/root/.ssh/authorized_keys" "/home/$TARGET_USER/.ssh/authorized_keys"
fi

chown -R "$TARGET_USER:$TARGET_USER" "/home/$TARGET_USER/.ssh"
chmod 700 "/home/$TARGET_USER/.ssh"
chmod 600 "/home/$TARGET_USER/.ssh/authorized_keys"

echo "$TARGET_USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$TARGET_USER"
chmod 440 "/etc/sudoers.d/$TARGET_USER"
