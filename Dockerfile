ARG ID=debian
ARG CODENAME=trixie@sha256:6d87375016340817ac2391e670971725a9981cfc24e221c47734681ed0f6c0f5

FROM ${ID}:${CODENAME}

SHELL ["/bin/bash", "-c"]

ARG ID
ARG CODENAME
ARG ARCH
ARG APT_ARCH
ARG CHOST

ENV PATH=/opt/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	LD_LIBRARY_PATH=/opt/local/lib:/usr/lib/${CHOST}:/usr/lib:/usr/local/lib \
	CHOST=${CHOST} \
	AR=${CHOST}-ar \
	CC=${CHOST}-gcc \
	CPP=${CHOST}-cpp \
	CXX=${CHOST}-g++ \
	CFLAGS="" \
	CCXFLAGS="-g0 -std=17" \
	CPPFLAGS="-I/opt/local/include" \
	LDFLAGS="-s -L/opt/local/lib" \
	LANG="C.UTF8" \
	LANGUAGE="C.UTF8" \
	DEBIAN_FRONTEND=noninteractive

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

RUN if [[ "${ID}" == 'debian' && "${ARCH}" != 'amd64' ]];then dpkg --add-architecture ${ARCH}; fi

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y curl git jq sudo

RUN if [[ "${ARCH}" == 'amd64' ]];then apt-get install -y build-essential; fi

RUN if [[ "${ID}" == 'ubuntu' && "${ARCH}" != 'amd64' ]];then dpkg --add-architecture ${ARCH}; fi

RUN if [[ "${ARCH}" != 'amd64' ]];then apt-get install -y crossbuild-essential-${ARCH}; fi

RUN apt-get install -y \
	ccache${APT_ARCH} libgeoip-dev${APT_ARCH} \
	libssl-dev${APT_ARCH} re2c${APT_ARCH} libstdc++-*-dev${APT_ARCH} libarchive-dev${APT_ARCH} \
	libcurl4-openssl-dev${APT_ARCH} libuv1-dev${APT_ARCH} procps${APT_ARCH} zlib1g-dev${APT_ARCH} \
	libexpat1-dev${APT_ARCH} openssl${APT_ARCH} libicu[0-9][^a-z]${APT_ARCH} libicu-dev${APT_ARCH} \
	libdouble-conversion[0-9]${APT_ARCH} libdouble-conversion-dev${APT_ARCH} \
	libjsoncpp-dev${APT_ARCH} libncurses5-dev${APT_ARCH} librhash-dev${APT_ARCH}

RUN if [[ ! "${CODENAME}" =~ focal ]];then \
		apt-get install -y libmd4c-html0${APT_ARCH} libmd4c-html0-dev${APT_ARCH}; \
	fi

RUN useradd -ms /bin/bash -u 1001 gh \
	&& printf '%s' 'gh ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/gh \
	&& chmod 0440 /etc/sudoers.d/gh

RUN if [[ "${CODENAME}" == "noble" ]]; then \
		usermod -md /home/username -l username ubuntu;\
		groupmod -n username ubuntu; \
	else \
		useradd -ms /bin/bash -u 1000 username; \
	fi \
	&& printf '%s' 'username ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/username \
	&& chmod 0440 /etc/sudoers.d/username

VOLUME /home/gh
VOLUME /home/username
