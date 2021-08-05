FROM ruby:2.6.7-buster

ARG OVERSEER_HOME=./doubtfire-overseer

# docker-ce-cli apt dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN apt-get update
RUN apt-get -y install docker-ce docker-ce-cli containerd.io

WORKDIR /app

RUN gem install bundler

COPY "$OVERSEER_HOME" /app/
RUN bundle install

# Is not needed as long as the equivalent HOST DIR
# has been initiated with the correct FACLs.
# RUN mkdir /home/overseer/work-dir
    # && chown -R 1001:999 /home/overseer/work-dir \
    # && chmod -R 777 /home/overseer/work-dir

CMD bundle exec ruby ./app.rb