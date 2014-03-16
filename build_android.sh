#!/bin/bash

if [ -z "$ANDROID_NDK" ]; then
	echo "You must define ANDROID_NDK before starting."
	echo "They must point to your NDK directories.\n"
	exit 1
fi

# Detect OS
OS=`uname`
HOST_ARCH=`uname -m`
export CCACHE=; type ccache >/dev/null 2>&1 && export CCACHE=ccache
if [ $OS == 'Linux' ]; then
	export HOST_SYSTEM=linux-$HOST_ARCH
elif [ $OS == 'Darwin' ]; then
	export HOST_SYSTEM=darwin-$HOST_ARCH
fi


SOURCE=`pwd`
PREFIX=$SOURCE/build/android

SYSROOT=$ANDROID_NDK/platforms/android-18/arch-arm
CROSS_PREFIX=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.8/prebuilt/$HOST_SYSTEM/bin/arm-linux-androideabi-

./configure  --prefix=$PREFIX \
  --host=arm-linux \
  --with-sysroot=${SYSROOT} \
  --enable-shared \
  --disable-static \
  --with-pic=no \
  CC="${CROSS_PREFIX}gcc --sysroot=${SYSROOT}" \
  CXX="${CROSS_PREFIX}g++ --sysroot=${SYSROOT}" \
  RANLIB="${CROSS_PREFIX}ranlib" \
  AR="${CROSS_PREFIX}ar" \
  AR_FLAGS=rcu \
  STRIP="${CROSS_PREFIX}strip" \
  NM="${CROSS_PREFIX}nm" \
  CFLAGS="-O3  --sysroot=${SYSROOT} -D__DragonFly__" \
  CXXFLAGS="-O3 --sysroot=${SYSROOT}" \
  || exit 1

make clean
make -j4 install || exit 1

