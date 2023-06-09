#!/bin/bash

if [[ "${ID}" == 'ubuntu' ]]; then
	printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME} main restricted universe multiverse" > /etc/apt/sources.list
	printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list
	printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME}-backports restricted universe multiverse" >> /etc/apt/sources.list
	printf '%s\n' "deb [arch=amd64] http://security.ubuntu.com/ubuntu/ ${CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list
fi

if [[ "${ID}" == 'ubuntu' && "${ARCH}" != 'amd64' ]]; then
	printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME} main restricted universe multiverse" >> /etc/apt/sources.list
	printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list
	printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list
fi

apt-get update
dpkg --add-architecture "${ARCH}"
apt-get upgrade -y
apt-get install -y curl git jq

if [[ "${ARCH}" != 'amd64' ]]; then
	apt-get update
	apt-get install -y crossbuild-essential-${ARCH} ccache:${ARCH} \
		libssl-dev:${ARCH} re2c:${ARCH} libstdc++-*-dev:${ARCH} \
		libarchive-dev:${ARCH} libcurl4-openssl-dev:${ARCH} libuv1-dev:${ARCH} \
		procps:${ARCH} zlib1g-dev:${ARCH} libexpat1-dev:${ARCH} \
		libjsoncpp-dev:${ARCH} libncurses5-dev:${ARCH} librhash-dev:${ARCH}
fi

if [[ "${ARCH}" != 'amd64' && "${CODENAME}" == 'bionic' ]]; then
	apt-get install -y cpp-8-${CHOST} g++-8-${CHOST} gcc-8-${CHOST}
fi

if [[ "${ARCH}" == 'amd64' ]]; then
	apt-get update
	apt-get install -y build-essential libssl-dev re2c libstdc++-*-dev \
		libarchive-dev libcurl4-openssl-dev libuv1-dev \
		procps zlib1g-dev libexpat1-dev ccache \
		libjsoncpp-dev libncurses5-dev librhash-dev
fi

if [[ "${ARCH}" == 'amd64' && "${CODENAME}" == 'bionic' ]]; then
	apt-get install -y gcc-8 g++-8
fi
