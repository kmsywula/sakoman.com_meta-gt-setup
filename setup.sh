#!/bin/bash

set -e

SRCREV_POKY=6c1c01392d91f512e2949ad1d57a75a8077478ba
SRCREV_INTEL=7d2b2f5b644a2729c75b8ecb38345c9668d2c8bb
SRCREV_IOT_MIDDLEWARE=821cf14c8304669d9ce0c5b87b9be5a6eecff6e5
SRCREV_GT_BSP=auto
SRCREV_GT_EXTRAS=auto
SRCREV_OE=73fa6a99128d299733612779ffd504d280520e1f
SRCREV_ROS=69c4af9ee6fdbb563bea3e2cb32b3ddeeea630ad
SRCREV_REALSENSE=auto
SRCREV_JAVA=74811bbadaf55fd105ad092a1fcb4923afd4d41d

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

echo "Cloning meta-java, master branch"
git clone -b master http://git.yoctoproject.org/git/meta-java poky/meta-java
if [[ $SRCREV_JAVA != "auto" ]]; then
	cd poky/meta-java
	git checkout $SRCREV_JAVA
	cd ../..
fi

echo "Cloning meta-intel-iot-middleware, master branch"
git clone -b master git://git.yoctoproject.org/meta-intel-iot-middleware poky/meta-intel-iot-middleware
if [[ $SRCREV_IOT_MIDDLEWARE != "auto" ]]; then
	cd poky/meta-intel-iot-middleware
	git checkout $SRCREV_IOT_MIDDLEWARE
	cd ../..
fi

echo "Cloning meta-intel-librealsense, master branch"
git clone -b master git://github.com/IntelRealSense/meta-intel-librealsense.git poky/meta-intel-librealsense
if [[ $SRCREV_REALSENSE != "auto" ]]; then
	cd poky/meta-intel-librealsense
	git checkout $SRCREV_REALSENSE
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

# hack for meta-intel-librealsense
echo BBMASK = \"meta-intel-librealsense/recipes-kernel/linux/\" >> conf/local.conf

if [ "X$my_dlss" = "Xdefault" ]; then
	echo "Using default download and sstate directories"
else
	echo DL_DIR ?= \""$my_dlss"/downloads\" >> conf/local.conf
	echo SSTATE_DIR ?= \""$my_dlss/sstate-cache"\" >> conf/local.conf
fi


