FROM cvugrinec/acs-engine-tested:1.1
COPY create-acs.example /opt
COPY scripts /opt/
COPY templates /opt/
RUN echo 'alias ll="ls -al"' >> ~/.bashrc
WORKDIR /opt
