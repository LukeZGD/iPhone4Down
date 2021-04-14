# iPhone4Down
### iPhone 4 downgrade script for Linux (uses ch3rryflower)

- This script uses an older Linux compiled version of ch3rryflower and automates the downgrade process for the iPhone 4
- **Linux and macOS** are supported by this downgrade script/tool
  - Windows users can create a Linux live USB (see Requirements)
  - macOS users should use [cherryflowerJB](https://dora2ios.web.app/CFJB/) instead for more support
- **This supports iPhone3,1 only**
- The downgrades have the option to jailbreak
- **You do NOT need blobs to use this**, the script will get the needed 7.1.2 blobs for you
- 8GB models may not work with downgrades below iOS 6
- Newer models may not work with downgrades below iOS 5
- If you want to go back and restore to iOS 7.1.2, you need to disable the exploit
    - From the menu, select "Disable/Enable exploit" > "Disable exploit" while device is in DFU mode

## Supported iOS versions
- This script supports downgrading to **any version from iOS 5.0 to 6.1.3**
- I can't verify if restoring to iOS 4.3.x works or not, let me know if it does work
- I don't think restoring to any iOS 7.x version works (gets stuck in recovery mode)
    
## Requirements:
- **iPhone 4 GSM (iPhone3,1)**
- IPSW of iOS 7.1.2 and the version you want to downgrade to (Links in [ipsw.me](https://ipsw.me/iPhone3,1))
- A **64-bit Linux install/live USB** or a supported **macOS** version
    - See supported OS versions and Linux distros below
    - A Linux live USB can be easily created with tools like [balenaEtcher](https://www.balena.io/etcher/) or [Rufus](https://rufus.ie/)

## Usage:
1. [Download iPhone4Down here](https://github.com/LukeZGD/iPhone4Down/archive/master.zip) and extract the zip archive
2. Plug in your iOS device
3. Open a Terminal window
4. `cd` to where the zip archive is extracted, and run `./restore.sh`
    - You can also drag `restore.sh` to the Terminal window and press ENTER
5. Select option to be used
6. Follow instructions

## Supported OS versions/distros:
- **Ubuntu** [18.04](https://releases.ubuntu.com/bionic/), [20.04](https://releases.ubuntu.com/focal/), [20.10](https://releases.ubuntu.com/groovy/), [21.04](https://releases.ubuntu.com/hirsute/); and Ubuntu-based distros like [Linux Mint](https://www.linuxmint.com/)
- [**Arch Linux**](https://www.archlinux.org/) and Arch-based distros like [EndeavourOS](https://endeavouros.com/)
- [**Fedora** 32 to 34](https://getfedora.org/)
- [**Debian** Buster, Bullseye, Sid](https://www.debian.org/); and Debian-based distros like [MX Linux](https://mxlinux.org/)
- **openSUSE** [Tumbleweed](https://software.opensuse.org/distributions/tumbleweed), [Leap 15.2](https://software.opensuse.org/distributions/leap)
- **macOS** 10.12 to 11

## Tools and other stuff used by this script:
- [ch3rryflower by dora2iOS](https://github.com/dora2-iOS/ch3rryflower/tree/316d2cdc5351c918e9db9650247b91632af3f11f)
- cURL
- bspatch
- [irecovery](https://github.com/LukeZGD/libirecovery)
- [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice)
- [imobiledevice-net](https://github.com/libimobiledevice-win32/imobiledevice-net) (macOS)
- [idevicerestore](https://github.com/LukeZGD/idevicerestore)
- [tsschecker](https://github.com/tihmstar/tsschecker)
- [kloader](https://www.youtube.com/watch?v=fh0tB6fp0Sc)
- [kloader5 for iOS 5](https://mtmdev.org/pmbonneau-archive)
- [partial-zip](https://github.com/matteyeux/partial-zip)
