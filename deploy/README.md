# AEGIS Local Development Stack

This directory contains everything needed to spin up the full AEGIS backing-service stack locally using Docker Compose.

See the [Getting Started guide](https://docs.aegis.ai/docs/getting-started) for a complete walkthrough.

## Files

| File | Purpose |
| --- | --- |
| `docker-compose.yml` | All backing services (Postgres, Temporal, SeaweedFS, Ollama) |
| `aegis-config.yaml` | Reference AEGIS node configuration (mounted into the aegis-runtime container) |
| `.env.example` | Environment variable template |
| `init-multiple-dbs.sh` | PostgreSQL init script — creates all required databases on first start |
| `temporal/development-sql.yaml` | Temporal dynamic configuration for the PostgreSQL backend |

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/100monkeys-ai/aegis-examples.git
cd aegis-examples

# 2. Configure environment
cp deploy/.env.example deploy/.env
# Edit deploy/.env if you need to change AEGIS_NFS_HOST or other settings

# 3. Start all services
docker compose -f deploy/docker-compose.yml up -d

# 4. Wait for services to become healthy (~30s)
docker compose -f deploy/docker-compose.yml ps

# 5. (Optional) Pull an Ollama model for local LLM inference
docker compose -f deploy/docker-compose.yml exec ollama ollama pull phi3:mini
```

## Services

| Service | URL | Purpose |
| --- | --- | --- |
| AEGIS Runtime | <http://localhost:8088> | Orchestrator HTTP API |
| AEGIS gRPC | localhost:50051 | gRPC for worker activities |
| Temporal UI | <http://localhost:8233> | Workflow visibility |
| Temporal gRPC | localhost:7233 | Temporal client endpoint |
| SeaweedFS Master | <http://localhost:9333> | Storage cluster admin |
| SeaweedFS Filer | <http://localhost:8888> | POSIX file API |
| SeaweedFS WebDAV | <http://localhost:7333> | File browser |
| Ollama | <http://localhost:11434> | Local LLM inference |
| PostgreSQL | localhost:5432 | Primary data store |

## GPU Support (Ollama)

The `ollama` service is configured for NVIDIA GPU passthrough. If you don't have an NVIDIA GPU or `nvidia-container-toolkit` installed, remove the `deploy.resources.reservations` block from the `ollama` service in `docker-compose.yml` before starting.

## NFS Volume Mounts

If you want agents to use persistent or ephemeral volumes, you must set `AEGIS_NFS_HOST` in your `.env` to an address the Docker daemon on your host can reach. See `.env.example` for platform-specific values.

## Stopping the Stack

```bash
# Stop without removing data
docker compose -f deploy/docker-compose.yml down

# Stop and delete all persistent volumes (full reset)
docker compose -f deploy/docker-compose.yml down -v
```
