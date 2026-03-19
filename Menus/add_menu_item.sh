#!/bin/bash

COURSE_NAME=$1
# Ensure COURSE_NAME is set
if [[ -z "$COURSE_NAME" ]]; then
    echo "Error: COURSE_NAME is not set. Exiting."
    exit 1
fi

MFILE=xfce-applications.menu
TMPMENU=/etc/tmpMenu
MENU=/etc/xdg/menus
MENU_DESKTOP=/usr/share/applications

cp ${TMPMENU}/${MFILE} ${MENU}/${MFILE}
# Convert COURSE_NAME to lowercase
COURSE_NAME_LOWER=$(echo "$COURSE_NAME" | tr '[:upper:]' '[:lower:]')

# Replace FOO with COURSE_NAME in the menu file
# Replacing FOO in /etc/xdg/menus/xfce-application.menu
sed -i "s|FOO|${COURSE_NAME}|g" "${MENU}/xfce-applications.menu"
sed -i "s|foo|${COURSE_NAME_LOWER}|g" "${MENU}/xfce-applications.menu"
# Create a new desktop directory entry

echo -e "[Desktop Entry]
Version=1.0
Type=Directory
Icon=dlogo.png
Name=${COURSE_NAME}
Comment=${COURSE_NAME}" > "/usr/share/desktop-directories/xfce-${COURSE_NAME_LOWER}.directory"

# chown -R "${USER}:${USER}" "$MENU_DESKTOP"
chown -R "${USER}:${USER}" ${DESKTOP}/*.desktop

exit 0