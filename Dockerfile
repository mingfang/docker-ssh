FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Runit
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir -p /var/run/sshd && \
    echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo

#SSH service
RUN mkdir -p /etc/sv/ssh && echo "\
#!/bin/sh\n\
exec 2>&1\n\
exec /usr/sbin/sshd -D -e\
" > /etc/sv/ssh/run 
RUN mkdir -p /etc/sv/ssh/log /var/log/ssh && echo "\
#!/bin/sh\n\
exec 2>&1\n\
exec /usr/bin/svlogd -tt /var/log/ssh\
" > /etc/sv/ssh/log/run
RUN chmod +x /etc/sv/ssh/run /etc/sv/ssh/log/run && ln -s /etc/sv/ssh /etc/service/

ENV HOME /root
WORKDIR /root
EXPOSE 22
