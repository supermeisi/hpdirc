# Author: Mustafa Schmidt
# E-Mail: muschmidt@uni-wuppertal.de
# Created: 22. June 2024

# Download base image ubuntu 22.04
FROM ubuntu:22.04

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Update Ubuntu Software repository
RUN apt update

# Installing system requirements
RUN apt install -y git wget sudo

# Installing ROOT dependencies
RUN apt install -y binutils cmake dpkg-dev g++ gcc libssl-dev git libx11-dev libxext-dev libxft-dev libxpm-dev python3 libtbb-dev

# Installing optional dependencies
RUN apt install -y gfortran libpcre3-dev libglu1-mesa-dev libglew-dev libftgl-dev libfftw3-dev libcfitsio-dev libgraphviz-dev libavahi-compat-libdnssd-dev libldap2-dev python3-dev python3-numpy libxml2-dev libkrb5-dev libgsl-dev qtwebengine5-dev nlohmann-json3-dev libmysqlclient-dev libpython3.10-dev

# Installing Geant4 dependencies
RUN apt update && apt install -y \
    libexpat1-dev \
    libxerces-c-dev \
    libqt5core5a \
    qtbase5-dev \
    libqt5opengl5-dev \
    libxmu-dev \
    libxi-dev

# Installint additional programs
RUN apt install -y emacs

# Create a non-root user
RUN useradd -m dockeruser && echo "dockeruser:dockeruser" | chpasswd && adduser dockeruser sudo

# Switch to non-root user
USER dockeruser
WORKDIR /home/dockeruser

# Creating ROOT directory
RUN mkdir -p /home/dockeruser/software/root/
WORKDIR /home/dockeruser/software/root/

# Downloading ROOT source code
RUN wget https://root.cern/download/root_v6.32.02.source.tar.gz

# Unpacking ROOT
RUN tar xzfv root_v6.32.02.source.tar.gz

# Making and installing ROOT
RUN mkdir -p root_v6.32.02-build
WORKDIR /home/dockeruser/software/root/root_v6.32.02-build
RUN cmake -DCMAKE_INSTALL_PREFIX=/home/dockeruser/software/root/root_v6.32.02-install/ -Dxrootd=off -Dbuiltin_xroot=off /home/dockeruser/software/root/root-6.32.02/
RUN make -j$(nproc)
RUN make install

# Setting environment variables for ROOT
ENV ROOTSYS=/home/dockeruser/software/root/root_v6.32.02-install
ENV PATH=$ROOTSYS/bin:$PATH
ENV LD_LIBRARY_PATH=$ROOTSYS/lib:$LD_LIBRARY_PATH
ENV PYTHONPATH=$ROOTSYS/lib:$PYTHONPATH

# Return to the original work directory
WORKDIR /home/dockeruser

# Creating Geant4 directory
RUN mkdir -p /home/dockeruser/software/geant4/
WORKDIR /home/dockeruser/software/geant4/

# Downloading Geant4 source code
RUN wget https://gitlab.cern.ch/geant4/geant4/-/archive/v11.1.1/geant4-v11.1.1.tar.gz

# Unpacking Geant4
RUN tar -xzf geant4-v11.1.1.tar.gz

# Making and installing Geant4
RUN mkdir -p geant4-v11.1.1-build
WORKDIR /home/dockeruser/software/geant4/geant4-v11.1.1-build
RUN cmake -DCMAKE_INSTALL_PREFIX=/home/dockeruser/software/geant4/geant4-v11.1.1-install \
          -DGEANT4_USE_QT=ON \
          -DGEANT4_INSTALL_DATA=ON \
          /home/dockeruser/software/geant4/geant4-v11.1.1
RUN make -j$(nproc)
RUN make install

# Setting environment variables for Geant4
ENV G4INSTALL=/home/dockeruser/software/geant4/geant4-v11.1.1-install
ENV G4DATA=$G4INSTALL/share/Geant4-11.1.0/data
ENV PATH=$G4INSTALL/bin:$PATH
ENV LD_LIBRARY_PATH=$G4INSTALL/lib:$LD_LIBRARY_PATH
ENV G4WORKDIR=$HOME/geant4_workdir
ENV G4INCLUDE=$G4INSTALL/include
    
# Return to the original work directory
WORKDIR /home/dockeruser

# Check out prttools
RUN git clone https://github.com/rdom/prttools.git

# Check out eicdirc
RUN git clone https://github.com/rdom/eicdirc.git

# Compile eicdirc
WORKDIR /home/dockeruser/eicdirc
RUN mkdir -p build
WORKDIR /home/dockeruser/eicdirc/build
RUN cmake .. && make -j$(nproc)
