#!/usr/bin/fish

echo -e "\n\nUpdate:" ;and sudo apt update \
     ;and echo -e "\n\nUpgrade:" ;and sudo apt upgrade \
     ;and echo -e "\n\nFull upgrade:" ;and sudo apt full-upgrade \
     ;and echo -e "\n\nStill remaining:" ;and apt list --upgradable
     ;and echo -e "\n\nSnaps:" ;and sudo snap refresh
