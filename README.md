This build of ONLYOFFICE community edition simply has mobile editing enabled.

It is intended to be NOT production-ready *use at your own risk. 

Contact Ascensio System https://www.onlyoffice.com/contacts.aspx and buy an Enterprise license to support development.

* [Overview](#overview)
* [Functionality](#functionality)
* [Recommended System Requirements](#recommended-system-requirements)
* [Running Docker Image](#running-docker-image)
* [Configuring Docker Image](#configuring-docker-image)
    - [Storing Data](#storing-data)
    - [Running ONLYOFFICE Document Server on Different Port](#running-onlyoffice-document-server-on-different-port)
    - [Running ONLYOFFICE Document Server using HTTPS](#running-onlyoffice-document-server-using-https)
        + [Generation of Self Signed Certificates](#generation-of-self-signed-certificates)
        + [Strengthening the Server Security](#strengthening-the-server-security)
        + [Installation of the SSL Certificates](#installation-of-the-ssl-certificates)
        + [Available Configuration Parameters](#available-configuration-parameters)
* [ONLYOFFICE Document Server ipv6 setup](#onlyoffice-document-server-ipv6-setup)
* [Issues](#issues)
    - [Docker Issues](#docker-issues)
    - [Document Server usage Issues](#document-server-usage-issues)
* [Project Information](#project-information)
* [User Feedback and Support](#user-feedback-and-support)

## Overview

ONLYOFFICE Docs (Document Server) is an open-source office suite that comprises all the tools you need to work with documents, spreadsheets, presentations, PDFs, and PDF forms. The suite supports office files of all popular formats (DOCX, ODT, XLSX, ODS, CSV, PPTX, ODP, etc.) and enables collaborative editing in real time.

Starting from version 6.0, Document Server is distributed as ONLYOFFICE Docs. It has [three editions](https://github.com/ONLYOFFICE/DocumentServer#onlyoffice-docs-editions). With this image, you will install the free Community version. 

ONLYOFFICE Docs can be used as a part of [ONLYOFFICE DocSpace](https://www.onlyoffice.com/docspace.aspx) and ONLYOFFICE Workspace, or with [third-party sync&share solutions](https://www.onlyoffice.com/all-connectors.aspx) (e.g. Odoo, Moodle, Nextcloud, ownCloud, Seafile, etc.) to enable collaborative editing within their interface.

***Important*** Please update `docker-engine` to latest version (`20.10.21` as of writing this doc) before using it. We use `ubuntu:24.04` as base image and it older versions of docker have compatibility problems with it

## Functionality ##
Take advantage of the powerful editors included in ONLYOFFICE Docs:

* [ONLYOFFICE Document Editor](https://www.onlyoffice.com/document-editor.aspx)
* [ONLYOFFICE Spreadsheet Editor](https://www.onlyoffice.com/spreadsheet-editor.aspx)
* [ONLYOFFICE Presentation Editor](https://www.onlyoffice.com/presentation-editor.aspx)
* [ONLYOFFICE Form Creator](https://www.onlyoffice.com/form-creator.aspx)
* [ONLYOFFICE PDF Editor](https://www.onlyoffice.com/pdf-editor.aspx)
* [ONLYOFFICE Diagram Viewer](https://www.onlyoffice.com/diagram-viewer.aspx) 

The editors empower you to create, edit, save, and export text docs, sheets, presentations, PDFs, create and fill out PDF forms, open diagrams, all while offering additional advanced features such as:

* Collaborative editing (review & track changes, comments, chat)
* [AI-powered assistants](https://www.onlyoffice.com/ai-assistants.aspx) 
* Spell-checking 
* Scalable UI options (including dark mode)
* [Security tools & services](https://www.onlyoffice.com/security.aspx)

ONLYOFFICE Docs offer support for plugins allowing you to add specific features to the editors that are not directly related to the OOXML format. For more details, see [our API](https://api.onlyoffice.com/docs/plugin-and-macros/get-started/overview/) or visit the [plugins repo](https://github.com/ONLYOFFICE/onlyoffice.github.io). Would like to explore the existing plugins? Open the [Marketplace](https://www.onlyoffice.com/app-directory).

## Recommended System Requirements

* **RAM**: 4 GB or more
* **CPU**: dual-core 2 GHz or higher
* **Swap**: at least 2 GB
* **HDD**: at least 2 GB of free space
* **Distribution**: 64-bit Red Hat, CentOS or other compatible distributive with kernel version 3.8 or later, 64-bit Debian, Ubuntu or other compatible distributive with kernel version 3.8 or later
* **Docker**: version 1.9.0 or later

## Running Docker Image

    sudo docker run -i -t -d -p 80:80 dcoffin88/documentserver

Use this command if you wish to install ONLYOFFICE Document Server separately. To install ONLYOFFICE Document Server integrated with Community and Mail Servers, refer to the corresponding instructions below.

## Configuring Docker Image

### Storing Data

All the data are stored in the specially-designated directories, **data volumes**, at the following location:
* **/var/log/onlyoffice** for ONLYOFFICE Document Server logs
* **/var/www/onlyoffice/Data** for certificates
* **/var/lib/onlyoffice** for file cache
* **/var/lib/postgresql** for database

To get access to your data from outside the container, you need to mount the volumes. It can be done by specifying the '-v' option in the docker run command.

    sudo docker run -i -t -d -p 80:80 \
        -v /app/onlyoffice/DocumentServer/logs:/var/log/onlyoffice  \
        -v /app/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data  \
        -v /app/onlyoffice/DocumentServer/lib:/var/lib/onlyoffice \
        -v /app/onlyoffice/DocumentServer/rabbitmq:/var/lib/rabbitmq \
        -v /app/onlyoffice/DocumentServer/redis:/var/lib/redis \
        -v /app/onlyoffice/DocumentServer/db:/var/lib/postgresql  dcoffin88/documentserver

Normally, you do not need to store container data because the container's operation does not depend on its state. Saving data will be useful:
* For easy access to container data, such as logs
* To remove the limit on the size of the data inside the container
* When using services launched outside the container such as PostgreSQL, Redis, RabbitMQ

### Running ONLYOFFICE Document Server on Different Port

To change the port, use the -p command. E.g.: to make your portal accessible via port 8080 execute the following command:

    sudo docker run -i -t -d -p 8080:80 dcoffin88/documentserver

### Running ONLYOFFICE Document Server using HTTPS

        sudo docker run -i -t -d -p 443:443 \
        -v /app/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data  dcoffin88/documentserver

Access to the ONLYOFFICE application can be secured using SSL so as to prevent unauthorized access. While a CA certified SSL certificate allows for verification of trust via the CA, a self-signed certificate can also provide an equal level of trust verification as long as each client takes some additional steps to verify the identity of your website. Below the instructions on achieving this are provided.

To secure the application via SSL basically two things are needed:

- **Private key (.key)**
- **SSL certificate (.crt)**

So you need to create and install the following files:

        /app/onlyoffice/DocumentServer/data/certs/tls.key
        /app/onlyoffice/DocumentServer/data/certs/tls.crt

When using CA certified certificates (e.g. [Let's Encrypt](https://letsencrypt.org)), these files are provided to you by the CA. If you are using self-signed certificates you need to generate these files [yourself](#generation-of-self-signed-certificates).

#### Using the automatically generated Let's Encrypt SSL Certificates

        sudo docker run -i -t -d -p 80:80 -p 443:443 \
        -e LETS_ENCRYPT_DOMAIN=your_domain -e LETS_ENCRYPT_MAIL=your_mail  dcoffin88/documentserver

If you want to get and extend Let's Encrypt SSL Certificates automatically just set LETS_ENCRYPT_DOMAIN and LETS_ENCRYPT_MAIL variables.

#### Generation of Self Signed Certificates

Generation of self-signed SSL certificates involves a simple 3 step procedure.

**STEP 1**: Create the server private key

```bash
openssl genrsa -out tls.key 2048
```

**STEP 2**: Create the certificate signing request (CSR)

```bash
openssl req -new -key tls.key -out tls.csr
```

**STEP 3**: Sign the certificate using the private key and CSR

```bash
openssl x509 -req -days 365 -in tls.csr -signkey tls.key -out tls.crt
```

You have now generated an SSL certificate that's valid for 365 days.

#### Strengthening the server security

This section provides you with instructions to [strengthen your server security](https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html).
To achieve this you need to generate stronger DHE parameters.

```bash
openssl dhparam -out dhparam.pem 2048
```

#### Installation of the SSL Certificates

Out of the four files generated above, you need to install the `tls.key`, `tls.crt` and `dhparam.pem` files at the ONLYOFFICE server. The CSR file is not needed, but do make sure you safely backup the file (in case you ever need it again).

The default path that the ONLYOFFICE application is configured to look for the SSL certificates is at `/var/www/onlyoffice/Data/certs`, this can however be changed using the `SSL_KEY_PATH`, `SSL_CERTIFICATE_PATH` and `SSL_DHPARAM_PATH` configuration options.

The `/var/www/onlyoffice/Data/` path is the path of the data store, which means that you have to create a folder named certs inside `/app/onlyoffice/DocumentServer/data/` and copy the files into it and as a measure of security you will update the permission on the `tls.key` file to only be readable by the owner.

```bash
mkdir -p /app/onlyoffice/DocumentServer/data/certs
cp tls.key /app/onlyoffice/DocumentServer/data/certs/
cp tls.crt /app/onlyoffice/DocumentServer/data/certs/
cp dhparam.pem /app/onlyoffice/DocumentServer/data/certs/
chmod 400 /app/onlyoffice/DocumentServer/data/certs/tls.key
```

You are now just one step away from having our application secured.

#### Available Configuration Parameters

*Please refer the docker run command options for the `--env-file` flag where you can specify all required environment variables in a single file. This will save you from writing a potentially long docker run command.*

Below is the complete list of parameters that can be set using environment variables.

- **ONLYOFFICE_HTTPS_HSTS_ENABLED**: Advanced configuration option for turning off the HSTS configuration. Applicable only when SSL is in use. Defaults to `true`.
- **ONLYOFFICE_HTTPS_HSTS_MAXAGE**: Advanced configuration option for setting the HSTS max-age in the ONLYOFFICE nginx vHost configuration. Applicable only when SSL is in use. Defaults to `31536000`.
- **SSL_CERTIFICATE_PATH**: The path to the SSL certificate to use. Defaults to `/var/www/onlyoffice/Data/certs/tls.crt`.
- **SSL_KEY_PATH**: The path to the SSL certificate's private key. Defaults to `/var/www/onlyoffice/Data/certs/tls.key`.
- **SSL_DHPARAM_PATH**: The path to the Diffie-Hellman parameter. Defaults to `/var/www/onlyoffice/Data/certs/dhparam.pem`.
- **SSL_VERIFY_CLIENT**: Enable verification of client certificates using the `CA_CERTIFICATES_PATH` file. Defaults to `false`
- **NODE_EXTRA_CA_CERTS**: The [NODE_EXTRA_CA_CERTS](https://nodejs.org/api/cli.html#node_extra_ca_certsfile "Node.js documentation") to extend CAs with the extra certificates for Node.js. Defaults to `/var/www/onlyoffice/Data/certs/extra-ca-certs.pem`.
- **DB_TYPE**: The database type. Supported values are `postgres`, `mariadb`, `mysql`, `mssql` or `oracle`. Defaults to `postgres`.
- **DB_HOST**: The IP address or the name of the host where the database server is running.
- **DB_PORT**: The database server port number.
- **DB_NAME**: The name of a database to use. Should be existing on container startup.
- **DB_USER**: The new user name with superuser permissions for the database account.
- **DB_PWD**: The password set for the database account.
- **DB_SCHEMA**: Database schema name (optional).  
  - **PostgreSQL** — schema for [search_path](https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-PATH), default `public`.  
  - **MSSQL** — schema to set as [DEFAULT_SCHEMA](https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-user-transact-sql?view=sql-server-ver17#default_schema---schema_name--null-), default `dbo`.  
- **AMQP_URI**: The [AMQP URI](https://www.rabbitmq.com/uri-spec.html "RabbitMQ URI Specification") to connect to message broker server.
- **AMQP_TYPE**: The message broker type. Supported values are `rabbitmq` or `activemq`. Defaults to `rabbitmq`.
- **REDIS_SERVER_HOST**: The IP address or the name of the host where the Redis server is running.
- **REDIS_SERVER_PORT**:  The Redis server port number.
- **REDIS_SERVER_USER**: The Redis server username. The username is not set by default.
- **REDIS_SERVER_PASS**: The Redis server password. The password is not set by default.
- **REDIS_SERVER_DB**: The Redis database index number to select. Defaults to `0`.  
- **NGINX_WORKER_PROCESSES**: Defines the number of nginx worker processes.
- **NGINX_WORKER_CONNECTIONS**: Sets the maximum number of simultaneous connections that can be opened by a nginx worker process.
- **NGINX_ACCESS_LOG**: Defines whether access logging is enabled. Defaults to `false`.
- **SECURE_LINK_SECRET**: Defines secret for the nginx config directive [secure_link_md5](https://nginx.org/en/docs/http/ngx_http_secure_link_module.html#secure_link_md5). Defaults to `random string`.
- **JWT_ENABLED**: Specifies the enabling the JSON Web Token validation by the ONLYOFFICE Document Server. Defaults to `true`.
- **JWT_SECRET**: Defines the secret key to validate the JSON Web Token in the request to the ONLYOFFICE Document Server. Defaults to random value.
- **JWT_HEADER**: Defines the http header that will be used to send the JSON Web Token. Defaults to `Authorization`.
- **JWT_IN_BODY**: Specifies the enabling the token validation in the request body to the ONLYOFFICE Document Server. Defaults to `false`.
- **WOPI_ENABLED**: Specifies the enabling the wopi handlers. Defaults to `false`.
- **ALLOW_META_IP_ADDRESS**: Defines if it is allowed to connect meta IP address or not. Defaults to `false`.
- **ALLOW_PRIVATE_IP_ADDRESS**: Defines if it is allowed to connect private IP address or not. Defaults to `false`.
- **USE_UNAUTHORIZED_STORAGE**: Set to `true` if using self-signed certificates for your storage server e.g. Nextcloud. Defaults to `false`
- **GENERATE_FONTS**: When 'true' regenerates fonts list and the fonts thumbnails etc. at each start. Defaults to `true`
- **METRICS_ENABLED**: Specifies the enabling StatsD for ONLYOFFICE Document Server. Defaults to `false`.
- **METRICS_HOST**: Defines StatsD listening host. Defaults to `localhost`.
- **METRICS_PORT**: Defines StatsD listening port. Defaults to `8125`.
- **METRICS_PREFIX**: Defines StatsD metrics prefix for backend services. Defaults to `ds.`.
- **LETS_ENCRYPT_DOMAIN**: Defines the domain for Let's Encrypt certificate.
- **LETS_ENCRYPT_MAIL**: Defines the domain administrator mail address for Let's Encrypt certificate.
- **PLUGINS_ENABLED**: Defines whether to enable default plugins. Defaults to `true`.

## Installing ONLYOFFICE Document Server using Docker Compose

You can also install ONLYOFFICE Document Server using [docker-compose](https://docs.docker.com/compose/install "docker-compose"). 

First you need to clone this [GitHub repository](https://github.com/ONLYOFFICE/Docker-DocumentServer/):

```bash
git clone https://github.com/ONLYOFFICE/Docker-DocumentServer
```

After that switch to the repository folder:

```bash
cd Docker-DocumentServer
```

After that, assuming you have docker-compose installed, execute the following command:

```bash
docker-compose up -d
```

## ONLYOFFICE Document Server ipv6 setup

(Works and is supported only for Linux hosts)

Docker does not currently provide ipv6 addresses to containers by default. This function is experimental now.

To set up interaction via ipv6, you need to enable support for this feature in your Docker. For this you need:
- create the `/etc/docker/daemon.json` file with the following content:

```
{
"ipv6": true,
"fixed-cidr-v6": "2001:db8:abc1::/64"
}
```
- restart docker with the following command: `systemctl restart docker`

After that, all running containers receive an ipv6 address and have an inet6 interface.

You can check your default bridge network and see the field there
`EnableIPv6=true`. A new ipv6 subnet will also be added.

For more information, visit the official [Docker manual site](https://docs.docker.com/config/daemon/ipv6/)

## Issues

### Docker Issues

As a relatively new project Docker is being worked on and actively developed by its community. So it's recommended to use the latest version of Docker, because the issues that you encounter might have already been fixed with a newer Docker release.

The known Docker issue with ONLYOFFICE Document Server with rpm-based distributives is that sometimes the processes fail to start inside Docker container. Fedora and RHEL/CentOS users should try disabling SELinux with setenforce 0. If it fixes the issue then you can either stick with SELinux disabled which is not recommended by Red Hat, or switch to using Ubuntu.

### Document Server usage issues

Due to the operational characteristic, **Document Server** saves a document only after the document has been closed by all the users who edited it. To avoid data loss, you must forcefully disconnect the **Document Server** users when you need to stop **Document Server** in cases of the application update, server reboot etc. To do that, execute the following script on the server where **Document Server** is installed:

```
sudo docker exec <CONTAINER> documentserver-prepare4shutdown.sh
```

Please note, that both executing the script and disconnecting users may take a long time (up to 5 minutes).

## Project Information

Official website: [https://www.onlyoffice.com](https://www.onlyoffice.com/?utm_source=github&utm_medium=cpc&utm_campaign=GitHubDockerDS)

Code repository: [https://github.com/ONLYOFFICE/DocumentServer](https://github.com/ONLYOFFICE/DocumentServer "https://github.com/ONLYOFFICE/DocumentServer")

Docker Image: [https://github.com/ONLYOFFICE/Docker-DocumentServer](https://github.com/ONLYOFFICE/Docker-DocumentServer "https://github.com/ONLYOFFICE/Docker-DocumentServer")

License: [GNU AGPL v3.0](https://help.onlyoffice.com/products/files/doceditor.aspx?fileid=4358397&doc=K0ZUdlVuQzQ0RFhhMzhZRVN4ZFIvaHlhUjN2eS9XMXpKR1M5WEppUk1Gcz0_IjQzNTgzOTci0 "GNU AGPL v3.0")

Free version vs commercial builds comparison: https://github.com/ONLYOFFICE/DocumentServer#onlyoffice-document-server-editions

SaaS version: [https://www.onlyoffice.com/cloud-office.aspx](https://www.onlyoffice.com/cloud-office.aspx?utm_source=github&utm_medium=cpc&utm_campaign=GitHubDockerDS)

## User Feedback and Support

If you have any problems with or questions about this image, please visit our official forum to find answers to your questions: [forum.onlyoffice.com][1] or you can ask and answer ONLYOFFICE development questions on [Stack Overflow][2].

  [1]: https://forum.onlyoffice.com
  [2]: https://stackoverflow.com/questions/tagged/onlyoffice
