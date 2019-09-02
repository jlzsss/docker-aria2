FROM alpine:3.10 as compilingaria2c

#compiling aria2c

ARG  ARIA2_VER=1.34.0

RUN  apk add --no-cache ca-certificates make g++ gcc zlib-dev openssl-dev expat-dev sqlite-dev c-ares-dev libssh2-dev  \
&&   mkdir /aria2c  \
&&   wget -P /aria2c   https://github.com/aria2/aria2/releases/download/release-${ARIA2_VER}/aria2-${ARIA2_VER}.tar.gz  \
&&   tar  -zxvf  /aria2c/aria2-${ARIA2_VER}.tar.gz  -C    /aria2c  \
&&   cd  /aria2c/aria2-${ARIA2_VER}  \
&&   sed  -i  's/"1", 1, 16/"1", 1, 128/g'          src/OptionHandlerFactory.cc    \
&&   sed  -i  's/"20M", 1_m, 1_g/"4k", 1_k, 1_g/g'  src/OptionHandlerFactory.cc    \
&&   ./configure --without-libxml2  --without-gnutls --with-openssl  --host=x86_64-alpine-linux-musl   \
&&   make install-strip   \
&&   ldd /usr/local/bin/aria2c   |cut -d ">" -f 2|grep lib|cut -d "(" -f 1|xargs tar -chvf /aria2c/aria2c.tar  \
&&   mkdir /aria2  \
&&   tar  -xvf /aria2c/aria2c.tar  -C /aria2   \
&&   cp --parents /usr/local/bin/aria2c /aria2

# docker aria2 

FROM lsiobase/alpine:3.10

# set version label
LABEL maintainer="Auska"

ENV TZ=Asia/Shanghai ARIA2_VERSION=1.34.0 ARIANG_VERSION=1.1.3 SECRET=admin TRACKERSAUTO=Yes

# copy local files
COPY  root /
COPY --from=compilingaria2c  /aria2  /

RUN \
	echo "**** install packages ****" \
#	&& sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	&& apk add --no-cache darkhttpd unzip curl \
	&& cd /tmp \
	&& curl -fSL https://github.com/mayswind/AriaNg/releases/download/${ARIANG_VERSION}/AriaNg-${ARIANG_VERSION}.zip -o ariang.zip \
	&& mkdir -p /webui \
	&& unzip ariang.zip -d /webui \
	&& rm -rf /tmp \
	&& sed -i 's/max:16/max:128/g' /webui/js/aria-ng* \
	&& sed -i 's/defaultValue:"20M"/defaultValue:"4k"/g' /webui/js/aria-ng* 

# ports and volumes
EXPOSE 6800 8080
VOLUME /mnt /config
