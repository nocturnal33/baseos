#!/usr/bin/env bash

# Define the directory variable
vncdir="/home/operator/.vnc"

# Check if the VNC directory exists, create it if it does not
if [ ! -d "$vncdir" ]; then
  mkdir -p "$vncdir"
  echo "Created directory: $vncdir"
fi

# Outputting information for user
echo "Setting VNC password..."

# Generate an 8-character alphanumeric password
pw=$(openssl rand -base64 12 | tr -cd '[:alnum:]' | tr -d '\n' | cut -c1-8) 

# Use the password with vncpasswd to generate the appropriate file
echo -n $pw | vncpasswd -f > "${vncdir}/passwd"

# # Find the string and replace it with the auto generated password
# sed -i "s/{{THAYERPW}}/${pw}/g" /usr/share/novnc/vnc_lite.html

