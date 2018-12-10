#!/bin/bash

mysqlPassword=$1
replicaPassword=$2

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

service mysql restart







#set the password
#sudo mysqladmin -u root password "$mysqlPassword"   #without -p means here the initial password is empty

#alternative update mysql root password method
#sudo mysql -u root -e "set password for 'root'@'localhost' = PASSWORD('$mysqlPassword')"
#without -p here means the initial password is empty

#sudo service mysql restart

#iptables -A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT
#    iptables -A INPUT -p tcp -m tcp --dport 9200 -j ACCEPT
#    iptables-save
#}
#
#disable_apparmor_ubuntu() {
#    /etc/init.d/apparmor stop
#    /etc/init.d/apparmor teardown
#    update-rc.d -f apparmor remove
#    apt-get remove apparmor apparmor-utils -y