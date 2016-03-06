#!/bin/bash

set -e

if [ $# -eq 0 ]; then
	echo ""
	echo "Usage: $0 <branch> <dlss_dir>"
	echo "   branch: poky branch name (default master)"
	echo "   dlss_dir: directory to place downloads and sstate-cache (ommit for yocto default)"
	exit 1;
fi

if [ -z "$1" ]; then
	my_branch="master"
else
	my_branch=$1
fi

if [ -z "$2" ]; then
	my_dlss="default"
else
	my_dlss=$2
fi

echo "Removing previous installation"
rm -rf poky
rm -rf build

echo "Cloning poky, $my_branch branch"
git clone -b $my_branch git://git.yoctoproject.org/poky

echo "Cloning meta-intel, $my_branch branch"
git clone -b $my_branch git://git.yoctoproject.org/meta-intel poky/meta-intel

echo "Cloning meta-openembedded, $my_branch branch"
git clone -b $my_branch git://git.openembedded.org/meta-openembedded poky/meta-openembedded

echo "Cloning meta-ros, master branch"
git clone -b master git://github.com/bmwcarit/meta-ros.git poky/meta-ros

echo "Cloning meta-intel-iot-middleware, master branch"
git clone -b master git://git.yoctoproject.org/meta-intel-iot-middleware poky/meta-intel-iot-middleware

echo "Cloning meta-gt-bsp, $my_branch branch"
git clone -b $my_branch git://sandbox.sakoman.com/meta-gt-bsp.git poky/meta-gt-bsp

echo "Cloning meta-gt-extras, $my_branch branch"
git clone -b $my_branch git://sandbox.sakoman.com/meta-gt-extras.git poky/meta-gt-extras

set build
TEMPLATECONF=meta-gt-extras/conf source poky/oe-init-build-env >> /dev/null

if [ "X$my_dl" = "Xdefault" ]; then
	echo "Using default download and sstate directories"
else
	echo DL_DIR ?= \""$my_dlss"/downloads\" >> conf/local.conf
	echo SSTATE_DIR ?= \""$my_dlss/sstate-cache"\" >> conf/local.conf
fi


