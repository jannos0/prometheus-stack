#!/usr/bin/env powershell

# PostgreSQL Monitoring Stack Deployment Script
# For Windows Server with Docker

Write-Host "Starting PostgreSQL Monitoring Stack deployment..." -ForegroundColor Green

# Docker Compose file path test
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not installed. Please install Docker Desktop for Windows." -ForegroundColor Red
    exit 1
}

# Check if Docker Compose is available
if (!(Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Compose is not available. Installing..." -ForegroundColor Yellow
    # Install Docker Compose if not available
    Invoke-WebRequest -Uri "https://github.com/docker/compose/releases/latest/download/docker-compose-windows-x86_64.exe" -OutFile "$env:ProgramFiles\Docker\Docker\resources\bin\docker-compose.exe"
}

# Create directory structure
$directories = @(
    "prometheus",
    "grafana/provisioning/datasources",
    "grafana/provisioning/dashboards",
    "grafana/dashboards",
    "postgres",
    "postgres-exporter",
    "certs"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force
        Write-Host "Created directory: $dir" -ForegroundColor Yellow
    }
}

# Generate SSL certificates, uncomment if ssl certificates are needed


#Write-Host "Generating SSL certificates..." -ForegroundColor Yellow
#& openssl req -x509 -newkey rsa:4096 -nodes -keyout certs/server.key -out certs/server.crt -days 365 -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
#& openssl req -x509 -newkey rsa:4096 -nodes -keyout certs/prometheus.key -out certs/prometheus.crt -days 365 -subj "/C=US/ST=State/L=City/O=Organization/CN=prometheus"
#& openssl req -x509 -newkey rsa:4096 -nodes -keyout certs/grafana.key -out certs/grafana.crt -days 365 -subj "/C=US/ST=State/L=City/O=Organization/CN=grafana"

# Create .env file with default passwords
$envContent = @"
POSTGRES_PASSWORD=your_super_secure_password_here
EXPORTER_PASSWORD=exporter_secure_password_here
GRAFANA_PASSWORD=grafana_admin_password_here
GRAFANA_DB_PASSWORD=grafana_db_password_here
"@

$envContent | Out-File -FilePath ".env" -Encoding utf8

# Start the monitoring stack
Write-Host "Starting monitoring stack..." -ForegroundColor Green
& docker-compose up -d

# Wait for services to be ready
Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check service status
Write-Host "Checking service status..." -ForegroundColor Yellow
& docker-compose ps

# Display access information
Write-Host "`nMonitoring Stack URLs:" -ForegroundColor Green
Write-Host "Grafana: https://localhost:3000 (admin/grafana_admin_password_here)" -ForegroundColor Cyan
Write-Host "Prometheus: http://localhost:9090 (admin/admin_password)" -ForegroundColor Cyan
Write-Host "PostgreSQL: localhost:5432 (postgres/your_super_secure_password_here)" -ForegroundColor Cyan

Write-Host "`nDeployment completed successfully!" -ForegroundColor Green
