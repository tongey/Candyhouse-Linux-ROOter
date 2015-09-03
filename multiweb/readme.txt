MultiWeb Packages
-----------------

Extract "package0308.zip" to the "/trunk/package/rooter" folder of your OpenWRT build.

All packages can be found in Network when doing a "make menuconfig".

Basic 4 meg ROOter R43228
-------------------------

ext-buttons		(Y)
choose from :
  ext-rooter4		(Y) old qmi and Load Balancing
  ext-rooter-lite	(Y) old qmi and no Load Balancing
ext-sms			(Y)


8/16 meg ROOter R44510
----------------------

ext-buttons		(Y)
ext-rooter		(Y) 8 meg - uqmi and Load Balancing
ext-rooter8		(Y)
ext-extra		(Y)
  ext-mjpg-streamer	(Y)
ext-openvpn		(Y)
ext-p910nd		(Y)
ext-samba		(Y)
ext-transmission	(Y)
ext-umount		(Y)
ext-vsftpd		(Y)
ext-command		(Y)