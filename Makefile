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
	if [[ ! `ls /usr/lib/libbluetooth.so` ]]; then sudo find /usr/lib/* -type f -iname "libbluetooth.so." -exec cp -u {} /usr/lib/libbluetooth.so \; ; fi
	sudo mkdir -p /var/lib/sixad
	sudo touch /home/${USER}/tmp1
	sudo chmod 775 /var/lib/sixad
	sudo chmod 775 /home/${USER}/tmp1
	make -C qtsixa-1.5.0 

install:
	sudo make install-system -C qtsixa-1.5.0
	sudo adduser ${USER} sixad
	sudo cp SixPairTk.pl /usr/bin/
	sudo mv /usr/bin/SixPairTk.pl /usr/bin/SixPairTk
	sudo cp sixpair /usr/bin/
	sudo cp /home/anthony/Documents/Perl/SixPairTK/qtsixa-1.5.0/sixad/sixad /etc/init.d/
	sudo cp qtsixa-1.5.0/sixad/bins/sixad-bin /usr/sbin/
	sudo cp qtsixa-1.5.0/utils/bins/hcid /usr/sbin/
	sudo chmod 775 /usr/bin/SixPairTk
	sudo chmod 775 /etc/init.d/sixad
	sudo ln -sf /etc/init.d/sixad /etc/default/sixad
	su -c "echo '%sixad ALL=(ALL) NOPASSWD: /usr/bin/sixpair' >> /etc/sudoers"

clean:
	sudo make clean -C qtsixa-1.5.0
	sudo deluser ${USER} sixad
	sudo rm /usr/bin/SixPairTk /etc/init.d/sixad 
	sudo rm -rf /var/lib/sixad qtsixa-1.5.0 sixpair /usr/sbin/sixad-bin /usr/sbin/hcid
	sudo rm -rf /etc/default/sixad
	sudo sed -i 's/^%sixad.*sixpair$//g' /etc/sudoers
