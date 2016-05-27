#!/bin/bash
#


#misc globals
#usb_devs=""
#num_usb_devs=0
#usb_device=""
isChromeOS=true
#isChromiumOS=false
flashromcmd=""
#cbfstoolcmd=""
#gbbutilitycmd=""
#preferUSB=false
#useHeadless=false
#addPXE=false
#pxeDefault=false
#isHswBox=false
#isBdwBox=false
#isHswBook=false
#isBdwBook=false
isBaytrail=false

#hsw_boxes=('<panther>' '<zako>' '<tricky>' '<mccloud>');
#hsw_books=('<falco>' '<leon>' '<monroe>' '<peppy>' '<wolf>');
#bdw_boxes=('<guado>' '<rikku>' '<tidus>');
#bdw_books=('<auron_paine>' '<auron_yuna>' '<gandof>' '<lulu>' '<samus>');
#baytrail=('<ninja>' '<gnawty>' '<banjo>' '<squawks>' '<quawks>' '<enguarde>' '<candy>' '<kip>' '<clapper>' '<glimmer>' '<winky>' '<swanky>' '<heli>' '<orco>' '<sumo>');
baytrail=('<winky>');

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



################
# Get flashrom #
################
function get_flashrom()
{
if [ ! -f ${flashromcmd} ]; then
	
	echo_red "Error finding flashrom."
	return 1	
	
    #working_dir=`pwd`
    #cd /tmp
    #curl -s -L -O "${dropbox_url}"flashrom.tar.gz
    #if [ $? -ne 0 ]; then 
    #    echo_red "Error downloading flashrom; cannot proceed."
        #restore working dir
    #    cd ${working_dir}
    #    return 1
    #fi
    #tar -zxf flashrom.tar.gz
    #if [ $? -ne 0 ]; then 
    #    echo_red "Error extracting flashrom; cannot proceed."
        #restore working dir
    #    cd ${working_dir}
    #    return 1
    #fi
    #set +x
    #chmod +x flashrom
    #restore working dir
    #cd ${working_dir}
fi
return 0    
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
#[[ "${hsw_boxes[@]}" =~ "$device" ]] && isHswBox=true
#[[ "${bdw_boxes[@]}" =~ "$device" ]] && isBdwBox=true
#[[ "${hsw_books[@]}" =~ "$device" ]] && isHswBook=true
#[[ "${bdw_books[@]}" =~ "$device" ]] && isBdwBook=true
[[ "${baytrail[@]}" =~ "$device" ]] && isBaytrail=true

#check if running under ChromeOS / ChromiumOS
if [ -f /etc/lsb-release ]; then
    cat /etc/lsb-release | grep "Chrome OS" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        isChromeOS=false
    fi
    #cat /etc/lsb-release | grep "Chromium OS" > /dev/null 2>&1
    #if [ $? -eq 0 ]; then
    #    isChromiumOS=true
    #fi
else
    isChromeOS=false
    #isChromiumOS=false
fi
    
if [ "$isChromeOS" = true ]; then
    #disable power mgmt
    initctl stop powerd > /dev/null 2>&1
    #set cmds
    flashromcmd=/usr/sbin/flashrom
    
    #cbfstoolcmd=/tmp/boot/util/cbfstool
    #gbbutilitycmd=$(which gbb_utility)
else
    echo_red "Script only works on ChromeOS; cannot continue. Recovery it first."
    return 1
    #set cmds
    #flashromcmd=/tmp/flashrom
    #cbfstoolcmd=/tmp/cbfstool
    #gbbutilitycmd=/tmp/gbb_utility
fi

#start with a known good state
cleanup

#get required tools
get_flashrom
if [ $? -ne 0 ]; then
    echo_red "Unable to use flashrom utility; cannot continue"
    return 1
fi
#get_cbfstool
#if [ $? -ne 0 ]; then
#    echo_red "Unable to download cbfstool utility; cannot continue"
#    return 1
#fi
#get_gbb_utility
#if [ $? -ne 0 ]; then
#    echo_red "Unable to download gbb_utility utility; cannot continue"
#    return 1
#fi

return 0
}


###########
# Cleanup #
###########
function cleanup() 
{
#remove temp files, unmount temp stuff
if [ -d /tmp/boot/util ]; then
    rm -rf /tmp/boot/util > /dev/null 2>&1
fi
umount /tmp/boot > /dev/null 2>&1
umount /tmp/Storage > /dev/null 2>&1
umount /tmp/System > /dev/null 2>&1
umount /tmp/urfs/proc > /dev/null 2>&1
umount /tmp/urfs/dev/pts > /dev/null 2>&1
umount /tmp/urfs/dev > /dev/null 2>&1
umount /tmp/urfs/sys > /dev/null 2>&1
umount /tmp/urfs > /dev/null 2>&1
umount /tmp/usb > /dev/null 2>&1

#umount sdcard that is be used to install GalliumOS
umount /dev/mmcblk1p1 > /dev/null 2>&1
}
