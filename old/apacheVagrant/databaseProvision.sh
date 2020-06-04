#!/bin/bash

# Let the soon-to-be MySQL instance know that this installation is not to be interactive
export DEBIAN_FRONTEND=noninteractive

apt update
apt install -y mysql-server
# Replace loopback-only listening with all interfaces
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
# Set a root password
mysqladmin -u root password supersecretpass
systemctl restart mysql
# Allow MySQL to allow root to connect from any host.
# VERY UNSAFE IN PRACTICE, but O.K. for our example here
mysql -uroot mysql <<< "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'supersecretpass'; FLUSH PRIVILEGES;"
