FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Declare AMP core dependencies
ARG AMPDEPS="\
    bzip2 \
    coreutils \
    curl \
    gdb \
    git \
    git-lfs \
    gnupg \
    iputils-ping \
    libc++-dev \
    libc6 \
    libatomic1 \
    libgdiplus \
    liblua5.3-0 \
    libpulse-dev \
    libsqlite3-0 \
    libzstd1 \
    locales \
    numactl \
    procps \
    socat \
    tmux \
    unzip \
    xz-utils"

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    sudo \
    grep \
    zip \
    tar \
    screen \
    dirmngr \
    software-properties-common \
    net-tools \
    util-linux \
    lib32stdc++6 \
    lib32gcc-s1 \
    libstdc++6 \
    lib32z1 \
    mono-devel \
    $AMPDEPS \
    && sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen \
    # Adoptium Repo Setup
    && mkdir -p /etc/apt/keyrings \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb bookworm main" > /etc/apt/sources.list.d/adoptium.list \
    # Docker CLI Repo Setup
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list \
    # CubeCoders Repo Setup
    && wget -qO - https://repo.cubecoders.com/archive.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/cubecoders.gpg \
    && echo "deb https://repo.cubecoders.com/ debian/" > /etc/apt/sources.list.d/cubecoders.list \
    # Install Temurin JVMs and Docker CLI
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        temurin-8-jdk \
        temurin-11-jdk \
        temurin-17-jdk \
        temurin-21-jdk \
        temurin-22-jdk \
        temurin-23-jdk \
        temurin-24-jdk \
        temurin-25-jdk \
        docker-ce-cli \
        docker-buildx-plugin \
    # Extract ampinstmgr
    && apt-get install -y --no-install-recommends --download-only ampinstmgr \
    && mkdir -p /tmp/ampinstmgr \
    && dpkg-deb -x /var/cache/apt/archives/ampinstmgr_*.deb /tmp/ampinstmgr \
    && mv /tmp/ampinstmgr/opt/cubecoders/amp/ampinstmgr /usr/local/bin/ampinstmgr \
    # Group and User Creation Fix
    && groupadd -f amp \
    && groupadd -f docker \
    && useradd -m -s /bin/bash -g amp -G docker amp \
    # Clean up
    && apt-get -y autoremove --purge \
    && apt-get -y clean \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8

COPY amp-init.sh /usr/local/bin/amp-init.sh
RUN chmod +x /usr/local/bin/amp-init.sh

WORKDIR /home/amp

EXPOSE 8080 2223

ENTRYPOINT ["/usr/local/bin/amp-init.sh"]
