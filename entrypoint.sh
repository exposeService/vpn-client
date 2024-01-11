#!/bin/bash

finish () {
    wg-quick down wg0
    exit 0
}
trap finish SIGTERM SIGINT SIGQUIT

cat > /etc/nginx/nginx.conf << EOL
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}

stream {
    server {
        listen ${PORT};
        proxy_pass ${SERVER};
    }
}
EOL

mkdir -p /etc/wireguard
touch /etc/wireguard/wg0.conf

cat > /etc/wireguard/wg0.conf << EOL
[Interface]
Address = 10.99.0.2/24
ListenPort = 51820
PrivateKey = ${WG_PRIVATE}

[Peer]
PublicKey = ${WG_PUBLIC}
AllowedIPs = 10.99.0.0/24
Endpoint = ${WG_ENDPOINT}
PersistentKeepalive = 20
EOL

wg-quick up /etc/wireguard/wg0.conf

nginx -g "daemon off;"
