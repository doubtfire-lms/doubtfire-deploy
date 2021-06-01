# syntax=docker/dockerfile:1
FROM ruby:2.6.7-buster

ARG API_HOME=./doubtfire-api

# Setup dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
  ffmpeg \
  ghostscript \
  imagemagick \
  libmagic-dev \
  libmagickwand-dev \
  libmariadb-dev \
  python3-pygments \
  tzdata

# Setup the folder where we will deploy the code
WORKDIR /doubtfire

# Copy doubtfire-api source
COPY "$API_HOME" /doubtfire/

# Install LaTex
RUN /doubtfire/.ci-setup/texlive-install.sh

# Install the Gems
RUN bundle install --without passenger webserver

# Setup path
ENV PATH /tmp/texlive/bin/x86_64-linux:$PATH

CMD bundle exec rake submission:generate_pdfs