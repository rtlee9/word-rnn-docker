FROM ubuntu:14.04
MAINTAINER Ryan Lee <ryantlee9@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get install -y \
	curl \
	git \
	libpcre3 \
	libpcre3-dev \
	fastjar \
	software-properties-common \
	wget
RUN curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash
# Torch and luarocks
RUN git clone https://github.com/torch/distro.git /root/torch --recursive && cd /root/torch && \
    bash install-deps && \
    ./install.sh -b

ENV LUA_PATH='/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/root/torch/install/share/lua/5.1/?.lua;/root/torch/install/share/lua/5.1/?/init.lua;./?.lua;/root/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua'
ENV LUA_CPATH='/root/.luarocks/lib/lua/5.1/?.so;/root/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
ENV PATH=/root/torch/install/bin:$PATH
ENV LD_LIBRARY_PATH=/root/torch/install/lib:$LD_LIBRARY_PATH
ENV DYLD_LIBRARY_PATH=/root/torch/install/lib:$DYLD_LIBRARY_PATH
ENV LUA_CPATH='/root/torch/install/lib/?.so;'$LUA_CPATH

WORKDIR /root
RUN luarocks install nngraph
RUN luarocks install nninit
RUN luarocks install optim
RUN luarocks install nn
RUN luarocks install underscore.lua --from=http://marcusirven.s3.amazonaws.com/rocks/
RUN luarocks install lrexlib-pcre PCRE_LIBDIR=/lib/x86_64-linux-gnu

WORKDIR /root
RUN git clone https://github.com/larspars/word-rnn.git

WORKDIR word-rnn
RUN wget http://nlp.stanford.edu/data/glove.6B.zip
RUN mkdir util/glove
RUN fastjar xvf glove.6B.zip
RUN mv glove.6B.200d.txt util/glove/vectors.6B.200d.txt
RUN rm glove*
