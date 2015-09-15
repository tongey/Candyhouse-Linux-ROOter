# Candyhouse Routers

_Candyhouse_ is the codename for the Cisco board that powers the Cisco/Linksys EA4500, E4200v2, and EA3500 WiFi routers.  

# Building OpenWRT images

```bash
$ make openwrt3500
```
Or
```bash
$ make openwrt4500
```

The included [Makefile](Makefile) will clone the kirkwood branch of OpenWRT, and build a bin file for the EA4500 / E4200v2 / EA3500. A tar file is also created to allow system upgrades from an older flashed version (to maintain config)

For more info and disucssion about OpenWRT on Candyhouse routers, please visit:

[http://www.wolfteck.com/projects/candyhouse/openwrt/](http://www.wolfteck.com/projects/candyhouse/openwrt/)

## Returning to the stock firmware for reflashing

You can flash the original Linksys stock firmware from within the OpenWRT interface.

# Building / Installing Modules

No need.  All required functions are built into the kernel image.  No more mounting your router FS to you build box!

# Cleaning Up

```bash
$ make clean
```

This will remove all of the status files, the patchlog, the image, the downloaded kernel source and its extracted tree.
