#!/bin/bash
trap "Clean" EXIT
trap "Clean; exit 1" INT TERM

if [[ $1 != "NoColor" && $2 != "NoColor" ]]; then
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
    [[ -n $2 ]] && echo "${Color_R}* $2 ${Color_N}"
    echo
    exit 1
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
kernelcache.release.n90
)

Main() {
    Echo "***** iPhone4Down *****"
    Echo "* Script by LukeZGD"
    echo
    Echo "Mode: Ramdisk"
    Echo "* This uses files and script from 4tify by Zurac-Apps"
    Echo "* Make sure that your device is already in DFU mode"

    if [[ $OSTYPE == "linux"* ]]; then
        platform="linux"
        cherry="./ch3rryflower/Tools/ubuntu/UNTETHERED"
        ExpectSudo=sudo
    elif [[ $OSTYPE == "darwin"* ]]; then
        platform="macos"
        cherry="ch3rryflower/Tools/macos/UNTETHERED"
    fi
    iproxy="./libimobiledevice_$platform/iproxy"
    irecovery="./tools/irecovery_$platform"
    irecovery2="./libimobiledevice_$platform/irecovery"
    partialzip="./tools/partialzip_$platform"
    if [[ $platform == "linux" ]]; then
        irecovery="sudo LD_LIBRARY_PATH=./lib $irecovery"
        irecovery2="sudo LD_LIBRARY_PATH=./lib $irecovery2"
    fi

    mkdir tmp 2>/dev/null

    if [[ ! -d ramdisk ]]; then
        JailbreakLink=https://github.com/Zurac-Apps/4tify/raw/ad319e2774f54dc3a355812cc287f39f7c38cc66
        cd tmp
        mkdir ramdisk
        cd ramdisk
        Log "Downloading ramdisk files from 4tify repo..."
        for file in "${Ramdisk[@]}"; do
            curl -L $JailbreakLink/support_files/7.1.2/Ramdisk/$file -o $file
        done
        cd ..
        cp -rf ramdisk ..
        cd ..
    fi

    if [[ ! -d ch3rryflower ]]; then
        Error "Install dependencies with the restore script first!"
    fi

    Log "Entering pwnDFU mode..."
    $ExpectSudo $cherry/pwnedDFU -p
    [[ $? != 0 ]] && Error "Failed to enter pwnDFU mode. Please run the script again"

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

    Log "Device should now be in SSH ramdisk mode."
    echo
    Echo "* To access SSH ramdisk, run iproxy first:"
    Echo "    iproxy 2022 22"
    Echo "* Then SSH to 127.0.0.1:2022"
    Echo "    ssh -p 2022 root@127.0.0.1"
    Echo "* Enter root password: alpine"
    Echo "* Mount filesystems with these commands:"
    Echo "    mount_hfs /dev/disk0s1s1 /mnt1"
    Echo "    mount_hfs /dev/disk0s1s2 /mnt1/private/var"
    exit 0
}

cd "$(dirname $0)"
Main $1
