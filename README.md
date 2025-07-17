Prometheus & Grafana Monitoring Stack for PostgreSQL
This repository provides a comprehensive, out-of-the-box monitoring solution for PostgreSQL, orchestrated with Docker Compose. It includes Prometheus for metrics collection, Grafana for visualization, and postgres_exporter to expose detailed PostgreSQL metrics.

This stack is designed for easy deployment and scalability, making it ideal for DevOps environments.

✨ Features
End-to-end Monitoring: Full-stack monitoring for your PostgreSQL database.

Docker-based: Fully containerized for consistent environments and easy setup.

Pre-configured Dashboards: Comes with a provisioned Grafana dashboard to get you started immediately.

Automated Metrics Collection: postgres_exporter automatically scrapes a wide range of PostgreSQL metrics.

🧩 Components
Prometheus: A time-series database for storing and querying metrics .

Grafana: A powerful visualization tool for creating and sharing dashboards .

PostgreSQL: The target database for monitoring.

Postgres Exporter: An exporter that queries PostgreSQL for metrics and exposes them in a Prometheus-compatible format.

💻 Prerequisites
Docker

Docker Compose

⚡ Quick Start
Clone the Repository

bash
git clone https://github.com/jannos0/prometheus-stack.git
cd prometheus-stack
Configure Environment Variables

Create a .env file in the root of the project and add your PostgreSQL credentials. This method keeps your sensitive data separate from the docker-compose.yml file .

text
POSTGRES_USER=your_user
POSTGRES_PASSWORD=your_secret_password
POSTGRES_DB=your_database
Start the Stack

Launch the entire stack in detached mode using Docker Compose:

bash
docker-compose up -d
🔗 Access Points
Once the containers are running, you can access the services at the following endpoints:

Grafana Dashboard: http://localhost:3000

Login: admin / admin (change on first login)

Prometheus UI: http://localhost:9090

PostgreSQL Exporter Metrics: http://localhost:9187/metrics

⚙️ Configuration Overview
Prometheus (prometheus/prometheus.yml)
The Prometheus service is configured to automatically discover and scrape metrics from the postgres-exporter container . The docker-compose.yml file ensures the services are on the same network, allowing Prometheus to reach the exporter at postgres-exporter:9187 .

Grafana (grafana/provisioning/)
Grafana is automatically provisioned with a default data source and a dashboard upon startup .

Data Source: The grafana/provisioning/datasources/datasource.yml file configures the connection to the Prometheus service.

Dashboards: The grafana/provisioning/dashboards/dashboard.yml file tells Grafana to load dashboard JSON files from the /etc/grafana/provisioning/dashboards directory inside the container .

🛠️ Customization
Adding Grafana Dashboards
To add more dashboards, place their JSON files inside the grafana/provisioning/dashboards/ directory on your host machine. Grafana will automatically detect and add them . You can find a wide variety of community-built dashboards on the Grafana Labs marketplace. The popular PostgreSQL dashboard ID 9628 is a great starting point .

Custom Prometheus Rules
You can add custom alerting or recording rules by creating .yml files in the prometheus/rules/ directory and mounting them into the Prometheus container via the docker-compose.yml file.

Data Persistence
The docker-compose.yml file uses Docker volumes to persist data for Prometheus and Grafana across container restarts . This is critical for production environments to prevent data loss.

🆘 Troubleshooting
Port Conflicts: If a default port (e.g., 9090, 3000) is already in use on your host, you can change the port mappings in the docker-compose.yml file. For example, to map Grafana to port 3001, change 3000:3000 to 3001:3000.

Exporter Connection Errors: If the exporter fails to connect to the database, check the logs of the postgres-exporter container (docker-compose logs postgres-exporter). Ensure the credentials in your .env file are correct and that the PostgreSQL database is running and accessible.

Containers Won't Start: Run docker-compose logs <service_name> to inspect the logs for a specific container to diagnose the issue.
