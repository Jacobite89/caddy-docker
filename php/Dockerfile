#
# Builder
#
FROM alpine:3.13 as builder
ARG version="2.4.0"

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
FROM alpine:3.13

RUN apk add --no-cache \
    ca-certificates \
    libcap \
    mailcap \
    php7-fpm \
    php7-json \
    php7-mbstring \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_sqlite \
    php7-session

COPY --from=builder /tmp/Caddyfile /etc/caddy/
COPY --from=builder /tmp/index.html /usr/share/caddy/
COPY --from=builder /usr/bin/caddy /usr/bin/
COPY entrypoint.sh /

RUN addgroup -g 82 -S www-data && \
    adduser -u 82 -SD -h /var/lib/caddy/ -g 'Caddy web server' -s /sbin/nologin -G www-data www-data && \
    setcap cap_net_bind_service=+ep /usr/bin/caddy && \
    chown -R www-data /var/log/php7 && \
    chmod +x /entrypoint.sh

USER www-data
RUN mkdir -p /var/lib/caddy/.local/share/caddy
VOLUME /var/lib/caddy/.local/share/caddy

EXPOSE 80 443 2019
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--environ", "--config", "/etc/caddy/Caddyfile"]
