# MariaDB and Adminer in docker-compose

Easily launch MariaDB with accompanying adminer using docker-compose

Meant to be used with [claudesky/local-webserver](https://github.com/claudesky/local-webserver)

## Usage

### (optional) Create a docker-compose.override.yml

```
vim ./docker-compose.override.yml
```

Make any changes you want to override the base docker-compose file.

For example changing the default MYSQL_ROOT_PASSWORD:

`docker-compose.override.yml`
```
version: "3"

services:
    mariadb:
        environment:
            - MYSQL_ROOT_PASSWORD=secret
```

### Run `init.sh`

```
sudo ./init.sh
```

Note:
By default, the services do not publish any ports.

You can use the add-site script if you are using claudesky/local-webserver to give the new container a subdomain on your localhost.

Adminer exposes its webserver on port **8080**.

### Add containers to the `db` network

Any containers that need access to the database can simply be added to the `db` network created by the init script.

