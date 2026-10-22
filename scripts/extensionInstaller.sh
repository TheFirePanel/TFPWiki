#!/bin/bash
DIR="/var/www/html"
cd $DIR # Make sure we are set in the correct wd

# All extensions to add, [GIT URL]="BRANCH [DIRECTORY NAME]"
# Directory name defaults to the repo name, and must match what wfLoadExtension() expects
declare -A repos=(
    ["https://github.com/jayktaylor/mw-discord"]="REL1_45"
    ["https://github.com/edwardspec/mediawiki-aws-s3"]="master"
    ["https://github.com/wikimedia/mediawiki-extensions-Disambiguator"]="REL1_46 Disambiguator"
    ["https://github.com/wikimedia/mediawiki-extensions-MobileFrontend"]="REL1_46 MobileFrontend"
    ["https://github.com/wikimedia/mediawiki-extensions-OpenIDConnect"]="REL1_46 OpenIDConnect"
    ["https://github.com/wikimedia/mediawiki-extensions-PluggableAuth"]="REL1_46 PluggableAuth"
)

# Go into extensions directory
cd $DIR/extensions/
for repo in "${!repos[@]}"; do
    read -r branch name <<< "${repos[$repo]}"

    if [ -z "$name" ]; then
        IFS='/' read -ra VAL <<< "$repo"
        name=${VAL[-1]}
    fi

    # Retry clones in case of transient network failures
    for attempt in 1 2 3; do
        echo "Cloning $repo into $name (branch: $branch, attempt $attempt)"
        if git clone --depth 1 --single-branch --branch $branch $repo $name; then
            break
        fi
        rm -rf $name
        if [ $attempt -eq 3 ]; then
            echo "Failed to clone $repo" >&2
            exit 1
        fi
        sleep 10
    done

    chown -R www-data:www-data $name
done

## Update/Install extension dependencies
# Delete problem child composer files
IGNORE_COMPOSER=()
for ext in "${IGNORE_COMPOSER[@]}"; do
    rm $DIR/extensions/$ext/composer.json
done

# Run the actual composer command
cd $DIR
echo "Running composer update in $DIR"
COMPOSER_ALLOW_SUPERUSER=1 composer update --prefer-dist --no-dev
rm -rf /root/.composer # Remove composer cache
