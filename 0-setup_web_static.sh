#!/usr/bin/env bash
# Sets up a web server for deployment of web_static.

if command -v nginx > /dev/null 2>&1; then
sudo systemctl stop nginx
sudo apt-get remove -y nginx
sudo apt-get autoremove -y
sudo apt-get purge -y nginx
sudo apt-get autoremove -y
sudo find / -name 'nginx*' -exec rm -rf {} +
fi

# Install nginx
sudo pt-get update
sudo apt-get install -y nginx
sudo ufw allow 'Nginx HTTP'
sudo mkdir -p /var/www/html/
sudo chmod -R 755 /var/www
sudo sh -c 'echo "Hello World!" > /var/www/html/index.html' > /dev/null 2>&1
sudo sh -c 'echo "Ceci n'\''est pas une page" > /var/www/html/404.html' > /dev/null 2>&1
sudo sed -i 's/server_name _;/server_name _;'\
	'\n\trewrite ^\/redirect_me https:\/\/www.youtube.com\/watch?v=QH2-TGUlwu4 permanent;'\
	'\n\n\terror_page 404 \/404.html;'\
	'\n\tlocation = \/404.html {'\
	'\n\t\troot \/var\/www\/html;'\
	'\n\t\tinternal;'\
	'\n\t}'\
	'\n\tlocation \/hbnb_static {'\
	'\n\t\talias \/data\/web_static\/current;'\
	'\n\t}/' /etc/nginx/sites-available/default
sudo sed -i 's/include \/etc\/nginx\/sites-enabled\/\*;/include \/etc\/nginx\/sites-enabled\/\*;'\
	'\n\tadd_header X-Served-By "$HOSTNAME";/' /etc/nginx/nginx.conf
# Create directories and symbolic link
sudo mkdir -p /data/web_static/releases/test/
sudo mkdir -p /data/web_static/shared/
# Add html content to index
sudo tee /data/web_static/releases/test/index.html > /dev/null <<EOF
<html>
	<head>
	</head>
	<body>
		Holberton School
	</body>
</html>
EOF
# Create a symblic link
if [ -d /data/web_static/current ]
then
sudo rm -rf /data/web_static/current
fi
sudo ln -sf /data/web_static/releases/test/ /data/web_static/current
# Give ownership to ubuntu
sudo chown -R ubuntu /data/
sudo chgrp -R ubuntu /data/
# Edit nginx config
sudo ln -sf '/etc/nginx/sites-available/default' '/etc/nginx/sites-enabled/default'
# Restart nginx
if sudo systemctl is-active --quiet nginx; then
sudo systemctl stop nginx
fi
sudo service nginx start
