# 📊 PostgreSQL Monitoring Stack with Prometheus & Grafana

Production-ready, Docker Compose–based monitoring for PostgreSQL. Includes:
- 🐘 PostgreSQL 17 (configurable, with secure auth)
- 📈 Prometheus (scraping, retention tuning, optional TLS/auth)
- 🔎 postgres_exporter (metrics for Prometheus, extendable queries)
- 📊 Grafana (pre-provisioned datasources and dashboards)

This repo supports two modes:
- Full stack (Postgres + Exporter + Prometheus + Grafana) via docker-compose.yml
- Simplified mode (monitor an external PostgreSQL only) via docker-compose-simplified.yml

---

## 🧩 Stack Components

- PostgreSQL (service: postgres)
  - Image: postgres:17
  - Port: 5432
  - Config: postgres/postgresql.conf, postgres/pg_hba.conf
  - Init SQL: setup-database.sql (creates users and DB for Grafana and exporter)
  - Auth: SCRAM-SHA-256 by default
- postgres_exporter (service: postgres-exporter)
  - Image: prometheuscommunity/postgres-exporter:latest
  - Port: 9187 (metrics)
  - Config: postgres-exporter/queries.yaml (extend/override exporter queries)
- Prometheus (service: prometheus)
  - Image: prom/prometheus:latest
  - Port: 9090
  - Config: prometheus/prometheus.yml
  - Retention: 60d (time) or 50GB (size)
  - Optional web auth/TLS: prometheus/web-config.yml (not mounted by default)
- Grafana (service: grafana)
  - Image: grafana/grafana:latest
  - Port: 3000
  - Uses PostgreSQL as backend storage (grafana DB) in full stack
  - Provisioning: grafana/provisioning/* and grafana/dashboards/*

---

## 📁 Directory Structure

- docker-compose.yml — Full stack (Postgres + Exporter + Prometheus + Grafana)
- docker-compose-simplified.yml — External-DB only (Exporter + Prometheus + Grafana [SQLite])
- prometheus/
  - prometheus.yml — Scrape config (prometheus, postgres-exporter)
  - web-config.yml — Optional TLS + basic auth for Prometheus UI
- grafana/
  - provisioning/datasources/datasource.yaml — Pre-provisioned datasources
  - dashboards/postgresql-dashboard.json — Example PostgreSQL dashboard
- postgres/
  - postgresql.conf — DB config (auth, memory, logging, SSL placeholders)
  - pg_hba.conf — Client authentication (SCRAM, networks)
- postgres-exporter/queries.yaml — Extend exporter metrics
- setup-database.sql — Auto-run DB init (users, DB, privileges, views)
- setup-monitoring-users.sql — Script for external (non-container) PostgreSQL

---

## ✅ Prerequisites

- Docker and Docker Compose (v2 preferred; use `docker compose`, or `docker-compose` for v1)

---

## ⚡ Quick Start (Full Stack)

1) Clone
```
 git clone https://github.com/jannos0/prometheus-stack.git
 cd prometheus-stack
```

2) Create .env (recommended)
```
POSTGRES_PASSWORD=change_me_strong
EXPORTER_PASSWORD=exporter_secure_password_here
GRAFANA_PASSWORD=admin_change_me
GRAFANA_DB_PASSWORD=grafana_db_password_here
```
- These map to docker-compose.yml defaults; using the values above will match the init SQL in setup-database.sql. If you change them, also update setup-database.sql accordingly.

3) Launch
```
 docker compose up -d
# or: docker-compose up -d
```

4) Access
- Grafana: http://localhost:3000 (admin / from GRAFANA_PASSWORD; default admin123 if not set)
- Prometheus: http://localhost:9090
- Postgres Exporter metrics: http://localhost:9187/metrics

Persistent volumes: postgres_data, prometheus_data, grafana_data

---

## 🧪 Simplified Mode (External PostgreSQL)
Use when PostgreSQL runs outside Docker (e.g., Windows Server) and you only need Exporter + Prometheus + Grafana.

1) Open docker-compose-simplified.yml and replace placeholders:
- YOUR_WINDOWS_SERVER_IP in exporter DSN and (optional) Grafana DB env
- your_secure_exporter_password (align with your DB user)

2) Option A: Grafana uses PostgreSQL on your server (uncomment in file)
- Set GF_DATABASE_* env to point to your external DB

3) Option B: Grafana uses SQLite (default in file)
- No external DB needed

4) Prepare your external PostgreSQL
- Run setup-monitoring-users.sql on that server to create postgres_exporter and optional grafana user + DB

5) Launch
```
 docker compose -f docker-compose-simplified.yml up -d
```

---

## ⚙️ Configuration Notes

- PostgreSQL
  - Auth: SCRAM-SHA-256 via pg_hba.conf, init args set to "--auth-host=scram-sha-256"
  - SSL: Disabled by default; enable in postgres/postgresql.conf if needed
  - Logging: Extensive logging enabled (adjust for production)
- postgres_exporter
  - DSN composed from EXPORTER_PASSWORD, user postgres_exporter, DB postgres
  - Extend queries in postgres-exporter/queries.yaml
- Prometheus
  - Scrapes: prometheus itself and postgres-exporter
  - Retention flags: 60d or 50GB (whichever reached first)
  - Alerting: prometheus.yml references alert_rules.yml and Alertmanager at alertmanager:9093
    - Files and service are not included by default. Add rule_files and Alertmanager service or remove these stanzas to silence warnings.
  - Optional auth/TLS: web-config.yml present but not used unless you mount and pass `--web.config.file`
- Grafana
  - In full stack: uses local Postgres service (grafana DB)
  - Datasources: pre-provisioned Prometheus; PostgreSQL datasource contains placeholders you may update

---

## 🔐 Security Checklist

- Use strong secrets via .env (do not commit this file)
- Restrict pg_hba.conf networks to only what you need (currently includes 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- Enable SSL for PostgreSQL if traffic crosses untrusted networks
- Do not publicly expose ports 3000, 9090, 9187 without a reverse proxy/WAF
- Prometheus UI auth/TLS:
  - Mount web-config.yml and start Prometheus with:
    - Volume: ./prometheus/web-config.yml:/etc/prometheus/web.yml:ro
    - Arg: --web.config.file=/etc/prometheus/web.yml
  - Provide valid certs/keys in the mounted paths referenced by web-config.yml

---

## 🛠️ Common Operations

- Start/Stop
```
 docker compose up -d
 docker compose down
```

- Tail logs
```
 docker compose logs -f postgres
 docker compose logs -f postgres-exporter
 docker compose logs -f prometheus
 docker compose logs -f grafana
```

- Reset state (danger: removes data volumes)
```
 docker compose down -v
```

- Change ports
  - Edit port mappings in docker-compose.yml (e.g., change 3000:3000 to 3001:3000 for Grafana)

---

## 🧯 Troubleshooting

- Exporter not scraping
  - Check logs: `docker compose logs postgres-exporter`
  - Hit metrics endpoint: `http://localhost:9187/metrics`
  - Validate DB user/password and pg_hba.conf allows the exporter

- Grafana can’t start or login
  - Check GF_SECURITY_ADMIN_PASSWORD (GRAFANA_PASSWORD env)
  - If using Postgres as backend, confirm DB grafana exists and credentials match init SQL or .env

- Prometheus warnings about rules/Alertmanager
  - Remove `rule_files` and `alerting` sections or supply the referenced files/services

- Postgres connectivity
  - Healthcheck uses `pg_isready` as postgres user; ensure POSTGRES_PASSWORD is set and DB is reachable

---

## 🎛️ Customization

- Add Grafana dashboards: drop JSON files into grafana/dashboards/ and reference them via provisioning
- Add Prometheus scrape jobs: extend prometheus/prometheus.yml with new `scrape_configs`
- Extend exporter metrics: edit postgres-exporter/queries.yaml
- Tune retention: adjust `--storage.tsdb.retention.time` and `--storage.tsdb.retention.size`

---

## 📝 Notes for Developers

- The provisioning datasource at grafana/provisioning/datasources/datasource.yaml includes placeholders for a PostgreSQL datasource. Update host, password, and SSL mode per your environment.
- setup-database.sql grants required privileges to postgres_exporter and creates a `pg_stat_activity_monitoring` view. If you change usernames/passwords in .env, reflect them in this SQL or vice versa.
- For Prometheus web auth/TLS, the provided web-config.yml is an example and includes bcrypt hashes for example users. Replace with your own hashes and certs.

---

Happy monitoring! 🔭✨