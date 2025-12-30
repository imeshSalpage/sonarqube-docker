# SonarQube Docker Setup

A streamlined Docker Compose setup to deploy SonarQube locally with PostgreSQL, featuring a comprehensive guide for performing static code analysis on your projects.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Running Code Analysis](#running-code-analysis)
- [Accessing SonarQube](#accessing-sonarqube)
- [Project Configuration](#project-configuration)
- [Troubleshooting](#troubleshooting)
- [Stopping and Cleanup](#stopping-and-cleanup)

## Prerequisites

- Docker Desktop installed and running
- Docker Compose (included with Docker Desktop)
- At least 2GB of available RAM for SonarQube
- Basic understanding of Docker concepts

## Quick Start

### 1. Clone and Start Services

```bash
# Clone this repository
git clone https://github.com/imeshSalpage/sonarqube-docker.git
cd sonarqube-docker

# Start SonarQube and PostgreSQL
docker compose up -d
```

### 2. Wait for Services to Start

SonarQube takes 1-2 minutes to initialize. Monitor the logs:

```bash
docker compose logs -f sonarqube
```

Wait until you see: `SonarQube is operational`

### 3. Access SonarQube

Open your browser and navigate to: `http://localhost:9000`

**Default Credentials:**
- Username: `admin`
- Password: `admin`

⚠️ You'll be prompted to change the password on first login.

## Configuration

### Docker Services

This setup includes two services:

1. **SonarQube** (Port 9000)
   - Community Edition
   - Connected to PostgreSQL database
   - Persistent data storage via Docker volumes

2. **PostgreSQL** (Internal)
   - Database for SonarQube
   - Default credentials (change in production):
     - User: `sonar`
     - Password: `sonar`
     - Database: `sonar`

### Persistent Storage

Data is stored in Docker volumes:
- `sonarqube_data` - Analysis data and configuration
- `sonarqube_extensions` - Plugins and extensions
- `sonarqube_logs` - Application logs
- `postgresql_data` - Database files

## Running Code Analysis

### Step 1: Generate Authentication Token

1. Log in to SonarQube at `http://localhost:9000`
2. Go to **Account → Security** (or navigate to `http://localhost:9000/account/security`)
3. Generate a new token:
   - Name: `local-analysis` (or any name you prefer)
   - Type: User Token
   - Expiration: Choose as needed
4. **Copy the token immediately** (you won't be able to see it again)

### Step 2: Configure Your Project

Copy the template configuration file to your project root:

```bash
cp sonar-project.properties /path/to/your/project/
```

Edit `sonar-project.properties` in your project:

```properties
# Project identification
sonar.projectKey=my-awesome-project
sonar.projectName=My Awesome Project
sonar.projectVersion=1.0

# Source code location
sonar.sources=src
sonar.tests=tests

# Exclusions
sonar.exclusions=**/vendor/**,**/node_modules/**,**/build/**,**/dist/**

# Encoding
sonar.sourceEncoding=UTF-8

# SonarQube server
sonar.host.url=http://localhost:9000

# Authentication token
sonar.token=YOUR_GENERATED_TOKEN_HERE
```

### Step 3: Run Analysis

#### Option A: Using Docker (Recommended)

From your project directory:

```bash
docker run --rm \
  -v $(pwd):/usr/src \
  --network=sonarqube-docker_sonarnet \
  sonarsource/sonar-scanner-cli
```

#### Option B: Using Makefile

If using the provided Makefile:

```bash
# Update the Makefile network name if needed
make sonar-scan
```

#### Option C: Using Local Scanner

Install SonarScanner locally and run:

```bash
sonar-scanner
```

## Accessing SonarQube

### Web Interface

- **URL:** `http://localhost:9000`
- **Default Admin:** admin/admin (change on first login)

### Key Features

- **Dashboard:** Overview of code quality metrics
- **Projects:** List of analyzed projects
- **Issues:** Bugs, vulnerabilities, and code smells
- **Rules:** Configure quality profiles
- **Quality Gates:** Define pass/fail criteria

## Project Configuration

### Language-Specific Settings

#### PHP Projects

```properties
sonar.language=php
sonar.sources=app,src
sonar.tests=tests
sonar.php.coverage.reportPaths=coverage.xml
sonar.php.tests.reportPath=test-report.xml
```

#### JavaScript/TypeScript

```properties
sonar.sources=src
sonar.tests=tests
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.exclusions=**/node_modules/**,**/dist/**,**/build/**
```

#### Python

```properties
sonar.language=python
sonar.sources=.
sonar.tests=tests
sonar.python.coverage.reportPaths=coverage.xml
```

#### Java

```properties
sonar.sources=src/main/java
sonar.tests=src/test/java
sonar.java.binaries=target/classes
sonar.java.test.binaries=target/test-classes
```

### Common Exclusions

```properties
sonar.exclusions=\
  **/vendor/**,\
  **/node_modules/**,\
  **/dist/**,\
  **/build/**,\
  **/target/**,\
  **/*.min.js,\
  **/migrations/**,\
  **/tests/**
```

## Troubleshooting

### SonarQube Won't Start

```bash
# Check logs
docker compose logs sonarqube

# Common issues:
# 1. Not enough memory - increase Docker memory to 2GB+
# 2. Port 9000 already in use - change port in docker-compose.yml
```

### Connection Refused

```bash
# Ensure containers are on the same network
docker network ls
docker network inspect sonarqube-docker_sonarnet

# Update scanner network flag:
--network=sonarqube-docker_sonarnet
```

### Analysis Fails

```bash
# Check sonar-project.properties:
# 1. Verify token is correct
# 2. Ensure sonar.sources points to existing directories
# 3. Check sonar.host.url matches your setup

# Verify connectivity
curl http://localhost:9000/api/system/status
```

### Database Issues

```bash
# Restart services
docker compose restart

# If problems persist, reset database
docker compose down -v
docker compose up -d
```

## Stopping and Cleanup

### Stop Services

```bash
# Stop containers (keeps data)
docker compose stop

# Stop and remove containers (keeps volumes)
docker compose down
```

### Complete Cleanup

```bash
# Remove everything including data
docker compose down -v

# Remove specific volumes
docker volume rm sonarqube-docker_sonarqube_data
docker volume rm sonarqube-docker_postgresql_data
```

### View Resource Usage

```bash
# Check running containers
docker compose ps

# View logs
docker compose logs -f

# Check volume sizes
docker system df -v
```

## Advanced Usage

### Custom Port

Edit `docker-compose.yml`:

```yaml
ports:
  - "8080:9000"  # Access at http://localhost:8080
```

### Production Considerations

1. **Change default passwords** in `docker-compose.yml`
2. **Use strong tokens** for authentication
3. **Set up backups** for Docker volumes
4. **Configure reverse proxy** (nginx/traefik) for HTTPS
5. **Monitor resource usage** and adjust as needed

### Plugins

Install plugins via the web interface:
1. Login as admin
2. Go to **Administration → Marketplace**
3. Browse and install desired plugins
4. Restart SonarQube

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions:
- SonarQube Documentation: https://docs.sonarqube.org/
- GitHub Issues: https://github.com/imeshSalpage/sonarqube-docker/issues
