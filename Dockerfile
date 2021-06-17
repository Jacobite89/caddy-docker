#
# Builder
#
FROM alpine:3.14 AS builder
ARG version="2.4.3"

RUN apk add --no-cache \
    ca-certificates \
    tar \
    wget

RUN wget -nv -O /tmp/Caddyfile "https://raw.githubusercontent.com/caddyserver/dist/master/config/Caddyfile" && \
    wget -nv -O /tmp/index.html "https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html" && \
    wget -nv -O /tmp/caddy.tar.gz "https://github.com/caddyserver/caddy/releases/download/v${version}/caddy_${version}_linux_amd64.tar.gz" && \
    tar -xzf /tmp/caddy.tar.gz -C /usr/bin caddy && \
    chmod +x /usr/bin/caddy && \
    caddy version

#
# Final Stage
#
FROM alpine:3.14

RUN apk add --no-cache \
    ca-certificates \
    libcap \
    mailcap

COPY --from=builder /tmp/Caddyfile /etc/caddy/
COPY --from=builder /tmp/index.html /usr/share/caddy/
COPY --from=builder /usr/bin/caddy /usr/bin/

RUN addgroup -g 82 -S www-data && \
    adduser -u 82 -SD -h /var/lib/caddy/ -g 'Caddy web server' -s /sbin/nologin -G www-data www-data && \
    setcap cap_net_bind_service=+ep /usr/bin/caddy

USER www-data
RUN mkdir -p /var/lib/caddy/.local/share/caddy
VOLUME /var/lib/caddy/.local/share/caddy

EXPOSE 80 443 2019
ENTRYPOINT ["caddy", "run"]
CMD ["--environ", "--config", "/etc/caddy/Caddyfile"]
