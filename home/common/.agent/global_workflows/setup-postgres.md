---
description: Setup PostgreSQL Workflow
---

# Setup PostgreSQL Workflow

This workflow copies a standard PostgreSQL Docker Compose configuration and customizes it for a new project.

## 1. Gather Configuration
Please provide the following details:
- **Target Directory**: The path where `docker-compose.yml` should be created.
- **Project/Container Name**: A unique name for the service and container (e.g., `my-app-db`).
- **External Port**: The host port to map to PostgreSQL (e.g., `5433`).

## 2. Generate Docker Compose
Create the `docker-compose.yml` file in the specified **Target Directory**.

// turbo
Use the `write_to_file` tool to create `docker-compose.yml` with the following template:

```yaml
services:
  {{NAME}}:
    image: postgres:latest
    container_name: {{NAME}}
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      PGDATA: /var/lib/postgresql/18/docker
    ports:
      - "{{PORT}}:5432"
    restart: unless-stopped
    volumes:
      - {{NAME}}_data:/var/lib/postgresql

volumes:
  {{NAME}}_data:
```

Replace `{{NAME}}` with the **Project/Container Name** and `{{PORT}}` with the **External Port**.

## 3. Verification
Run `docker-compose up -d` in the target directory to start the database.
