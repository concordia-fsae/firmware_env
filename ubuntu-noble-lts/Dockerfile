FROM ubuntu:noble-20240429 as base

# update packages
RUN apt-get update -qq && apt-get install -y \
        && rm -rf /var/lib/apt/lists/*


# build python 3.8.19 from source (required for gdb)
# do this in a separate image to prevent bloat in the final image
FROM base as python38

# install python build dependencies
RUN apt-get update -qq && apt-get install -y \
        gdebi-core \
        curl \
        gcc \
        libbz2-dev \
        libev-dev \
        libffi-dev \
        libgdbm-dev \
        liblzma-dev \
        libncurses-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        make \
        tk-dev \
        zlib1g-dev \
        && rm -rf /var/lib/apt/lists/*

ARG PYTHON_VERSION=3.8.19
ARG PYTHON_PREFIX=/opt/python3.8
ARG PYTHON_WORKDIR=/tmp/python3.8
ARG PYTHON_DLPATH=${PYTHON_WORKDIR}/python${PYTHON_VERSION}.tgz

# download and extract source from python
RUN mkdir -p ${PYTHON_WORKDIR}/python3.8/

ADD --checksum=sha256:c7fa55a36e5c7a19ec37d8f90f60a2197548908c9ac8b31e7c0dbffdd470eeac \
    https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz ${PYTHON_DLPATH}

RUN tar -xvzf ${PYTHON_DLPATH} -C ${PYTHON_WORKDIR}/python3.8 --strip-components 1

# compile and install into PYTHON_PREFIX
RUN cd ${PYTHON_WORKDIR}/python3.8 \
        && ./configure --prefix=${PYTHON_PREFIX} --enable-shared --enable-optimizations --enable-ipv6 LDFLAGS=-Wl,-rpath=${PYTHON_PREFIX}/lib,--disable-new-dtags \
        && make -j8 \
        && make altinstall

# upgrade pip
RUN ${PYTHON_PREFIX}/bin/python3.8 -m pip install --upgrade pip

# download the compiler in a separate image so we don't have to keep redoing it while iterating
FROM alpine:3.20.0 as compiler_dl

RUN apk add --no-cache wget tar xz

ARG COMPILER="https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz"
ARG COMPILER_TAR=/opt/toolchains/gcc-arm-none-eabi.tar.xz
ARG COMPILER_DIR=/opt/toolchains/gcc-arm-none-eabi/

RUN mkdir -p $COMPILER_DIR
# FIXME: add checksum here once I can figure out how to download it...
ADD ${COMPILER} ${COMPILER_TAR}
RUN tar -xf $COMPILER_TAR -C $COMPILER_DIR --strip-components 1

# build final image
FROM base as image

# link to containers repo
LABEL org.opencontainers.image.source https://github.com/concordia-fsae/containers/ubuntu-noble-lts

# copy the compiled python dir from the other image
COPY --from=python38 /opt/python3.8/ /opt/python3.8/
RUN ln -s /opt/python3.8/lib/python3.8 /usr/lib/python3.8

# copy the compiler from the image where we downloaded it
COPY --from=compiler_dl /opt/toolchains/gcc-arm-none-eabi/ /opt/toolchains/gcc-arm-none-eabi/
RUN cd /usr/lib/x86_64-linux-gnu && \
        ln -s libncursesw.so.6 libncursesw.so.5 && \
        ln -s libtinfo.so.6 libtinfo.so.5

# Get ST-Link drivers, openocd, gdb, and other os-level dependencies
RUN apt-get update -qq && apt-get install -y \
        sudo \
        vim \
        wget \
        python3.10 \
        python3-pip \
        python-is-python3 \
        stlink-tools=1.8.0-1build2 \
        openocd=0.12.0-1build2 \
        doxygen \
        graphviz \
        && rm -rf /var/lib/apt/lists/*

# noble already has a user/group called "ubuntu" at 1000, so just rename them
RUN usermod -l builduser ubuntu
RUN groupmod -n builduser ubuntu

# allow sudo group to use sudo command without password
RUN echo "%sudo   ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoers

# disable externally managed python env errors
RUN python -m pip config set global.break-system-packages true

# install python dependencies
RUN --mount=type=bind,source=requirements.txt,target=/tmp/requirements.txt \
    pip install --requirement /tmp/requirements.txt

COPY entrypoint.sh /opt/entrypoint.sh
RUN chown builduser:builduser /opt/entrypoint.sh
RUN chmod u+x /opt/entrypoint.sh

# switch to non-root user
USER builduser

# define default dir when entering shell to be dir of project 
WORKDIR /firmware

ENTRYPOINT /opt/entrypoint.sh
