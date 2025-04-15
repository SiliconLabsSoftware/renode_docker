# Dockerfile to run Renode, built from SiLabs public fork
# Uses .NET to build, based on x86_64 architecture

FROM ubuntu:24.04

# -----------------------------------------------------------------------------
# metadata
LABEL maintainer="chlight@silabs.com"
LABEL description="Container w/ built-in version of SiLabs renode (public fork)"

# -----------------------------------------------------------------------------
# scaffolding
ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LOG4J_FORMAT_MSG_NO_LOOKUPS=true
ENV CONTAINER_USER=renoder
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

# dependencies
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

# -----------------------------------------------------------------------------
# dependencies for robot test-framework (listed in `renode/tests/requirements.txt`)
RUN pip3 install --no-cache-dir --break-system-packages \
        construct==2.10.* \
        psutil==5.9.* \
        pyelftools==0.30 \
        pyyaml==6.0.* \
        requests==2.27.* \
        robotframework-retryfailed==0.2.* \
        robotframework==6.1 \
        pybgapi==1.3.*


# -----------------------------------------------------------------------------
# Install the renode built from Actions inside SiliconLabsSoftware/renode_docker
RUN mkdir -p /opt/renode
COPY silabs-renode-dotnet /opt/renode
RUN ls /opt/renode
ENV PATH=/opt/renode:$PATH

# -----------------------------------------------------------------------------
# create local, unprivileged user
RUN useradd ${CONTAINER_USER} --uid ${CONTAINER_UID} --no-log-init --create-home --shell /bin/bash \
    && chown ${CONTAINER_USER} /opt

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# switch to unprivileged user
USER  ${CONTAINER_USER}
WORKDIR ${USER_HOMEDIR}

# -----------------------------------------------------------------------------
# cheat sheet
# docker build --platform linux/amd64 --build-arg CONTAINER_UID=`id -u` -t renode:local -f Dockerfile .
# docker run --rm -it --platform linux/amd64 renode:local
# > renode-test /opt/renode/tests/example.robot /opt/renode/tests/unit-tests/emulation-environment.robot