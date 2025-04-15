#Container to build and test Renode for an Ubuntu Linux environment.
#Currently this only supports x86_64/amd64 architecture and building Renode with Mono,
#but future support for .NET and ARM64 is planned.

FROM ubuntu:24.04

# -----------------------------------------------------------------------------
# metadata
LABEL maintainer="chlight@silabs.com"
LABEL description="Container used to build, test, and package the SiLabs fork of Renode for Linux"

# -----------------------------------------------------------------------------
# scaffolding
ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LOG4J_FORMAT_MSG_NO_LOOKUPS=true
ENV CONTAINER_USER=buildengineer
ARG CONTAINER_UID=1001
ARG USER_HOMEDIR=/home/${CONTAINER_USER}
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

# -----------------------------------------------------------------------------
# Install .NET
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && apt-get install -y \
        ca-certificates \
        dotnet-sdk-8.0 \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# dependencies: packages required to BUILD
# https://renode.readthedocs.io/en/latest/advanced/building_from_sources.html#prerequisites
RUN apt-get update && apt-get install -y \
        autoconf \
        automake \
        cmake \
        coreutils \
        g++ \
        git \
        gtk-sharp3 \
        libgtk-3-dev \
        libtool \
        policykit-1 \
        python3 \
        python3-pip \
        uml-utilities \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# dependencies: packages required to PACKAGE
# https://renode.readthedocs.io/en/latest/advanced/building_from_sources.html#creating-packages
RUN apt-get update && apt-get install -y \
        libarchive-tools \
        rpm \
        ruby \
        ruby-dev \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    && gem install dotenv -v 2.8.1 \
    && gem install fpm

# -----------------------------------------------------------------------------
# dependencies for robot test-framework (listed in `renode/tests/requirements.txt`)
RUN pip3 install --no-cache-dir --break-system-packages \
        construct==2.10.* \
        psutil==5.9.* \
        pyyaml==6.0.* \
        requests==2.27.* \
        robotframework-retryfailed==0.2.* \
        robotframework==6.1 \
        pybgapi==1.3.*

# -----------------------------------------------------------------------------
# fixups
# cross-mount /opt/renode 'git' has some issues ... these aim to work around them
RUN git config --global --add safe.directory /opt/renode \
    && git config --global --add safe.directory /opt/renode/lib/resources

# -----------------------------------------------------------------------------
# create local, unprivileged user
RUN useradd ${CONTAINER_USER} --uid ${CONTAINER_UID} --no-log-init --create-home --shell /bin/bash

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# switch to unprivileged user
USER  ${CONTAINER_USER}
WORKDIR /opt/renode


# -----------------------------------------------------------------------------
# cheat sheet
# docker build --no-cache --platform linux/amd64 --build-arg CONTAINER_UID=`id -u` -t renode-dev:local -f Dockerfile .
# docker run --rm -it --platform linux/amd64 -v ~/repos/renode:/opt/renode renode-dev:local
# > ./build.sh -c ; ./build.sh ; ./build.sh -p "