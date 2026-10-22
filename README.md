# TFPWiki

Docker image for **TFPWiki**, the wiki for The Fire Panel. It is built on the official `mediawiki:stable-fpm` image (currently MediaWiki 1.46) and runs nginx, PHP-FPM, cron and a MediaWiki job runner inside a single container under supervisord.

The image is built and pushed to `ghcr.io/thefirepanel/tfpwiki` by GitHub Actions on every push and pull request (see [.github/workflows/build-docker.yaml](.github/workflows/build-docker.yaml)). The `main` branch is published as the `main` tag.

## Repository layout

| Path | Purpose |
| --- | --- |
| [Dockerfile](Dockerfile) | Image definition: system packages, LuaSandbox, Composer, extension install, config copy. |
| [LocalSettings.php](LocalSettings.php) | Wiki-specific MediaWiki settings. **Not baked into the image**; fetched at container start (see below). |
| [config/](config/) | Files copied into the image root as-is (`config/etc/...` becomes `/etc/...`, and so on). |
| [config/var/www/html/CommonSettings.php](config/var/www/html/CommonSettings.php) | Baked-in settings for site name, server URL, secret key, database and web server paths. |
| [scripts/entrypoint.sh](scripts/entrypoint.sh) | Container entrypoint. |
| [scripts/extensionInstaller.sh](scripts/extensionInstaller.sh) | Clones extra extensions and runs Composer at build time. |
| [scripts/generateSitemap.sh](scripts/generateSitemap.sh) | Generates the sitemap; run at startup and daily by cron. |
| [scripts/jobRunner.sh](scripts/jobRunner.sh) | Long-running MediaWiki job queue worker. |
| [docker-compose.example.yaml](docker-compose.example.yaml) | Example deployment with MariaDB. |

## How settings are loaded

Settings are split between two files:

- **`CommonSettings.php`** is copied into the image at `/var/www/html/CommonSettings.php`. It holds the values that are the same for any deployment of this image and that come from environment variables (site name, server, secret key, database connection, URL paths, job runner and proxy settings).
- **`LocalSettings.php`** lives in the root of this repository and holds everything specific to TFPWiki: logos, skins, enabled extensions, permissions, uploads, SMTP, S3, OpenID Connect and Discord. It starts by including `CommonSettings.php`.

`LocalSettings.php` is intentionally **not** packaged with the image. On every container start, [scripts/entrypoint.sh](scripts/entrypoint.sh) downloads the current version from the `main` branch:

```
https://raw.githubusercontent.com/TheFirePanel/TFPWiki/main/LocalSettings.php
```

This means:

- Changes to `LocalSettings.php` take effect after a merge to `main` and a container restart. No image rebuild is required.
- Changes to anything else (the Dockerfile, `config/`, `scripts/`, or the extension list) require a new image build.
- If an edit to `LocalSettings.php` needs an extension that is not yet in the image, ship the image change first, then the settings change. Otherwise a restarted container will load a settings file that references a missing extension.
- The container needs outbound access to `raw.githubusercontent.com` at startup.

### Startup sequence

When the container starts, the entrypoint:

1. Writes the container environment to `/etc/environment` so cron jobs can see it.
2. If `DEBUG` is `false`:
   1. Downloads `LocalSettings.php` from GitHub into `/var/www/html`.
   2. Generates the sitemap and appends `Sitemap: $MW_SERVER/sitemap.xml` to `robots.txt`.
3. Starts supervisord, which runs nginx, PHP-FPM, cron and the job runner.

### Debug mode

When `DEBUG` is anything other than `false` (including when it is **unset**), the entrypoint skips the LocalSettings download and sitemap generation. Use this for local development by mounting your working copy of `LocalSettings.php` into the container:

```yaml
volumes:
  - ./LocalSettings.php:/var/www/html/LocalSettings.php
```

Production deployments must set `DEBUG: "false"` explicitly, or the container will start without a `LocalSettings.php`.

## Environment variables

### Core (required)

Read by `CommonSettings.php` and the entrypoint.

| Variable | Description |
| --- | --- |
| `DEBUG` | `false` for production. Any other value, or leaving it unset, enables debug mode (see above). |
| `MW_SITENAME` | Wiki name (`$wgSitename`). Also used to derive `$wgMetaNamespace`, with spaces replaced by underscores. |
| `MW_SERVER` | Full base URL including protocol, e.g. `https://wiki.thefirepanel.com` (`$wgServer`). Also used for the sitemap. |
| `MW_SECRET` | Secret key (`$wgSecretKey`). Use a long random string. |
| `DB_HOST` | MySQL/MariaDB host. |
| `DB_NAME` | Database name. |
| `DB_USER` | Database user. |
| `DB_PASS` | Database password. |

### Optional features

These are read by `LocalSettings.php`. Each feature is only enabled when its "trigger" variable is set; the other variables in the group are then expected to be set too.

**SMTP email** (trigger: `SMTP_HOST`)

| Variable | Description |
| --- | --- |
| `SMTP_HOST` | SMTP server host. |
| `SMTP_PORT` | SMTP server port. |
| `SMTP_DOMAIN` | Domain used in the HELO/EHLO greeting. |
| `SMTP_USERNAME` | SMTP username. |
| `SMTP_PASSWORD` | SMTP password. |
| `SMTP_SENDER` | Address used for `$wgPasswordSender` and `$wgEmergencyContact`. |

Enables wiki email and user-to-user email. Email authentication and talk page/watchlist notifications are turned off.

**S3 file storage** (trigger: `S3_KEY`)

| Variable | Description |
| --- | --- |
| `S3_KEY` | Access key ID. |
| `S3_SECRET` | Secret access key. |
| `S3_NAME` | Bucket name. |
| `S3_REGION` | Bucket region. |
| `S3_PREFIX` | Top-level subdirectory within the bucket. |
| `S3_DOMAIN` | Public domain used to serve files from the bucket. |

Loads the `mediawiki-aws-s3` extension so uploads are stored in S3 instead of the container filesystem.

**OpenID Connect login** (trigger: `ID_SECRET`)

| Variable | Description |
| --- | --- |
| `ID_PROVIDER` | OpenID provider URL. |
| `ID_CLIENT` | Client ID. |
| `ID_SECRET` | Client secret. |

Loads `PluggableAuth` and `OpenIDConnect`. Local account creation is disabled, accounts are auto-created on first login, and usernames come from the `preferred_username` claim (the Discourse username). Existing users are re-linked by username via `$wgOpenIDConnect_MigrateUsersByUserName`.

**Discord notifications** (trigger: `DISCORD_WEBHOOK`)

| Variable | Description |
| --- | --- |
| `DISCORD_WEBHOOK` | Discord webhook URL that receives wiki activity. |

Loads the `mw-discord` extension.

## Extensions

### Bundled with MediaWiki

Most extensions and skins enabled in `LocalSettings.php` (AbuseFilter, Cite, Echo, Scribunto, VisualEditor and so on) ship with the MediaWiki base image and only need a `wfLoadExtension()` / `wfLoadSkin()` line. Scribunto uses the LuaSandbox engine, which is compiled via PECL in the Dockerfile.

### Extra extensions

Extensions not bundled with MediaWiki are installed at **image build time** by [scripts/extensionInstaller.sh](scripts/extensionInstaller.sh):

- [mw-discord](https://www.mediawiki.org/wiki/Extension:Discord)
- [mediawiki-aws-s3](https://www.mediawiki.org/wiki/Extension:AWS)
- [Disambiguator](https://www.mediawiki.org/wiki/Extension:Disambiguator)
- [MobileFrontend](https://www.mediawiki.org/wiki/Extension:MobileFrontend)
- [OpenID_Connect](https://www.mediawiki.org/wiki/Extension:OpenID_Connect)
- [PluggableAuth](https://www.mediawiki.org/wiki/Extension:PluggableAuth)

The installer:

1. Shallow-clones each repository into `/var/www/html/extensions/`, retrying up to three times on network failure.
2. Runs `composer update --no-dev` in `/var/www/html`. [composer.local.json](config/var/www/html/composer.local.json) uses the merge plugin to pull in every extension's and skin's `composer.json`, so extension PHP dependencies are installed automatically.

The installer is deleted from the image after it runs.

### Adding an extension

1. Add an entry to the `repos` array in [scripts/extensionInstaller.sh](scripts/extensionInstaller.sh):

   ```bash
   ["<git url>"]="<branch> [directory name]"
   ```

   - Use the `REL1_xx` branch that matches the MediaWiki version where one exists.
   - The directory name is optional and defaults to the last part of the repository URL. It must match the name passed to `wfLoadExtension()`. For Wikimedia repositories (`mediawiki-extensions-Foo`) you will normally need to set it to `Foo`.
   - If an extension's `composer.json` breaks the Composer step, add the extension's directory name to `IGNORE_COMPOSER`.

2. Merge the change and let the image rebuild and deploy.
3. Add `wfLoadExtension('<directory name>');` and any configuration to `LocalSettings.php`, then restart the container.

When upgrading MediaWiki, update the `REL1_xx` branches in the installer to match the new version.

## Background tasks

| Task | Where | Schedule |
| --- | --- | --- |
| Job queue | [scripts/jobRunner.sh](scripts/jobRunner.sh) under supervisord | Continuous. `$wgJobRunRate` is `0`, so jobs are never run during web requests. |
| Sitemap | [scripts/generateSitemap.sh](scripts/generateSitemap.sh) via [cron](config/etc/cron.d/cron) | At startup (production only) and daily at 00:00 UTC. Served at `/sitemap.xml`. |

## Running locally

1. Copy [docker-compose.example.yaml](docker-compose.example.yaml) to `docker-compose.yaml` and change the placeholder passwords and secret.
2. The example runs in debug mode, so uncomment the `volumes` entry to mount your local `LocalSettings.php`.
3. Start it with `docker compose up -d`. The wiki is available on port `8080`.

The image trusts `X-Forwarded-For` from private network ranges (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`), so it is designed to sit behind a reverse proxy on a private network.
