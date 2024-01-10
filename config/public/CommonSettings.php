<?php

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
$wgArticlePath = '/wiki/$1';
$wgUsePathInfo = true;

# Job runner disable
$wgJobRunRate = 0;

## Permission Config
# Interwiki
$wgGroupPermissions['sysop']['interwiki'] = true;
