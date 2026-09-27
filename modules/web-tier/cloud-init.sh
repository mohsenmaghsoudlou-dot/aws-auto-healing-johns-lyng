#!/bin/bash
set -euo pipefail

# Record setup output for troubleshooting.
exec > >(tee -a /var/log/web-bootstrap.log) 2>&1

# Retry installation if the package repository is temporarily unavailable.
installed=false

for attempt in 1 2 3 4 5; do
  if dnf install -y --setopt=ip_resolve=4 nginx; then
    installed=true
    break
  fi

  echo "NGINX installation attempt ${attempt} failed."
  sleep 10
done

if [ "$installed" != "true" ]; then
  echo "NGINX installation failed."
  exit 1
fi

mkdir -p /usr/share/nginx/html

# Identify the responding instance to help demonstrate load balancing.
cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Auto-healing web tier</title>
</head>
<body>
  <h1>Welcome to NGINX</h1>
  <p>Served by: $(hostname)</p>
</body>
</html>
EOF

printf 'healthy\n' > /usr/share/nginx/html/health

# Configure a simple HTTP server for the page and health check.
cat > /etc/nginx/nginx.conf <<'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /var/log/nginx/access.log;
    sendfile on;

    server {
        listen 80 default_server;
        server_name _;
        root /usr/share/nginx/html;

        location / {
            try_files $uri $uri/ =404;
        }
    }
}
EOF

nginx -t
systemctl enable nginx
systemctl restart nginx

curl --fail --silent --show-error http://127.0.0.1/health