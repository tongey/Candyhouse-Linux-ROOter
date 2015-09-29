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

.openwrt_config: .openwrt_fetched
	@echo "" > openwrt/.config	

	cp openwrt/feeds.conf.default openwrt/feeds.conf
	@echo "src-git rooter https://github.com/fbradyirl/rooter.git" >> openwrt/feeds.conf

	cd openwrt && ./scripts/feeds update rooter && ./scripts/feeds install -a -p rooter

	# Only finbarr basic packages. No ROOter MODs.
	@echo CONFIG_PACKAGE_ext-finbarr-addons=y >> openwrt/.config
	
	@echo CONFIG_PACKAGE_kmod-usb-net-huawei-cdc-ncm=y >> openwrt/.config

	# 1. Only generic basic modem packages. No ROOter MODs.
	#@echo CONFIG_PACKAGE_ext-modem-basic=y >> openwrt/.config

	# 2. Only huawei basic modem packages. No ROOter MODs.
	#@echo CONFIG_PACKAGE_ext-huawei-modems=y >> openwrt/.config

	# 4. All the ROOter stuff
	@echo CONFIG_PACKAGE_ext-rooter-basic=y >> openwrt/.config
	@echo CONFIG_PACKAGE_ext-buttons=y >> openwrt/.config
	@echo CONFIG_PACKAGE_ext-command=y >> openwrt/.config
	#@echo CONFIG_PACKAGE_ext-rooter=y >> openwrt/.config
	@echo CONFIG_PACKAGE_ext-sms=y >> openwrt/.config
	#@echo CONFIG_PACKAGE_ext-rooter8=y >> openwrt/.config

	touch $@

.openwrt_luci: .openwrt_config
	cd openwrt && ./scripts/feeds update packages luci && ./scripts/feeds install -a -p luci

	#@echo CONFIG_PACKAGE_luci-mod-rpc=y >> openwrt/.config
	#@echo CONFIG_PACKAGE_luci-app-ddns=y >> openwrt/.config
	touch $@

openwrt-kirkwood-ea4500: .openwrt_luci

	@echo CONFIG_TARGET_kirkwood=y >> openwrt/.config
	@echo CONFIG_TARGET_kirkwood_EA4500=y >> openwrt/.config

	cd openwrt && make defconfig
	cd openwrt && make -j4

	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea4500-squashfs-factory.bin openwrt-ea4500-factory.bin 
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea4500-squashfs-sysupgrade.tar openwrt-ea4500-sysupgrade.tar 

openwrt-kirkwood-ea3500: .openwrt_luci

	@echo CONFIG_TARGET_kirkwood=y >> openwrt/.config
	@echo CONFIG_TARGET_kirkwood_EA3500=y >> openwrt/.config

	cd openwrt && make defconfig
	cd openwrt && make -j4

	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea3500-squashfs-factory.bin openwrt-ea3500-factory.bin
	cp openwrt/bin/kirkwood/openwrt-kirkwood-ea3500-squashfs-sysupgrade.tar openwrt-ea3500-sysupgrade.tar


openwrt-clean::
	rm -rf *.ssa *.bin *.tar

openwrt-distclean: openwrt-clean
	rm -rf openwrt/ .openwrt*

clean: openwrt-clean openwrt-distclean

distclean: openwrt-distclean

