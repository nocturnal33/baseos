#!/bin/bash

# Remove logout actions panel
xfconf-query -c xfce4-panel -p /plugins/plugin-14 -r -R
xfce4-panel -r


