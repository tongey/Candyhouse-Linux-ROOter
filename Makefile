VERSION=3.19.5
LINUX=linux-$(VERSION)

all::
	@echo
	@echo "Options:"
	@echo
	@echo "make openwrt4500|openwrt4200|viper\tBuilds OpenWRT firmware images with minimal ROOter extensions for EA4500 \ E4200v2"
	@echo "make openwrt3500|audi\tBuilds OpenWRT firmware images with minimal ROOter extensions for EA3500"
	@echo


openwrt4500:: openwrt-kirkwood-ea4500

openwrt4200:: openwrt-kirkwood-ea4500

viper:: openwrt-kirkwood-ea4500

openwrt3500:: openwrt-kirkwood-ea3500

audi:: openwrt-kirkwood-ea3500

openwrt3420:: openwrt-tplink-3420-min

.openwrt_fetched:
	# Use trunk for Linksys
	git clone git://git.openwrt.org/openwrt.git openwrt
	
	# Use 15.05 for 3420
	#git clone git://git.openwrt.org/15.05/openwrt.git openwrt

	touch $@

.openwrt_config: .openwrt_fetched
	@echo "" > openwrt/.config	

	cp openwrt/feeds.conf.default openwrt/feeds.conf
	@echo "src-git rooter https://github.com/fbradyirl/rooter.git" >> openwrt/feeds.conf

	cd openwrt && ./scripts/feeds update rooter && ./scripts/feeds install -a -p rooter

	# Basic ROOter stuff. Comment these out if you dont need 3G/4G dongle support
	@echo CONFIG_PACKAGE_ext-rooter-basic=y >> openwrt/.config
	@echo CONFIG_PACKAGE_ext-sms=y >> openwrt/.config

	touch $@

.openwrt_luci: .openwrt_config
	cd openwrt && ./scripts/feeds update packages luci && ./scripts/feeds install -a -p luci
	cd openwrt && ./scripts/feeds update packages packages && ./scripts/feeds install -a -p packages

	#@echo CONFIG_PACKAGE_luci-app-sqm=y >> openwrt/.config
	@echo CONFIG_PACKAGE_luci-app-openvpn=y >> openwrt/.config
	@echo CONFIG_PACKAGE_luci-app-wol=y >> openwrt/.config
	@echo CONFIG_PACKAGE_luci-mod-rpc=y >> openwrt/.config
	@echo CONFIG_PACKAGE_luci-app-ddns=y >> openwrt/.config
	
	touch $@

openwrt-kirkwood-ea4500: .openwrt_luci

	@echo CONFIG_TARGET_kirkwood=y >> openwrt/.config
	@echo CONFIG_TARGET_kirkwood_VIPER=y >> openwrt/.config
	# Support for Marvell chipset wifi driver
	@echo CONFIG_PACKAGE_kmod-mwl8k=y >> openwrt/.config

	cd openwrt && make defconfig
	cd openwrt && make -j4

	mkdir -p artifacts
	cp openwrt/bin/kirkwood/*.bin artifacts/
	cp openwrt/bin/kirkwood/*.tar artifacts/
	ls -l artifacts

openwrt-kirkwood-ea3500: .openwrt_luci

	@echo CONFIG_TARGET_kirkwood=y >> openwrt/.config
	@echo CONFIG_TARGET_kirkwood_AUDI=y >> openwrt/.config
	# Support for Marvell chipset wifi driver
	@echo CONFIG_PACKAGE_kmod-mwl8k=y >> openwrt/.config

	cd openwrt && make defconfig
	cd openwrt && make -j4

	mkdir -p artifacts
	cp openwrt/bin/kirkwood/*.bin artifacts/
	cp openwrt/bin/kirkwood/*.tar artifacts/
	ls -l artifacts

openwrt-tplink-3420: .openwrt_luci

	@echo CONFIG_TARGET_ar71xx_generic_TLMR3420=y >> openwrt/.config

	cd openwrt && make defconfig
	cd openwrt && make -j4

	mkdir -p artifacts
	cp openwrt/bin/ar71xx/*factory.bin artifacts/
	cp openwrt/bin/ar71xx/*upgrade.bin artifacts/
	ls -l artifacts

openwrt-tplink-3420-min:

	git clone git://git.openwrt.org/15.05/openwrt.git openwrt
	
	cp /tmp/mktplinkfw.c openwrt/tools/firmware-utils/src/mktplinkfw.c
	
	@echo "" > openwrt/.config	
	
	cp openwrt/feeds.conf.default openwrt/feeds.conf
	
	@echo CONFIG_TARGET_ar71xx_generic_TLMR3420=y >> openwrt/.config
	
	touch $@
		
	cd openwrt && make defconfig
	cd openwrt && make -j4

	mkdir -p artifacts
	cp openwrt/bin/ar71xx/*factory.bin artifacts/
	cp openwrt/bin/ar71xx/*upgrade.bin artifacts/
	ls -l artifacts
	
openwrt-tplink-3420-min-openvpn:

	git clone git://git.openwrt.org/15.05/openwrt.git openwrt
	
	cp /tmp/mktplinkfw.c openwrt/tools/firmware-utils/src/mktplinkfw.c
	
	@echo "" > openwrt/.config	
	
	cp openwrt/feeds.conf.default openwrt/feeds.conf
	
	@echo CONFIG_PACKAGE_openvpn-easy-rsa=y >> openwrt/.config 
	@echo CONFIG_PACKAGE_openvpn-openssl=y >> openwrt/.config 
	@echo CONFIG_TARGET_ar71xx_generic_TLMR3420=y >> openwrt/.config
	
	touch $@
		
	cd openwrt && make defconfig
	cd openwrt && make -j4

	mkdir -p artifacts
	cp openwrt/bin/ar71xx/*factory.bin artifacts/
	cp openwrt/bin/ar71xx/*upgrade.bin artifacts/
	ls -l artifacts
	
openwrt-clean::
	rm -rf *.ssa *.bin *.tar artifacts

openwrt-distclean: openwrt-clean
	rm -rf openwrt/ .openwrt*

clean: openwrt-clean openwrt-distclean

distclean: openwrt-distclean

