#!/bin/bash
sudo su
IP=$(curl http://169.254.169.254/local-ipv4)
REGION=$(curl http://169.254.169.254/placement/region)
AZ=$(curl http://169.254.169.254/placement/availability-zone)
echo -e "<center><h4>IP: $IP</h4><br><h4>REGION: $REGION</h4><br><h4>AZ: $AZ</h4></center>" > /usr/share/nginx/html/index.html
systemctl start nginx
