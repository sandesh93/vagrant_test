#!/bin/bash


echo "############## Updating packages ###############"
sudo yum update -y 
sudo yum install epel-release -y


echo "############## Insatalling apache ##############"
sudo yum install httpd  mod_ssl php-cgi -y


echo "############ Starting apache ###########"
sudo service httpd start


echo "########## set chkconfig for apache #############"
sudo chkconfig httpd on


echo "############# Create Dummy app##############"
sudo mkdir /var/www/html/app
sudo cp /vagrant/index.html  /var/www/html/app/
sudo chown $USER:$USER /var/www/html/app/
sudo chmod -R 775 /var/www


echo "#############Configuring virtual hosts#############"
VHOST=$(cat <<EOF
<VirtualHost *:80>
    ProxyPreserveHost On
#    ProxyPass        "/app" "http://localhost/"
#    ProxyPassReverse "/app" "http://localhost/"
    ServerName localhost
Redirect / https://localhost:8443/app
</VirtualHost>
EOF
)
echo "${VHOST}" >> /etc/httpd/conf/httpd.conf


# setup the virtual host /var/www/html/app
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/app"
      <Directory "/var/www/html/app">
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require local
    </Directory>
    # Other directives here
</VirtualHost>
EOF
)
echo "${VHOST}" >> /etc/httpd/conf/httpd.conf


###Create sample web app
sudo mkdir /etc/httpd/ssl

###Copying dummy ssl certificates
sudo cp /vagrant/ssl/www.mywebapp.com.cert /etc/httpd/ssl/www.mywebapp.com.cert
sudo cp /vagrant/ssl/www.mywebapp.com.key /etc/httpd/ssl/www.mywebapp.com.key

# installing the ssl certificate

VHOST=$(cat <<EOF
<VirtualHost *:443>
ServerName localhost:443
SSLEngine on
SSLCertificateFile /etc/httpd/ssl/www.mywebapp.com.cert
SSLCertificateKeyFile /etc/httpd/ssl/www.mywebapp.com.key
ProxyPreserveHost On
#    ProxyPass        "/app" "http://localhost/"
#    ProxyPassReverse "/app" "http://localhost/"
    ServerName localhost
</VirtualHost>
EOF
)
echo "${VHOST}" >> /etc/httpd/conf.d/ssl.conf


VHOST=$(cat <<EOF
<VirtualHost *:443>
DocumentRoot "/var/www/html/app"
SSLEngine on
SSLCertificateFile /etc/httpd/ssl/www.mywebapp.com.cert
SSLCertificateKeyFile /etc/httpd/ssl/www.mywebapp.com.key
ProxyPreserveHost On
      <Directory "/var/www/html/app">
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require local
    </Directory>
    ProxyPass        "/app" "http://localhost/"
    ProxyPassReverse "/app" "http://localhost/"
    ServerName localhost
</VirtualHost>
EOF
)
echo "${VHOST}" >> /etc/httpd/conf.d/ssl.conf


echo "#######Restart apache##############"
sudo service httpd restart



echo "##########Installing memcached#################"
sudo yum install memcached -y
sudo service memcached start
sudo chkconfig memcached on

sudo yum install php php-mysql php-devel php-gd php-pecl-memcache php-pspell php-snmp php-xmlrpc php-xml -y



sed -i '/mod_foo.so/a LoadModule php5_module modules/libphp5.so' /etc/httpd/conf/httpd.conf

echo "#### setting up cron job for memcache restart if status is not running ######"
# ---------------------------------------
#         Cronjob Setup :: to check the process is up or not
# ---------------------------------------
VHOST=$(cat <<EOF
#!/bin/bash

ps auxw | grep memcache| grep -v grep > /dev/null

if [ $? != 0 ]
then
        /etc/init.d/memcached start > /dev/null
fi
EOF
)
echo "${VHOST}" > /home/vagrant/exercise-memcached.sh

sudo crontab -l | { cat; echo "*/1 * * * * /home/vagrant/exercise-memcached.sh > /dev/null 2>&1"; } | crontab 

sudo yum install nc -y

##########################

echo "copy php script to var/www"

sudo cp /vagrant/stats.php  /var/www/html/app/stats.php

sudo chmod -R 775 /var/www

sudo /etc/init.d/httpd restart



