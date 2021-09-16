# syntax=docker/dockerfile:1
FROM ruby:2.6.7-buster

ARG API_HOME=./doubtfire-api
ARG WEB_HOME=./doubtfire-web

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

# Copy doubtfire-api source
COPY "$API_HOME" /doubtfire/
# Copy doubtfire-web dist
COPY --from=doubtfire-web:local /doubtfire-web/dist /doubtfire/public/
# COPY "$WEB_HOME/dist" /doubtfire/public/

# Install bundler
RUN gem install bundler -v "< 2.0"

# Install the Gems
RUN bundle _1.17.3_ install --without passenger

EXPOSE 3000
ENV RAILS_ENV production

# Watch tower labels
LABEL com.centurylinklabs.watchtower.lifecycle.post-update="rake db:migrate"

# we set this when we run watchtower: https://containrrr.dev/watchtower/arguments/#wait_until_timeout
CMD bundle exec rails s -b 0.0.0.0
