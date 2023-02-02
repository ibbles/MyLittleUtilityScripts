#!/bin/bash

dpkg --get-selections | grep --quiet vlc-plugin-access-extra
if [ $? -ne 0 ] ; then
    echo "Don't have vlc-plugin-access-extra installed. Screen capture may not work."
fi

cvlc \
     --no-video-deco \
     --no-embedded-video \
     --screen-fps=20 \
     --screen-top=0 \
     --screen-left=0 \
     --screen-width=1920 \
     --screen-height=1080 \
     screen://
