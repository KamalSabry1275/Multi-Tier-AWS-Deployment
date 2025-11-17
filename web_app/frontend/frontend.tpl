#!/bin/bash
yum install -y httpd mod_proxy mod_proxy_http
systemctl enable httpd
systemctl start httpd

cat <<'HTML' > /var/www/html/index.html
${index_file}
HTML

cat <<'CONF' > /etc/httpd/conf.d/backend-proxy.conf
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot "/var/www/html"
    DirectoryIndex index.html

    ProxyPreserveHost On
    ProxyRequests Off
    ProxyPass /api/ http://${backend_ip}:5000/
    ProxyPassReverse /api/ http://${backend_ip}:5000/

    <Directory "/var/www/html">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
CONF

systemctl restart httpd
