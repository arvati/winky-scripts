#!/bin/bash
#


###################################
# Install GaOS/Ubuntu (dual boot) #
###################################
function chrx() 
{
echo_green "\nUbuntu / Dual Boot Install"
echo_green "Now using reynhout's chrx script - www.chrx.org"

target_disk="/dev/mmcblk1"
# Do partitioning (if we haven't already)
#ckern_size="`cgpt show -i 6 -n -s -q ${target_disk}`"
#croot_size="`cgpt show -i 7 -n -s -q ${target_disk}`"
#state_size="`cgpt show -i 1 -n -s -q ${target_disk}`"
#max_ubuntu_size=$(($state_size/1024/1024/2))
#rec_ubuntu_size=$(($max_ubuntu_size - 1))
# If KERN-C and ROOT-C are one, we partition, otherwise assume they're what they need to be...
#if [ "$ckern_size" =  "1" -o "$croot_size" = "1" ]; then

	#update legacy BIOS
	echo_green "Now using Matt DeVillier's flash rwlegacy update script - https://github.com/MattDevo/scripts"
	#flash_rwlegacy skip_usb > /dev/null
	flash_rwlegacy > /dev/null
	
#	echo_green "Stage 1: Repartitioning the internal HDD"
#	while :
#	do
#		echo "Enter the size in GB you want to reserve for Ubuntu."
#		read -p "Acceptable range is 6 to $max_ubuntu_size  but $rec_ubuntu_size is the recommended maximum: " ubuntu_size
#		if [ $ubuntu_size -ne $ubuntu_size 2> /dev/null]; then
#			echo_red "\n\nWhole numbers only please...\n\n"
#			continue
#		elif [ $ubuntu_size -lt 6 -o $ubuntu_size -gt $max_ubuntu_size ]; then
#			echo_red "\n\nThat number is out of range. Enter a number 6 through $max_ubuntu_size\n\n"
#			continue
#		fi
#		break
#	done
	# We've got our size in GB for ROOT-C so do the math...
	#calculate sector size for rootc
#	rootc_size=$(($ubuntu_size*1024*1024*2))
	#kernc is always 16mb
#	kernc_size=32768
	#new stateful size with rootc and kernc subtracted from original
#	stateful_size=$(($state_size - $rootc_size - $kernc_size))
	#start stateful at the same spot it currently starts at
#	stateful_start="`cgpt show -i 1 -n -b -q ${target_disk}`"
	#start kernc at stateful start plus stateful size
#	kernc_start=$(($stateful_start + $stateful_size))
	#start rootc at kernc start plus kernc size
#	rootc_start=$(($kernc_start + $kernc_size))
	#Do the real work
#	echo_green "\n\nModifying partition table to make room for Ubuntu." 
#	umount -f /mnt/stateful_partition > /dev/null 2>&1
	# stateful first
#	cgpt add -i 1 -b $stateful_start -s $stateful_size -l STATE ${target_disk}
	# now kernc
#	cgpt add -i 6 -b $kernc_start -s $kernc_size -l KERN-C -t "kernel" ${target_disk}
	# finally rootc
#	cgpt add -i 7 -b $rootc_start -s $rootc_size -l ROOT-C ${target_disk}
#	echo_green "Stage 1 complete; after reboot, press CTRL-D and ChromeOS will \"repair\" itself."
#	echo_yellow "Afterwards, you must re-download/re-run this script to complete Ubuntu setup."
#	read -p "Press [Enter] to reboot and continue..."
#	cleanup
#	reboot
#	exit
#fi
echo_yellow "Stage 1 / rwlegacy update completed, moving on."
echo_green "Stage 2: Installing GalliumOS via chrx"

#init vars
ubuntu_package="galliumos"
ubuntu_version="latest"

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
if [ "$ubuntu_package" != "galliumos" ]; then
	validVersions=('<lts>' '<latest>' '<dev>' '<15.10>' '<15.04>' '<14.10>' '<14.04>');
	echo -e "\nEnter the Ubuntu version to install. Valid options are `echo ${validVersions[*]}`. 
If no (valid) version is entered, 'latest' will be used."
	read -p "" ubuntu_version	

	versionValid=$(echo ${validVersions[*]} | grep "<$ubuntu_version>")
	if [[ "$ubuntu_version" = "" || "$versionValid" = "" ]]; then
		ubuntu_version="latest"
	fi
fi



#Install More Packages?
kodi_install=""
read -p "Do you wish to install additional Packages ? [Y/n] "
if [[ "$REPLY" != "n" && "$REPLY" != "N" ]]; then
	kodi_install="-p minecraft -p steam -p kodi -p admin-misc"
fi

echo_green "\nInstallation is ready to begin.\nThis is going to take some time, so be patient."

read -p "Press [Enter] to continue..."
echo -e ""

#Install via chrx
export CHRX_NO_REBOOT=1
curl -L -s -o chrx ${chrx_url}

#sh ./chrx -d ${ubuntu_package} -r ${ubuntu_version} -H ChromeBox -y $kodi_install
#todo: need to give option to choose username, locale and timeshift

sh ./chrx -d ${ubuntu_package} -r ${ubuntu_version} -H fly -U manager -L pt_BR.UTF-8 -Z America/Sao_Paulo -t /dev/mmcblk1 -y $kodi_install

#chrx will end with prompt for user to press enter to reboot
read -p ""
cleanup;
reboot;
}





#############
# Kodi Menu #
#############
function menu_kodi() {
    clear
	echo -e "${NORMAL}\n Chromebook Winky Setup ${script_date} ${NORMAL}"
    echo -e "${MENU}*********************************************${NORMAL}"
	#if [ "$isChromeOS" = true ]; then
		echo -e "${MENU}**${NUMBER}  1)${MENU} Install: ChromeOS + GalliumOS/Ubuntu ${NORMAL}"
		echo -e "${MENU}**${NUMBER}  5)${MENU} Update Legacy BIOS (SeaBIOS)${NORMAL}"
		echo -e "${MENU}**${NORMAL}"
	#fi
	echo -e "${MENU}**${NORMAL}"
	echo -e "${MENU}**${NUMBER}  8)${NORMAL} Reboot ${NORMAL}"
	echo -e "${MENU}**${NUMBER}  9)${NORMAL} Power Off ${NORMAL}"
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${ENTER_LINE}Select a menu option or ${RED_TEXT}q to quit${NORMAL}"
    
	read opt
	
	while [ opt != '' ]
		do
		if [[ $opt = "q" ]]; then 
				exit;
		else
			if [ "$isChromeOS" = true ]; then
				case $opt in
					1)	clear;
						chrx;
						menu_kodi;
						;;
					5)	clear;
						update_rwlegacy;	
						menu_kodi;
						;;
					*)
						;;
				esac
			fi
			
			case $opt in				
			8)	echo -e "\nRebooting...\n";
				cleanup;
				reboot;
				exit;
				;;
			9)	echo -e "\nPowering off...\n";
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
				menu_kodi;
				;;
		esac
	fi
	done
}
