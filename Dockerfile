# Dockerfile to run Renode, built from SiLabs public fork
FROM ubuntu:22.04

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
ARG CONTAINER_UID=1010
ARG USER_HOMEDIR=/home/${CONTAINER_USER}
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone
ARG GIT_COMMIT=NOTSET
ENV GIT_COMMIT=${GIT_COMMIT}

# -----------------------------------------------------------------------------
# WARNING: HAS TO BE INSTALLED FIRST! (before libgtk2.0, ...)
# dependencies: install 'mono-complete' (not 'mono-dev')
# https://www.mono-project.com/download/stable/#download-lin
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && apt-get install -y ca-certificates gnupg=2.2.* \
    && gpg --homedir /tmp \
        --no-default-keyring \
        --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg \
        --keyserver hkp://keyserver.ubuntu.com:80 \
        --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | tee /etc/apt/sources.list.d/mono-official-stable.list \
    && apt-get update && apt-get install -y mono-complete=6.12.* \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# dependencies
RUN apt-get update && apt-get install -y \
        gtk-sharp2 \
        libgtk2.0 \
        libutempter0 \
        policykit-1 \
        python3 \
        python3-pip\
        screen \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# dependencies for robot test-framework (listed in `renode/tests/requirements.txt`)
RUN pip3 install --no-cache-dir \
        construct==2.10.68 \
        psutil==5.9.3 \
        pyelftools==0.30 \
        pyyaml==6.0.* \
        requests==2.27.1 \
        robotframework-retryfailed==0.2.0 \
        robotframework==6.1 \
        pybgapi==1.3.0


# -----------------------------------------------------------------------------
# Install the renode built from Actions inside SiliconLabsSoftware/renode_docker
COPY silabs-renode.deb /tmp/silabs-renode.deb
RUN dpkg --install /tmp/silabs-renode.deb \
    && rm -v /tmp/silabs-renode.deb

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