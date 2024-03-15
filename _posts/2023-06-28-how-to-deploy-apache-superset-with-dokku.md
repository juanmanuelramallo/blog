---
layout: post
title: "How to deploy Apache Superset with Dokku?"
categories: how-to
tags: [how-to, dokku]
excerpt: Deploying Apache Superest via Dokku—git deployment, nginx, SSL out of the box
---

**Why?**

- Because it is much easier than doing everything manually
- Configuration changes are deployed via git (`git push dokku main`)
- Reverse proxy (nginx) is configured by Dokku (no lines of nginx config files are touched, not even looked at)
- SSL is configured by a Dokku plugin (I don't even know how to use certbot)
- Ideal to spin up a Superset instance quickly to test things out

**Why not?**

Well, if the plan is to serve thousands of dashboards and charts for thousands of users, maybe look into the kubernetes installation.

----

Before we start, ACME is used as an example of a company name. Feel free to replace with your own.

### In your virtual machine

## 1. Install dokku

Go to [Dokku's installation page](https://dokku.com/docs/getting-started/installation/) and follow the steps. There's no need to have Docker pre-installed, Dokku installer will take care of that.

Make sure to follow all steps until the end including the ones about adding your SSH key and setting the global domain. A domain is required to run Superset with SSL.

The SSH key must belong to the machine from where you intend to deploy Superset, so that `git push` can authenticate.

## 2. Create the app in Dokku

```bash
dokku apps:create acme-superset
```

## 3. Install postgres/redis

Install [postgres plugin](https://github.com/dokku/dokku-postgres) and [redis plugin](https://github.com/dokku/dokku-redis).

Then create the services and link them to the app.

```bash
sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
sudo dokku plugin:install https://github.com/dokku/dokku-redis.git redis

dokku postgres:create acme-superset
dokku postgres:link acme-superset acme-superset

dokku redis:create acme-superset
dokku redis:link acme-superset acme-superset
```

This is optional, but I recommend doing it.

By default Superset uses SQLite, which will not allow us to create multiple Datasets pointing to different tables and using the same name. This is solved by using Postgres as the metastore (metastore is how Superset documentation refers to the database where Supersets objects are stored—dashboards, charts, etc).

Redis is also optional but it's nice to have in case you want to configure data caching.

Postgres and Redis connection strings will be present as environment variables in the acme-superset application:
```bash
dokku config:show acme-superset
```

<small>After running the link command you may encounter a message like `App image (dokku/acme-superset:latest) not found`, just ignore them.</small>

## 4. Configure the default port

```bash
dokku proxy:ports-add acme-superset http:80:8088
```

By default Superset uses the `8088` port, but in order to properly configure SSL it is required for us to proxy the port `80`.

----


### In your local machine

## 1. Create a new local repository

```bash
mkdir acme-superset
cd acme-superset
git init
```

Create a new folder and initialize git. We'll use this folder as the Dokku application to deploy.

## 2. Create a config.py

```
curl https://raw.githubusercontent.com/apache/superset/2.1.0/superset/config.py -o config.py
```

The config.py from your repo will be placed instead of the default config.py.

Grab the default config.py from [github.com/apache/superset/blob/**VERSION**/superset/config.py](https://github.com/apache/superset/blob/2.1.0/superset/config.py){:target="_blank"}.

To use the database connection string from the `DATABASE_URL` env var, update the config.py file as follows:

```python
SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL")
```

To use the redis connection string from the `REDIS_URL` en var, update the config.py file as follows:

```python
# Cache for datasource metadata and query results
DATA_CACHE_CONFIG: CacheConfig = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": int(timedelta(hours=1).total_seconds()),
    "CACHE_KEY_PREFIX": "superset_data_cache_",
    "CACHE_REDIS_URL": os.environ.get("REDIS_URL")
}
```

Configure anything else as needed.

## 3. Create a Dockerfile

```bash
touch Dockerfile
```

```dockerfile
# ./Dockerfile
FROM apache/superset:2.1.0
USER root

# Set my secret key
ENV SUPERSET_SECRET_KEY=SUPER_SECRET_KEY_PLEASE_REPLACE_ME

# Use my config
COPY config.py superset/config.py

# Add database drivers
RUN pip install psycopg2
RUN pip install sqlalchemy-bigquery

# Adds vim to be able to enter the container and read files with vim
RUN apt-get update && apt-get -y install vim

USER superset
```

First line allows us to select what version to use. This example uses 2.1.0, latest version as of this writing.

Add any database driver needed. This example adds the driver for Bigquery. [More drivers can be found here](https://superset.apache.org/docs/databases/installing-database-drivers){:target="_blank"}.

The base image can be found in [Docker hub](https://hub.docker.com/r/apache/superset){:target="_blank"}.

## 4. Add Dokku's remote repository

```bash
git remote add dokku dokku@dokku.acme.com:acme-superset
```

Where `dokku.acme.com` is the global domain configured for Dokku and `acme-superset` is the name of the application in Dokku.

## 5. Deploy

Commit all files and push to Dokku's remote.

```bash
git add .
git commit -m 'Superset initial configuration'
```

```bash
git push dokku main
```

The deploy will start and you should have output in the terminal about the Dockerfile steps we defined previously.

```bash
Enumerating objects: 4, done.
Counting objects: 100% (4/4), done.
Delta compression using up to 8 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 23.48 KiB | 5.87 MiB/s, done.
Total 4 (delta 0), reused 0 (delta 0), pack-reused 0
-----> Cleaning up...
-----> Building jm-superset from Dockerfile
remote: build context to Docker daemon  66.56kB
Step 1/14 : FROM apache/superset:2.1.0
...

```

Finally [configure SSL](https://dokku.com/docs/deployment/application-deployment/#setting-up-ssl){:target=blank} in the Dokku machine via the [letsencrypt plugin](https://github.com/dokku/dokku-letsencrypt){:target=blank}.

```bash
# This is performed in the virtual machine, where Dokku is running
sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git

# Set global email for letsencrypt
dokku letsencrypt:set --global email admin@acme.com

dokku letsencrypt:enable acme-superset
```

That's it, open `acme-superset.dokku.acme.com` in your browser.

Superset is running and you are able to change its configuration, install new drivers, change version, and pretty much do anything in a very easy manner.

----

### Final considerations

The first time you deploy superset, you may need to create an admin user, migrate the database and run `superset init`.

Enter the container by running:

```bash
dokku enter acme-superset
```

Then run:

```bash
# Create an admin
superset fab create-admin \
  --username admin \
  --firstname Superset \
  --lastname Admin \
  --email admin@superset.com \
  --password admin

# Migrate DB
superset db upgrade

# Init and setup roles
superset init
```

Refer to [Superset documentation](https://superset.apache.org/docs/intro){:target="_blank"} for more information about its configuration.

Happy dashboarding.

<small>I have a Superset instance running smoothly in a Digital Ocean Droplet. <a href="https://m.do.co/c/cc1a72a2e544" target="_blank">Get $200 in credit over 60 days to try this out.</a></small>
