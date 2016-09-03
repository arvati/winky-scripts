#!/bin/bash
#
# This script will prep Baytrail based ChromeOS devices for GalliumOS installation
# Based on script originally made by Matt Devo	<mrchromebox@gmail.com>
# May be freely distributed and modified as needed, as long as proper attribution is given.
#

#define these here for easy updating
script_date="[2016-09-03] BETA"
isChromeOS=true
isBaytrail=false
baytrail=('<winky>');

#where the stuff is
chrx_url="https://chrx.org/go"
source_url="https://github.com/arvati/winky-scripts/raw/master/sources/"
seabios_baytrail="seabios-byt-mrchromebox-20160805.bin"

#menu text output
NORMAL=$(echo "\033[m")
MENU=$(echo "\033[36m") #Blue
NUMBER=$(echo "\033[33m") #yellow
FGRED=$(echo "\033[41m")
RED_TEXT=$(echo "\033[31m")
GRAY_TEXT=$(echo "\033[1;30m")
ENTER_LINE=$(echo "\033[33m")

function echo_red()
{
echo -e "\E[0;31m$1"
echo -e '\e[0m'
}

function echo_green()
{
echo -e "\E[0;32m$1"
echo -e '\e[0m'
}

function echo_yellow()
{
echo -e "\E[1;33m$1"
echo -e '\e[0m'
}

function exit_red()
{
    echo_red "$@"
    read -p "Press [Enter] to return to the main menu."
}

function die()
{
    echo_red "$@"
    exit 1
}

###################
# flash RW_LEGACY #
###################
function flash_rwlegacy()
{
# set dev mode boot flags 
    crossystem dev_boot_legacy=1 dev_boot_signed_only=0 > /dev/null 2>&1

echo_green "\nInstall/Update Legacy BIOS (RW_LEGACY)"

#determine proper file 
if [ "$isBaytrail" = true ]; then
    seabios_file=$seabios_baytrail
else
    echo_red "Unknown or unsupported device (${device}); cannot update Legacy BIOS."; return 1
fi

#download SeaBIOS update
echo_yellow "\nDownloading Legacy BIOS update"
curl -s -L -O ${source_url}${seabios_file}.md5
curl -s -L -O ${source_url}${seabios_file}

#verify checksum on downloaded file
md5sum -c ${seabios_file}.md5 --quiet 2> /dev/null
[[ $? -ne 0 ]] && { exit_red "Legacy BIOS download checksum fail; download corrupted, cannot flash"; return 1; }


#flash updated legacy BIOS
echo_yellow "Installing Legacy BIOS / RW_LEGACY (${seabios_file})"
${flashromcmd} -w -i RW_LEGACY:${seabios_file} > /dev/null 2>&1
echo_green "Legacy BIOS successfully updated."  
}


######################
# update legacy BIOS #
######################
function update_rwlegacy()
{
flash_rwlegacy
read -p "Press [Enter] to return to the main menu."
}


###################################
# Install GaOS/Ubuntu (dual boot) #
###################################
function chrx() 
{
echo_green "\nUbuntu / Dual Boot Install"
echo_green "Now using reynhout's chrx script - www.chrx.org"

echo_green "Stage 1: Flashing Legacy BIOS / RW_LEGACY "
#update legacy BIOS
echo_green "Now using Matt DeVillier's flash rwlegacy update script - https://github.com/MattDevo/scripts"
flash_rwlegacy > /dev/null
echo_yellow "Stage 1 / rwlegacy update completed, moving on."

echo_green "Stage 2: Installing GalliumOS via chrx"
#init vars
ubuntu_package="galliumos"
ubuntu_version="latest"
target_disk="/dev/mmcblk1"
locale="pt_BR.UTF-8"
fuse="America/Sao_Paulo"
user="manager"
machine="fly"

#select Ubuntu metapackage
validPackages=('<galliumos>' '<ubuntu>' '<kubuntu>' '<lubuntu>' '<xubuntu>' '<edubuntu>');
echo -e "\nEnter the Ubuntu (or Ubuntu-derivative) to install.  Valid options are `echo ${validPackages[*]}`.
If no (valid) option is entered, 'galliumos' will be used."
read -p "" ubuntu_package	
packageValid=$(echo ${validPackages[*]} | grep "<$ubuntu_package>")
if [[ "$ubuntu_package" = "" || "$packageValid" = "" ]]; then
	ubuntu_package="galliumos"
fi
#select Ubuntu version
useBeta=""
if [ "$ubuntu_package" != "galliumos" ]; then
	validVersions=('<lts>' '<latest>' '<dev>' '<15.10>' '<15.04>' '<14.10>' '<14.04>');
	echo -e "\nEnter the Ubuntu version to install. Valid options are `echo ${validVersions[*]}`. 
If no (valid) version is entered, 'latest' will be used."
	read -p "" ubuntu_version	
	versionValid=$(echo ${validVersions[*]} | grep "<$ubuntu_version>")
	if [[ "$ubuntu_version" = "" || "$versionValid" = "" ]]; then
		ubuntu_version="latest"
	fi
else
    read -p "Do you wish use the latest beta version? [Y/n] "
    [[ "$REPLY" != "n" && "$REPLY" != "N" ]] && useBeta="-r nightly"
fi

#Install More Packages?
packages_install=""
read -p "Do you wish to install additional Packages ? [Y/n] "
if [[ "$REPLY" != "n" && "$REPLY" != "N" ]]; then
	packages_install="-p minecraft -p steam -p kodi -p admin-misc -p chrome"
fi

echo_green "\nInstallation is ready to begin.\nThis is going to take some time, so be patient."
read -p "Press [Enter] to continue..."
echo -e ""
#Install via chrx
export CHRX_NO_REBOOT=1
curl -L -s -o chrx ${chrx_url}


#todo: need to give option to choose username, locale and timeshift

sh ./chrx -d ${ubuntu_package} -r ${ubuntu_version} -H ${machine} -U ${user} -L ${locale} -Z ${fuse} -t ${target_disk} -y ${packages_install} ${useBeta}

#chrx will end with prompt for user to press enter to reboot
read -p ""
cleanup;
reboot;
}


##################
# GalliumOS Menu #
##################

function menu_galliumos() {
    clear
	echo -e "${NORMAL}\n Chromebook Winky Setup ${script_date} ${NORMAL}"
    	echo -e "${MENU}*********************************************${NORMAL}"
	echo -e "${MENU}**${NUMBER}  1)${MENU} Install GalliumOS/Ubuntu on SDCard${NORMAL}"
	echo -e "${MENU}**${NUMBER}  2)${MENU} Update Legacy BIOS (SeaBIOS)${NORMAL}"
	echo -e "${MENU}**${NORMAL}"
	echo -e "${MENU}**${NUMBER}  3)${NORMAL} Reboot ${NORMAL}"
	echo -e "${MENU}**${NUMBER}  4)${NORMAL} Power Off ${NORMAL}"
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${ENTER_LINE}Select a menu option or ${RED_TEXT}q to quit${NORMAL}"
    
	read opt
	
	while [ opt != '' ]
		do
		if [[ $opt = "q" ]]; then 
				exit;
		else	
			case $opt in
			
			1)	clear;
				chrx;
				menu_galliumos;
				;;
			2)	clear;
				update_rwlegacy;	
				menu_galliumos;			
				;;			
			3)	echo -e "\nRebooting...\n";
				cleanup;
				reboot;
				exit;
				;;
			4)	echo -e "\nPowering off...\n";
				cleanup;
				poweroff;
				exit;
				;;
			q)	cleanup;
				exit;
				;;
			\n)	cleanup;
				exit;
				;;
			*)	clear;
				menu_galliumos;
				;;
		esac
	fi
	done
}

################
# Prelim Setup #
################

function prelim_setup() 
{

# Must run as root 
[ "$(whoami)" = "root" ] || die "You need to run this script as root; use 'sudo bash <script name>'"

#check for required tools
which dmidecode > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo_red "Required package 'dmidecode' not found; cannot continue.  Please install and try again."
    return 1
fi
which tar > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo_red "Required package 'tar' not found; cannot continue.  Please install and try again."
    return 1
fi
which md5sum > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo_red "Required package 'md5sum' not found; cannot continue.  Please install and try again."
    return 1
fi


#get device name
device=$(dmidecode -s system-product-name | tr '[:upper:]' '[:lower:]' | awk 'NR==1{print $1}')
if [[ $? -ne 0 || "${device}" = "" ]]; then
    echo_red "Unable to determine Chromebox/book model; cannot continue."
    return 1
fi
[[ "${baytrail[@]}" =~ "$device" ]] && isBaytrail=true

#check if running under ChromeOS
if [ -f /etc/lsb-release ]; then
    cat /etc/lsb-release | grep "Chrome OS" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        isChromeOS=false
    fi
else
    isChromeOS=false
fi
    
if [ "$isChromeOS" = true ]; then
    #disable power mgmt
    initctl stop powerd > /dev/null 2>&1
    #set cmds
    flashromcmd=/usr/sbin/flashrom
else
    echo_red "Script only works on ChromeOS; cannot continue. Recovery it first."
    return 1
fi

if [ "$isBaytrail" = false ]; then
    echo_red "Script only works on Winky Chromebook; cannot continue."
    return 1
fi

#start with a known good state
cleanup

#get required tools
if [ ! -f ${flashromcmd} ]; then
    echo_red "Unable to use flashrom utility; cannot continue"
    return 1
fi

return 0
}


###########
# Cleanup #
###########
function cleanup() 
{
#umount sdcard that is be used to install GalliumOS
umount /dev/mmcblk1p1 > /dev/null 2>&1
}


#set working dir
cd /tmp

#do setup stuff
prelim_setup
[[ $? -ne 0 ]] && exit 1

#show menu
menu_galliumos
