ARG BASE_IMAGE=ubuntu
ARG BASE_IMAGE_VERSION=24.04
FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION}

LABEL maintainer="nocturnal33"
LABEL description="base OS"

##############################
### SYSTEM-WIDE ENV VARS ###
##############################
ENV DEBIAN_FRONTEND=noninteractive
ENV XDG_SESSION_DESKTOP=xfce
ENV XDG_SESSION_TYPE=x11
ENV XDG_CURRENT_DESKTOP=XFCE
ENV XDG_CONFIG_DIRS=/etc/xdg/xdg-xfce:/etc/xdg

##############################
### USER / SESSION VARS ###
##############################
ARG USER_ID
ENV USER_ID=${USER_ID:-1000}
ARG GROUP_ID
ENV GROUP_ID=${GROUP_ID:-1000}
ENV USER=operator
ENV HOME=/home/${USER}
ENV DESKTOP=${HOME}/Desktop
ENV PERSIST=${HOME}/workspace

ENV VNCPORT=5901
ENV NOVNCPORT=6901
ENV VNCDISPLAY=1920x1080
ENV VNCDEPTH=24
ENV VNCDIR=${HOME}/.vnc

ENV VSCODE=/opt/share/VSCode-linux-x64
ENV PATH=${VSCODE}/bin:$PATH

ENV MENU=/etc/xdg/menus
ENV COURSEAPPS=/usr/share/applications/course_apps
ENV TMPMENU=/etc/tmpMenu

ENV BROWSER=/usr/local/bin/firefox
ENV BROWSER_EXECUTABLE=/usr/local/bin/firefox
ENV BROWSER_NAME=Firefox

# Build Date Info
ARG BUILD_DATE
ENV BUILD_DATE=${BUILD_DATE}
ARG COURSE_BUILD_DATE
ENV COURSE_BUILD_DATE=${COURSE_BUILD_DATE}
ENV AWAKE=1

###########################
### APT PACKAGE INSTALL ###
###########################
ENV PACKAGES=/tmp/Packages
RUN mkdir -p ${PACKAGES}
COPY Packages/* ${PACKAGES}/

RUN apt-get update && apt-get upgrade -y && \
    xargs -a ${PACKAGES}/essentials apt-get install --fix-missing -y && \
    xargs -a ${PACKAGES}/languages apt-get install --fix-missing -y && \
    xargs -a ${PACKAGES}/xfce apt-get install --fix-missing -y && \
    xargs -a ${PACKAGES}/vnc apt-get install --fix-missing -y && \
    xargs -a ${PACKAGES}/editors apt-get install --fix-missing -y && \
    xargs -a ${PACKAGES}/development apt-get install --fix-missing -y && \
    xargs -a ${PACKAGES}/remove apt-get remove --purge -y && \
    rm -rf ${PACKAGES} && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#############################
### LOCALE AND TIMEZONE ###
#############################
ENV TZ=America/New_York
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

##########################
### SCRIPT INSTALLATION ###
##########################
COPY Files/userpw.sh /tmp/userpw.sh
COPY Files/entrypoint.sh /
COPY  --chown=root:root Files/ssl.sh /usr/local/bin/ssl.sh

RUN getent group "${USER}" >/dev/null 2>&1 || groupadd "${USER}" && \
    id -u "${USER}" >/dev/null 2>&1 || useradd -m -s /bin/bash -g "${USER}" "${USER}"

RUN chmod +x /tmp/userpw.sh /usr/local/bin/ssl.sh && \
    /tmp/userpw.sh && rm /tmp/userpw.sh && \
    mkdir -p ${HOME} ${VNCDIR} /opt/share && \
    cp -r /etc/skel/. ${HOME}/ && \
    chown -R ${USER}:${USER} ${HOME} && \
    chmod +x /entrypoint.sh

#############################
### CREATE BASIC FOLDERS ###
#############################
RUN mkdir -p ${HOME}/Documents ${HOME}/Downloads ${DESKTOP} ${PERSIST} && \
    chown -R ${USER}:${USER} ${HOME} && \
    chmod -R 777 ${DESKTOP} && \
    echo "alias code='/opt/share/VSCode-linux-x64/bin/code --no-sandbox'" >> ${HOME}/.bashrc

#############################
### DESKTOP SHORTCUTS ###
#############################
RUN mkdir -p "${COURSEAPPS}"
COPY Desktop_Apps/*.desktop "${COURSEAPPS}/"
RUN chmod 644 "${COURSEAPPS}"/* && chown -R root:root "${COURSEAPPS}"

##########################
### VSCODE + FIREFOX ###
##########################
RUN wget -qO- "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" | tar -zx -C /opt/share/ && \
    chmod 4755 ${VSCODE}/chrome-sandbox && \
    mkdir ${VSCODE}/database && \
    curl -sSL "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" | tar -xJ -C /opt/share/ && \
    ln -s /opt/share/firefox/firefox /usr/local/bin/firefox


#####################
### Google Chrome ###
#####################
RUN apt-get update && \
    apt-get install -y --no-install-recommends fonts-liberation xdg-utils && \
    wget -qO /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y /tmp/google-chrome-stable_current_amd64.deb && \
    sed -i 's/google-chrome-stable %U/google-chrome-stable --no-sandbox %U/g' /usr/share/applications/google-chrome.desktop && \
    rm /tmp/google-chrome-stable_current_amd64.deb && \
    mv /usr/bin/google-chrome-stable /usr/bin/google-chrome-stable-real && \
    printf '#!/bin/bash\nexec /usr/bin/google-chrome-stable-real --no-sandbox "$@"\n' > /usr/bin/google-chrome-stable && \
    chmod +x /usr/bin/google-chrome-stable && \
    echo 'alias google-chrome-stable="google-chrome-stable-real --no-sandbox"' >> ${HOME}/.bashrc

##########################
### VNC CONFIGURATION ###
##########################
COPY VNC/xstartup ${VNCDIR}/
COPY VNC/index.html /usr/share/novnc/
COPY VNC/base.css /usr/share/novnc/app/styles/
COPY VNC/launch.sh /usr/share/novnc/utils/
COPY --chown=${USER}:${USER} VNC/vncpw.sh /tmp/

RUN chmod +x ${VNCDIR}/xstartup /usr/share/novnc/utils/launch.sh /tmp/vncpw.sh && \
    /usr/local/bin/ssl.sh && \
    /tmp/vncpw.sh && \
    chown -R ${USER}:${USER} ${VNCDIR}
    # rm /tmp/vncpw.sh

##########################
### MENU SETUP ###
##########################
RUN mkdir ${TMPMENU}
COPY Menus/images/* /usr/share/pixmaps/
COPY Menus/xfce-applications.menu ${TMPMENU}/
COPY Menus/add_menu_item.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/add_menu_item.sh && \
    ln -s /usr/local/bin/add_menu_item.sh /usr/local/bin/createMenu

# Set Firefox as default web browser
COPY Files/xfce4-web-browser.desktop /usr/share/applications/

##########################
### USER CONTEXT SETUP ###
##########################
USER ${USER}
WORKDIR ${HOME}

##########################
### XFCE USER TWEAKS ###
##########################
ARG AUTOSTART=${HOME}/.config/autostart
COPY --chown=${USER}:${USER} Tweaks/xfce4-tweaks.sh ${VNCDIR}/
COPY --chown=${USER}:${USER} Tweaks/xfce_tweaks.desktop ${AUTOSTART}/
COPY --chown=${USER}:${USER} Tweaks/monitor_location.desktop ${AUTOSTART}/
COPY --chown=${USER}:${USER} Tweaks/fix_unsecure_location.sh ${HOME}/.config/
COPY --chown=${USER}:${USER} Tweaks/gitconfig.sh /usr/local/bin/
COPY --chown=root:root Menus/replaceFoo.sh /usr/local/bin/

RUN sudo chmod +x ${VNCDIR}/xfce4-tweaks.sh ${AUTOSTART}/* ${HOME}/.config/fix_unsecure_location.sh && \
    sudo chmod +x /usr/local/bin/gitconfig.sh /usr/local/bin/replaceFoo.sh && \
    sudo ln -s /usr/local/bin/gitconfig.sh /usr/local/bin/gitconfig && \
    sudo ln -s /usr/local/bin/replaceFoo.sh /usr/local/bin/addAppsToMenu && \
    sudo chown -R ${USER}:${USER} ${HOME}

##########################
### TERMINAL + PROMPT ###
##########################
RUN echo 'export PS1="\[$(tput setaf 214)\]\u\[$(tput setaf 214)\]@\[$(tput setaf 214)\]\${COURSE_NAME} \[$(tput setaf 33)\]\w \[$(tput sgr0)\]$ "' >> ${HOME}/.bashrc && \
    echo "XDG_DATA_DIRS='/home/operator/Desktop:/opt/share:/usr/local/share:/usr/share'" >> ~/.bashrc

##########################
### LOCALE CONFIG FIX ###
##########################
RUN sudo sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sudo locale-gen

##########################
### BUILD DATE BANNER ###
##########################
RUN echo "Build Date: $(date +'%A, %B %d, %Y - %T')" > ${HOME}/.bd && \
    echo "BUILD_DATE='$(cat ~/.bd)'" >> ${HOME}/.bashrc

#########################
### Stay Awake Script ###
#########################
# set ENV AWAKE to 0 to disable
COPY Files/keepAwake.sh /usr/local/bin/keepAwake.sh
RUN sudo chmod +x /usr/local/bin/keepAwake.sh 

##########################
### Git Config Scripts ###
##########################
# GitConfig script
COPY --chown=${USER}:${USER} Files/gitconfig.sh /usr/local/bin/
RUN sudo chmod +x /usr/local/bin/gitconfig.sh && \
    sudo ln -sf /usr/local/bin/gitconfig.sh /usr/local/bin/gitconfig 

## PERSISTENT STORAGE
RUN touch ${PERSIST}/.gitconfig && \
    ln -s ${PERSIST}/.gitconfig ${HOME}/.gitconfig && \
    touch ${PERSIST}/.git-credentials && \
    ln -s ${PERSIST}/.git-credentials ${HOME}/.git-credentials

####################################
### WORKING DIR SET TO WORKSPACE ###
####################################
RUN sudo sed -i -E 's|^Exec=exo-open --launch TerminalEmulator(.*)$|Exec=exo-open --launch TerminalEmulator --working-directory=/home/operator/workspace|' \
  /usr/share/applications/xfce4-terminal-emulator.desktop

###################################
## Entrpoint script to start VNC ##
###################################
ENTRYPOINT ["/entrypoint.sh"]
