-- Run this on your Windows Server PostgreSQL
-- Connect as superuser (postgres) and execute these commands

-- Create monitoring user for Prometheus PostgreSQL exporter
CREATE USER postgres_exporter WITH PASSWORD 'your_secure_exporter_password';

-- Grant minimal required permissions for monitoring
GRANT CONNECT ON DATABASE postgres TO postgres_exporter;
GRANT USAGE ON SCHEMA public TO postgres_exporter;

-- Grant access to system views and functions needed for monitoring
GRANT SELECT ON pg_stat_database TO postgres_exporter;
GRANT SELECT ON pg_stat_user_tables TO postgres_exporter;
GRANT SELECT ON pg_stat_user_indexes TO postgres_exporter;
GRANT SELECT ON pg_stat_activity TO postgres_exporter;
GRANT SELECT ON pg_locks TO postgres_exporter;
GRANT SELECT ON pg_stat_replication TO postgres_exporter;
GRANT SELECT ON pg_stat_bgwriter TO postgres_exporter;
GRANT SELECT ON pg_stat_archiver TO postgres_exporter;
GRANT EXECUTE ON FUNCTION pg_stat_file(text) TO postgres_exporter;
GRANT EXECUTE ON FUNCTION pg_ls_dir(text) TO postgres_exporter;

-- Enable pg_stat_statements extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
GRANT SELECT ON pg_stat_statements TO postgres_exporter;

-- Create Grafana database and user (optional - you can use existing DB)
CREATE USER grafana WITH PASSWORD 'your_secure_grafana_password';
CREATE DATABASE grafana OWNER grafana;
GRANT ALL PRIVILEGES ON DATABASE grafana TO grafana;

-- Create a monitoring schema for custom queries (optional)
CREATE SCHEMA IF NOT EXISTS monitoring;
GRANT USAGE ON SCHEMA monitoring TO postgres_exporter;
GRANT SELECT ON ALL TABLES IN SCHEMA monitoring TO postgres_exporter;