#!/bin/bash
## Setup environment
# Set working directory to MediaWiki install location
DIR="/var/www/html"
cd $DIR

## LocalSettings manager
LOCALSETTINGS_URL="https://raw.githubusercontent.com/TheFirePanel/TFPWiki/main/LocalSettings.php"
echo "Grabbing LocalSettings from GitHub"
curl $LOCALSETTINGS_URL -O

## Start supervisord
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
