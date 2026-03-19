#!/bin/bash

# uncomment if done already for the existing .desktop files in /home/operator/Desktop
for f in /home/operator/Desktop/*.desktop; do gio set -t string "$f" metadata::xfce-exe-checksum "$(sha256sum "$f" | awk '{print $1}')"; done

# monitor new added .desktop launchers (needs inotifywait, from package "inotify-tools") 
inotifywait -m /home/operator/Desktop -e create -e moved_to |
    while read path action file; do
        if [[ "$file" =~ .*desktop$ ]]; then # Does the file end with .desktop?
            echo "$path $file" # If so, do your thing here!
#        chmod +x "$path/$file"
gio set -t string "$path/$file" metadata::xfce-exe-checksum "$(sha256sum "$path/$file" | awk '{print $1}')"
        fi
        
# adjust sleep time as preferred
sleep 2
    done
