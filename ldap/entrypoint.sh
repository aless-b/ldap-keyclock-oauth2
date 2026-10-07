#!/bin/bash
set -e

mkdir -p /var/log/nginx /var/run/fail2ban /run/nginx
rm -f /var/log/nginx/access.log /var/log/nginx/error.log
touch /var/log/nginx/access.log /var/log/nginx/error.log /var/log/ldap-tls.log /var/log/fail2ban.log
rm -f /var/run/fail2ban/fail2ban.sock /var/run/fail2ban/fail2ban.pid

# Protección extra a nivel de puerto para el servicio de LDAP que utiliza TLS (Puerto 636 - LDAPS)
iptables -A INPUT -p tcp --dport 636 -j DROP

# Iniciar Nginx en puerto 80 para monitoreo HTTP con Fail2Ban
nginx -g 'daemon off;' &
sleep 1

# Iniciar Fail2Ban con los jails [http-flood] y [ldap-tls]
fail2ban-client -x start

echo "[openldap] Nginx + Fail2Ban (http-flood) + Port 636 (LDAP TLS) protection active..."
exec /container/tool/run
