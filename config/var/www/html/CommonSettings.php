<?php
## Site Name
$wgSitename = getenv('MW_SITENAME');
$wgMetaNamespace = preg_replace('/\s+/', '_', $wgSitename); # Replaces sitename spaces with underscores

## The protocol and server name to use in fully-qualified URLs
$wgServer = getenv('MW_SERVER');

## Secret key
$wgSecretKey = getenv('MW_SECRET');

## Database config
$wgDBtype = "mysql";
$wgDBserver = getenv('DB_HOST');
$wgDBname = getenv('DB_NAME');
$wgDBuser = getenv('DB_USER');
$wgDBpassword = getenv('DB_PASS');
$wgDBprefix = "";

## Webserver changes
# Path settings
$wgArticlePath = '/wiki/$1'; $wgUsePathInfo = true;
## The URL base path to the directory containing the wiki;
$wgScriptPath = "";
## The URL path to static resources (images, scripts, etc.)
$wgResourceBasePath = $wgScriptPath;
# Job runner disable
$wgJobRunRate = 0;
