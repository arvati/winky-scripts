# Install scripts to dual boot ChromeOS and Linux

Collection of scripts, based on MattDevo scripts available here: [https://github.com/MattDevo/scripts](https://github.com/MattDevo/scripts)


MattDevo scripts were here adapted to make a dual boot system with linux and chromeos and they are tested to work on Samsung Chromebook 2 Baytrail - Winky


First you need your Chromebook in  [developer mode](https://www.chromium.org/chromium-os/poking-around-your-chrome-os-device#TOC-Putting-your-Chrome-OS-Device-into-Developer-Mode) and a micro sdcard (class 10 required) to boot linux from.


Then just run this script and choose options available to have a fully dual boot system, running ChromeOS when you choose CTRL+D (developer mode) or an Linux System when you choose CTRL+L running from your sdcard.

&nbsp;
**How to begin**


This script is under development and not ready to use yet, you have instructions on how to execute it soon.

&nbsp;
**What happens behind the scenes**


1. firmware will be updated and a new legacy boot payload (RW_LEGACY) will be flashed on your machine. There will be always risks on this procedure, so be aware of them. There is no need to remove write-protect screw to run this. Firmware comes from [MattDevo scripts](https://github.com/MattDevo/scripts).


2. [chrx](https://chrx.org/) will be executed afterwords


3. [GalliumOS](https://galliumos.org/) will be installed on your sdcard



&nbsp;
**Supported Devices**


Only Samsung Chromebooks 2 Baytrail - WINKY
