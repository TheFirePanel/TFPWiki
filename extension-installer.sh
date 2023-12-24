#!/bin/bash
cd /var/www/html # Make sure we are set in the correct wd

declare -A ext_array
ext_array[0]="https://gerrit.wikimedia.org/r/mediawiki/extensions/TemplateStyles"

# Go into extensions directory
cd extensions/
for i in "${!ext_array[@]}"
do
    echo "Installing extension with the git url of ${ext_array[$i]}"
    git clone ${ext_array[$i]}
done
