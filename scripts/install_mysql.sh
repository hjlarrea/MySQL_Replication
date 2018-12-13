#!/bin/bash

mysqlPassword=$1
replicaPassword=$2
remoteAdmin=$3
remotePassword=$4
remoteServer=$5
publicIpAddress=$6

apt-get update

echo "mysql-server-5.7 mysql-server/root_password password $mysqlPassword" | sudo debconf-set-selections 
echo "mysql-server-5.7 mysql-server/root_password_again password $mysqlPassword" | sudo debconf-set-selections 

apt-get -y install mysql-server-5.7

sed -i 's/\(bind-address\)/#\1/' /etc/mysql/mysql.conf.d/mysqld.cnf
echo 'bind-address           = 0.0.0.0' >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo 'server-id              = 1' >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo 'log_bin                = /var/log/mysql/mysql-bin.log' >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo '[mysqld]' >> /etc/mysql/my.cnf
echo 'lower_case_table_names=1' >> /etc/mysql/my.cnf

service mysql restart

iptables -A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 9200 -j ACCEPT
iptables-save

mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';use mysql;UPDATE mysql.user SET host='%' WHERE user='root';" -p$mysqlPassword

mysql -u root -e "CREATE USER 'syncuser'@'%' IDENTIFIED BY '$replicaPassword';GRANT REPLICATION SLAVE ON *.* TO ' syncuser'@'%';" -p$mysqlPassword

binLog= mysql -u root -e "show master status;" -p$mysqlPassword | grep -i mysql-bin | awk '{print $2}'
position= mysql -u root -e "show master status;" -p$mysqlPassword | grep -i mysql-bin | awk '{print $2}'
service mysql restart

mysql -u $remoteAdmin@$remoteServer -h $remoteServer -e "CALL mysql.az_replication_change_master('$publicIpAddress', 'syncuser', '$replicaPassword', 3306, '$binLog', '$position', ' ');CALL mysql.az_replication_start;" -p$remotePassword