FROM pandoc/latex:3.1.13

# Copy the install script
COPY doubtfire-api/.ci-setup/update-install.sh .

# Install additional packages
RUN ./update-install.sh \
  && rm update-install.sh

RUN tlmgr install pdfmanagement-testphase
RUN tlmgr install lt3luabridge
RUN tlmgr install gobble
RUN tlmgr install luatextra
RUN tlmgr install metalogo
RUN tlmgr install graphics
RUN tlmgr install pdfpages
RUN tlmgr install newpax
