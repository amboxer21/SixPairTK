#!/bin/bash

apt-get install --force-yes --yes libusb-dev libusb-0.1-4 pyqt4-dev-tools libjack-dev bluez-hcidump checkinstall libusb-dev libbluetooth-dev joystick pyqt4-dev-tools linux-headers-generic libdbus-glib-1-dev libdbus-1-dev libbluetooth* xserver-xorg-input-joystick &&
perl -MCPAN -e 'install Tk' &&
gcc sixpair.c -o sixpair -lusb &&
sudo find / -type f -iname 'glibconfig.h' -exec cp {} /usr/include/glib-2.0/ \; &&

tar -xzvf qtsixa-1.4.96.tar.gz &&
cd qtsixa-1.4.96 &&

sudo cp utils/hcid/dbus.h /usr/include/glib-2.0/ &&
sudo cp -R utils/hcid/common /usr/include/glib-2.0/ &&
sudo cp ../dbus-arch-deps.h /usr/include/dbus-1.0/dbus/ &&
sudo cp ../dbus-sdp.c utils/hcid/ &&
sudo cp /lib/x86_64-linux-gnu/libglib-2.0.so.0 /usr/lib/libglib-2.0.so &&
sudo find /usr/lib/* -type f -iname "libbluetooth.so*" -exec cp {} /usr/lib/libbluetooth.so \; &&
sudo ./configure &&
sudo make && sudo make install-system
