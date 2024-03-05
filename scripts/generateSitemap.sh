#!/bin/bash
MW_INSTALL_PATH="/var/www/html"
MW_SM_SCRIPT="$MW_INSTALL_PATH/maintenance/run.php generateSitemap\
    --memory-limit=50M\
    --identifier=tfp\
    --fspath=$MW_INSTALL_PATH/sitemap/\
    --urlpath=/sitemap/\
    --server=$MW_SERVER\
    --compress=yes\
    --skip-redirects"
SM_INDEX="sitemap-index-tfp.xml"

# Set CWD to install path
cd $MW_INSTALL_PATH

# Generate new sitemap
php $MW_SM_SCRIPT

# Create a link in our root directory to the sitemap, delete if already exists
ln -sf $MW_INSTALL_PATH/sitemap/$SM_INDEX $MW_INSTALL_PATH/sitemap.xml
