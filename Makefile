# Makefile

SHELL := /bin/bash

build:
	sudo apt-get install --force-yes --yes libusb-dev libusb-0.1-4 pyqt4-dev-tools libjack-dev bluez-hcidump checkinstall libusb-dev libbluetooth-dev joystick pyqt4-dev-tools linux-headers-generic libdbus-glib-1-dev libdbus-1-dev libbluetooth* xserver-xorg-input-joystick
	perl -MCPAN -e 'install Tk'
	gcc sixpair.c -o sixpair -lusb
	if [[ ! `ls /usr/include/glib-2.0/glibconfig.h` ]]; then sudo find / -type f -iname 'glibconfig.h' -exec cp -u {} /usr/include/glib-2.0/ \; ; fi
	tar -xzvf qtsixa-1.5.0.tar.gz
	sudo cp -u qtsixa-1.5.0/utils/hcid/dbus.h /usr/include/glib-2.0/ 
	sudo cp -R qtsixa-1.5.0/utils/hcid/common /usr/include/glib-2.0/ 
	sudo cp -u dbus-arch-deps.h /usr/include/dbus-1.0/dbus/ 
	sudo cp -u dbus-sdp.c qtsixa-1.5.0/utils/hcid/ 
	sudo cp -u /lib/x86_64-linux-gnu/libglib-2.0.so.0 /usr/lib/libglib-2.0.so 
	if [[ ! `/usr/lib/libbluetooth.so` ]]; then sudo find /usr/lib/* -type f -iname "libbluetooth.so." -exec cp -u {} /usr/lib/libbluetooth.so \; ; fi
	sudo mkdir -p /var/lib/sixad
	sudo chmod 775 /var/lib/sixad
	make -C qtsixa-1.5.0 

install:
	sudo make install-system -C qtsixa-1.5.0
	sudo adduser ${USER} sixad
	sudo chmod 775 SixPairTk.pl
	mv SixPairTk.pl SixPairTk
	sudo cp SixPairTk /usr/bin

clean:
