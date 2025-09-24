# XploreSG System Architecture

## 🎯 Overview

XploreSG is designed as a modern, cloud-native application following microservices architecture principles. The system is built to scale from local development to production deployment on DigitalOcean Kubernetes.

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Internet/Users                           │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                     Load Balancer                               │
│                 (DigitalOcean LB)                              │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                   Ingress Controller                            │
│                   (NGINX Ingress)                              │
└─────┬───────────────┬───────────────┬─────────────────────────────┘
      │               │               │
      ▼               ▼               ▼
┌────────────┐ ┌─────────────┐ ┌─────────────────┐
│  Frontend  │ │ User Service│ │  Other Services │
│ (React/Vue)│ │  (Node.js)  │ │   (Future)      │
│   Pod      │ │    Pod      │ │     Pods        │
└─────┬──────┘ └──────┬──────┘ └─────────────────┘
      │               │
      │               ▼
      │        ┌─────────────┐
      │        │   Database  │
      │        │ (PostgreSQL)│
      │        │     Pod     │
      │        └─────┬───────┘
      │              │
      │              ▼
      │        ┌─────────────┐
      │        │ Persistent  │
      │        │   Volume    │
      │        └─────────────┘
      │
      ▼
┌─────────────┐
│    Cache    │
│   (Redis)   │
│    Pod      │
└─────────────┘
```

## 🌟 Key Architectural Principles

### 1. Microservices Architecture

- **Loosely Coupled**: Services communicate through well-defined APIs
- **Domain Driven**: Each service owns its data and business logic
- **Technology Agnostic**: Services can use different technologies
- **Independent Deployment**: Services can be deployed independently

### 2. Container-First Design

- **Docker Containers**: All services packaged as containers
- **Kubernetes Native**: Designed for Kubernetes orchestration
- **12-Factor App**: Follows twelve-factor app methodology
- **Immutable Infrastructure**: Infrastructure defined as code

### 3. Progressive Development

- **Docker Compose**: Local monolithic development
- **Minikube**: Local Kubernetes development
- **Production K8s**: DigitalOcean Kubernetes cluster

### 4. Cloud-Native Patterns

- **Health Checks**: Liveness and readiness probes
- **Configuration Management**: ConfigMaps and Secrets
- **Service Discovery**: Kubernetes native service discovery
- **Load Balancing**: Automatic load balancing between pods

## 🧩 Service Architecture

### Frontend Service

**Technology**: React/Vue.js/Angular  
**Responsibility**: User interface and user experience  
**Dependencies**: User Service (API calls)

```yaml
Frontend Service:
  - Static file serving (Nginx)
  - Client-side routing
  - API integration
  - Responsive design
  - Progressive Web App capabilities
```

### User Service

**Technology**: Node.js/Python/Java  
**Responsibility**: User management and authentication  
**Dependencies**: PostgreSQL, Redis (optional)

```yaml
User Service:
  - User registration/login
  - JWT authentication
  - Profile management
  - Password reset
  - Email verification
  - Role-based access control
```

### Database Layer

**Primary Database**: PostgreSQL  
**Cache**: Redis (optional)  
**Document Store**: MongoDB (optional)

```yaml
Database Strategy:
  - PostgreSQL: Relational data (users, transactions)
  - Redis: Session storage, caching
  - MongoDB: Content management, reviews
```

## 🔧 Technology Stack

### Frontend

- **Framework**: React/Vue.js/Angular
- **Build Tool**: Webpack/Vite
- **Styling**: CSS Modules/Styled Components
- **State Management**: Redux/Vuex/Context API

### Backend

- **Runtime**: Node.js/Python/Java
- **Framework**: Express/FastAPI/Spring Boot
- **Authentication**: JWT tokens
- **Validation**: Joi/Yup/Class Validator

### Database

- **Primary**: PostgreSQL 14+
- **Cache**: Redis 7+
- **Search**: Elasticsearch (future)
- **File Storage**: MinIO/AWS S3 (future)

### Infrastructure

- **Orchestration**: Kubernetes
- **Ingress**: NGINX Ingress Controller
- **Monitoring**: Prometheus + Grafana (future)
- **Logging**: ELK Stack (future)

## 🔒 Security Architecture

### Authentication & Authorization

```yaml
Security Layers:
  1. Network Level:
    - TLS/SSL encryption
    - Network policies
    - Firewall rules

  2. Application Level:
    - JWT authentication
    - Role-based access control (RBAC)
    - Input validation
    - Rate limiting

  3. Data Level:
    - Data encryption at rest
    - Database access controls
    - Sensitive data masking
```

### Security Best Practices

- **Secrets Management**: Kubernetes Secrets for sensitive data
- **Container Security**: Non-root containers, security contexts
- **Network Security**: Network policies, service mesh (future)
- **Image Security**: Container image scanning, trusted registries

## 📊 Data Architecture

### Data Flow

```
User Request → Ingress → Service → Database → Response
     ↓
   Frontend → API Gateway → Microservice → Database
     ↓
   Cache Layer (Redis) for performance optimization
```

### Database Schema Design

```sql
-- Core Tables
Users (id, email, password_hash, profile_data, created_at)
Sessions (id, user_id, token_hash, expires_at)
Profiles (user_id, display_name, preferences, settings)

-- Singapore-specific Tables (Future)
Locations (id, name, category, coordinates, description)
Reviews (id, user_id, location_id, rating, content)
Bookings (id, user_id, location_id, date, status)
```

## 🚀 Scalability Considerations

### Horizontal Scaling

- **Stateless Services**: All services designed to be stateless
- **Load Balancing**: Kubernetes native load balancing
- **Auto-scaling**: HPA (Horizontal Pod Autoscaler)
- **Database Scaling**: Read replicas, connection pooling

### Performance Optimization

- **Caching Strategy**: Redis for session and data caching
- **CDN**: Static asset delivery (future)
- **Database Optimization**: Indexing, query optimization
- **Image Optimization**: WebP format, responsive images

## 🔄 Development Environments

### Local Development (Docker Compose)

```yaml
Services:
  - postgres: Database
  - redis: Cache (optional)
  - user-service: Backend API
  - frontend: React application
```

### Kubernetes Development (Minikube)

```yaml
Namespaces:
  - xploresg-dev: Development environment

Services:
  - PostgreSQL with persistent storage
  - User service with health checks
  - Frontend service
  - Ingress for routing
```

### Production (DigitalOcean Kubernetes)

```yaml
Features:
  - Multi-node cluster
  - Load balancer integration
  - Persistent volume provisioning
  - Monitoring and logging
  - Backup and disaster recovery
```

## 📈 Monitoring & Observability

### Metrics Collection

- **Application Metrics**: Custom metrics via Prometheus
- **Infrastructure Metrics**: Node and pod metrics
- **Database Metrics**: PostgreSQL performance metrics

### Logging Strategy

- **Centralized Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Structured Logging**: JSON format logs
- **Log Correlation**: Trace IDs across services

### Health Monitoring

- **Kubernetes Probes**: Liveness and readiness checks
- **Service Health**: Custom health endpoints
- **Dependency Monitoring**: Database and external service health

## 🔮 Future Architecture Enhancements

### Planned Features

1. **API Gateway**: Centralized routing and authentication
2. **Service Mesh**: Istio for advanced traffic management
3. **Event-Driven Architecture**: Message queues for async processing
4. **Multi-Region Deployment**: Geographic distribution
5. **Machine Learning Pipeline**: Recommendation engine
6. **Real-time Features**: WebSocket support for live updates

### Technology Roadmap

- **Year 1**: Core platform with basic features
- **Year 2**: Advanced features, ML recommendations
- **Year 3**: Multi-region, real-time collaboration

---

This architecture provides a solid foundation that can grow from a simple local development setup to a robust, scalable production system serving thousands of users exploring Singapore! 🇸🇬
