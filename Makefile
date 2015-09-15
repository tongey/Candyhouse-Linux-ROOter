VERSION=3.19.5
LINUX=linux-$(VERSION)
includerooter?=NO
menuconfig?=NO

all::
	@echo
	@echo "Options:"
	@echo
	@echo "make usb\t\tBuilds a linux kernel that when flashed will boot a filesystem on a USB stick"
	@echo
	@echo "make openwrt\t\tBuilds pri and alt OpenWRT firmware images for EA4500 / E4200v2 and EA3500"
	@echo "make openwrt4500\tBuilds pri and alt OpenWRT firmware images for EA4500 / E4200v2"
	@echo "make openwrt3500\tBuilds pri and alt OpenWRT firmware images for EA3500"
	@echo
	@echo "make openwrt-kirkwood-ea3500-pri.ssa \tBuilds pri OpenWRT firmware image for EA3500"
	@echo "make openwrt-kirkwood-ea3500-alt.ssa \tBuilds alt OpenWRT firmware image for EA3500"
	@echo "make openwrt-kirkwood-ea4500-pri.ssa \tBuilds pri OpenWRT firmware image for EA4500 / E4200v2"
	@echo "make openwrt-kirkwood-ea4500-alt.ssa \tBuilds alt OpenWRT firmware image for EA4500 / E4200v2"
	@echo

usb:: .usb_built

.usb_fetched:
	wget https://www.kernel.org/pub/linux/kernel/v3.x/$(LINUX).tar.xz
	touch $@

.usb_extracted: .usb_fetched
	tar xvf $(LINUX).tar.xz
	touch $@

.usb_patched: .usb_extracted
	cd $(LINUX) && patch -p1 < ../patches/usb.patch > ../.usb_patchlog
	touch $@

.usb_configured: .usb_patched
	cd $(LINUX) && make oldconfig ARCH=arm
	touch $@

.usb_built: .usb_configured
	cd $(LINUX) && make -j4 ARCH=arm LOADADDR=0x00008000 uImage
	cd $(LINUX) && make ARCH=arm dtbs
	cat $(LINUX)/arch/arm/boot/zImage $(LINUX)/arch/arm/boot/dts/kirkwood-candyhouse.dtb > /tmp/zImage+kirkwood-candyhouse.dtb
	mkimage -A arm -O linux -T kernel -C none -a 0x00008000 -e 0x00008000 -n $(LINUX) -d /tmp/zImage+kirkwood-candyhouse.dtb uImage-$(VERSION)-ea4500
	touch $@

openwrt:: openwrt4500 

openwrt4500:: openwrt-kirkwood-ea4500

.openwrt_fetched:
	#git clone git://git.openwrt.org/15.05/openwrt.git
	git clone -b kirkwood-squashfs https://github.com/leitec/openwrt-staging
	touch $@

.openwrt_rooter: .openwrt_fetched
	@echo "src-git rooter https://github.com/fbradyirl/rooter.git" >> openwrt-staging/feeds.conf.default

	cd openwrt-staging && ./scripts/feeds update -a 


	@echo CONFIG_PACKAGE_ext-buttons=y >> openwrt-staging/.config
	@echo CONFIG_PACKAGE_ext-command=y >> openwrt-staging/.config
	@echo CONFIG_PACKAGE_ext-rooter=y >> openwrt-staging/.config
	@echo CONFIG_PACKAGE_ext-rooter8=y >> openwrt-staging/.config
	@echo CONFIG_PACKAGE_ext-sms=y >> openwrt-staging/.config

	touch $@

.openwrt_luci: .openwrt_rooter
	cd openwrt-staging && ./scripts/feeds update packages luci && ./scripts/feeds install -a -p luci
	touch $@

openwrt-kirkwood-ea4500: .openwrt_luci

	@echo CONFIG_TARGET_kirkwood=y > openwrt-staging/.config
	@echo CONFIG_TARGET_kirkwood_EA4500=y >> openwrt-staging/.config

	cd openwrt-staging && make defconfig

	cd openwrt-staging && make -j4

	@echo "Then check that your image exists here:"
	@echo "ls -l openwrt-staging/bin/kirkwood/openwrt-kirkwood-ea4500-squashfs-factory.bin"

	# I created a diff using the command
	# 
	# diff -ruN a/.config b/.config > ../patches/openwrt-rooter.patch

usb-clean::
	rm -rf .usb_extracted .usb_patched .usb_configured .usb_built $(LINUX) uImage-$(VERSION)-ea4500

usb-distclean: usb-clean
	rm -rf $(LINUX).tar.xz .usb*

openwrt-clean::
	rm -rf *.ssa

openwrt-distclean: openwrt-clean
	rm -rf openwrt/ .openwrt*

clean: usb-clean openwrt-clean

distclean: usb-distclean openwrt-distclean

