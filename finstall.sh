#!/usr/bin/env bash
set -x

### Color codes (every script needs to be fabulous with style right from the beginning)
FC0="\033[0m" #normal
FB="\033[1m" #bold
FG="\033[2m" #grayed out
FI="\033[3m" #italic
FU="\033[4m" #underlined
CBG="\E[1;30;42m" #black foreground, green BG (bold)
CBY="\E[1;30;43m" #black FG, yellow BG (bold)
CBR="\E[1;30;41m" #black FG, red BG (bold)
ERR="$CBR ERROR:$FC0"
WARN="$CBY WARNING:$FC0"
SUCCESS="$CBG SUCCESS:$FC0"

INSTALLER="$(dirname "$0")/installer"
AUTODESK_SITE="https://dl.appstreaming.autodesk.com/production/installers/Fusion%20360%20Client%20Downloader.exe"
export WINEPREFIX="/home/$USER/Downloads/F360/" #TODO user be able to add own install path

function basic_checks () {
  # check directory structure + create if not existing
  if [ ! -d $INSTALLER ]; then mkdir -p $INSTALLER; fi
  if [ ! -d $WINEPREFIX ]; then mkdir -p $WINEPREFIX; fi
  # Check autodesk site availability TODO not working, find some less retarded way
  #SITE_TEST=$(curl -sv "$AUTODESK_SITE")
  #if [ $? != 23 ]; then
  #  printf "\n$ERR Autodesk site not reachable.\n"
  #  printf "Check you connection or download installer manually from:\n"
  #  printf "$AUTODESK_SITE"
  #  printf "and put it into folder $INSTALLER under name 'Fusion360.exe'"
  #  printf "Afterwards run the installer again."
  #  exit 1
  #fi
}

function prepare_installer () {
  #download installer from autodesk site and name as "Fusion360.exe"
  if [ ! -f "$INSTALLER/Fusion360.exe" ]; then
  wget $AUTODESK_SITE -O "$INSTALLER"/Fusion360.exe
  fi
  7z e -o$INSTALLER/ -y "$INSTALLER"/Fusion360.exe
  if [ ! -e "$INSTALLER/python35.zip"  ]; then
    printf "\n$ERR python35.zip missing, something wen during installer decompression.\n "
    printf "\n Installer will not continue\n"
    exit 1
  fi
  unzip "$INSTALLER"/python35.zip platform.pyc -d "$INSTALLER"
  if [ ! -e "$INSTALLER/platform.pyc" ]; then
    printf "\n$ERR platform.pyc missing, something wen during decompression.\n "
    printf "\n Installer will not continue\n"
    exit 1
  fi
  uncompyle6 -o "$INSTALLER"/platform.py "$INSTALLER"/platform.pyc
  sed -i -e 's/winver._platform_version or winver/winver/g' "$INSTALLER"/platform.py
  sed -i -e 's/return uname().system/return "Windows"/g' "$INSTALLER"/platform.py
  sed -i -e 's/return uname().release/return "7"/g' "$INSTALLER"/platform.py
  sed -i -e 's/return uname().version/return "6.1.7601"/g' "$INSTALLER"/platform.py
  printf "\n$SUCCESS installer ready\n"
}

function prepare_wineprefix () {
  echo $WINEPREFIX
  wine wineboot
  winetricks vcrun2017 win7 wininet winhttp corefonts
  printf "$SUCCESS Wineprefix preparation done"
}

basic_checks
prepare_installer
prepare_wineprefix

# TODO: install gecko,mono(mono-complete=suse), 7z
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
