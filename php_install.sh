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
for package in vim vim-enhanced wget zip unzip telnet ntsysv compat* apr* nasm* gcc gcc* gcc-c++ ntp make imake cmake automake autoconf python-devel zlib zlib-devel glibc glibc-devel glib2 libxml glib2-devel libxml2 libxml2-devel bzip2 bzip2-devel libXpm libXpm-devel libidn libidn-devel libtool libtool-ltdl-devel* libmcrypt libmcrypt-devel libevent-devel libmcrypt* libicu-devel libxslt-devel postgresql-devel curl curl-devel perl perl-Net-SSLeay pcre pcre-devel ncurses ncurses-devel openssl openssl-devel openldap openldap-devel openldap-clients openldap-servers krb5 krb5-devel e2fsprogs e2fsprogs-devel libjpeg libpng libjpeg-devel libjpeg-6b libjpeg-devel-6b libpng-devel libtiff-devel freetype freetype-devel fontconfig-devel gd gd-devel kernel screen sysstat flex bison nss_ldap pam-devel compat-libstdc++-33
do
	yum install -y $package
done

echo "-----Make and make install PHP---------"
wget ftp://ftp.gnu.org/gnu/autoconf/autoconf-2.68.tar.gz
tar xf autoconf-2.68.tar.gz
cd autoconf-2.68
./configure
make && make install
cd ..

wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.13.1.tar.gz
tar xf libiconv-1.13.1.tar.gz
cd libiconv-1.13.1
./configure
cd srclib/
sed -ir -e '/gets is a security/d' ./stdio.in.h
cd ../
make
make && make install
cd ..

wget http://nchc.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
tar xf  libmcrypt-2.5.8.tar.gz
./configure
make && make install
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../..

wget http://downloads.sourceforge.net/mhash/mhash-0.9.9.9.tar.gz
tar xf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure
make && make install
cd ..


wget  http://mirrors.sohu.com/php/php-5.6.20.tar.gz
tar xf php-5.6.20.tar.gz
cd php-5.6.20
./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--with-fpm-user=www \
--with-fpm-group=www \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-pgsql \
--with-iconv \
--with-iconv-dir=/usr/ \
--with-freetype-dir=/usr/\
--with-jpeg-dir=/usr/ \
--with-png-dir=/usr/ \
--with-libxml-dir=/usr \
--with-gettext \
--with-gd \
--with-pear \
--with-curl \
--with-zlib \
--with-zlib-dir \
--with-mcrypt \
--with-mhash \
--with-openssl \
--with-xmlrpc \
--with-xsl \
--with-pcre-regex \
--with-kerberos \
--enable-fpm \
--enable-opcache \
--enable-gd-native-ttf \
--enable-exif \
--enable-mysqlnd \
--enable-ftp \
--enable-zip \
--enable-sockets \
--enable-static \
--enable-xml \
--enable-xmlreader \
--enable-xmlwriter \
--enable-soap \
--enable-mbstring \
--enable-bcmath \
--enable-sysvshm \
--enable-sysvsem \
--enable-intl \
--enable-wddx \
--enable-shmop \
--enable-pcntl \
--enable-mbregex \
--enable-calendar \
--enable-inline-optimization \
--disable-maintainer-zts \
--disable-ipv6 \
--disable-rpath \
--disable-debug \
--disable-fileinfo
/usr/local/webserver/php/bin/php go-pear.phar
/usr/local/php/bin/php go-pear.pha
make ZEND_EXTRA_LIBS='-liconv -L/usr/local/lib'
make install
echo "export PATH=$PATH:/usr/local/php/bin" >> /etc/profile
source /etc/profile

cp php.ini-production  /usr/local/php/etc/php.ini
mv /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cd ..
#cp  /opt/php-fpm /etc/init.d/
chmod +x /etc/init.d/php-fpm
service php-fpm start



nginx_proc=`ps -ef|grep nginx|grep -v grep|wc -l`
if [ $nginx_proc -ge 2 ];then
	echo 'PHP started successfully!'
else
	service nginx restart
fi
