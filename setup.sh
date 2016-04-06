#!/bin/bash

set -e

SRCREV_POKY=1ca71e5178ed8514655524f714877e02f6db90af
SRCREV_INTEL=7965dc814964a30e54542b1d5ef2029d565240bd
SRCREV_IOT_MIDDLEWARE=ed3991f551b879401bf09ca7d1101d1fdd8f9fa9
SRCREV_GT_BSP=auto
SRCREV_GT_EXTRAS=auto
SRCREV_OE=44f0e74954628d6a3d04fa5249dbe0c94f6dff59
SRCREV_ROS=279e7303c9695ab517cf26e0e1db4911fcfc8e4c

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
if [[ $SRCREV_POKY != "auto" ]]; then
	cd poky
	git checkout $SRCREV_POKY
	cd ..
fi

echo "Cloning meta-intel, $my_branch branch"
git clone -b $my_branch git://git.yoctoproject.org/meta-intel poky/meta-intel
if [[ $SRCREV_INTEL != "auto" ]]; then
	cd poky/meta-intel
	git checkout $SRCREV_INTEL
	cd ../..
fi

echo "Cloning meta-openembedded, $my_branch branch"
git clone -b $my_branch git://git.openembedded.org/meta-openembedded poky/meta-openembedded
if [[ $SRCREV_OE != "auto" ]]; then
	cd poky/meta-openembedded
	git checkout $SRCREV_OE
	cd ../..
fi

echo "Cloning meta-ros, master branch"
git clone -b master git://github.com/bmwcarit/meta-ros.git poky/meta-ros
if [[ $SRCREV_ROS != "auto" ]]; then
	cd poky/meta-ros
	git checkout $SRCREV_ROS
	cd ../..
fi

echo "Cloning meta-intel-iot-middleware, master branch"
git clone -b master git://git.yoctoproject.org/meta-intel-iot-middleware poky/meta-intel-iot-middleware
if [[ $SRCREV_IOT_MIDDLEWARE != "auto" ]]; then
	cd poky/meta-intel-iot-middleware
	git checkout $SRCREV_IOT_MIDDLEWARE
	cd ../..
fi

echo "Cloning meta-gt-bsp, $my_branch branch"
git clone -b $my_branch git://sandbox.sakoman.com/meta-gt-bsp.git poky/meta-gt-bsp
if [[ $SRCREV_GT_BSP != "auto" ]]; then
	cd poky/meta-gt-bsp
	git checkout $SRCREV_GT_BSP
	cd ../..
fi

echo "Cloning meta-gt-extras, $my_branch branch"
git clone -b $my_branch git://sandbox.sakoman.com/meta-gt-extras.git poky/meta-gt-extras
if [[ $SRCREV_GT_EXTRAS != "auto" ]]; then
	cd poky/meta-gt-extras
	git checkout $SRCREV_GT_EXTRAS
	cd ../..
fi

set build
TEMPLATECONF=meta-gt-extras/conf source poky/oe-init-build-env >> /dev/null

if [ "X$my_dlss" = "Xdefault" ]; then
	echo "Using default download and sstate directories"
else
	echo DL_DIR ?= \""$my_dlss"/downloads\" >> conf/local.conf
	echo SSTATE_DIR ?= \""$my_dlss/sstate-cache"\" >> conf/local.conf
fi


