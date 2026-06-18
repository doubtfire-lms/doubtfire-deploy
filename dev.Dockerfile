FROM mcr.microsoft.com/devcontainers/ruby:3.4-bookworm

# DEBIAN_FRONTEND=noninteractive is required to install tzdata in non interactive way
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg2 \
  software-properties-common \
  && install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
  && chmod a+r /etc/apt/keyrings/docker.asc \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list

# Get node from nodesource - node 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh \
  && sudo -E bash nodesource_setup.sh \
  && rm nodesource_setup.sh

ENV USER 'vscode'
ENV NODE_ENV docker
ENV NPM_CONFIG_PREFIX "/home/${USER}/.npm-global"
ENV BUNDLE_PATH /home/${USER}/.gems

COPY --chown="${USER}":"${USER}" doubtfire-api/.ci-setup/ /workspace/doubtfire-api/.ci-setup/

RUN apt-get update \
  && apt-get install -y  --no-install-recommends \
  lsb-release \
  nodejs \
  ffmpeg \
  ghostscript \
  qpdf \
  imagemagick \
  libmagic-dev \
  libmagickwand-dev \
  libmariadb-dev \
  # python3-pygments \
  tzdata \
  wget \
  libc6-dev \
  gosu \
  # inkscape \
  # librsvg2-bin \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  # smoke tests
  && node --version \
  && npm --version \
  && gem install bundler -v '~> 2.6.6'

USER "${USER}"

WORKDIR /workspace

RUN mkdir -p "${NPM_CONFIG_PREFIX}/lib" \
  && npm install -g npm@10.9.8 \
  && npm install -g husky --save-dev \
  && npm install -g @angular/cli \
  && npm i -g standard-version

# Install oh-my-zsh, powerlevel10k theme, and plugins
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k \
  && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
  && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

ENV RAILS_ENV development
ENV PATH /home/$USER/.gems/ruby/3.4.0/bin:$PATH:/tmp/texlive/bin/x86_64-linux:/tmp/texlive/bin/aarch64-linux:$PATH:/home/$USER/.npm-global/bin
ENV GEM_PATH /home/$USER/.gems/ruby/3.4.0:$GEM_PATH

# Install the web ui
WORKDIR /workspace/doubtfire-web
COPY --chown="${USER}":"${USER}" doubtfire-web/package.json /workspace/doubtfire-web

# Install web ui packages
RUN npm install -f

# Setup the folder where we will deploy the code
WORKDIR /workspace/doubtfire-api

COPY --chown="${USER}":"${USER}" doubtfire-api/Gemfile /workspace/doubtfire-api/Gemfile
COPY --chown="${USER}":"${USER}" doubtfire-api/Gemfile.lock /workspace/doubtfire-api/Gemfile.lock

RUN bundle install

WORKDIR /workspace

EXPOSE 9876

COPY --chown="${USER}":"${USER}" .devcontainer /workspace/.devcontainer

ENV HISTFILE /workspace/tmp/.zsh_history

RUN sudo chmod +x /workspace/.devcontainer/*.sh

RUN rm -rf /workspace/tmp && \
  mkdir /workspace/tmp && \
  sudo mkdir /student-work && \
  sudo chown vscode:vscode /student-work

ENTRYPOINT [ "/workspace/.devcontainer/docker-entrypoint.sh" ]
