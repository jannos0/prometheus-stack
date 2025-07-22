🚀 Prometheus & Grafana Monitoring Stack for PostgreSQL
This comprehensive stack offers a ready-to-go, Docker Compose–orchestrated monitoring solution for PostgreSQL, perfect for DevOps environments emphasizing scalability and automation. It includes Prometheus (metrics collection), Grafana (visualization), and postgres_exporter (PostgreSQL metrics exporter).

✨ Features
End-to-End Monitoring: Full PostgreSQL visibility — performance, stats, and queries.

Dockerized: Containerized for easy, consistent deployment.

Preconfigured Grafana Dashboards: Start monitoring instantly with built-in dashboards.

Automated Metrics Collection: postgres_exporter scrapes a wide range of PostgreSQL metrics.

🧩 Components
Prometheus: Time-series metrics database and query engine.

Grafana: Turn metrics into insightful dashboards.

PostgreSQL: Your monitored database.

Postgres Exporter: Gathers detailed PostgreSQL stats for Prometheus.

💻 Prerequisites
Docker

Docker Compose

⚡ Quick Start
Step 1: Clone the Repository
bash
git clone https://github.com/jannos0/prometheus-stack.git
cd prometheus-stack
Step 2: Create .env File
Create a .env file in the project root with your PostgreSQL credentials:

text
POSTGRES_USER=your_user
POSTGRES_PASSWORD=your_secret_password
POSTGRES_DB=your_database
Step 3: Launch the Stack
Start all services detached:

bash
docker-compose up -d
🔗 Access the Services
Grafana Dashboard: http://localhost:3000
Login: admin / admin (please change password after first login)

Prometheus UI: http://localhost:9090

Postgres Exporter Metrics: http://localhost:9187/metrics

⚙️ Configuration Summary
Prometheus scrapes metrics from the postgres-exporter service via Docker network.

Grafana comes pre-provisioned with data sources and dashboards — configured through grafana/provisioning/.

Data persistence is handled via Docker volumes for Prometheus and Grafana to ensure data durability.

🛠️ Customization
Add More Grafana Dashboards: Drop JSON files into grafana/provisioning/dashboards/ and they auto-load.

Add Prometheus Rules: Place custom .yml rule files into prometheus/rules/ and mount them via docker-compose.yml.

Change Ports: Modify ports in docker-compose.yml if defaults like 3000 or 9090 conflict.

🆘 Troubleshooting
Port Conflicts: Edit ports in the docker-compose.yml file (e.g., change 3000:3000 to 3001:3000 for Grafana).

Exporter Connection Issues: Check postgres_exporter logs with

bash
docker-compose logs postgres-exporter
Confirm .env credentials and PostgreSQL availability.

Containers Not Starting: Check individual container logs via

bash
docker-compose logs <service_name>
Deploy this stack to quickly gain robust, scalable PostgreSQL monitoring coupled with flexible visualization—an ideal toolset for DevOps automation and observability.