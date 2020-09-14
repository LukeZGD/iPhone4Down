#!/bin/bash
trap 'Clean; exit' INT TERM EXIT
if [[ $1 != 'NoColor' ]]; then
    Color_R=$(tput setaf 9)
    Color_G=$(tput setaf 10)
    Color_B=$(tput setaf 12)
    Color_Y=$(tput setaf 11)
    Color_N=$(tput sgr0)
fi

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

cherrydir="resources/ch3rryflower/Tools/ubuntu/UNTETHERED"
cherry="$cherrydir/cherry"
idevicerestore="sudo resources/tools/idevicerestore"

Echo "***** iPhone4Tool *****"
Echo "- Script by LukeZGD"
echo
Echo "Mode: Downgrade"
Echo "* Downgrade uses ch3rryflower by dora2iOS"
Echo "* Downgrade jailbreak files are from Pluvia by parrotgeek1"
mkdir tmp 2>/dev/null

if [[ ! -d resources/ch3rryflower ]]; then
    Echo "Downloading ch3rryflower..."
    curl -L https://github.com/dora2-iOS/ch3rryflower/archive/316d2cdc5351c918e9db9650247b91632af3f11f.zip -o tmp/ch3rryflower.zip
    cd resources
    unzip -q ../tmp/ch3rryflower.zip -d .
    mv ch3rryflower* ch3rryflower
    cd ..
fi

Input "Select version:"
select opt in "iOS 6.1.3" "iOS 5.1.1"; do
    case $opt in
        "iOS 6.1.3" ) OSVer=6; break;;
        "iOS 5.1.1" ) OSVer=5; break;;
        * ) exit;;
    esac
done

read -p "$(Input 'Jailbreak? (Y/n)')" JailbreakYN
Custom="Custom"
if [[ $JailbreakYN != n ]] && [[ $JailbreakYN != N ]]; then
    if [[ ! -d resources/jailbreak ]]; then
        cd tmp
        mkdir jailbreak
        cd jailbreak
        JailbreakFiles=(Cydia5.tar Cydia6.tar fstab_rw.tar p0sixspwn.tar unthredeh4il.tar)
        JailbreakLink=https://raw.githubusercontent.com/parrotgeek1/Pluvia/8ad52a3cfeb48bfbf482843691c87f798039f161
        Log "Downloading jailbreak files from Pluvia repo..."
        for file in "${JailbreakFiles[@]}"; do
            curl -L $JailbreakLink/jailbreak/$file -o $file
        done
        mkdir ../../resources/jailbreak
        cp * ../../resources/jailbreak
    fi
    Custom="CustomJB"
fi

Jailbreak="resources/jailbreak"
if [[ $OSVer == 6 ]]; then
    IPSW="6.1.3_10B329"
    IV="b559a2c7dae9b95643c6610b4cf26dbd"
    Key="3dbe8be17af793b043eed7af865f0b843936659550ad692db96865c00171959f"
    Jailbreak="$Jailbreak/Cydia6.tar $Jailbreak/p0sixspwn.tar $Jailbreak/fstab_rw.tar"
elif [[ $OSVer == 5 ]]; then
    IPSW="5.1.1_9B208"
    IV="71fe96da25812ff341181ba43546ea4f"
    Key="6377d34deddf26c9b464f927f18b222be75f1b5547e537742e7dfca305660fea"
    Jailbreak="$Jailbreak/Cydia5.tar $Jailbreak/unthredeh4hil.tar $Jailbreak/fstab_rw.tar"
fi

echo here
read

IPSW="iPhone3,1_${IPSW}_Restore.ipsw"
IPSWCustom="iPhone3,1_${IPSW}_${Custom}.ipsw"
if [ ! -e $IPSWCustom ]; then
    Log "Creating custom IPSW with ch3rryflower..."
    $cherrydir/make_iBoot.sh $IPSW -iv $IV -k $Key
    $cherry $IPSW $IPSWCustom -memory -derebusantiquis iPhone3,1_7.1.2_11D257_Restore.ipsw iBoot $Jailbreak
fi

Log "Entering pwnDFU mode..."
sudo $cherrydir/pwnedDFU -p
[ $? != 0 ] && Error "Failed to enter pwnDFU mode. Please run the script again"

Log "Proceeding to idevicerestore..."
$idevicerestore -e -w $IPSWCustom
