FROM ubuntu:xenial
#Based on Dockerfile from Kalion @ https://github.com/kalinon/htpc-docker/blob/master/comicstreamer/Dockerfile
MAINTAINER CCarpo <ccarpo@gmx.net>

# Set up static options
ENV DEBIAN_FRONTEND="noninteractive" \
  LANG="en_US.UTF-8" \
  LC_ALL="C.UTF-8" \
  LANGUAGE="en_US.UTF-8"

RUN apt-get -q update && \
  apt-get -qy --force-yes dist-upgrade && \
  apt-get install -qy git wget python-pip python-dev build-essential \
  # pillow required libs
  libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk

# Install unrar
RUN wget -O /root/unrarsrc-5.2.6.tar.gz http://www.rarlab.com/rar/unrarsrc-5.2.6.tar.gz && \
  tar xzf /root/unrarsrc-5.2.6.tar.gz -C /root/ 

WORKDIR /root/unrar
RUN pip -V 
RUN make lib && make install-lib
WORKDIR /
RUN rm -r /root/unrar*
ENV UNRAR_LIB_PATH /usr/lib/libunrar.so
RUN echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf
	 
# Install PIP libs
RUN pip install -U setuptools certifi && \
  pip install tornado sqlalchemy watchdog python-dateutil pillow configobj natsort unrar PyPDF2 pylzma

# Cleanup
RUN apt-get purge -y --auto-remove wget gcc build-essential python-dev && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/*

# Clone needed repos
RUN git clone https://github.com/ccarpo/ComicStreamer.git /opt/comicstreamer
RUN cp /usr/lib/libunrar.so /opt/comicstreamer/libunrar/libunrar.so

# Declare volumes needed
VOLUME ["/config","/data"]

# Final setup
EXPOSE 32500
ENTRYPOINT ["/opt/comicstreamer/comicstreamer", "--webroot=/comicstreamer", "--nobrowser", "--user-dir=/config"]
