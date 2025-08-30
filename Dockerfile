ARG ID=debian
ARG CODENAME=trixie@sha256:6d87375016340817ac2391e670971725a9981cfc24e221c47734681ed0f6c0f5

FROM ${ID}:${CODENAME}

# Add metadata labels for easy parsing
LABEL org.opencontainers.image.base.name="${ID}:${CODENAME}" \
      org.opencontainers.image.base.id="${ID}" \
      org.opencontainers.image.base.codename="${CODENAME}" \
      org.opencontainers.image.title="Debian Cross-Build Docker" \
      org.opencontainers.image.description="Cross-compilation environment for Debian/Ubuntu" \
      org.opencontainers.image.source="https://github.com/userdocs/debian-crossbuild-docker" \
      org.opencontainers.image.url="https://github.com/userdocs/debian-crossbuild-docker" \
      org.opencontainers.image.documentation="https://github.com/userdocs/debian-crossbuild-docker/blob/main/README.md" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.vendor="userdocs"

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
	CXXFLAGS="-g0 -std=c++17" \
	CPPFLAGS="-I/opt/local/include" \
	LDFLAGS="-s -L/opt/local/lib" \
	LANG="C.UTF-8" \
	LANGUAGE="C.UTF-8" \
	LC_ALL="C.UTF-8" \
	DEBIAN_FRONTEND=noninteractive

RUN if [[ "${ID}" == 'ubuntu' ]];then \
		rm -f /etc/apt/sources.list.d/ubuntu.sources \
		&& printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME} main restricted universe multiverse" > /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME}-backports restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=amd64] http://security.ubuntu.com/ubuntu/ ${CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list; \
	fi

RUN if [[ "${ID}" == 'ubuntu' && "${ARCH}" != 'amd64' ]];then \
		printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME} main restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list \
		&& dpkg --add-architecture ${ARCH} \
		&& apt-get update; \
	fi

RUN if [[ "${ID}" == 'debian' && "${ARCH}" != 'amd64' ]];then dpkg --add-architecture ${ARCH}; fi

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y curl git jq sudo

RUN if [[ "${ARCH}" == 'amd64' ]];then apt-get install -y build-essential; fi


RUN if [[ "${ARCH}" != 'amd64' ]];then apt-get install -y crossbuild-essential-${ARCH} dpkg-cross; fi

RUN apt-get install -y \
	make${APT_ARCH} ccache${APT_ARCH} libgeoip-dev${APT_ARCH} \
	libssl-dev${APT_ARCH} re2c${APT_ARCH} libstdc++-*-dev${APT_ARCH} libarchive-dev${APT_ARCH} \
	libcurl4-openssl-dev${APT_ARCH} libuv1-dev${APT_ARCH} procps${APT_ARCH} zlib1g-dev${APT_ARCH} \
	libexpat1-dev${APT_ARCH} openssl${APT_ARCH} libicu[0-9][^a-z]${APT_ARCH} libicu-dev${APT_ARCH} \
	libdouble-conversion[0-9]${APT_ARCH} libdouble-conversion-dev${APT_ARCH} \
	libjsoncpp-dev${APT_ARCH} libncurses5-dev${APT_ARCH} librhash-dev${APT_ARCH}

RUN if [[ ! "${CODENAME}" == "focal" ]];then \
		apt-get install -y libmd4c-html0${APT_ARCH} libmd4c-html0-dev${APT_ARCH}; \
	fi

# Reduce image size by cleaning apt cache and lists
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupadd -f -o -g 1001 gh \
	&& useradd -ms /bin/bash -u 1001 -g gh gh \
	&& useradd -ms /bin/bash -u 1002 -g gh github \
	&& printf '%s\n' 'gh ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/gh \
	&& printf '%s\n' 'github ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/github \
	&& chmod 0440 /etc/sudoers.d/gh /etc/sudoers.d/github

RUN if [[ "${CODENAME}" == "noble" ]]; then \
		usermod -md /home/username -l username ubuntu;\
		groupmod -n username ubuntu; \
	else \
		useradd -ms /bin/bash -u 1000 username; \
	fi \
	&& printf '%s\n' 'username ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/username \
	&& chmod 0440 /etc/sudoers.d/username

VOLUME /home/gh
VOLUME /home/username

WORKDIR /home/gh
