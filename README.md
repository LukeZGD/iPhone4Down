# iPhone4Down
### iPhone 4 downgrade script for Linux (uses ch3rryflower)

- This script uses an older Linux compiled version of ch3rryflower and automates the downgrade process for the iPhone 4
- **Linux and macOS** are supported by this downgrade script/tool
  - Windows users can create a Linux live USB (see Requirements)
  - macOS users should use [cherryflowerJB](https://dora2ios.web.app/CFJB/) or [powdersn0w](https://dora2ios.web.app/konayuki/index.html) instead for more support
- **This supports the iPhone 4 GSM (iPhone3,1) only**
- iPhone4Down will not and cannot be updated for iPhone3,3 support. Look forward for updates to powdersn0w instead
- The downgrades have the option to jailbreak
- **You do NOT need blobs to use this**, the script will get the needed 7.1.2 blobs for you
- 8GB models may not work with downgrades below iOS 6
- Newer models may not work with downgrades below iOS 5
- Use an Intel PC/Mac as entering pwnDFU may be a lot more unreliable on AMD devices
- If you want to go back and restore to iOS 7.1.2, you need to disable the exploit
    - From the menu, select "Disable/Enable exploit" > "Disable exploit" while device is in DFU mode
    - If disabling the exploit did not work, [try these steps](https://github.com/LukeZGD/iPhone4Down/issues/3#issuecomment-841622695)
- iPhone4Down can be also used to restore back to iOS 7.1.2 with the option to jailbreak the install

## Supported iOS versions
- This script supports downgrading to **any version from iOS 5.0 to 6.1.3**
- You are on your own if you attempt to restore to any version above or below this range (except 7.1.2)
    
## Requirements:
- **iPhone 4 GSM (iPhone3,1)**
- IPSW of iOS 7.1.2 and the version you want to downgrade to (Links in [ipsw.me](https://ipsw.me/iPhone3,1)) (ignore the signing statuses in the site)
- A **64-bit Linux install/live USB** or a supported **macOS** version
    - See supported OS versions and Linux distros below
    - A Linux live USB can be easily created with tools like [Ventoy](https://www.ventoy.net/en/index.html)

## Usage:
1. [Download iPhone4Down here](https://api.github.com/repos/LukeZGD/iPhone4Down/zipball) and extract the zip archive
2. Plug in your iOS device
3. Open a Terminal window
4. `cd` to where the extracted files are located, and run `./restore.sh`
    - You can also drag `restore.sh` to the Terminal window and press Enter/Return
5. Select options to be used
6. Follow instructions

## Supported OS versions/distros:
- [**Ubuntu**](https://ubuntu.com/) 20.04 and newer, and Ubuntu-based distros like [Linux Mint](https://www.linuxmint.com/)
- [**Arch Linux**](https://www.archlinux.org/) and Arch-based distros like [EndeavourOS](https://endeavouros.com/)
- [**Fedora**](https://getfedora.org/) 33 and newer
- [**Debian**](https://www.debian.org/) 11 Bullseye, Testing and Unstable
- [**openSUSE**](https://www.opensuse.org/) Tumbleweed and Leap 15.3
- **macOS** 10.13 and newer

## Tools and other stuff used by this script:
- cURL
- bspatch
- [ch3rryflower](https://github.com/dora2-iOS/ch3rryflower/tree/316d2cdc5351c918e9db9650247b91632af3f11f) - dora2ios
- [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) - libimobiledevice
- [libirecovery](https://github.com/libimobiledevice/libirecovery) - libimobiledevice
- [imobiledevice-net](https://github.com/libimobiledevice-win32/imobiledevice-net) - libimobiledevice (macOS binaries)
- [idevicerestore](https://github.com/LukeeGD/idevicerestore) - LukeZGD fork
- ipsw tool from [xpwn](https://github.com/LukeZGD/xpwn/tree/ootc) - LukeZGD fork
- [tsschecker](https://github.com/tihmstar/tsschecker) - tihmstar
- [partial-zip](https://github.com/matteyeux/partial-zip)
- [evasi0n](https://www.theiphonewiki.com/wiki/Evasi0n)
- [p0sixspwn](https://www.theiphonewiki.com/wiki/p0sixspwn)
- [unthredeh4il](https://www.theiphonewiki.com/wiki/Unthredera1n#unthredeh4il)
