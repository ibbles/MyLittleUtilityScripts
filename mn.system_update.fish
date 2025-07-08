#!/usr/bin/fish

echo -e "\n\nUpdate:"
sudo apt update

echo -e "\n\nUpgrade:"
sudo apt upgrade

echo -e "\n\nFull upgrade:"
sudo apt full-upgrade

echo -e "\n\nStill remaining:"
apt list --upgradable

if command -q --search snap
    echo -e "\n\nSnaps:"
    sudo snap refresh
end

if command -q --search flatpak
    echo -e "\n\nFlatpaks:"
    flatpak update
end
