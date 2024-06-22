# Download base image ubuntu 22.04
FROM ubuntu:22.04

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Update Ubuntu Software repository
RUN apt update

# Installing system requirements
RUN apt install -y git wget

# Installing ROOT dependencies
RUN apt install -y binutils cmake dpkg-dev g++ gcc libssl-dev git libx11-dev libxext-dev libxft-dev libxpm-dev python3 libtbb-dev

# Installing optional dependencies
RUN apt install -y gfortran libpcre3-dev libglu1-mesa-dev libglew-dev libftgl-dev libfftw3-dev libcfitsio-dev libgraphviz-dev libavahi-compat-libdnssd-dev libldap2-dev python3-dev python3-numpy libxml2-dev libkrb5-dev libgsl-dev qtwebengine5-dev nlohmann-json3-dev libmysqlclient-dev libpython3.10-dev

# Creating ROOT directory
RUN mkdir -p software/root/
RUN cd software/root/

# Downloading ROOT source code
RUN wget https://root.cern/download/root_v6.32.02.source.tar.gz

# Unpacking ROOT
RUN tar xzfv root_v6.32.02.source.tar.gz

# Making and installing ROOT
RUN mkdir -p root_v6.32.02-build
RUN cd root_v6.32.02-build
RUN cmake -DCMAKE_INSTALL_PREFIX=../root_v6.32.02-install/ ../root-6.32.02/
RUN make -j$(nproc) 
RUN make install
