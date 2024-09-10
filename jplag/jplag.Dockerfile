FROM openjdk:21-jdk-slim

RUN apt-get update \
    && apt-get install -y \
        curl \
        libxrender1 \
        libjpeg62-turbo \
        fontconfig \
        libxtst6 \
        xfonts-75dpi \
        xfonts-base \
        xz-utils \
        && curl -LO http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
        && dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

RUN curl "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb" -L -o "wkhtmltopdf.deb"

RUN dpkg -i wkhtmltopdf.deb

COPY ./myJplag.jar /jplag/myJplag.jar