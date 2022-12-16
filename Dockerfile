# Base distro:
FROM ubuntu

# Installatıon of the project to the container:
## Set workdir for installation.
WORKDIR /tmp/hpkg
## Copy all the assets.
COPY . .
## Get dependencies.
RUN apt update && apt install -y "make" "bash"
## Configure and install the project.
RUN make install
## Switch home.
WORKDIR /root

# Entry Point:
ENTRYPOINT /bin/bash
