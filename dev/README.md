# XploreSG Development Environment

This directory contains the Docker Compose setup for the entire XploreSG development environment.

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** installed and running
- All project repositories cloned (run `../setup/setup.sh` first)

### Start Development Environment

```bash
# Make scripts executable (Linux/Mac/WSL)
chmod +x dev-up.sh dev-down.sh

# Start all services
./dev-up.sh
```

### Stop Development Environment

```bash
# Stop all services
./dev-down.sh
```

## 🏗️ Architecture Overview

The development environment includes:

### 📊 **Infrastructure Services**

- **PostgreSQL** (Port 5432) - Rental, User, Gamification data
- **MongoDB** (Port 27017) - Routes, Journal data
- **Redis** (Port 6379) - Caching, Sessions, Fleet status

### 🔧 **Backend Services**

| Service              | Port | Technology | Purpose                            |
| -------------------- | ---- | ---------- | ---------------------------------- |
| Rental Service       | 3001 | Node.js    | Vehicle booking & fleet management |
| User Service         | 3002 | Node.js    | Authentication & user profiles     |
| Route Service        | 3003 | Node.js    | Map overlays & curated routes      |
| Calendar Service     | 3004 | Python     | Google Calendar integration        |
| Weather Service      | 3005 | Go         | Weather forecasts & alerts         |
| Journal Service      | 3006 | Node.js    | Note-taking & sentiment analysis   |
| AI Service           | 3007 | Python     | Gemini-powered summaries           |
| Gamification Service | 3008 | Node.js    | Medals & achievements              |

### 🌐 **Gateway & Frontend**

| Service     | Port | Technology | Purpose                         |
| ----------- | ---- | ---------- | ------------------------------- |
| API Gateway | 3009 | Node.js    | Service orchestration & routing |
| Frontend    | 3000 | React      | User interface                  |

## ⚙️ Configuration

### Environment Variables

1. **Copy the example file:**

   ```bash
   cp .env.example .env
   ```

2. **Configure your API keys in `.env`:**

   ```bash
   # Google Services
   GOOGLE_CLIENT_ID=your_google_client_id_here
   GOOGLE_CLIENT_SECRET=your_google_client_secret_here
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here

   # External APIs
   WEATHER_API_KEY=your_weather_api_key_here
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

### Database Credentials

All databases are pre-configured with development credentials:

- **PostgreSQL:** `postgres / postgres123`
- **MongoDB:** `mongo / mongo123`
- **Redis:** `redis123`

## 🛠️ Development Workflow

### Hot Reload Development

All services are configured with volume mounts for hot reload:

```yaml
volumes:
  - ../../exploresg-rental-service:/app # Source code mount
  - /app/node_modules # Preserve node_modules
```

### Service Management

```bash
# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f rental-service

# Restart a specific service
docker-compose restart rental-service

# Rebuild and restart a service
docker-compose up --build rental-service

# Scale a service (if needed)
docker-compose up --scale rental-service=2
```

### Database Access

#### PostgreSQL

```bash
# Connect to PostgreSQL
docker exec -it xploresg-postgres psql -U postgres -d xploresg

# Or using external client
Host: localhost
Port: 5432
Database: xploresg
Username: postgres
Password: postgres123
```

#### MongoDB

```bash
# Connect to MongoDB
docker exec -it xploresg-mongodb mongosh --username mongo --password mongo123 --authenticationDatabase admin

# Or using external client (MongoDB Compass)
mongodb://mongo:mongo123@localhost:27017/xploresg
```

#### Redis

```bash
# Connect to Redis
docker exec -it xploresg-redis redis-cli -a redis123

# Or using external client
Host: localhost
Port: 6379
Password: redis123
```

## 🔍 Service Health Monitoring

### Health Check Endpoints

Each service should expose a health endpoint:

```bash
# Check service health
curl http://localhost:3001/health  # Rental Service
curl http://localhost:3002/health  # User Service
curl http://localhost:3003/health  # Route Service
# ... and so on
```

### Container Status

```bash
# View running containers
docker-compose ps

# View resource usage
docker stats

# View container details
docker inspect xploresg-rental-service
```

## 🚨 Troubleshooting

### Common Issues

1. **Port Conflicts**

   ```bash
   # Check what's using a port
   netstat -ano | findstr :3000  # Windows
   lsof -i :3000                 # Linux/Mac
   ```

2. **Database Connection Issues**

   ```bash
   # Check database container logs
   docker-compose logs postgres
   docker-compose logs mongodb
   ```

3. **Service Build Failures**

   ```bash
   # Rebuild specific service
   docker-compose build --no-cache rental-service

   # Remove all containers and rebuild
   docker-compose down
   docker-compose up --build
   ```

4. **Volume Issues**
   ```bash
   # Reset volumes (⚠️ This will delete all data)
   docker-compose down -v
   docker-compose up
   ```

### Reset Everything

```bash
# Complete reset (⚠️ Destructive)
docker-compose down -v          # Stop and remove volumes
docker system prune -f          # Clean up containers/networks
docker-compose up --build       # Rebuild everything
```

## 📋 Development Checklist

- [ ] All repositories cloned via `../setup/setup.sh`
- [ ] Docker Desktop installed and running
- [ ] `.env` file configured with API keys
- [ ] Services start without errors (`./dev-up.sh`)
- [ ] Frontend accessible at http://localhost:3000
- [ ] API Gateway responds at http://localhost:3009
- [ ] Database connections working
- [ ] Hot reload working for development

## 🔗 Related Documentation

- **[Main README](../README.md)** - Project overview and architecture
- **[Setup Guide](../setup/README.md)** - Repository bootstrap instructions
- **[API Documentation](../docs/api.md)** - Service API specifications
- **[Architecture Guide](../docs/architecture.md)** - System design details

---

**Happy Coding!** 🚀 The XploreSG development environment is designed for maximum developer productivity with minimal setup friction.
