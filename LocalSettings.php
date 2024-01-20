<?php
# This file was automatically generated by the MediaWiki 1.40.1
# installer. If you make manual changes, please keep track in case you
# need to recreate them later.
#
# See includes/MainConfigSchema.php for all configurable settings
# and their default values, but don't forget to make changes in _this_
# file, not there.
#
# Further documentation for configuration settings may be found at:
# https://www.mediawiki.org/wiki/Manual:Configuration_settings

# Protect against web entry
if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}

# Add CommonSettings from image.
require_once("$IP/CommonSettings.php");

## Uncomment this to disable output compression
# $wgDisableOutputCompression = true;

## The URL paths to the logo.  Make sure you change this from the default,
## or else you'll overwrite your logo when you upgrade!
$wgLogos = [
	'1x' => 'https://cdn.thefirepanel.com/original/2X/f/f13b84d22c745f168dbb20b53f704faf1bcce17c.png',
	'icon' => 'https://cdn.thefirepanel.com/wiki/logos/logo_mark.png',
	'wordmark' => [
		'width' => '124',
		'height' => '50',
		'src' => 'https://cdn.thefirepanel.com/wiki/logos/word_mark.png'
	]
];
$wgFavicon = "https://cdn.thefirepanel.com/wiki/logos/logo_mark.png";

## UPO means: this is also a user preference option

$wgEnableEmail = false;
$wgEnableUserEmail = true; # UPO

$wgEmergencyContact = "";
$wgPasswordSender = "";

$wgEnotifUserTalk = false; # UPO
$wgEnotifWatchlist = false; # UPO
$wgEmailAuthentication = true;

# MySQL table options to use during installation or update
$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";

# Shared database table
# This has no effect unless $wgSharedDB is also set.
$wgSharedTables[] = "actor";

## Shared memory settings
$wgMainCacheType = CACHE_ACCEL;
$wgMemCachedServers = [];

## To enable image uploads, make sure the 'images' directory
## is writable, then set this to true:
$wgEnableUploads = true;
$wgUseImageMagick = true;
$wgImageMagickConvertCommand = "/usr/bin/convert";

# InstantCommons allows wiki to use images from https://commons.wikimedia.org
$wgUseInstantCommons = false;

# Periodically send a pingback to https://www.mediawiki.org/ with basic data
# about this MediaWiki instance. The Wikimedia Foundation shares this data
# with MediaWiki developers to help guide future development efforts.
$wgPingback = false;

# Site language code, should be one of the list in ./includes/languages/data/Names.php
$wgLanguageCode = "en";

# Time zone
$wgLocaltimezone = "UTC";

## Set $wgCacheDirectory to a writable directory on the web server
## to make your wiki go slightly faster. The directory should not
## be publicly accessible from the web.
#$wgCacheDirectory = "$IP/cache";

# Changing this will log out all existing sessions.
$wgAuthenticationTokenVersion = "1";

# Site upgrade key. Must be set to a string (default provided) to turn on the
# web installer while LocalSettings.php is in place
# $wgUpgradeKey = "2cec52e12206466c";

## For attaching licensing metadata to pages, and displaying an
## appropriate copyright notice / icon. GNU Free Documentation
## License and Creative Commons licenses are supported so far.
$wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl = "https://creativecommons.org/licenses/by-nc-sa/4.0/";
$wgRightsText = "Creative Commons Attribution-ShareAlike License";
$wgRightsIcon = "https://cdn.thefirepanel.com/wiki/Creative_commons.png";

# Path to the GNU diff3 utility. Used for conflict resolution.
$wgDiff3 = "/usr/bin/diff3";

## Default skin: you can change the default skin. Use the internal symbolic
## names, e.g. 'vector' or 'monobook':
$wgDefaultSkin = "vector-2022";

# Enabled skins.
# The following skins were automatically enabled:
wfLoadSkin( 'MinervaNeue' );
wfLoadSkin( 'MonoBook' );
wfLoadSkin( 'Timeless' );
wfLoadSkin( 'Vector' );

# Enabled extensions. Most of the extensions are enabled by adding
# wfLoadExtension( 'ExtensionName' );
# to LocalSettings.php. Check specific extension documentation for more details.
# The following extensions were automatically enabled:
wfLoadExtension( 'AbuseFilter' );
wfLoadExtension( 'CategoryTree' );
wfLoadExtension( 'Cite' );
wfLoadExtension( 'CiteThisPage' );
wfLoadExtension( 'CodeEditor' );
wfLoadExtension( 'ConfirmEdit' );
wfLoadExtension( 'Echo' );
wfLoadExtension( 'Gadgets' );
wfLoadExtension( 'ImageMap' );
wfLoadExtension( 'InputBox' );
wfLoadExtension( 'Interwiki' );
wfLoadExtension( 'LoginNotify' );
wfLoadExtension( 'Math' );
wfLoadExtension( 'MultimediaViewer' );
wfLoadExtension( 'Nuke' );
wfLoadExtension( 'OATHAuth' );
wfLoadExtension( 'ParserFunctions' );
wfLoadExtension( 'PdfHandler' );
wfLoadExtension( 'Scribunto' ); $wgScribuntoDefaultEngine = 'luasandbox';
wfLoadExtension( 'SyntaxHighlight_GeSHi' );
wfLoadExtension( 'SecureLinkFixer' );
wfLoadExtension( 'SpamBlacklist' );
wfLoadExtension( 'TemplateData' );
wfLoadExtension( 'TextExtracts' );
wfLoadExtension( 'Thanks' );
wfLoadExtension( 'TitleBlacklist' );
wfLoadExtension( 'VisualEditor' );
wfLoadExtension( 'WikiEditor' );
# End of automatically generated settings.
# Add more configuration options below.

## Extra Extensions
wfLoadExtension( 'MobileFrontend' ); $wgMFDefaultSkinClass = 'MinervaNeue';
wfLoadExtension( 'TemplateStyles' );

## Image uploads
$wgFileExtensions = array_merge( $wgFileExtensions, [
	'pdf', 'svg', 'mp3', 'ogg', 'wav'
] );
$wgSVGNativeRendering = true;

## S3
wfLoadExtension( 'mediawiki-aws-s3' );
$wgAWSCredentials = [
	'key' => getenv('S3_KEY'),
	'secret' => getenv('S3_SECRET'),
	'token' => false
];
$wgAWSBucketName = getenv('S3_NAME');
$wgAWSRegion = getenv('S3_REGION');
$wgAWSBucketTopSubdirectory = getenv('S3_PREFIX');
$wgAWSBucketDomain = getenv('S3_DOMAIN');

## Permission Config
# Default settings
$wgGroupPermissions['*']['edit'] = false;

# Interwiki
$wgGroupPermissions['sysop']['interwiki'] = true;

## Pluggable Auth
wfLoadExtension( 'PluggableAuth' );
wfLoadExtension( 'OpenIDConnect' );

$wgGroupPermissions['*']['createaccount'] = false;
$wgGroupPermissions['*']['autocreateaccount'] = true;

# 1 week session storage, we do not provide a keep me signed in button
$wgObjectCacheSessionExpiry = 604800;

$wgPluggableAuth_Config[] = [
    'plugin' => 'OpenIDConnect',
    'data' => [
        'providerURL' => getenv('ID_PROVIDER'),
        'clientID' => getenv('ID_CLIENT'),
        'clientsecret' => getenv('ID_SECRET'),
		'preferred_username' => 'sub'
	]
];
