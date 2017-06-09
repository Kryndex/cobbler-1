#!/bin/bash

cobbler_cross_architectures="armhf arm64 "
cobbler_foreign_architectures="i386 ${cobbler_cross_architectures}"
cobbler_foreign_triplets="arm-linux-gnueabihf aarch64-linux-gnu"
cobbler_architectures_ports_list="armhf,arm64"

cobbler_packages_to_install=""
for triplet in $cobbler_foreign_triplets; do cobbler_packages_to_install="$cobbler_packages_to_install \
gcc-$triplet \
g++-$triplet"; done

for arch in $cobbler_cross_architectures; do cobbler_packages_to_install="$cobbler_packages_to_install \
libc6-$arch-cross \
libstdc++6-$arch-cross \
crossbuild-essential-$arch"; done

for arch in $cobbler_foreign_architectures; do cobbler_packages_to_install="$cobbler_packages_to_install \
libgtk2.0-0:$arch \
libxkbfile-dev:$arch \
libx11-dev:$arch \
libxdmcp-dev:$arch \
libdbus-1-3:$arch \
libpcre3:$arch \
libselinux1:$arch \
libp11-kit0:$arch \
libcomerr2:$arch \
libk5crypto3:$arch \
libkrb5-3:$arch \
libpango-1.0-0:$arch \
libpangocairo-1.0-0:$arch \
libpangoft2-1.0-0:$arch \
libxcursor1:$arch \
libxfixes3:$arch \
libfreetype6:$arch \
libavahi-client3:$arch \
libgssapi-krb5-2:$arch \
libjpeg8:$arch \
libtiff5:$arch \
fontconfig-config \
libgdk-pixbuf2.0-common \
libgdk-pixbuf2.0-0:$arch \
libfontconfig1:$arch \
libcups2:$arch \
libcairo2:$arch \
libc6-dev:$arch \
libatk1.0-0:$arch \
libx11-xcb-dev:$arch \
libxtst6:$arch \
libxss-dev:$arch \
libgconf-2-4:$arch \
libasound2:$arch \
libnss3:$arch \
zlib1g:$arch"; done

echo "Package install list: ${cobbler_packages_to_install}"

echo "Building cobbler image for ${cobbler_ports_architectures_list}"

echo "Adding architectures supported by cobbler"
dpkg --add-architecture i386
for arch in $cobbler_foreign_architectures; do dpkg --add-architecture $arch; done

echo "Adding ubuntu ports for multiarch packages"
echo "deb [arch=$cobbler_architectures_ports_list] http://ports.ubuntu.com/ubuntu-ports xenial main universe multiverse restricted" | tee /etc/apt/sources.list.d/cobbler.list;
echo "deb [arch=$cobbler_architectures_ports_list] http://ports.ubuntu.com/ubuntu-ports xenial-security main universe multiverse restricted" | tee -a /etc/apt/sources.list.d/cobbler.list;
echo "deb [arch=$cobbler_architectures_ports_list] http://ports.ubuntu.com/ubuntu-ports xenial-updates main universe multiverse restricted" | tee -a /etc/apt/sources.list.d/cobbler.list;
echo "deb [arch=$cobbler_architectures_ports_list] http://ports.ubuntu.com/ubuntu-ports xenial-backports main universe multiverse restricted" | tee -a /etc/apt/sources.list.d/cobbler.list;

echo "cobbler.list be like:"
cat /etc/apt/sources.list.d/cobbler.list;

echo "Binding all unfiltered repositories to intel";
sed -i 's/deb http/deb [arch=amd64,i386] http/g' /etc/apt/sources.list;
find /etc/apt/sources.list.d/ -name '*.list' -print0 | xargs -0 -I {} -P 0 sed -i 's/deb http/deb [arch=amd64,i386] http/g' {}

apt-get update -yq;

apt-get install -y \
software-properties-common xvfb wget git python curl zip p7zip-full \
rpm graphicsmagick libwww-perl libxml-libxml-perl libxml-sax-expat-perl \
dpkg-dev perl libconfig-inifiles-perl libxml-simple-perl \
liblocale-gettext-perl libdpkg-perl libconfig-auto-perl \
libdebian-dpkgcross-perl ucf debconf dpkg-cross \
zlib1g-dev qemu binfmt-support qemu-user-static ${cobbler_packages_to_install};