# mosdns v5
FROM golang:alpine AS builder
ARG CGO_ENABLED=0
ARG REPOSITORY

WORKDIR /root
RUN apk add --update git \
	&& git clone https://github.com/${REPOSITORY} mosdns \
	&& cd ./mosdns \
	&& git checkout v5.3.3 \
	&& go build -ldflags "-s -w -X main.version=v5.3.3" -trimpath -o mosdns

FROM alpine:latest
LABEL maintainer="Sgit <github.com/Sagit-chu>"

COPY --from=builder /root/mosdns/mosdns /usr/bin/

RUN apk add --no-cache ca-certificates \
	&& mkdir /etc/mosdns
ADD entrypoint.sh /entrypoint.sh
ADD config.yaml /config.yaml
ADD hosts /hosts
ADD https://raw.githubusercontent.com/gaoyifan/china-operator-ip/refs/heads/ip-lists/china.txt /geoip_cn.txt
ADD https://raw.githubusercontent.com/gaoyifan/china-operator-ip/refs/heads/ip-lists/china6.txt /geoip_cn_v6.txt
ADD https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/reject-list.txt /geosite_category-ads-all.txt
ADD https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt /geosite_geolocation-!cn.txt
ADD https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt /geosite_cn.txt

VOLUME /etc/mosdns
EXPOSE 53/udp 53/tcp
RUN chmod +x /entrypoint.sh
CMD ["sh", "/entrypoint.sh"]
