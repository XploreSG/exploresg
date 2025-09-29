# XploreSG Development Environment

Unified Docker Compose setup for ExploreSG microservices.

## 🚀 Quick Start

**Requirements:**

- Docker Desktop running
- All repositories cloned (`../setup/setup.sh`)

**Start:**

```bash
chmod +x dev.sh
./dev.sh      # Start all services
```

**Stop:**

## 🏗️ Environment Overview

- **PostgreSQL**: 5432 (rental, user, gamification)
- **MongoDB**: 27017 (routes, journal)
- **Redis**: 6379 (sessions, fleet, cache)
- **Node/Go/Python Backends**: 3001–3008
- **API Gateway**: 3009
- **Frontend (React)**: 3000

## ⚙️ Configuration

**Environment:**

```bash
cp .env.example .env    # Copy template and add your API keys
```

**Database Credentials:**

- PostgreSQL: `postgres / postgres123`
- MongoDB: `mongo / mongo123`
- Redis: `redis123`

## 🛠️ Dev Workflow

**Hot reload:**

- All Node/React services mount code with volumes for instant changes.

**Commands:**

```bash
docker compose logs -f
docker compose restart <service>
docker compose up --build <service>
docker compose ps
```

## 🔍 Troubleshooting

**Ports:**

```bash
netstat -ano | findstr :3000
```

**Logs:**

```bash
docker compose logs <service>
```

**Reset:**

```bash
docker compose down -v
docker system prune -f
```

## Checklist

- [ ] All repos cloned
- [ ] Docker running
- [ ] `.env` set with keys
- [ ] `./dev-up.sh` runs with no errors
- [ ] Frontend at [http://localhost:3000](http://localhost:3000)
- [ ] Gateway at [http://localhost:3009](http://localhost:3009)
- [ ] Databases accessible locally

**Docs:**

- [Main README](../README.md)
- [Setup Guide](../setup/README.md)
- [API Docs](../docs/api.md)
- [Architecture Guide](../docs/architecture.md)

**Happy Coding! 🚀**
