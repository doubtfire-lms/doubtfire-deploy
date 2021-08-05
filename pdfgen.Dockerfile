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

# Install LaTex
COPY "$API_HOME"/.ci-setup /doubtfire/.ci-setup
RUN /doubtfire/.ci-setup/texlive-install.sh

# Install bundler
RUN gem install bundler

# Install the Gems
COPY "$API_HOME"/Gemfile "$API_HOME"/Gemfile.lock /doubtfire/
RUN bundle install --without passenger webserver

# Setup path
ENV PATH /tmp/texlive/bin/x86_64-linux:$PATH

# Copy doubtfire-api source
COPY "$API_HOME" /doubtfire/

CMD bundle exec rake submission:generate_pdfs