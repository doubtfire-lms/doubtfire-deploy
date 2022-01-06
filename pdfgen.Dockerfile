# syntax=docker/dockerfile:1
FROM ruby:2.6.7-buster

ARG API_HOME=./doubtfire-api
ARG PDFGEN_HOME=./pdfGen

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
  tzdata \
  cron \
  msmtp-mta bsd-mailx

# Setup the folder where we will deploy the code
WORKDIR /doubtfire

# Install LaTex
COPY "$API_HOME"/.ci-setup /doubtfire/.ci-setup
RUN /doubtfire/.ci-setup/texlive-install.sh

# Install bundler
RUN gem install bundler -v 2.2.28
RUN bundle config set --global without development test staging

# Install the Gems
COPY "$API_HOME"/Gemfile "$API_HOME"/Gemfile.lock /doubtfire/
RUN bundle install

# Setup path
ENV PATH /tmp/texlive/bin/x86_64-linux:$PATH

# Copy doubtfire-api source
COPY "$API_HOME" /doubtfire/

# Crontab file copied to cron.d directory.
COPY "$PDFGEN_HOME"/entry_point.sh /doubtfire/
COPY "$PDFGEN_HOME"/crontab /etc/cron.d/container_cronjob

RUN touch /var/log/cron.log

CMD /doubtfire/entry_point.sh
