FROM auska/docker-aria2:no-web

# set version label
LABEL maintainer="Auska"

ENV TZ=Asia/Shanghai ARIANG_VERSION=1.1.6 SECRET=admin RPC=6800 PORT=16881 WEB=8080 TRACKERSAUTO=Yes MODE=BT

# copy local files
COPY  root /

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
