#!/bin/bash

sed -i 's/;short_open_tag/short_open_tag = On/g' /usr/local/php/etc/php.ini
service php-fpm restart

cd /opt

unzip Discuz_X3.2_SC_UTF8.zip

cp -R ./upload /usr/local/nginx/html

chown www.www -R ./upload 

cd upload
chmod -R 777 config
chmod -R 777 data
chmod -R 777 uc_client
chmod -R 777 uc_server

service nginx restart

