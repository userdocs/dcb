ARG ID
ARG CODENAME

FROM ${ID}:${CODENAME}

SHELL ["/bin/bash", "-c"]

ARG ID
ARG CODENAME
ARG ARCH
ARG APT_ARCH
ARG CHOST
ARG EXT
ARG EXTAR

ENV PATH=/opt/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	LD_LIBRARY_PATH=/opt/local/lib:/usr/lib/${CHOST}:/usr/lib:/usr/local/lib \
	AR=${CHOST}-${EXTAR:-ar} \
	CHOST=${CHOST} \
	CC=${CHOST}-gcc${EXT} \
	CPP=${CHOST}-cpp${EXT} \
	CXX=${CHOST}-g++${EXT} \
	CFLAGS="" \
	CCXFLAGS="-g0 -std=17" \
	CPPFLAGS="-I/opt/local/include" \
	LDFLAGS="-s -L/opt/local/lib" \
	DEBIAN_FRONTEND=noninteractive

# https://www.gnu.org/software/make/manual/make.html#index-CFLAGS
# COPY build.sh /opt/build.sh
# RUN /opt/build.sh

RUN if [[ "${ID}" =~ ^(buster|bullseye)$ && "${ARCH}" == 'armel' ]];then \
		printf '%s\n' "deb [arch=${ARCH}] http://deb.debian.org/debian ${ID}-proposed-updates main" > /etc/apt/sources.list; \
	fi

RUN if [[ "${ID}" == 'ubuntu' ]];then \
		printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME} main restricted universe multiverse" > /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME}-backports restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=amd64] http://security.ubuntu.com/ubuntu/ ${CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list; \
	fi

RUN if [[ "${ID}" == 'ubuntu' && "${ARCH}" != 'amd64' ]];then \
		printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME} main restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list; \
	fi

RUN if [[ "${ARCH}" != 'amd64' ]];then dpkg --add-architecture ${ARCH}; fi

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y curl git jq sudo

RUN if [[ "${ARCH}" == 'amd64' ]];then apt-get install -y build-essential; fi

RUN if [[ "${ARCH}" != 'amd64' ]];then apt-get install -y crossbuild-essential-${ARCH}; fi

RUN apt-get install -y \
	ccache${APT_ARCH} libgeoip-dev${APT_ARCH} \
	libssl-dev${APT_ARCH} re2c${APT_ARCH} libstdc++-*-dev${APT_ARCH} libarchive-dev${APT_ARCH} \
	libcurl4-openssl-dev${APT_ARCH} libuv1-dev${APT_ARCH} procps${APT_ARCH} zlib1g-dev${APT_ARCH} \
	libexpat1-dev${APT_ARCH} openssl${APT_ARCH} libicu[0-9][^a-z]${APT_ARCH} libicu-dev${APT_ARCH} \
	libdouble-conversion[0-9]${APT_ARCH} libdouble-conversion-dev${APT_ARCH} \
	libjsoncpp-dev${APT_ARCH} libncurses5-dev${APT_ARCH} librhash-dev${APT_ARCH}

RUN if [[ "${CODENAME}" =~ (bullseye|jammy) ]];then \
        apt-get install -y libmd4c-html0${APT_ARCH} libmd4c-html0-dev${APT_ARCH}; \
	fi

RUN if [[ "${ARCH}" == 'amd64' && "${CODENAME}" == 'bionic' ]];then \
        apt-get install -y cpp-8 gcc-8 g++-8; \
    fi

RUN if [[ "${ARCH}" != 'amd64' && "${CODENAME}" == 'bionic' ]];then \
        apt-get install -y cpp-8-${CHOST} g++-8-${CHOST} gcc-8-${CHOST}; \
    fi

RUN useradd -ms /bin/bash -u 1000 username \
	&& useradd -ms /bin/bash -u 1001 github \
	&& printf '%s' 'username ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/username \
	&& printf '%s' 'github ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/github

USER github

WORKDIR /home/github