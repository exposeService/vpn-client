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

wg-quick up /etc/wireguard/wg0.conf

# Inifinite sleep
# sleep infinity &
# wait $!

nginx -g "daemon off;"
