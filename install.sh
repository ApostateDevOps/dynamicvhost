#!/bin/bash
#
# Apache2 server install with Dynamic Host Configuration
# @author Shameem Abdul Salam
#


#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

if [ "$EUID" -ne 0 ]
  then echo -e "$Purple \n Please run as ROOT or Use sudo \n $Color_Off"
  exit
fi

if [ "$#" -lt 2 ]; then
    echo -e "$Red \n Usage : ./install.sh wildcard_domain document_root \n $Color_Off"
    exit 1
fi

WILDCARD=$1
ROOTDIR=${2%/}

# Installing Apache2 and Dnsmasq from the packages
echo -e "$Cyan \n Installing Apache2 and Dnsmasq from the packages $Color_Off"
apt-get update
apt-get install apache2 dnsmasq -y

# Deploy configuration

echo -e "$Green \n Deploy configuration ..... $Color_Off"

sed -e "s#ROOTDIR#$ROOTDIR#;s#WILDCARD#$WILDCARD#;" sample-conf/dynamic_host.conf > /etc/apache2/sites-enabled/dynamic_host.conf

echo "listen-address=127.0.0.1" >> /etc/dnsmasq.conf
echo "address=/."$WILDCARD"/127.0.0.1" >> /etc/dnsmasq.conf

# Start Apache and Dnsmasq
echo -e "$Yellow \n Restarting Services ..... $Color_Off"
a2enmod rewrite
a2enmod vhost_alias
systemctl restart apache2
systemctl restart dnsmasq

