#!/bin/bash
#
# This script will prep Baytrail based ChromeOS devices for GalliumOS installation
# Based on script originally made by Matt Devo	<mrchromebox@gmail.com>
# May be freely distributed and modified as needed, as long as proper attribution is given.
#

#where the stuff is
script_url="https://github.com/arvati/winky-scripts/raw/master/"
dropbox_url="https://github.com/arvati/winky-scripts/raw/master/sources/"

#set working dir
cd /tmp

#get support scripts
rm -rf firmware.sh >/dev/null &2>1
rm -rf functions.sh >/dev/null &2>1
rm -rf sources.sh >/dev/null &2>1
rm -rf kodi.sh >/dev/null &2>1
curl -s -L -O ${script_url}firmware.sh
rc0=$?
curl -s -L -O ${script_url}functions.sh
rc1=$?
curl -s -L -O ${script_url}sources.sh
rc2=$?
curl -s -L -O ${script_url}kodi.sh
rc3=$?
if [[ $rc0 -ne 0 || $rc1 -ne 0 || $rc2 -ne 0 || $rc3 -ne 0 ]]; then
	echo -e "Error downloading one or more required files; cannot continue"
	exit 1
fi

source ./sources.sh
source ./firmware.sh
source ./functions.sh
source ./kodi.sh

#do setup stuff
prelim_setup
[[ $? -ne 0 ]] && exit 1

#show menu
menu_kodi
