#!/bin/bash
trap 'Clean; exit' INT TERM EXIT
if [[ $1 != 'NoColor' ]]; then
    Color_R=$(tput setaf 9)
    Color_G=$(tput setaf 10)
    Color_B=$(tput setaf 12)
    Color_Y=$(tput setaf 11)
    Color_N=$(tput sgr0)
fi

function Clean {
    rm -rf iP*/ shsh/ tmp/ BuildManifest.plist
}

function Echo {
    echo "${Color_B}$1 ${Color_N}"
}

function Error {
    echo -e "\n${Color_R}[Error] $1 ${Color_N}"
    [[ ! -z $2 ]] && echo "${Color_R}* $2 ${Color_N}"
    echo
    exit
}

function Input {
    echo "${Color_Y}[Input] $1 ${Color_N}"
}

function Log {
    echo "${Color_G}[Log] $1 ${Color_N}"
}

function Main {
    clear
    Echo "***** iPhone4Down *****"
    Echo "* Downgrade script by LukeZGD"
    Echo "* This script uses ch3rryflower by dora2iOS"
    echo
    
    if [[ $OSTYPE == "linux-gnu" ]]; then
        . /etc/os-release 2>/dev/null
        platform="linux"
        ideviceenterrecovery="ideviceenterrecovery"
        ideviceinfo="ideviceinfo"
        idevicerestore="sudo LD_LIBRARY_PATH=resources/lib resources/tools/idevicerestore_linux"
        iproxy="iproxy"
        irecoverychk="resources/libirecovery/bin/irecovery"
        irecovery="sudo LD_LIBRARY_PATH=resources/lib $irecoverychk"
        tsschecker="env LD_LIBRARY_PATH=resources/lib resources/tools/tsschecker_linux"
        cherrydir="resources/ch3rryflower/Tools/ubuntu/UNTETHERED"

    elif [[ $OSTYPE == "darwin"* ]]; then
        platform="macos"
        ideviceenterrecovery="resources/libimobiledevice_$platform/ideviceenterrecovery"
        ideviceinfo="resources/libimobiledevice_$platform/ideviceinfo"
        idevicerestore="resources/tools/idevicerestore_$platform"
        iproxy="resources/libimobiledevice_$platform/iproxy"
        irecovery="resources/libimobiledevice_$platform/irecovery"
        irecoverychk=$irecovery
        tsschecker="resources/tools/tsschecker_$platform"
        cherrydir="resources/ch3rryflower/Tools/macos/UNTETHERED"
    fi
    cherry="$cherrydir/cherry"
    partialzip="resources/tools/partialzip_$platform"
    
    [[ ! -d resources ]] && Error "resources folder cannot be found. Replace resources folder and try again" "If resources folder is present try removing spaces from path/folder name"
    [[ ! $platform ]] && Error "Platform unknown/not supported."
    chmod +x resources/tools/*
    [ $? == 1 ] && Log "An error occurred in chmod. This might cause problems..."
    [[ ! $(ping -c1 google.com 2>/dev/null) ]] && Error "Please check your Internet connection before proceeding."
    [[ $(uname -m) != 'x86_64' ]] && Error "Only x86_64 distributions are supported. Use a 64-bit distro and try again"
    
    if [[ $1 == Install ]] || [ ! $(which $irecoverychk) ] || [ ! $(which $ideviceinfo) ]; then
        cd resources
        rm -rf firmware ipwndfu libimobiledevice_$platform libirecovery
        cd ..
        InstallDependencies
    fi
    
    if [[ ! -d resources/ch3rryflower ]]; then
        cd tmp
        Echo "Downloading ch3rryflower..."
        SaveFile https://github.com/dora2-iOS/ch3rryflower/archive/316d2cdc5351c918e9db9650247b91632af3f11f.zip ch3rryflower.zip 790d56db354151b9740c929e52c097ba57f2929d
        cd ../resources
        unzip -q ../tmp/ch3rryflower.zip -d .
        mv ch3rryflower* ch3rryflower
        cd ..
    fi
    
    Log "Finding device in normal mode..."
    ideviceinfo2=$($ideviceinfo -s)
    if [[ $? != 0 ]]; then
        Log "Finding device in DFU/recovery mode..."
        irecovery2=$($irecovery -q 2>/dev/null | grep 'MODE' | cut -c 7-)
    fi
    [[ $irecovery2 == "DFU" ]] && DFUDevice=1
    [[ $irecovery2 == "Recovery" ]] && RecoveryDevice=1
    
    if [[ $DFUDevice == 1 ]] || [[ $RecoveryDevice == 1 ]]; then
        ProductType=$($irecovery -q | grep 'PTYP' | cut -c 7-)
        [ ! $ProductType ] && read -p "[Input] Enter ProductType (eg. iPhone3,1): " ProductType
        UniqueChipID=$((16#$(echo $($irecovery -q | grep 'ECID' | cut -c 7-) | cut -c 3-)))
    else
        ProductType=$(echo "$ideviceinfo2" | grep 'ProductType' | cut -c 14-)
        [ ! $ProductType ] && ProductType=$($ideviceinfo | grep 'ProductType' | cut -c 14-)
        ProductVer=$(echo "$ideviceinfo2" | grep 'ProductVer' | cut -c 17-)
        VersionDetect=$(echo $ProductVer | cut -c 1)
        UniqueChipID=$(echo "$ideviceinfo2" | grep 'UniqueChipID' | cut -c 15-)
        UniqueDeviceID=$(echo "$ideviceinfo2" | grep 'UniqueDeviceID' | cut -c 17-)
    fi
    [[ $ProductType == iPhone3,1 ]] && HWModel=n90
    [[ $ProductType == iPhone3,2 ]] && HWModel=n90b
    [[ $ProductType == iPhone3,3 ]] && HWModel=n92
    iBSS="iBSS.${HWModel}ap.RELEASE"
    
    if [ ! $UniqueChipID ]; then
        Error "No device detected."
    elif [[ $ProductType != iPhone3* ]]; then
        Error "Your device $ProductType is not supported."
    fi
    
    Clean
    mkdir tmp
    Echo "* Platform: $platform"
    echo
    
    read -p "$(Input 'Is this device jailbroken and have OpenSSH installed? (kloader will be used) (Y/n): ')" Jailbroken
    [[ $Jailbroken == n ]] || [[ $Jailbroken == N ]] && RecoveryDevice=1
    
    [[ $RecoveryDevice == 1 ]] && Recovery
    if [[ $DFUDevice == 1 ]] && [[ $pwnDFUDevice != 1 ]]; then
        Log "$ProductType in DFU mode detected."
        Input "This device is in:"
        select opt in "kDFU/pwnDFU mode" "DFU mode" "(Any other key to exit)"; do
            case $opt in
                "kDFU/pwnDFU mode" ) pwnDFUDevice=1; break;;
                "DFU mode" ) PwnedDFU; break;;
                * ) exit;;
            esac
        done
    fi
    [[ $pwnDFUDevice == 1 ]] && DFUManual=1
    
    if [[ $1 ]] && [[ $1 != 'NoColor' ]]; then
        Mode="$1"
    else
        Selection=("Downgrade device")
        [[ $pwnDFUDevice != 1 ]] && Selection+=("Just put device in kDFU mode")
        Selection+=("Disable/Uninstall exploit" "(Re-)Install Dependencies" "(Any other key to exit)")
        Echo "*** Main Menu ***"
        Input "Select an option:"
        select opt in "${Selection[@]}"; do
            case $opt in
                "Downgrade device" ) Mode='Downgrade'; break;;
                "Disable/Uninstall exploit" ) Mode='Disable'; break;;
                "Just put device in kDFU mode" ) Mode='kDFU'; break;;
                "(Re-)Install Dependencies" ) InstallDependencies;;
                * ) exit;;
            esac
        done
    fi
    SelectVersion
}

function SelectVersion {
    [ $ProductType == iPhone3,1 ] && Selection=("iOS 6.1.3" "iOS 5.1.1 (9B206)" "iOS 5.1.1 (9B208)") || Selection=()
    [[ $Mode != 'Downgrade' ]] && Action
    Selection+=("(Any other key to exit)")
    Input "Select iOS version:"
    select opt in "${Selection[@]}"; do
        case $opt in
            "iOS 6.1.3" ) OSVer='6.1.3'; BuildVer='10B329'; break;;
            "iOS 5.1.1 (9B206)" ) OSVer='5.1.1'; BuildVer='9B206'; break;;
            "iOS 5.1.1 (9B208)" ) OSVer='5.1.1'; BuildVer='9B208'; break;;
            *) exit;;
        esac
    done
    Action
}

function Action {
    Log "Option: $Mode"
    if [[ $Mode == 'Downgrade' ]]; then
        read -p "$(Input 'Jailbreak the selected iOS version? (y/N): ')" Jailbreak
        [[ $Jailbreak == y ]] || [[ $Jailbreak == Y ]] && Jailbreak=1
    elif [[ $Mode == 'Disable' ]] && [[ $platform == linux ]]; then
        cp -rf resources/ch3rryflower/Tools/macos/UNTETHERED/remove_for_i4 $cherrydir
        sed -i "s|./ipwn|sudo python2 ipwn|g" $cherrydir/remove_for_i4/disable
    fi

    [[ $Mode == 'Downgrade' ]] && Downgrade
    [[ $Mode == 'Disable' ]] && cd $cherrydir/remove_for_i4 && ./disable
    [[ $Mode == 'kDFU' ]] && kDFU
    exit
}

function kDFU {
    Log "Patching iBSS..."
    $bspatch tmp/$iBSS.dfu tmp/pwnediBSS resources/patches/$iBSS.patch
    
    [[ $VersionDetect == 5 ]] && kloader='kloader5'
    [[ ! $kloader ]] && kloader='kloader'
    
    [ ! $(which $iproxy) ] && Error "iproxy cannot be found. Please re-install dependencies and try again" "./restore.sh Install"
    $iproxy 2222 22 &
    iproxyPID=$!    
    Log "Copying stuff to device via SSH..."
    Echo "* Make sure OpenSSH is installed on the device!"
    Echo "* Enter root password of your iOS device when prompted, default is 'alpine'"
    scp -P 2222 resources/tools/$kloader tmp/pwnediBSS tmp/pwn.sh root@127.0.0.1:/
    [ $? == 1 ] && Error "Cannot connect to device via SSH. Please check your ~/.ssh/known_hosts file and try again" "You may also run: rm ~/.ssh/known_hosts"
    ssh -p 2222 root@127.0.0.1 "/$kloader /pwnediBSS" &
    echo
    Echo "* Press POWER or HOME button when screen goes black on the device"
    Log "Finding device in DFU mode..."
    while [[ $DFUDevice != 1 ]]; do
        [[ $platform == linux ]] && DFUDevice=$(lsusb | grep -c '1227')
        [[ $platform == macos ]] && [[ $($irecovery -q 2>/dev/null | grep 'MODE' | cut -c 7-) == "DFU" ]] && DFUDevice=1
        sleep 1
    done
    Log "Found device in DFU mode."
    kill $iproxyPID
}

function Recovery {
    [[ $($irecovery -q 2>/dev/null | grep 'MODE' | cut -c 7-) == "Recovery" ]] && RecoveryDevice=1
    if [[ $RecoveryDevice != 1 ]]; then
        Log "Entering recovery mode..."
        $ideviceenterrecovery $UniqueDeviceID >/dev/null
        while [[ $RecoveryDevice != 1 ]]; do
            [[ $($irecovery -q 2>/dev/null | grep 'MODE' | cut -c 7-) == "Recovery" ]] && RecoveryDevice=1
        done
    fi
    Log "Device in recovery mode detected. Get ready to enter DFU mode"
    read -p "$(Input 'Select Y to continue, N to exit recovery (Y/n) ')" RecoveryDFU
    if [[ $RecoveryDFU == n ]] || [[ $RecoveryDFU == N ]]; then
        Log "Exiting recovery mode."
        $irecovery -n
        exit
    fi
    Echo "* Hold POWER and HOME button for 10 seconds."
    for i in {10..01}; do
        echo -n "$i "
        sleep 1
    done
    echo -e "\n$(Echo '* Release POWER and hold HOME button for 8 seconds.')"
    for i in {08..01}; do
        echo -n "$i "
        sleep 1
    done
    sleep 2
    [[ $($irecovery -q 2>/dev/null | grep 'MODE' | cut -c 7-) == "DFU" ]] && DFUDevice=1
    [[ $DFUDevice == 1 ]] && PwnedDFU
    Error "Failed to detect device in DFU mode. Please run the script again"
}

function PwnedDFU {
    Log "Entering pwnDFU mode..."
    sudo $cherrydir/pwnedDFU -p
    [ $? != 0 ] && Error "Failed to enter pwnDFU mode. Please run the script again" "./restore.sh Downgrade"
    pwnDFUDevice=1
}

function Downgrade {
    IPSW="iPhone3,1_${OSVer}_${BuildVer}_Restore"
    IPSW7="iPhone3,1_7.1.2_11D257_Restore"
    [[ ! -e $IPSW.ipsw ]] && Error "iOS $OSVer-$BuildVer IPSW cannot be found."
    [[ ! -e $IPSW7.ipsw ]] && Error "iOS 7.1.2 IPSW cannot be found."
    
    if [ ! $DFUManual ]; then
        Log "Extracting iBSS from IPSW..."
        mkdir -p saved/$ProductType 2>/dev/null
        unzip -o -j $IPSW.ipsw Firmware/dfu/iBSS.n90ap.RELEASE.dfu -d saved/$ProductType
        kDFU
    fi
    
    if [[ ! -d resources/ch3rryflower ]]; then
        Echo "Downloading ch3rryflower..."
        SaveFile https://github.com/dora2-iOS/ch3rryflower/archive/316d2cdc5351c918e9db9650247b91632af3f11f.zip 790d56db354151b9740c929e52c097ba57f2929d
        cd resources
        unzip -q ../tmp/ch3rryflower.zip -d .
        mv ch3rryflower* ch3rryflower
        cd ..
    fi
        
    if [[ $OSVer == 6.1.3 ]]; then
        IV="b559a2c7dae9b95643c6610b4cf26dbd"
        Key="3dbe8be17af793b043eed7af865f0b843936659550ad692db96865c00171959f"
        JBFiles=(Cydia6.tar p0sixspwn.tar fstab_rw.tar)
        JBSHA1=1d5a351016d2546aa9558bc86ce39186054dc281
    elif [[ $BuildVer == 9B206 ]]; then
        IV="b1846de299191186ce3bbb22432eca12"
        Key="e8e26976984e83f967b16bdb3a65a3ec45003cdf2aaf8d541104c26797484138"
    elif [[ $BuildVer == 9B208 ]]; then
        IV="71fe96da25812ff341181ba43546ea4f"
        Key="6377d34deddf26c9b464f927f18b222be75f1b5547e537742e7dfca305660fea"
    fi
    if [[ $OSVer == 5 ]] || [[ $OSVer == 5b ]]; then
        JBFiles=(Cydia5.tar unthredeh4hil.tar fstab_rw.tar)
        JBSHA1=f5b5565640f7e31289919c303efe44741e28543a
    fi
    for i in {0..2}; do
        JBFiles[$i]=resources/jailbreak/${JBFiles[$i]}
    done
    
    Custom="Custom"
    if [[ $Jailbreak == 1 ]]; then
        if [[ ! -e ${JBFiles[0]} ]]; then
            SaveFile https://github.com/LukeZGD/iOS-OTA-Downgrader-Keys/releases/download/jailbreak/${JBFiles[0]} resources/jailbreak/${JBFiles[0]} $JBSHA1
        fi
        cp * ../../resources/jailbreak
        cd ../..
        Custom="CustomJB"
    fi
    IPSWCustom="iPhone3,1_${OSVer}_${BuildVer}_${Custom}"
    
    if [[ ! -e $IPSWCustom ]]; then
        Echo "* By default, memory option is set to Y, you may select N later if you encounter problems"
        Echo "* If it doesn't work with both, you might not have enough RAM or tmp storage"
        read -p "$(Input 'Memory option? (press ENTER if unsure) (Y/n): ')" JBMemory
        [[ $JBMemory != n ]] && [[ $JBMemory != N ]] && JBMemory="-memory" || JBMemory=
        Log "Preparing custom IPSW with ch3rryflower..."
        $cherrydir/make_iBoot.sh $IPSW.ipsw -iv $IV -k $Key
        $cherry $IPSW.ipsw $IPSWCustom.ipsw $JBMemory -derebusantiquis $IPSW7.ipsw iBoot ${JBFiles[@]}
    fi
    [ ! -e $IPSWCustom.ipsw ] && Error "Failed to find custom IPSW. Please run the script again" "You may try selecting N for memory option"
    IPSW=$IPSWCustom
    
    Log "Saving 7.1.2 blobs with tsschecker..."
    $tsschecker -d $ProductType -i $OSVer -e $UniqueChipID -m resources/BuildManifest.plist -s
    SHSH=$(ls ${UniqueChipID}_${ProductType}_${OSVer}-${BuildVer}_*.shsh2)
    [ ! $SHSH ] && Error "Saving $OSVer blobs failed. Please run the script again"
    Log "Successfully saved 7.1.2 blobs."
    
    Log "Extracting IPSW..."
    unzip -q $IPSW.ipsw -d $IPSW/
    
    Log "Proceeding to idevicerestore..."
    mkdir shsh
    mv $SHSH shsh/${UniqueChipID}-${ProductType}-${OSVer}.shsh
    $idevicerestore -e -w $IPSW.ipsw
    
    Log "Restoring done!"
    Log "Downgrade script done!"
}

function InstallDependencies {
    mkdir tmp 2>/dev/null
    cd tmp
    
    Log "Installing dependencies..."
    if [[ $ID == "arch" ]] || [[ $ID_LIKE == "arch" ]]; then
        # Arch
        sudo pacman -Sy --noconfirm --needed bsdiff curl libimobiledevice libusbmuxd libzip openssh unzip usbmuxd usbutils
        
    elif [[ $UBUNTU_CODENAME == "bionic" ]] || [[ $UBUNTU_CODENAME == "focal" ]] || [[ $UBUNTU_CODENAME == "groovy" ]]; then
        # Ubuntu
        sudo add-apt-repository universe
        sudo apt update
        sudo apt install -y autoconf automake bsdiff build-essential checkinstall curl git libglib2.0-dev libimobiledevice-utils libreadline-dev libtool-bin libusb-1.0-0-dev libusbmuxd-tools openssh-client usbmuxd usbutils
        SavePkg
        if [[ $UBUNTU_CODENAME == "bionic" ]]; then
            sudo dpkg -i libzip5.deb
        else
            sudo apt install -y libzip5
        fi
        if [[ $UBUNTU_CODENAME == "focal" ]]; then
            ln -sf /usr/lib/x86_64-linux-gnu/libimobiledevice.so.6 ../resources/lib/libimobiledevice-1.0.so.6
            ln -sf /usr/lib/x86_64-linux-gnu/libplist.so.3 ../resources/lib/libplist-2.0.so.3
            ln -sf /usr/lib/x86_64-linux-gnu/libusbmuxd.so.6 ../resources/lib/libusbmuxd-2.0.so.6
        fi
        
    elif [[ $ID == "fedora" ]]; then
        # Fedora
        sudo dnf install -y automake binutils bsdiff git libimobiledevice-utils libtool libusb-devel libusbmuxd-utils make libzip perl-Digest-SHA readline-devel
        SavePkg
        if (( $VERSION_ID <= 32 )); then
            ln -sf /usr/lib64/libimobiledevice.so.6 ../resources/lib/libimobiledevice-1.0.so.6
            ln -sf /usr/lib64/libplist.so.3 ../resources/lib/libplist-2.0.so.3
            ln -sf /usr/lib64/libusbmuxd.so.6 ../resources/lib/libusbmuxd-2.0.so.6
        fi
        
    elif [[ $OSTYPE == "darwin"* ]]; then
        # macOS
        xcode-select --install
        SaveFile https://github.com/libimobiledevice-win32/imobiledevice-net/releases/download/v1.3.6/libimobiledevice.1.2.1-r1091-osx-x64.zip libimobiledevice.zip dba9ca5399e9ff7e39f0062d63753d1a0c749224
        
    else
        Error "Distro not detected/supported by the install script." "See the repo README for supported OS versions/distros"
    fi
    
    if [[ $platform == linux ]]; then
        Compile LukeZGD libirecovery
        ln -sf ../libirecovery/lib/libirecovery.so.3 ../resources/lib/libirecovery-1.0.so.3
        ln -sf ../libirecovery/lib/libirecovery.so.3 ../resources/lib/libirecovery.so.3
    else
        mkdir ../resources/libimobiledevice_$platform
        unzip libimobiledevice.zip -d ../resources/libimobiledevice_$platform
        chmod +x ../resources/libimobiledevice_$platform/*
    fi
    
    Log "Install script done! Please run the script again to proceed"
    exit
}

function Compile {
    git clone --depth 1 https://github.com/$1/$2.git
    cd $2
    ./autogen.sh --prefix="$(cd ../.. && pwd)/resources/$2"
    make install
    cd ..
    sudo rm -rf $2
}

function SaveFile {
    curl -L $1 -o $2
    if [[ $(shasum $2 | awk '{print $1}') != $3 ]]; then
        Error "Verifying failed. Please run the script again" "./restore.sh Install"
    fi
}

function SavePkg {
    if [[ ! -d ../saved/pkg ]]; then
        Log "Downloading packages..."
        SaveFile https://github.com/LukeZGD/iOS-OTA-Downgrader-Keys/releases/download/tools/depends_linux.zip depends_linux.zip 7daf991e0e80647547f5ceb33007eae6c99707d2
        mkdir -p ../saved/pkg
        unzip depends_linux.zip -d ../saved/pkg
    fi
    cp ../saved/pkg/* .
}

cd "$(dirname $0)"
Main $1
