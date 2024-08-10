FROM texlive/texlive:latest

RUN apt-get update \
    && apt-get install -y \ 
    imagemagick \
    inkscape \
    librsvg2-bin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["sh", "-c", "while sleep 5000; do :; done"]