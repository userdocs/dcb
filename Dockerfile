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

RUN if [[ "${ID}" == 'ubuntu' ]]; then \
		printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME} main restricted universe multiverse" > /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ ${CODENAME}-backports restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=amd64] http://security.ubuntu.com/ubuntu/ ${CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list; \
	fi

RUN if [[ "${ID}" == 'ubuntu' && "${ARCH}" != 'amd64' ]]; then \
		printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME} main restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME}-updates main restricted universe multiverse" >> /etc/apt/sources.list \
		&& printf '%s\n' "deb [arch=${ARCH}] http://ports.ubuntu.com/ubuntu-ports ${CODENAME}-security main restricted universe multiverse" >> /etc/apt/sources.list; \
	fi

RUN apt-get update \
	&& dpkg --add-architecture ${ARCH} \
	&& apt-get upgrade -y \
	&& apt-get install -y curl git jq sudo \
	&& apt-get update

RUN if [[ "${ARCH}" == 'amd64' && "${CODENAME}" =~ (stretch|bionic) ]]; then \
			apt-get install -y build-essential ccache libssl-dev re2c libstdc++-*-dev \
			libarchive-dev libcurl4-openssl-dev libuv1-dev procps zlib1g-dev libexpat1-dev \
			openssl  libicu6* libicu-dev libjsoncpp-dev libncurses5-dev librhash-dev; \
		fi

RUN if [[ "${ARCH}" == 'amd64' && "${CODENAME}" == 'bionic' ]]; then \
        apt-get install -y cpp-8 gcc-8 g++-8; \ 
    fi

RUN if [[ "${ARCH}" != 'amd64' && ! "${CODENAME}" =~ (stretch|bionic) ]]; then \
			apt-get install -y crossbuild-essential-${ARCH} ccache:${ARCH}  \
			libssl-dev:${ARCH} re2c:${ARCH} libstdc++-*-dev:${ARCH} libarchive-dev:${ARCH} \
			libcurl4-openssl-dev:${ARCH} libuv1-dev:${ARCH} procps:${ARCH} zlib1g-dev:${ARCH} \
			libexpat1-dev:${ARCH} openssl:${ARCH}  libicu6*:${ARCH} libicu-dev:${ARCH} \
			libjsoncpp-dev:${ARCH} libncurses5-dev:${ARCH} librhash-dev:${ARCH}; \
		fi

RUN if [[ "${ARCH}" != 'amd64' && "${CODENAME}" == 'bionic' ]]; then \
        apt-get install -y cpp-8-${CHOST} g++-8-${CHOST} gcc-8-${CHOST}; \
    fi

RUN if [[ "${CODENAME}" == 'buster' ]]; then \
        apt-get install -y libdouble-conversion1:${ARCH} libdouble-conversion-dev:${ARCH}; \
	fi

RUN if [[ ! "${CODENAME}" =~ (stretch|buster|bionic) ]]; then \
        apt-get install -y libdouble-conversion3:${ARCH} libdouble-conversion-dev:${ARCH}; \
	fi

RUN useradd -ms /bin/bash -u 1000 username \
	&& useradd -ms /bin/bash -u 1001 github \
	&& printf '%s' 'username ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/username \
	&& printf '%s' 'github ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/github

USER github

WORKDIR /home/github