#!/bin/bash

if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install this shell script"
    exit 1
fi


echo "-----Stop iptables and selinux------------"
systemctl stop firewalld.service
systemctl disable firewalld.service
if [ -f /etc/sysconfig/selinux  ];then
	sed -i 's#/SELINUX=Enforcing#SELINUX=disabled#g' /etc/sysconfig/selinux
	setenforce 0
fi

echo "-----Install depencied packages-----------"
for package in  vim vim-enhanced wget zip unzip telnet ntsysv compat* apr* nasm* gcc gcc* gcc-c++ ntp make imake cmake automake autoconf python-devel zlib zlib-devel glibc glibc-devel glib2 libxml glib2-devel libxml2 libxml2-devel bzip2 bzip2-devel libXpm libXpm-devel libidn libidn-devel libtool libtool-ltdl-devel* libmcrypt libmcrypt-devel libevent-devel libmcrypt* libicu-devel libxslt-devel postgresql-devel curl curl-devel perl perl-Net-SSLeay pcre pcre-devel ncurses ncurses-devel openssl openssl-devel openldap openldap-devel openldap-clients openldap-servers krb5 krb5-devel e2fsprogs e2fsprogs-devel libjpeg libpng libjpeg-devel libjpeg-6b libjpeg-devel-6b libpng-devel libtiff-devel freetype freetype-devel fontconfig-devel gd gd-devel kernel screen sysstat flex bison nss_ldap pam-devel compat-libstdc++-33
do
	yum install -y $package
done

echo "-----Make and make install Nginx---------"
groupadd www
useradd -s /sbin/nologin -g www www

wget wget http://nginx.org/download/nginx-1.8.0.tar.gz
tar -zxf nginx-1.8.0.tar.gz
cd nginx-1.8.0
./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gunzip_module

make && make install
sed -i 's/^#user  nobody;/user www www;/g' /usr/local/nginx/conf/nginx.conf

if [ $? == 0 ];then
	echo "export PATH=$PATH:/usr/local/nginx/bin" >> /etc/profile
fi

cd ..
#cp  nginx /etc/init.d
chmod +x /etc/init.d/nginx
service nginx start

nginx_proc=`ps -ef|grep nginx|grep -v grep|wc -l`
if [ $nginx_proc -ge 2 ];then
	echo 'Nginx started successfully!'
else
	service nginx restart
fi
