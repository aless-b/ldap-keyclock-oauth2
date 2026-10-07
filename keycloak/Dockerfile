FROM quay.io/keycloak/keycloak:26.7.4 AS keycloak-dist

FROM eclipse-temurin:21-jre-alpine

# Instalar Nginx, Fail2Ban, iptables e iproute2 para protección HTTP y de puerto LDAP TLS (636)
RUN apk add --no-cache nginx fail2ban bash iptables iproute2

COPY --from=keycloak-dist /opt/keycloak /opt/keycloak

COPY nginx.conf /etc/nginx/nginx.conf
COPY jail.local /etc/fail2ban/jail.local
COPY filter-http-flood.conf /etc/fail2ban/filter.d/http-flood.conf
COPY filter-ldap-tls.conf /etc/fail2ban/filter.d/ldap-tls.conf
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 80 8080 636

ENTRYPOINT ["/entrypoint.sh"]
