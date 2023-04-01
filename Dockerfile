ARG ID
ARG CODENAME

FROM ${ID}:${CODENAME}

SHELL ["/bin/bash", "-c"]

ARG ID
ARG CODENAME
ARG ARCH
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

RUN if [[ "${ARCH}" != 'amd64' ]];then apt_arch=":${ARCH}"; fi

RUN if [[ "${ARCH}" != 'amd64' ]];then dpkg --add-architecture ${ARCH}; fi

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y curl git jq sudo

RUN if [[ "${ARCH}" == 'amd64' ]];then apt-get install -y build-essential; fi

RUN if [[ "${ARCH}" != 'amd64' ]];then apt-get install -y crossbuild-essential-${ARCH}; fi

RUN apt-get install -y \
	ccache${apt_arch} libgeoip-dev${apt_arch} \
	libssl-dev${apt_arch} re2c${apt_arch} libstdc++-*-dev${apt_arch} libarchive-dev${apt_arch} \
	libcurl4-openssl-dev${apt_arch} libuv1-dev${apt_arch} procps${apt_arch} zlib1g-dev${apt_arch} \
	libexpat1-dev${apt_arch} openssl${apt_arch} libicu[0-9][^a-z]${apt_arch} libicu-dev${apt_arch} \
	libdouble-conversion[0-9]${apt_arch} libdouble-conversion-dev${apt_arch} \
	libjsoncpp-dev${apt_arch} libncurses5-dev${apt_arch} librhash-dev${apt_arch}

RUN if [[ "${CODENAME}" =~ (bullseye|jammy) ]];then \
        apt-get install -y libmd4c-html0${apt_arch} libmd4c-html0-dev${apt_arch}; \
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