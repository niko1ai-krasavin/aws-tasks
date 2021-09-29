#!/bin/bash
sudo su
yum -y update
amazon-linux-extras -y install nginx1
echo -e "http {\n server {\n listen 8888\n location / {\n  root /usr/share/nginx/html/\n  }\n }\n}">/etc/nginx/nginx.conf
IP=$(curl http://169.254.169.254/local-ipv4)
REGION=$(curl http://169.254.169.254/placement/region)
AZ=$(curl http://169.254.169.254/placement/availability-zone)
echo -e "<center><h4>IP: $IP</h4><br><h4>REGION: $REGION</h4><br><h4>AZ: $AZ</h4></center>">/usr/share/nginx/html/index.html
adduser teacher
usermod -aG adm teacher
cd /home/teacher
mkdir .ssh
chgrp teacher .ssh
chown teacher .ssh
chmod 700 .ssh
touch authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkBIEsfJD6d0J4tqTnVq4z3Ve0bop71b+27j75gncRsLdAHLVg/InhJdrtnVszNGzPIPTXM8jsb/cc0e0JDD7Teoqz0YxJH+ZhY5Y6iy5n8Vx+CCWr5Rra5IpfJclvDPbH+okiUqGyt1fmvS+VkoBWxOFiAOsfdSdTwJWyGs0kplZouOh93cRc/9mp16mNcR5B86+ORLrMZCq3ZGVj2F3YjlhXb1/aUz7Mi1E6Ze9UQQe2oKqf4w8wXIiSejCcrsZ9CT6SX28Kqw2Ilb+7cr84vXIQDKxZySupztn8qMFlDvtoeK4b+RvEtpRmJaC/no9yjTeDTnBYVsV+vQvxiaaeLzkbPRhd0Ovlayoz/gXqI4DOCaQTfISHxG7X+NLfpW6Hmvgf+2i9OStUMJatDx6y1BAj5cjBKo1JRS73U2o5wYYTAlq6jaDAUzWE8Ili7cZ2Qx2dz5uFq6S8NteIt9yR6LsfaHYKG/5WmaA3LOnYAqV+S7nq2WQVQ2Z5bzpJC9s= andrey@MBP-Andrey">>authorized_keys
chgrp teacher authorized_keys
chown teacher authorized_keys
chmod 600 authorized_keys
mv authorized_keys .ssh/