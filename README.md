# nginx-ldap-auth-portal

## Environment Variables

| Environment Variable | Description |
|-----|-----|
| `LDAP_URL` | LDAP URI to query (Default: `ldap://localhost:389`) |
| `LDAP_STARTTLS` | Set to `true` to establish a STARTTLS protected session (Default: `false`) |
| `LDAP_BASE_DN` | LDAP base DN (Default: unset) |
| `LDAP_BIND_DN` | LDAP bind DN (Default: `anonymous`) |
| `LDAP_BIND_PW` | LDAP password for the bind DN (Default: unset) |
| `LDAP_SEARCH` | LDAP filter (Default: `cn=%(username)s`). If using Active Directory, you may need to set to `(sAMAccountName=%(username)s)`. |
| `HTTP_AUTH_REALM` | HTTP auth realm (Default: `Restricted`) |
| `NGINX_ERROR_LOG_LEVEL` | Can be one of the following: `debug`, `info`, `notice`, `warn`, `error`, `crit`, `alert`, or `emerg` (Default: `notice`) |

