FROM texlive/texlive:latest

RUN apt-get update \
    && apt-get install -y \
    imagemagick \
    inkscape \
    librsvg2-bin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy in Latex build script, along with asset images
COPY ./doubtfire-api/lib/shell/latex_build.sh /texlive/shell/latex_build.sh
COPY ./doubtfire-api/public/assets/images /workspace/doubtfire-api/public/assets/images

RUN chmod +x /texlive/shell/latex_build.sh

CMD ["sh", "-c", "while sleep 5000; do :; done"]
