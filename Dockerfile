FROM lsiobase/alpine:3.11

# set version label
ARG BUILD_DATE
ARG VERSION
ARG MYLAR3_COMMIT
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
    curl \
	g++ \
	gcc \
	jpeg-dev \
	libffi-dev \
	libpng-dev \
	libxml2-dev \
	libxslt-dev \
	make \
	openjpeg-dev \
	python3-dev && \
 echo "**** install system packages ****" && \
 apk add --no-cache \
    git \
    libjpeg \
	nodejs \
	openjpeg \
    python3 \
	unrar \
	unzip \
	zlib && \
 echo "**** install app ****" && \
 if [ -z ${MYLAR3_COMMIT+x} ]; then \
	MYLAR3_COMMIT=$(curl -sX GET https://api.github.com/repos/mylar3/mylar3/commits/master \
	| awk '/sha/{print $4;exit}' FS='[""]'); \
 fi && \
 git clone https://github.com/mylar3/mylar3.git /app/mylar3 && \
 cd /app/mylar3 && \
 git checkout ${MYLAR3_COMMIT} && \
 echo "**** install pip packages ****" && \
 pip3 install --no-cache-dir -U -r \
	/app/mylar3/requirements.txt && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# add local files
COPY root/ /

# ports and volumes
VOLUME /config /comics /downloads
EXPOSE 8090
