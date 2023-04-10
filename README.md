# Project: Hive Docker Image
This is an open-source project that provides a Docker image for building and running the Presto server.
The Docker image is based on OpenJDK 8 and includes Presto version 0.280.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [License](#license)
- [Contact](#contact)

## Features
- OpenJDK 8 as the base image.
- Presto 2.8.0 pre-installed.
- Prometheus JMX exporter pre-installed for monitoring.

## Prerequisites
- Docker installed on your system.

## Installation
There is no need to install the Docker image as it is available on DockerHub. You can download the image using the following command:

```bash
docker pull rubensminoru/presto
```

### Building image manually
1. Clone the repository:
```bash
git clone https://github.com/rubensmabueno/docker-presto.git
```

2. Build the Docker image:
```bash
docker build -t your-image-name .
```

## Usage
### Option 1: Using Docker Compose
1. Create a docker-compose.yml file with the following content:

```
version: '3.8'

services:
  coordinator:
    image: rubensminoru/presto
    ports:
      - "8080:8080"
      - "5556:5556"
    volumes:
      - "./config/coordinator.properties:/etc/presto/config.properties"
      - "./config/node.properties:/etc/presto/node.properties"
      - "./config/log.properties:/etc/presto/log.properties"
      - "./config/jvm.config:/opt/presto/etc/jvm.config"
      - "./config/catalog:/etc/presto/catalog"
      - "./config/jmx-config.yml:/opt/jmx_prometheus_javaagent/config.yml"
      - "./tmp/coordinator/data:/data"
      - "./tmp/coordinator/worker:/presto"
    healthcheck:
      test: [ "CMD", "curl", "--fail", "http://localhost:8080/v1/info" ]
      interval: 10s
      timeout: 5s
      retries: 3
  workers:
    image: rubensminoru/presto
    volumes:
      - "./config/worker.properties:/etc/presto/config.properties"
      - "./config/node.properties:/etc/presto/node.properties"
      - "./config/log.properties:/etc/presto/log.properties"
      - "./config/jvm.config:/opt/presto/etc/jvm.config"
      - "./config/catalog:/etc/presto/catalog"
      - "./config/jmx-config.yml:/opt/jmx_prometheus_javaagent/config.yml"
      - "./tmp/worker_1/data:/data"
      - "./tmp/worker_1/worker:/presto"
    healthcheck:
      test: [ "CMD", "curl", "--fail", "http://localhost:8080/v1/info" ]
      interval: 10s
      timeout: 5s
      retries: 3
    depends_on:
      coordinator:
        condition: service_healthy
```

2. Start the containers:
```bash
docker-compose up
```

### Option 2: Usage with Docker Run
1. Start the Presto coordinator:
```bash
docker run -d \
    --name coordinator \
    -p 8080:8080 \
    -p 5556:5556 \
    -v "$(pwd)/config/coordinator.properties:/etc/presto/config.properties" \
    -v "$(pwd)/config/node.properties:/etc/presto/node.properties" \
    -v "$(pwd)/config/log.properties:/etc/presto/log.properties" \
    -v "$(pwd)/config/jvm.config:/opt/presto/etc/jvm.config" \
    -v "$(pwd)/config/catalog:/etc/presto/catalog" \
    -v "$(pwd)/config/jmx-config.yml:/opt/jmx_prometheus_javaagent/config.yml" \
    -v "$(pwd)/tmp/coordinator/data:/data" \
    -v "$(pwd)/tmp/coordinator/worker:/presto" \
    rubensminoru/presto
```

2. Start the Presto worker:
```bash
docker run -d \
    --name workers \
    --link coordinator:coordinator \
    -v "$(pwd)/config/worker.properties:/etc/presto/config.properties" \
    -v "$(pwd)/config/node.properties:/etc/presto/node.properties" \
    -v "$(pwd)/config/log.properties:/etc/presto/log.properties" \
    -v "$(pwd)/config/jvm.config:/opt/presto/etc/jvm.config" \
    -v "$(pwd)/config/catalog:/etc/presto/catalog" \
    -v "$(pwd)/config/jmx-config.yml:/opt/jmx_prometheus_javaagent/config.yml" \
    -v "$(pwd)/tmp/workers/data:/data" \
    -v "$(pwd)/tmp/workers/worker:/presto" \
    rubensminoru/presto
```

### Configuration
- Configuration files for the coordinator and worker are stored in the ./config directory.
- Data directories for the coordinator and worker are stored in the ./tmp directory.
- Edit the ./config/coordinator.properties, ./config/worker.properties, and other configuration files as needed to customize your cluster.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact
- Maintainer: Rubens Minoru Andako Bueno
- Email: rubensmabueno@hotmail.com
- Feel free to reach out for any questions, issues, or contributions.
