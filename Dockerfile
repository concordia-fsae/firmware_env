LABEL org.opencontainers.image.source https://github.com/concordia-fsae/firmware_env

FROM ubuntu:jammy-20220421

#ENV REFRESHED_AT 2022-04-28 # clear cache

RUN apt-get -qq update

# Get ST-Link drivers, openocd and gdb
RUN apt-get -y install \
        sudo \
        vim \
        scons \
        python3.10 \
        wget \
        python3-pip \
        stlink-tools=1.7.0+ds-1 \
        openocd=0.11.0-1

COPY requirements.txt /

RUN pip3 install -r /requirements.txt

RUN useradd -u 1000 -U -G sudo -m builduser

RUN echo "%sudo   ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoers

# define default dir when entering shell to be dir of project 
WORKDIR /firmware

# keep container running for debugging
#ENTRYPOINT ["tail", "-f", "/dev/null"]
