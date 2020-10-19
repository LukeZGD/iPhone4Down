# iPhone4Down
### iPhone 4 downgrade script (uses ch3rryflower)

- This downgrade script/tool supports **both Linux and macOS**
    - This script is mostly aimed for Linux users though
    - This script uses an older version of ch3rryflower by dora2iOS that has a Linux version compiled
    - For macOS users you may use [cherryflowerJB](https://dora2ios.web.app/CFJB/) instead for more support
- **This supports iPhone3,1 only**
- The downgrades have the option to jailbreak
- You do not need blobs to use this, the script will get the needed 7.1.2 blobs for you
- 8GB iPhones may not work with downgrades below iOS 6
- If you want to go back and restore to iOS 7.1.2, you need to disable the exploit
    - From the menu, select "Disable/Enable exploit" > "Disable exploit" while device is in DFU mode

## Supported iOS versions
- This script supports downgrading to **any version from iOS 5.0 to 6.1.3**
- I can't verify if iOS 4.3.x works or not, let me know if it does work
- I don't think any iOS 7.x version works (gets stuck in recovery mode)
    
## Requirements:
- **iPhone 4 (iPhone3,1)**
- IPSW of the version you want to downgrade to
- IPSW of iOS 7.1.2
- A **64-bit Linux install/live USB** or a supported **macOS** version
    - See supported OS versions and Linux distros below
    - A Linux live USB can be easily created with tools like [balenaEtcher](https://www.balena.io/etcher/) or [Rufus](https://rufus.ie/)

## How to use:
1. [Download iPhone4Down here](https://github.com/LukeZGD/iPhone4Down/archive/master.zip) and extract the zip archive
2. Plug in your iOS device
3. Open a Terminal window
4. `cd` to where the zip archive is extracted, and run `./restore.sh`
    - You can also drag `restore.sh` to the Terminal window and press ENTER
5. Select option to be used
6. Follow instructions

## Supported OS versions/distros:
- Ubuntu [16.04](http://releases.ubuntu.com/xenial/), [18.04](http://releases.ubuntu.com/bionic/), [20.04](http://releases.ubuntu.com/focal/), and [20.10](https://releases.ubuntu.com/groovy/) and Ubuntu-based distros like [Linux Mint](https://www.linuxmint.com/)
- [Arch Linux](https://www.archlinux.org/) and Arch-based distros like [Manjaro](https://manjaro.org/)
- [Fedora 32 to 33](https://getfedora.org/)
- macOS 10.13 to 10.15 (untested)

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
