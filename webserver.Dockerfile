# syntax=docker/dockerfile:1
FROM ruby:2.6.7-buster

ARG SOURCE_HOME=./doubtfire-api

# Setup dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
  ffmpeg \
  ghostscript \
  imagemagick \
  libmagic-dev \
  libmagickwand-dev \
  libmariadb-dev \
  tzdata

# Setup the folder where we will deploy the code
WORKDIR /doubtfire

# Copy in the Gemfile details from the doubtfire-api source
COPY $SOURCE_HOME/Gemfile $SOURCE_HOME/Gemfile.lock /doubtfire/

# Install the Gems
RUN bundle install --without staging test
EXPOSE 3000

ENV RAILS_ENV production

# Watch tower labels
LABEL com.centurylinklabs.watchtower.lifecycle.post-update="rake db:migrate"
# we set this when we run watchtower: https://containrrr.dev/watchtower/arguments/#wait_until_timeout
CMD bundle exec rails s -b 0.0.0.0
