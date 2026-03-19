#!/bin/bash

NEW_USER=${USER:-operator}

echo "Setting password to /tmp/vncpwd ..."

# Generate a safe alphanumeric password
upw=$(openssl rand -base64 12 | tr -cd '[:alnum:]' | cut -c1-12)

# Ensure the user exists (created in Dockerfile)
if ! id "${NEW_USER}" >/dev/null 2>&1; then
  echo "Error: user ${NEW_USER} does not exist. Create it in the Dockerfile before running this script."
  exit 1
fi

# Set the user password
echo "${NEW_USER}:${upw}" | chpasswd

# Add to sudo group and grant nopasswd sudo
usermod -aG sudo "${NEW_USER}"
echo "${NEW_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${NEW_USER}"
chmod 440 "/etc/sudoers.d/${NEW_USER}"

# Save password (for testing only)
echo "${upw}" > /tmp/vncpwd
chmod 600 /tmp/vncpwd
chown root:root /tmp/vncpwd

echo "Password saved to /tmp/vncpwd"
