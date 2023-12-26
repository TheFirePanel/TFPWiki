#!/bin/bash
dir="/var/www/html"
cd $dir # Make sure we are set in the correct wd

# All extensions to add, [GIT URL]="BRANCH"
declare -A repos=(
    ["https://github.com/edwardspec/mediawiki-aws-s3"]="master"
    ["https://gerrit.wikimedia.org/r/mediawiki/extensions/MobileFrontend"]="REL1_41"
    ["https://gerrit.wikimedia.org/r/mediawiki/extensions/TemplateStyles"]="REL1_41"
)

# Go into extensions directory
cd $dir/extensions/
for repo in "${!repos[@]}"; do
    branch=${repos[$repo]}
    
    echo "Cloning $repo (branch: $branch)"
    git clone --depth 1 --single-branch --branch $branch $repo
done

# Update/Install extension dependencies
cd $dir
echo "Running composer update in $dir"
composer update --no-dev --ignore-platform-reqs
