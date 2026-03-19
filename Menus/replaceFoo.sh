#!/bin/bash

echo -e
COURSE_NAME=$1
echo "Running replaceFoo..."

COURSEAPPS=/usr/share/applications/course_apps
DESKTOPAPPS=/home/operator/Desktop
echo "inspecting files..."

if [ -z "${COURSE_NAME}" ];then
  echo "Error: COURSE_NAME var not set. Exiting..."
  exit 0
fi

echo "Looking for FOO in '${COURSEAPPS}'..."
if [ ! -d "${COURSEAPPS}" ]; then
  echo "Directory ${COURSEAPPS} does not exist!"
  exit 0
fi

shopt -s nullglob
cfiles=("${COURSEAPPS}"/*.desktop)
if [ ${#files[@]} -eq 0 ]; then
  echo "No .desktop files found in ${COURSEAPPS}. Skipping"
fi

dfiles=("${DESTKOP}"/*.desktop)
if [ ${#files[@]} -eq 0 ]; then
  echo "No .desktop files found in ${DESKTOP}. Skipping"
fi

for f in "${cfiles[@]}"; do
    if grep -q '^Categories=' "$f"; then
        sed -i "s/^Categories=.*/Categories=${COURSE_NAME};/" "$f";
    else
        sed -i "/^\[Desktop Entry\]/a Categories=${COURSE_NAME};" "$f";
    fi
done

for f in "${dfiles[@]}"; do
    if grep -q '^Categories=' "$f"; then
        sed -i "s/^Categories=.*/Categories=${COURSE_NAME};/" "$f";
    else
        sed -i "/^\[Desktop Entry\]/a Categories=${COURSE_NAME};" "$f";
    fi
done

# Copy course apps to desktop
cp ${COURSEAPPS}/* ${DESKTOPAPPS}/
chown -R "${USER}:${USER}" ${DESKTOPAPPS}/*.desktop
chmod +x ${DESKTOPAPPS}/*.desktop


exit 0