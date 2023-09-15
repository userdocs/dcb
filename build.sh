#!/bin/bash

if [[ "${ID}" =~ ^(buster|bullseye)$ && "${ARCH}" == 'armel' ]]; then
	printf '%s\n' "deb [arch=${ARCH}] http://deb.debian.org/debian ${ID}-proposed-updates main" > /etc/apt/sources.list
fi

if [[ "${ID}" == 'ubuntu' ]]; then
	printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME} main restricted universe multiverse" > /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME}-backports restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=amd64] http://security.ubuntu.com/ubuntu/ ${CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list
fi

if [[ "${ID}" == 'ubuntu' && "${ARCH}" != 'amd64' ]]; then
	printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME} main restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list
fi

if [[ "${ARCH}" != 'amd64' ]]; then dpkg --add-architecture ${ARCH}; fi

apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y curl git jq sudo

if [[ "${ARCH}" == 'amd64' ]]; then apt-get install -y build-essential; fi

if [[ "${ARCH}" != 'amd64' ]]; then apt-get install -y crossbuild-essential-${ARCH}; fi

apt-get install -y \
	ccache${APT_ARCH} libgeoip-dev${APT_ARCH} \
	libssl-dev${APT_ARCH} re2c${APT_ARCH} libstdc++-*-dev${APT_ARCH} libarchive-dev${APT_ARCH} \
	libcurl4-openssl-dev${APT_ARCH} libuv1-dev${APT_ARCH} procps${APT_ARCH} zlib1g-dev${APT_ARCH} \
	libexpat1-dev${APT_ARCH} openssl${APT_ARCH} libicu[0-9][^a-z]${APT_ARCH} libicu-dev${APT_ARCH} \
	libdouble-conversion[0-9]${APT_ARCH} libdouble-conversion-dev${APT_ARCH} \
	libjsoncpp-dev${APT_ARCH} libncurses5-dev${APT_ARCH} librhash-dev${APT_ARCH}

if [[ "${CODENAME}" =~ (bullseye|jammy) ]]; then
	apt-get install -y libmd4c-html0${APT_ARCH} libmd4c-html0-dev${APT_ARCH}
fi

if [[ "${ARCH}" == 'amd64' && "${CODENAME}" == 'bionic' ]]; then
	apt-get install -y cpp-8 gcc-8 g++-8
fi

if [[ "${ARCH}" != 'amd64' && "${CODENAME}" == 'bionic' ]]; then
	apt-get install -y cpp-8-${CHOST} g++-8-${CHOST} gcc-8-${CHOST}
fi
