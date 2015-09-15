VERSION=3.19.5
LINUX=linux-$(VERSION)

all::
	@echo
	@echo "Options:"
	@echo
	@echo "make openwrt4500\tBuilds OpenWRT firmware images with minimal ROOter extensions for EA4500 / E4200v2"
	@echo "make openwrt3500\tBuilds OpenWRT firmware images with minimal ROOter extensions for EA3500"
	@echo


openwrt4500:: openwrt-kirkwood-ea4500

openwrt3500:: openwrt-kirkwood-ea3500

.openwrt_fetched:
	#git clone git://git.openwrt.org/15.05/openwrt.git
	git clone -b kirkwood-squashfs https://github.com/leitec/openwrt-staging openwrt
	
	touch $@

.openwrt_rooter: .openwrt_fetched
	cp openwrt/feeds.conf.default openwrt/feeds.conf
	@echo "src-git rooter https://github.com/fbradyirl/rooter.git" >> openwrt/feeds.conf
	cd openwrt && ./scripts/feeds update packages rooter && ./scripts/feeds install -a -p rooter

	@echo "" > openwrt/.config	
	@echo CONFIG_TARGET_kirkwood=y >> openwrt/.config

	@echo CONFIG_PACKAGE_ext-buttons=y >> openwrt/.config
	@echo CONFIG_PACKAGE_ext-command=y >> openwrt/.config
	@echo CONFIG_PACKAGE_ext-rooter=y >> openwrt/.config
	@echo CONFIG_PACKAGE_ext-rooter8=y >> openwrt/.config
	@echo CONFIG_PACKAGE_ext-sms=y >> openwrt/.config

	touch $@

.openwrt_luci: .openwrt_rooter
	cd openwrt && ./scripts/feeds update packages luci && ./scripts/feeds install -a -p luci

	@echo CONFIG_PACKAGE_luci-mod-rpc=y >> openwrt/.config
	
	touch $@

openwrt-kirkwood-ea4500: .openwrt_luci

	@echo CONFIG_TARGET_kirkwood_EA4500=y >> openwrt/.config

	cd openwrt && make defconfig
	cd openwrt && make -j4

	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea4500-squashfs-factory.bin .
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea4500-squashfs-sysupgrade.tar .

openwrt-kirkwood-ea3500: .openwrt_luci

	@echo CONFIG_TARGET_kirkwood_EA3500=y >> openwrt/.config

	cd openwrt && make defconfig
	cd openwrt && make -j4

	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea3500-squashfs-factory.bin .
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea3500-squashfs-sysupgrade.tar .


openwrt-clean::
	rm -rf *.ssa *.bin *.tar

openwrt-distclean: openwrt-clean
	rm -rf openwrt/ .openwrt*

clean: openwrt-clean

distclean: openwrt-distclean

