FROM alpine:3.11 as compilingaria2c

#compiling aria2c

ARG  ARIA2_VER=1.35.0

# copy local files
COPY  root /

RUN  apk add --no-cache bash bash-completion build-base pkgconf autoconf automake libtool perl linux-headers \
&&  bash /defaults/build.sh \
&&  mkdir /aria2 \
&&  cp --parents /usr/local/bin/aria2c /aria2

# docker aria2 

FROM lsiobase/alpine:3.11

# set version label
LABEL maintainer="Auska"

ENV TZ=Asia/Shanghai ARIANG_VERSION=1.1.6 SECRET=admin RPC=6800 PORT=16881 WEB=8080 TRACKERSAUTO=Yes

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
