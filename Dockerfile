FROM cvugrinec/acs-engine-tested:1.1
RUN echo 'alias ll="ls -al"' >> ~/.bashrc
RUN apt-get -y install vim
RUN apt-get -y install dnsutils
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl  && \
   mv kubectl /usr/bin  && \
   chmod 750 /usr/bin/kubectl && \
   mkdir ~/.kube
COPY scripts /opt/
COPY templates /opt/
WORKDIR /opt
