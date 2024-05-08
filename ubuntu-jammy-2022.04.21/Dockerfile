FROM ubuntu:jammy-20220421

# link to containers repo
LABEL org.opencontainers.image.source https://github.com/concordia-fsae/containers/ubuntu-jammy-2022.04.21

#ENV REFRESHED_AT 2022-04-28 # clear cache

# create build user
RUN useradd -u 1000 -U -G sudo -m builduser

# update packages
RUN apt-get -qq update

# Get ST-Link drivers, openocd, gdb, and other os-level dependencies
RUN apt-get -y install \
        sudo \
        vim \
        wget \
        python3.10 \
        python3-pip \
        stlink-tools=1.7.0+ds-1 \
        doxygen \
        graphviz

# allow sudo group to use sudo command without password
RUN echo "%sudo   ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoers

# download the compiler
ARG COMPILER="https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2017q4/gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2?revision=375265d4-e9b5-41c8-bf23-56cbe927e156?product=Downloads,64-bit,,Linux,7-2017-q4-major"
ARG COMPILER_TAR=/opt/toolchains/gcc-arm-none-eabi.tar.xz
ARG COMPILER_DIR=/opt/toolchains/gcc-arm-none-eabi/

RUN mkdir -p $COMPILER_DIR
RUN wget $COMPILER -O $COMPILER_TAR
RUN tar -xf $COMPILER_TAR -C $COMPILER_DIR --strip-components 1
# delete the tar to save space in the image
RUN rm $COMPILER_TAR

# download openocd=0.12.0
ARG OPENOCD="https://downloads.sourceforge.net/project/openocd-xpack/v0.12.0-2/xpack-openocd-0.12.0-2-linux-x64.tar.gz?ts=gAAAAABlfonv9CQwshyfx26jJ0MYL_Wqvj9lTx8E5miEOuIL_9Rb7L7MiRCDrRaGPwWtMNA7JcHOg4mfEpoQ1Q4U9u8v7_m9jg%3D%3D&r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fopenocd-xpack%2Ffiles%2Fv0.12.0-2%2Fxpack-openocd-0.12.0-2-linux-x64.tar.gz%2Fdownload"
ARG OPENOCD_TAR=/opt/openocd/openocd-0.12.0.tar.xz
ARG OPENOCD_DIR=/opt/openocd/

RUN mkdir $OPENOCD_DIR
RUN wget $OPENOCD -O $OPENOCD_TAR 
RUN tar -xf $OPENOCD_TAR -C $OPENOCD_DIR --strip-components 1
RUN rm $OPENOCD_TAR

# install python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

COPY entrypoint.sh /opt/entrypoint.sh
RUN chown builduser:builduser /opt/entrypoint.sh
RUN chmod u+x /opt/entrypoint.sh

# switch to non-root user
USER builduser

# define default dir when entering shell to be dir of project 
WORKDIR /firmware

ENTRYPOINT /opt/entrypoint.sh

# keep container running for debugging
#ENTRYPOINT ["tail", "-f", "/dev/null"]
