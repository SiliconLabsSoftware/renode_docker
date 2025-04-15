#Container to build and test Renode for an Ubuntu Linux environment.
#Currently this only supports x86_64/amd64 architecture and building Renode with Mono,
#but future support for .NET and ARM64 is planned.

FROM ubuntu:22.04

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
# WARNING: HAS TO BE INSTALLED FIRST! (before libgtk2.0, ...)
# dependencies: install 'mono-complete' (not 'mono-dev')
# https://www.mono-project.com/download/stable/#download-lin
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3015
RUN apt-get update && apt-get install -y ca-certificates gnupg=2.2.* \
    && gpg --homedir /tmp \
            --no-default-keyring \
            --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg \
            --keyserver hkp://keyserver.ubuntu.com:80 \
            --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | tee /etc/apt/sources.list.d/mono-official-stable.list \
    && apt-get update && apt-get install -y mono-complete=6.12.* \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# dependencies: packages required to BUILD
# https://renode.readthedocs.io/en/latest/advanced/building_from_sources.html#prerequisites
# hadolint ignore=DL3015
RUN apt-get update && apt-get install -y \
        autoconf=2.69* \
        automake=1:1.16.* \
        coreutils=8.30-* \
        g++=4:9.3.* \
        git=1:2.25.* \
        gtk-sharp2=2.12.* \
        libarchive-tools=3.4.* \
        libgtk2.0-dev=2.24.* \
        libtool=2.4.*\
        policykit-1=0.105-* \
        python3-pip=20.* \
        python3=3.8.* \
        uml-utilities=20070815.* \
        build-essential cmake \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# dependencies: packages required to PACKAGE
# https://renode.readthedocs.io/en/latest/advanced/building_from_sources.html#creating-packages
# note the workaround for 'fpm needing dotenv=2.8.1'
# hadolint ignore=DL3015
RUN apt-get update && apt-get install -y \
        libarchive-tools=3.4.* \
        rpm=4.14.*\
        ruby=1:2.7* \
        ruby-dev=1:2.7* \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    && gem install dotenv -v 2.8.1 \
    && gem install fpm

# -----------------------------------------------------------------------------
# dependencies for robot test-framework (listed in `renode/tests/requirements.txt`)
RUN pip3 install --no-cache-dir \
        construct==2.10.68 \
        psutil==5.9.3 \
        pyyaml==6.0.* \
        requests==2.27.1 \
        robotframework-retryfailed==0.2.0 \
        robotframework==6.1 \
        pybgapi==1.3.0

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