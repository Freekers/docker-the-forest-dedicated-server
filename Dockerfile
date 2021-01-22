FROM ubuntu:18.04

LABEL maintainer="Sebastian Schmidt"

ENV WINEPREFIX=/wine DEBIAN_FRONTEND=noninteractive PUID=0 PGID=0

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libxml2:i386 libasound2-plugins:i386 libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsqlite3-0:i386 \
    && apt-get install -y wget software-properties-common supervisor apt-transport-https xvfb winbind cabextract \
    && wget https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' \
    && add-apt-repository ppa:cybermax-dexter/sdl2-backport \
    && apt-get update \
    && apt update && apt install -y --install-recommends winehq-stable \
    && wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x ./winetricks \
    && WINEDLLOVERRIDES="mscoree,mshtml=" wineboot -u \
    && wineserver -w \
    && ./winetricks -q winhttp wsh57 vcrun6sp6

COPY . ./

RUN apt-get remove -y software-properties-common apt-transport-https cabextract \
    && rm -rf winetricks /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
    && chmod +x /usr/bin/steamcmdinstaller.sh /usr/bin/servermanager.sh /wrapper.sh

EXPOSE 8766/tcp 8766/udp 27015/tcp 27015/udp 27016/tcp 27016/udp

VOLUME ["/theforest", "/steamcmd"]

CMD ["supervisord"]
