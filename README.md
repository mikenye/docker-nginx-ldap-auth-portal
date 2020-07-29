# mikenye/nginx-ldap-auth-portal

A multi-architecture (`linux/amd64`, `linux/arm/v7`, `linux/arm64`) Docker image that implement [nginx](http://nginx.org) as a reverse proxy, providing [basic LDAP authentication](https://www.nginx.com/blog/nginx-plus-authenticate-users/) before serving the protected backend resource.

Useful where you just need a simple method to place LDAP authentication in front of a basic web service.

***Not recommended to be internet facing!***

## Up and Running with `docker run`

```shell
docker run \
    -d \
    --restart=always \
    -it \
    --name=rproxy_auth \
    --dns=internal.dns.ip.address \
    -e LDAP_URL="ldap://ldap.server:389" \
    -e PROTECTED_BACKEND_HOST="protected.server" \
    -e PROTECTED_BACKEND_PORT=80 \
    -e LDAP_SEARCH='(sAMAccountName=%(username)s)' \
    -e LDAP_BIND_DN="CN=svc-ldap-bind,OU=Users,DC=MyCompany,DC=com" \
    -e LDAP_BIND_PW='secret_password_123' \
    -e LDAP_BASE_DN="OU=Users,DC=MyCompany,DC=com" \
    -e NGINX_PATH_SSL_CERTIFICATE="/etc/ssl/certs/cert.crt" \
    -e NGINX_PATH_SSL_CERTIFICATE_KEY="/etc/ssl/certs/cert.key" \
    -e NGINX_SERVER_NAME="protected.server" \
    -e TZ="Australia/Perth" \
    -v "/path/to/ssl/certificates:/etc/ssl/certs:ro" \
    -p 8443:443 \
    mikenye/nginx-ldap-auth-portal
```

You can then point your browser at <https://dockerhost:8443/>, and with any luck you'll be presented with a username/password dialog box. Upon successful LDAP authentication, you should see the website served by `PROTECTED_BACKEND_HOST:PROTECTED_BACKEND_PORT`.

## Environment Variables

| Environment Variable | Description |
|-----|-----|
| `HTTP_AUTH_REALM` | HTTP auth realm (Default: `Restricted`) |
| `LDAP_BASE_DN` | LDAP base DN (Required) |
| `LDAP_BIND_DN` | LDAP bind DN (Required) |
| `LDAP_BIND_PW` | LDAP password for the bind DN (Required) |
| `LDAP_DISABLE_REFERRALS` | If set to `true`, will allow referrals to other LDAP servers (Default: `false`) |
| `LDAP_SEARCH` | LDAP filter (Default: `cn=%(username)s`). If using Active Directory, you may need to set to `(sAMAccountName=%(username)s)`. |
| `LDAP_STARTTLS` | Set to `true` to establish a STARTTLS protected session (Default: `false`) |
| `LDAP_URL` | LDAP URI to query (Required, syntax: `ldap://some.ldap.server:389`) |
| `NGINX_ERROR_LOG_LEVEL` | Can be one of the following: `debug`, `info`, `notice`, `warn`, `error`, `crit`, `alert`, or `emerg` (Default: `notice`) |
| `NGINX_PATH_SSL_CERTIFICATE_KEY` | The path (with respect to the container) to the SSL certificate's key (Required) |
| `NGINX_PATH_SSL_CERTIFICATE` | The path (with respect to the container) to the SSL certificate (Required) |
| `NGINX_SERVER_NAME` | The server name (should match what's set in the SSL certificate) (Required) |
| `PROTECTED_BACKEND_HOST` | The protected backend service's hostname (Required) |
| `PROTECTED_BACKEND_HOST` | The protected backend web server hostname (Required) |
| `TZ` | Container's local timezone in ["TZ database name" format](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) (Optional, default: `UTC`) |

## Ports

The nginx instance in the container listens on TCP port `443`.

## Logging

* All processes are logged to the container's stdout, and can be viewed with `docker logs [-f] container`.

## Getting help

Please feel free to [open an issue on the project's GitHub](https://github.com/mikenye/docker-nginx-ldap-auth-portal/issues).

I also have a [Discord channel](https://discord.gg/sTf9uYF), feel free to [join](https://discord.gg/sTf9uYF) and converse.
