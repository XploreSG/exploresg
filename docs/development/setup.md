# Development Environment Setup Guide

## 🚀 Quick Start

This guide will help you set up the XploreSG development environment. We support three development approaches:

1. **Docker Compose** (Recommended for beginners)
2. **Kubernetes with Minikube** (For Kubernetes experience)
3. **Native Development** (For advanced users)

## 📋 Prerequisites

### System Requirements

- **RAM**: Minimum 8GB (16GB recommended)
- **CPU**: 4+ cores recommended
- **Disk**: 10GB+ free space
- **OS**: Windows 10+, macOS 10.14+, or Ubuntu 18.04+

### Required Software

#### Essential Tools

```bash
# Git (for repository management)
git --version  # Should be 2.30+

# Docker (for containerization)
docker --version  # Should be 20.10+
docker-compose --version  # Should be 2.0+

# Node.js (for frontend development)
node --version  # Should be 18+
npm --version   # Should be 8+
```

#### Development Tools (Choose one)

**For Docker Compose Development:**

- Docker Desktop or Docker Engine
- Docker Compose v2

**For Kubernetes Development:**

- kubectl (Kubernetes CLI)
- minikube (local Kubernetes)

**For Native Development:**

- PostgreSQL 14+
- Redis 7+ (optional)
- Your preferred IDE/editor

## 🐳 Docker Compose Setup (Recommended)

### 1. Repository Setup

```bash
# Clone and setup all repositories
git clone https://github.com/XploreSG/exploresg.git
cd exploresg/setup
./setup.sh  # Linux/macOS
# OR
setup.bat   # Windows
```

### 2. Start Development Environment

```bash
# Navigate to Docker development
cd ../dev

# Start all services
./dev-up.sh  # Linux/macOS
# OR
.\dev-up.bat  # Windows (if available)
```

### 3. Verify Installation

```bash
# Check running containers
docker ps

# Access the application
# Frontend: http://localhost:3000
# API: http://localhost:3001
# Database: localhost:5432
```

### 4. Development Workflow

```bash
# View logs
docker-compose logs -f user-service
docker-compose logs -f frontend

# Stop services
docker-compose down

# Restart specific service
docker-compose restart user-service

# Rebuild after code changes
docker-compose up --build user-service
```

## ☸️ Kubernetes Development Setup

### 1. Install Kubernetes Tools

#### Install kubectl

```bash
# macOS (using Homebrew)
brew install kubectl

# Windows (using Chocolatey)
choco install kubernetes-cli

# Linux (using curl)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

#### Install Minikube

```bash
# macOS
brew install minikube

# Windows
choco install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### 2. Setup Kubernetes Environment

```bash
# Navigate to Kubernetes development
cd k8s-dev

# Start the development environment
./scripts/dev-up.sh
```

### 3. Verify Installation

```bash
# Check minikube status
minikube status

# Check pods
kubectl get pods -n xploresg-dev

# Get access URLs
minikube service list -n xploresg-dev
```

### 4. Access Applications

```bash
# Get minikube IP
minikube ip

# Access via browser:
# Frontend: http://<minikube-ip>
# API: http://<minikube-ip>/api

# Optional: Setup local DNS
echo "$(minikube ip) xploresg.local api.xploresg.local" | sudo tee -a /etc/hosts
```

## 💻 Native Development Setup

### 1. Database Setup

#### PostgreSQL Installation

```bash
# macOS
brew install postgresql@14
brew services start postgresql@14

# Ubuntu
sudo apt update
sudo apt install postgresql-14 postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Windows
# Download installer from: https://www.postgresql.org/download/windows/
```

#### Database Configuration

```sql
-- Connect to PostgreSQL
psql -U postgres

-- Create development database
CREATE DATABASE xploresg_dev;
CREATE USER xploresg_user WITH PASSWORD 'dev_password';
GRANT ALL PRIVILEGES ON DATABASE xploresg_dev TO xploresg_user;

-- Exit psql
\q
```

### 2. Redis Setup (Optional)

```bash
# macOS
brew install redis
brew services start redis

# Ubuntu
sudo apt install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Windows
# Use WSL or download from: https://redis.io/download
```

### 3. Application Setup

#### Backend Setup

```bash
# Navigate to user service directory
cd user-service  # Replace with actual repository path

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your database configuration

# Run database migrations
npm run migrate

# Start development server
npm run dev
```

#### Frontend Setup

```bash
# Navigate to frontend directory
cd frontend  # Replace with actual repository path

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your API configuration

# Start development server
npm start
```

## 🛠️ IDE Configuration

### Visual Studio Code

#### Recommended Extensions

```json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-eslint",
    "ms-kubernetes-tools.vscode-kubernetes-tools",
    "ms-azuretools.vscode-docker",
    "GitLab.gitlab-workflow",
    "redhat.vscode-yaml"
  ]
}
```

#### Workspace Settings

```json
{
  "typescript.preferences.importModuleSpecifier": "relative",
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "kubernetes.outputFormat": "yaml",
  "docker.images.sortBy": "CreatedTime",
  "files.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/.git": true
  }
}
```

### JetBrains WebStorm

#### Configuration

1. **TypeScript**: Enable TypeScript service
2. **Prettier**: Configure as default formatter
3. **ESLint**: Enable automatic fixing
4. **Docker**: Enable Docker integration
5. **Database**: Add PostgreSQL data source

## 🔧 Environment Configuration

### Environment Variables

#### Development (.env)

```bash
# Database Configuration
DATABASE_URL=postgresql://xploresg_user:dev_password@localhost:5432/xploresg_dev
DB_HOST=localhost
DB_PORT=5432
DB_NAME=xploresg_dev
DB_USER=xploresg_user
DB_PASSWORD=dev_password

# Redis Configuration (optional)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Application Configuration
NODE_ENV=development
PORT=3001
API_BASE_URL=http://localhost:3001

# Authentication
JWT_SECRET=your-super-secret-jwt-key-for-development-only
JWT_EXPIRES_IN=24h

# Email Configuration (development)
SMTP_HOST=smtp.mailtrap.io
SMTP_PORT=2525
SMTP_USER=your_mailtrap_user
SMTP_PASSWORD=your_mailtrap_password

# External APIs (if any)
GOOGLE_MAPS_API_KEY=your_google_maps_key
SINGAPORE_OPEN_DATA_API_KEY=your_singapore_api_key
```

#### Docker Environment

```bash
# Docker Compose environment
POSTGRES_DB=xploresg_dev
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres123

REDIS_PASSWORD=redis123

# Application
NODE_ENV=development
API_BASE_URL=http://localhost:3001
```

## 🧪 Testing Setup

### Unit Testing

```bash
# Backend testing
cd user-service
npm install --save-dev jest supertest
npm run test

# Frontend testing
cd frontend
npm install --save-dev @testing-library/react @testing-library/jest-dom
npm run test
```

### Integration Testing

```bash
# Database integration tests
npm run test:integration

# API integration tests
npm run test:api
```

### E2E Testing

```bash
# Install Cypress or Playwright
npm install --save-dev cypress
# OR
npm install --save-dev @playwright/test

# Run E2E tests
npm run test:e2e
```

## 🐛 Troubleshooting

### Common Issues

#### Docker Issues

```bash
# Container build fails
docker system prune -a  # Clean up old images
docker-compose build --no-cache

# Port already in use
lsof -i :3000  # Find process using port
kill -9 <PID>  # Kill process

# Database connection issues
docker-compose logs postgres
docker-compose restart postgres
```

#### Kubernetes Issues

```bash
# Minikube won't start
minikube delete
minikube start --driver=docker

# Pods stuck in pending
kubectl describe pod <pod-name> -n xploresg-dev
kubectl get events -n xploresg-dev

# Service not accessible
kubectl get svc -n xploresg-dev
kubectl port-forward service/<service-name> 8080:80 -n xploresg-dev
```

#### Database Issues

```bash
# PostgreSQL connection refused
sudo systemctl status postgresql
sudo systemctl start postgresql

# Database doesn't exist
createdb xploresg_dev -U postgres

# Migration issues
npm run migrate:fresh  # Drop and recreate tables
```

### Getting Help

1. **Check logs**: Always check application and container logs
2. **Verify configuration**: Ensure environment variables are correct
3. **Network issues**: Verify ports are not blocked by firewall
4. **Resource issues**: Ensure sufficient RAM and disk space
5. **Community**: Check GitHub issues or discussions

## 📚 Next Steps

After setting up your development environment:

1. **Read the [Architecture Overview](../architecture/overview.md)**
2. **Review [API Documentation](../api/overview.md)**
3. **Follow [Coding Standards](coding-standards.md)**
4. **Set up your [Git Workflow](git-workflow.md)**
5. **Start developing your first feature!**

---

You're now ready to start developing XploreSG! 🚀🇸🇬
