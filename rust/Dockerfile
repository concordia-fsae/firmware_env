FROM rust:1.78-buster

# update packages
RUN apt-get update -qq && apt-get install -y \
        sudo \
        vim \
        wget \
        && rm -rf /var/lib/apt/lists/*

# link to containers repo
LABEL org.opencontainers.image.source https://github.com/concordia-fsae/containers/rust

# create build user
RUN useradd -u 1000 -U -G sudo -m rustuser

# allow sudo group to use sudo command without password
RUN echo "%sudo   ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoers

COPY entrypoint.sh /opt/entrypoint.sh
RUN chown rustuser:rustuser /opt/entrypoint.sh
RUN chmod u+x /opt/entrypoint.sh

# switch to non-root user
USER rustuser

# define default dir when entering shell to be dir of project 
WORKDIR /conUDS/conUDS

ENTRYPOINT /opt/entrypoint.sh
