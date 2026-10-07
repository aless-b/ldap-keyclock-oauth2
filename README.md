# LDAP + Keycloak + OAuth 2.0 / OIDC Lab (Protected with Fail2Ban & Port-Level TLS Protection)

Complete Docker lab: **OpenLDAP + phpLDAPadmin + Keycloak + PostgreSQL + FastAPI**, hardened with **Fail2Ban HTTP flood protection** (`[http-flood]`) and **port-level protection for LDAP over TLS (LDAPS port `636`)** via `iptables` and Fail2Ban (`[ldap-tls]`).

---

## 🛡️ Security Protections Implemented

1. **HTTP Flood Protection (`[http-flood]` Jail)**:
   - Both `keycloak` (JWT issuer on `:8081`) and `openldap` run **Nginx + Fail2Ban**, logging all HTTP requests to `/var/log/nginx/access.log`.
   - Any IP exceeding `maxretry = 60` HTTP requests within `findtime = 10s` is banned via `iptables-allports` for `10m` (escalating up to `1d`).

2. **Extra Port-Level Protection for LDAP TLS (Port `636` / LDAPS)**:
   - **Firewall Rule (`iptables`)**: Direct traffic to TCP port `636` (LDAP over TLS / LDAPS) is blocked at the container firewall level:
     ```bash
     iptables -A INPUT -p tcp --dport 636 -j DROP
     ```
   - **Fail2Ban Jail (`[ldap-tls]`)**: Monitors port `636,ldaps` (`protocol = tcp`, `banaction = iptables-multiport`, `maxretry = 5`, `findtime = 10s`).
   - Plain LDAP federation between Keycloak and OpenLDAP continues to operate over internal port `389` (`ldap://openldap:389`).

### Verify Fail2Ban & Firewall Rules:
```bash
docker exec keycloak fail2ban-client status
docker exec keycloak fail2ban-client status http-flood
docker exec keycloak fail2ban-client status ldap-tls
docker exec keycloak iptables -L INPUT -n -v

docker exec openldap fail2ban-client status
docker exec openldap iptables -L INPUT -n -v
```

---

## 🚀 Start

```bash
docker compose up -d --build
./load-ldap-users.sh
```

## 🔗 URLs
- **phpLDAPadmin**: `http://localhost:8080`
- **Keycloak (JWT Issuer)**: `http://localhost:8081`
- **FastAPI Swagger**: `http://localhost:8000/docs`
- **FastAPI Health**: `http://localhost:8000/health`
- **Protected API**: `GET http://localhost:8000/api/profile`

## 🔑 Credentials
- **Keycloak Admin**: `admin` / `adminpassword`
- **LDAP Admin DN**: `cn=admin,dc=example,dc=com` / `adminpassword`
- **LDAP Users**: `alice` / `alice123`, `bob` / `bob123`
- **Keycloak Realm**: `cybersecurity`
- **OIDC Client**: `fastapi-api`

---

## 📁 Repository Structure

```text
ldap-keycloak-oauth2-lab/
├── keycloak/
│   ├── import/
│   │   └── cybersecurity-realm.json
│   ├── Dockerfile              # Keycloak + Nginx + Fail2Ban + iptables image
│   ├── entrypoint.sh           # Port 636 iptables rule + Nginx + Fail2Ban + Keycloak
│   ├── filter-http-flood.conf  # HTTP flood filter
│   ├── filter-ldap-tls.conf    # LDAP TLS (port 636) filter
│   ├── jail.local              # [http-flood] and [ldap-tls] jails
│   └── nginx.conf              # Reverse proxy to Keycloak with combined access log
├── ldap/
│   ├── Dockerfile              # OpenLDAP + Nginx + Fail2Ban + iptables image
│   ├── entrypoint.sh           # Port 636 iptables rule + Nginx + Fail2Ban + slapd
│   ├── filter-http-flood.conf  # HTTP flood filter
│   ├── filter-ldap-tls.conf    # LDAP TLS (port 636) filter
│   ├── jail.local              # [http-flood] and [ldap-tls] jails
│   ├── nginx.conf              # HTTP listener for Fail2Ban monitoring
│   └── users.ldif              # Initial LDAP users (alice, bob)
├── fastapi/
│   ├── app/main.py
│   ├── Dockerfile
│   └── requirements.txt
├── docker-compose.yml
├── load-ldap-users.sh
├── reset.sh
└── README.md
```
