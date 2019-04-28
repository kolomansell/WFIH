#!/usr/bin/env bash
set -x

INSTALLER="$(dirname "$0")/installer"
export WINEPREFIX="/home/$USER/Downloads/F360/" #TODO user be able to add own install path

function prepare_installer () {
  #download installer from autodesk site and name as "Fusion360.exe"
  if [ ! -f "$INSTALLER/Fusion360.exe" ]; then
  wget https://dl.appstreaming.autodesk.com/production/installers/Fusion%20360%20Client%20Downloader.exe -O "$INSTALLER"/Fusion360.exe
  fi
  7z e -o$INSTALLER/ -y "$INSTALLER"/Fusion360.exe
  unzip "$INSTALLER"/python35.zip platform.pyc -d "$INSTALLER"
  uncompyle6 -o "$INSTALLER"/platform.py "$INSTALLER"/platform.pyc
  sed -i -e 's/winver._platform_version or winver/winver/g' "$INSTALLER"/platform.py
  sed -i -e 's/return uname().system/return "Windows"/g' "$INSTALLER"/platform.py
  sed -i -e 's/return uname().release/return "7"/g' "$INSTALLER"/platform.py
  sed -i -e 's/return uname().version/return "6.1.7601"/g' "$INSTALLER"/platform.py
  echo "installer ready"
}

function prepare_wineprefix () {
  echo $WINEPREFIX
  wine wineboot
  winetricks vcrun2017 win7 wininet winhttp corefonts
}

#prepare_installer
prepare_wineprefix

# TODO: install gecko,mono(mono-complete=suse)
#sed replace
# sed -i -e 's/few/asd/g' hello.txt
# 747 windows
# return uname().system
# 766
# return uname().release
# 775 return uname().version
# maj, min, build = winver._platform_version or winver[:3]
# maj, min, build = winver[:3]
#    def system() : change the return value to 'Windows'
#    def release() : change the return value to '7'
#    def version() : change the return value to '6.1.7601'
# https://dl.appstreaming.autodesk.com/production/installers/Fusion%20360%20Client%20Downloader.exe

#TODO: cleanup
# ctrl+C traps -> cleanup
