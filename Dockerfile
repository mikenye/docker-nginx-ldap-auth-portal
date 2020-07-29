FROM debian:stable-slim

ENV BUILD_NGINX_KEY_URL="https://nginx.org/keys/nginx_signing.key" \
    BUILD_NGINX_REPO_URL="https://nginx.org/packages/debian/" \
    BUILD_NGINX_SOURCES_FILE="/etc/apt/sources.list.d/nginx.list" \
    BUILD_NGINX_LDAP_AUTH_REPO_URL="https://github.com/nginxinc/nginx-ldap-auth.git" \
    NGINX_ERROR_LOG_LEVEL="notice" \
    LDAP_STARTTLS="false" \
    LDAP_SEARCH='cn=%(username)s' \
    LDAP_DISABLE_REFERRALS="false" \
    HTTP_AUTH_REALM="Restricted" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        file \
        git \
        gnupg2 \
        python3 \
        python3-ldap \
        python3-setuptools \
        python3-wheel \
        && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    # Add nginx repo
    curl --location -o - "$BUILD_NGINX_KEY_URL" | apt-key add - && \
    echo "deb $BUILD_NGINX_REPO_URL $(grep VERSION_CODENAME= /etc/os-release | cut -d '=' -f 2) nginx" > "$BUILD_NGINX_SOURCES_FILE" && \
    echo "deb-src $BUILD_NGINX_REPO_URL $(grep VERSION_CODENAME= /etc/os-release | cut -d '=' -f 2) nginx" >> "$BUILD_NGINX_SOURCES_FILE" && \
    apt-get update && \
    # Install nginx
    apt-get install -y --no-install-recommends \
        nginx-full \
        && \
    # Clone & install nginx-ldap-auth
    mkdir -p /src/nginx-ldap-auth && \
    mkdir -p /opt/nginx-ldap-auth && \
    git clone "$BUILD_NGINX_LDAP_AUTH_REPO_URL" /src/nginx-ldap-auth && \
    cp -v /src/nginx-ldap-auth/nginx-ldap-auth.conf /etc/nginx/conf.d/ && \
    cp -v /src/nginx-ldap-auth/nginx-ldap-auth-daemon.py /opt/nginx-ldap-auth/ && \
    cp -v /src/nginx-ldap-auth/backend-sample-app.py /opt/nginx-ldap-auth/ && \
    # Install s6-overlay
    curl -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    # Clean up
    apt-get remove -y \
        curl \
        file \
        git \
        gnupg2 \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /src /tmp/* /var/lib/apt/lists/* && \
    find /var/log -type f -iname "*log" -exec truncate --size 0 {} \;

COPY rootfs/ /

ENTRYPOINT [ "/init" ]

EXPOSE 443/tcp

HEALTHCHECK --start-period=30s CMD pgrep -a nginx
