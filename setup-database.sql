-- Create monitoring user for PostgreSQL exporter
CREATE USER postgres_exporter WITH PASSWORD 'exporter_secure_password_here';
ALTER USER postgres_exporter SET SEARCH_PATH TO postgres_exporter,public;

-- Grant necessary permissions
GRANT CONNECT ON DATABASE postgres TO postgres_exporter;
GRANT USAGE ON SCHEMA public TO postgres_exporter;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres_exporter;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO postgres_exporter;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO postgres_exporter;

-- Create Grafana database user
CREATE USER grafana WITH PASSWORD 'grafana_db_password_here';
CREATE DATABASE grafana OWNER grafana;
GRANT ALL PRIVILEGES ON DATABASE grafana TO grafana;

-- Enable pg_stat_statements extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Create monitoring views
CREATE OR REPLACE VIEW pg_stat_activity_monitoring AS
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query,
    query_start,
    state_change,
    backend_start,
    now() - query_start AS query_duration,
    now() - state_change AS state_duration
FROM pg_stat_activity
WHERE state != 'idle';

-- Grant access to monitoring views
GRANT SELECT ON pg_stat_activity_monitoring TO postgres_exporter;
GRANT SELECT ON pg_stat_statements TO postgres_exporter;
