FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# https://github.com/jenkinsci/docker/issues/543#issuecomment-318356276
RUN echo "Acquire::http::Pipeline-Depth 0;" > /etc/apt/apt.conf.d/99custom && \
  echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf.d/99custom && \
  echo "Acquire::BrokenProxy    true;" >> /etc/apt/apt.conf.d/99custom

RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean
RUN apt-get update -o Acquire::CompressionTypes::Order::=gz

RUN apt-get update && \
  apt-get install -y --no-install-recommends --fix-missing \
  curl \
  git \
  python3 \
  python3-pip \
  cmake \
  pkg-config \
  libpng16-16 \
  libcurl4 \
  libsdl2-2.0-0 \
  libsdl2-mixer-2.0-0 \
  libsdl2-gfx-1.0-0 \
  libsdl2-image-2.0-0 \
  libsdl2-net-2.0-0 \
  libsdl2-ttf-2.0-0 \
  build-essential \
  fonts-dejavu-core \
  clang \
  ca-certificates \
  sudo \
  && rm -rf /var/lib/apt/lists/*

# Install .NET
RUN curl -L https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -o packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb && \
  rm packages-microsoft-prod.deb

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  dotnet-sdk-10.0 && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Install SplashKit
RUN curl -s https://raw.githubusercontent.com/splashkit/skm/master/install-scripts/skm-install.sh | bash
ENV PATH="/root/.splashkit:${PATH}"
RUN skm linux install

# Pre-cache the SplashKit nuget package
RUN mkdir -p /nuget-local
RUN dotnet new console -n tmp && \
  cd tmp && \
  dotnet add package SplashKit --package-directory /nuget-local && \
  cd .. && \
  rm -rf tmp
RUN dotnet nuget add source /nuget-local -n splashkit-local

ENV DOTNET_RESTORE_SOURCES="/nuget-local"

# Suppress audio/display warnings for headless SplashKit
RUN echo "pcm.!default { type hw card 0 }" > /etc/asound.conf
ENV SDL_AUDIODRIVER=dummy
ENV XDG_RUNTIME_DIR=/tmp/runtime-root
RUN mkdir -p $XDG_RUNTIME_DIR
