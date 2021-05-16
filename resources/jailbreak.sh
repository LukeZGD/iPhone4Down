#!/bin/bash
trap 'Clean; exit' INT TERM EXIT
if [[ $1 != 'NoColor' ]]; then
    Color_R=$(tput setaf 9)
    Color_G=$(tput setaf 10)
    Color_B=$(tput setaf 12)
    Color_Y=$(tput setaf 11)
    Color_N=$(tput sgr0)
fi

Clean() {
    rm -rf tmp/
}

Echo() {
    echo "${Color_B}$1 ${Color_N}"
}

Error() {
    echo -e "\n${Color_R}[Error] $1 ${Color_N}"
    [[ ! -z $2 ]] && echo "${Color_R}* $2 ${Color_N}"
    echo
    exit
}

Input() {
    echo "${Color_Y}[Input] $1 ${Color_N}"
}

Log() {
    echo "${Color_G}[Log] $1 ${Color_N}"
}

Ramdisk=(
058-1056-002.dmg
DeviceTree.n90ap.img3
iBEC.n90ap.RELEASE.dfu
iBSS.n90ap.RELEASE.dfu
kernelcache.release.n90)

Debs=(
org.thebigboss.repo.icons_1.0.deb
cydia_1.1.9_iphoneos-arm.deb
cydia-lproj_1.1.12_iphoneos-arm.deb
coreutils_8.12-13_iphoneos-arm.deb
openssl_0.9.8zg-13_iphoneos-arm.deb
openssh_6.7p1-13_iphoneos-arm.deb)

Jailbreak7=(
com.apple.springboard.plist
Cydia.tar
panguaxe
panguaxe-APT.tar
panguaxe.tar
tar)

if [[ $OSTYPE == "linux-gnu" ]]; then
    platform='linux'
    cherry="ch3rryflower/Tools/ubuntu/UNTETHERED"
    irecovery="sudo tools/irecovery_linux"
    irecovery2="sudo libirecovery/bin/irecovery"
    iproxy="iproxy"
    partialzip="tools/partialzip_linux"
    python="sudo python2"
elif [[ $OSTYPE == "darwin"* ]]; then
    platform='macos'
    cherry="ch3rryflower/Tools/macos/UNTETHERED"
    iproxy="resources/libimobiledevice_$platform/iproxy"
    irecovery="sudo tools/irecovery_macos"
    irecovery2="libimobiledevice_$platform/irecovery"
    partialzip="tools/partialzip_macos"
    python="python"
fi

Echo "***** iPhone4Down *****"
Echo "* Script by LukeZGD"
echo
Echo "Mode: Jailbreak/Ramdisk"
Echo "* This uses files and script from 4tify by Zurac-Apps"
Echo "* Make sure that your device is already in DFU mode"
mkdir tmp 2>/dev/null

if [[ ! -d ramdisk ]]; then # [ ! -d jailbreak7 ]] || 
    JailbreakLink=https://github.com/Zurac-Apps/4tify/raw/ad319e2774f54dc3a355812cc287f39f7c38cc66
    cd tmp
    mkdir ramdisk jailbreak7
    cd ramdisk
    Log "Downloading ramdisk files from 4tify repo..."
    for file in "${Ramdisk[@]}"; do
        curl -L $JailbreakLink/support_files/7.1.2/Ramdisk/$file -o $file
    done
    #cd ../jailbreak7
    #Log "Downloading jailbreak files from 4tify repo..."
    #for file in "${Jailbreak7[@]}"; do
    #    curl -L $JailbreakLink/support_files/7.1.2/Jailbreak/$file -o $file
    #done
    #for file in "${Debs[@]}"; do
    #    curl -L $JailbreakLink/support_files/7.1.2/Jailbreak/$file -o $file
    #done
    cd ..
    cp -rf ramdisk jailbreak7 ..
    cd ..
fi

if [[ ! -d ch3rryflower ]]; then
    Error "Install dependencies with the restore script first!"
fi

Log "Entering pwnDFU mode..."
sudo $cherry/pwnedDFU -p
[ $? != 0 ] && Error "Failed to enter pwnDFU mode. Please run the script again"

Log "Sending iBSS and iBEC..."
$irecovery -f ramdisk/iBSS.n90ap.RELEASE.dfu
sleep 2
$irecovery -f ramdisk/iBEC.n90ap.RELEASE.dfu

Log "Waiting for device..."
while [[ $RecoveryDevice != 1 ]]; do
    [[ $($irecovery2 -q 2>/dev/null | grep 'MODE' | cut -c 7-) == "Recovery" ]] && RecoveryDevice=1
done

cd ramdisk
Log "Booting..."
[[ $platform == linux ]] && ExpectSudo=sudo
$ExpectSudo expect -c "
spawn ../tools/irecovery_$platform -s
expect \"iRecovery>\"
send \"/send DeviceTree.n90ap.img3\r\"
expect \"iRecovery>\"
send \"devicetree\r\"
expect \"iRecovery>\"
send \"/send 058-1056-002.dmg\r\"
expect \"iRecovery>\"
send \"ramdisk\r\"
expect \"iRecovery>\"
send \"/send kernelcache.release.n90\r\"
expect \"iRecovery>\"
send \"bootx\r\"
expect \"iRecovery>\"
send \"/exit\r\"
expect eof"

Log "Waiting for device..."
while [[ $(lsusb | grep -c "iPhone") != 1 ]]; do
    sleep 2
done

#$iproxy 2022 22 &
#cd ../jailbreak7

# Stop here for now (ramdisk only)
Log "Device is now in SSH ramdisk mode"
echo
Echo "* To access SSH ramdisk, run:"
Echo "    iproxy 2222 22"
Echo "* Then SSH to 127.0.0.1:2022"
Echo "    ssh -p 2022 root@127.0.0.1"
Echo "* Enter root password: alpine"
Echo "* Mount filesystems with these commands:"
Echo "    mount_hfs /dev/disk0s1s1 /mnt1"
Echo "    mount_hfs /dev/disk0s1s1 /mnt1/private/var"
exit

# this throws errors for some reason
Log "Mounting filesystems..."
expect -c "
spawn ssh -o StrictHostKeyChecking=no -p 2022 root@127.0.0.1
expect \"root@127.0.0.1's password:\"
send \"alpine\r\"
expect \"sh-4.0#\"
send \"mount_hfs /dev/disk0s1s1 /mnt1\r\"
expect \"sh-4.0#\"
send \"mount_hfs /dev/disk0s1s2 /mnt1/private/var\r\"
expect \"sh-4.0#\"
send \"exit\r\"
expect eof"

Log "Sending jailbreak files..."
expect -c "
spawn scp -P 2022 tar root@127.0.0.1:/bin
expect \"root@127.0.0.1's password:\"
send \"alpine\r\"
expect eof
spawn scp -P 2022 panguaxe.tar Cydia.tar panguaxe-APT.tar panguaxe root@127.0.0.1:/mnt1/private/var
expect \"root@127.0.0.1's password:\"
send \"alpine\r\"
expect eof"

# tar doesn't work when I test for some reason, so this is where the script stops working
Log "Jailbreaking..."
expect -c "
spawn ssh -p 2022 root@127.0.0.1
expect \"root@127.0.0.1's password:\"
send \"alpine\r\"
expect \"sh-4.0#\"
send \"tar -x --no-overwrite-dir -f /mnt1/private/var/panguaxe.tar -C /mnt1 \r\"
expect \"sh-4.0#\"
send \"tar -x --no-overwrite-dir -f /mnt1/private/var/Cydia.tar -C /mnt1 \r\"
expect \"sh-4.0#\"
send \"tar -x --no-overwrite-dir -f /mnt1/private/var/APT.tar -C /mnt1 \r\"
expect \"sh-4.0#\"
send \"tar -x --no-overwrite-dir -f /mnt1/private/var/panguaxe-APT.tar -C /mnt1 \r\"
expect \"sh-4.0#\"
send \"rm -rf /mnt1/panguaxe \r\"
expect \"sh-4.0#\"
send \"cp -a /mnt1/private/var/panguaxe /mnt1 \r\"
expect \"sh-4.0#\"
send \"touch /mnt1/panguaxe.installed \r\"
expect \"sh-4.0#\"
send \"touch /mnt1/private/var/mobile/Media/panguaxe.installed \r\"
expect \"sh-4.0#\"
send \"mkdir -p /mnt1/private/var/root/Media/Cydia/AutoInstall \r\"
expect \"sh-4.0#\"
send \"exit\r\"
expect eof"

Log "Sending debs..."
expect -c "
spawn scp -P 2022 ${Debs[@]} root@127.0.0.1:/mnt1/private/var/root/Media/Cydia/AutoInstall
expect \"root@127.0.0.1's password:\"
send \"alpine\r\"
expect eof"

Log "Patching Springboard..."
expect -c "
spawn scp -P 2022 com.apple.springboard.plist root@127.0.0.1:/mnt1/var/mobile/Library/Preferences
expect \"root@127.0.0.1's password:\"
send \"alpine\r\"
expect eof"

Log "Patching fstab..."
expect -c "
spawn scp -P 2022 fstab root@127.0.0.1:/mnt1/etc
expect \"root@127.0.0.1's password:\"
send \"alpine\r\"
expect eof"

Log "Rebooting..."
expect -c "
spawn ssh -p 2022 root@127.0.0.1
expect \"root@127.0.0.1's password:\"
send \"alpine\r\"
expect \"sh-4.0#\"
send \"reboot_bak\r\"
expect eof"

Log "Done!"
