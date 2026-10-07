#!/bin/bash
set -e

mkdir -p /var/log/nginx /var/run/fail2ban /run/nginx
rm -f /var/log/nginx/access.log /var/log/nginx/error.log
touch /var/log/nginx/access.log /var/log/nginx/error.log /var/log/ldap-tls.log /var/log/fail2ban.log
rm -f /var/run/fail2ban/fail2ban.sock /var/run/fail2ban/fail2ban.pid

# Protección extra a nivel de puerto para el servicio de LDAP que utiliza TLS (Puerto 636 - LDAPS)
iptables -A INPUT -p tcp --dport 636 -j DROP

# Iniciar Nginx en puertos 80 y 8080 registrando en /var/log/nginx/access.log
nginx -g 'daemon off;' &
sleep 1

# Iniciar Fail2Ban con los jails [http-flood] y [ldap-tls]
fail2ban-client -x start

echo "[keycloak-jwt] Nginx + Fail2Ban (http-flood & ldap-tls port 636) active. Starting Keycloak..."
exec /opt/keycloak/bin/kc.sh start-dev --import-realm --http-port=8082
