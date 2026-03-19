# THAYERBASE-NOBLE-CP
This image has copy/paste functionality. The only apps installed are Firefox and VScode. Both are in `/opt/share` with symlinks and aliases built in.

## BUILDING THE IMAGE
This is an Ubuntu Noble (24.04) base image to be used for base_os. To use it, create a Dockerfile:
```bash
FROM public.ecr.aws/o9k6n7s0/thayer/thayerbase:noble-cp
```

You can create one course specific menu with the following. 
```bash
USER root
#This will set the PS1 prompt and the Menu to the same name
ENV COURSE_NAME=ENGG-499
RUN addAppsToMenu ${COURSE_NAME}
RUN createMenu ${COURSE_NAME}
#Make sure to swith back to User
USER ${USER}
```

## SUDO ACCESS
To remove sudo, add the following to the end of the Dockerfile
```bash
############################
#### REMOVE SUDO ACCESS ####
############################
USER root
RUN export SUDO_FORCE_REMOVE=yes && apt-get remove --purge -y sudo

############################
### Change back to operator ###
############################
USER ${USER}
```

## BUILD DATE
This is ONLY for the base image:
There is also a build date environment variable build in. To see when the image was created, in a running docker, open terminal and run: 
```bash
echo $BUILD_DATE
```

You'll see an output similar to this
```bash
operator@ENGG-499 ~ $ echo $BUILD_DATE 
Build Date: Wednesday, April 30, 2025 - 09:41:23
```

If you want a build date for the course image, add this to you dockerfile under the USER $USER section:
```bash
##################
### Build Date ###
##################
RUN echo "Course Build Date: $(date +'%A, %B %d, %Y - %T')" > ${HOME}/.cbd && \
    echo "COURSE_BUILD_DATE='$(cat ~/.cbd)'" >> ${HOME}/.bashrc
```

## DESKTOP SHORTCUTS

There are two different ways to create .desktop files so the course name gets baked in. Use either one that makes sense for you.

### **Method 1**
Create an inline file and place in $COURSEAPPS, which is set to: 
/usr/share/applications/course_apps
The createMenu script will copy it to the Desktop and place in menu

```bash
# Create a VScode Desktop File
RUN echo -e "[Desktop Entry] \
Version=1.0 \
Type=Application \
Name=Visual Studio Code \
Exec=/opt/share/VSCode-linux-x64/bin/code --no-sandbox \
Icon=/opt/share/VSCode-linux-x64/resources/app/resources/linux/code.png \
Terminal=false \
Categories=Development;${COURSE_NAME};" > ${COURSEAPPS}/vscode.desktop
```

### **Method 2** -
Create a file and use COPY to place in $COURSEAPPS. Use `FOO` as the category as shown here: 
```bash
[Desktop Entry]
Version=1.0
Type=Application
Name=VSCode
Exec=/opt/share/VSCode-linux-x64/bin/code --no-sandbox
Icon=/opt/share/VSCode-linux-x64/resources/app/resources/linux/code.png
Path=
Terminal=false
StartupNotify=false
Categories=Development;FOO
```
The `addAppsToMenu` script will sed replace all FOO in Category to $COURSE_NAME


