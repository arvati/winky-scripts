#!/bin/bash
#


###################
# flash RW_LEGACY #
###################
function flash_rwlegacy()
{

#set working dir
cd /tmp

# set dev mode boot flags 
if [ "${isChromeOS}" = true ]; then
    crossystem dev_boot_legacy=1 dev_boot_signed_only=0 > /dev/null 2>&1
fi

echo_green "\nInstall/Update Legacy BIOS (RW_LEGACY)"

#determine proper file 
#if [[ "$isHswBox" = true || "$isBdwBox" = true ]]; then
#    seabios_file=$seabios_hswbdw_box
#elif [ "$isHswBook" = true ]; then
#    seabios_file=$seabios_hsw_book
#elif [ "$isBdwBook" = true ]; then
#    seabios_file=$seabios_bdw_book

if [ "$isBaytrail" = true ]; then
    seabios_file=$seabios_baytrail
else
    echo_red "Unknown or unsupported device (${device}); cannot update Legacy BIOS."; return 1
fi


#preferUSB=false
#useHeadless=false
#if [ -z "$1" ]; then
    #echo -e ""
    #USB boot priority
    #read -p "Default to booting from USB? If N, always boot from internal storage unless selected from boot menu. [y/N] "
    #[[ "$REPLY" = "y" || "$REPLY" = "Y" ]] && preferUSB=true    
    #echo -e ""
    #headless?
    #if [ "$seabios_file" = "$seabios_hswbdw_box" ]; then
    #    read -p "Install \"headless\" firmware? This is only needed for servers running without a connected display. [y/N] "
    #    [[ "$REPLY" = "y" || "$REPLY" = "Y" ]] && useHeadless=true
    #    echo -e ""
    #fi
#fi

#download SeaBIOS update
echo_yellow "\nDownloading Legacy BIOS update"
curl -s -L -O ${dropbox_url}${seabios_file}.md5
curl -s -L -O ${dropbox_url}${seabios_file}

#verify checksum on downloaded file
md5sum -c ${seabios_file}.md5 --quiet 2> /dev/null
[[ $? -ne 0 ]] && { exit_red "Legacy BIOS download checksum fail; download corrupted, cannot flash"; return 1; }

#preferUSB?
#if [ "$preferUSB" = true  ]; then
#    curl -s -L -o bootorder "${dropbox_url}bootorder.usb"
#    if [ $? -ne 0 ]; then
#        echo_red "Unable to download bootorder file; boot order cannot be changed."
#    else
#        ${cbfstoolcmd} ${seabios_file} remove -n bootorder > /dev/null 2>&1
#        ${cbfstoolcmd} ${seabios_file} add -n bootorder -f /tmp/bootorder -t raw > /dev/null 2>&1
#    fi      
#fi
#useHeadless?
#if [ "$useHeadless" = true  ]; then
#    curl -s -L -O "${dropbox_url}${hswbdw_headless_vbios}"
#    if [ $? -ne 0 ]; then
#        echo_red "Unable to download headless VGA BIOS; headless firmware cannot be installed."
#    else
#        ${cbfstoolcmd} ${seabios_file} remove -n pci8086,0406.rom > /dev/null 2>&1
#        rc0=$?
#        ${cbfstoolcmd} ${seabios_file} add -f ${hswbdw_headless_vbios} -n pci8086,0406.rom -t optionrom > /dev/null 2>&1
#        rc1=$?
#        if [[ "$rc0" -ne 0 || "$rc1" -ne 0 ]]; then
#            echo_red "Warning: error installing headless VGA BIOS"
#        else
#            echo_yellow "Headless VGA BIOS installed"
#        fi
#    fi      
#fi

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



########################
# Firmware Update Menu #
########################
function menu_fwupdate() {
    clear
    echo -e "${NORMAL}\n ChromeOS device Firmware Utility ${script_date} ${NORMAL}"
    echo -e "${NORMAL} (c) Matt Devo <mr.chromebox@gmail.com>\n ${NORMAL}"
    echo -e "${NORMAL} Paypal towards beer/programmer fuel welcomed at above address :)\n ${NORMAL}"
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${MENU}**${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Install/Update Legacy BIOS in RW_LEGACY slot${NORMAL}"
    echo -e "${MENU}**${NORMAL}"
    echo -e "${MENU}**${NUMBER} 8)${NORMAL} Reboot ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 9)${NORMAL} Power Off ${NORMAL}"
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${ENTER_LINE}Select a menu option or ${RED_TEXT}q to quit${NORMAL}"
    
    read opt
            
    while [ opt != '' ]
        do
        if [[ $opt = "q" ]]; then 
                exit;
        else
            #options always available
            case $opt in
                
                1)  update_rwlegacy;    
                    menu_fwupdate;
                    ;;                   
                8)  echo -e "\nRebooting...\n";
                    cleanup;
                    reboot;
                    exit;
                    ;;
                9)  echo -e "\nPowering off...\n";
                    cleanup;
                    poweroff;
                    exit;
                    ;;
                q)  cleanup;
                    exit;
                    ;;
                \n) cleanup;
                    exit;
                    ;;
                *)  clear;
                    menu_fwupdate;
                    ;;
            esac
        fi
    done
}


