# Deployment Overview

## 🚀 Deployment Strategy

XploreSG follows a progressive deployment approach that mirrors the development environment structure, ensuring consistency from development to production.

## 🎯 Deployment Environments

### Development Environments

| Environment      | Purpose                | Infrastructure   | URL                    |
| ---------------- | ---------------------- | ---------------- | ---------------------- |
| **Local Docker** | Individual development | Docker Compose   | `localhost:3000`       |
| **Local K8s**    | Kubernetes development | Minikube         | `xploresg.local`       |
| **Staging**      | Integration testing    | DigitalOcean K8s | `staging.xploresg.com` |
| **Production**   | Live application       | DigitalOcean K8s | `xploresg.com`         |

## 🏗️ Infrastructure Architecture

### Production Infrastructure (DigitalOcean)

```
┌─────────────────────────────────────────────────────────────────┐
│                     DigitalOcean Infrastructure                 │
├─────────────────────────────────────────────────────────────────┤
│ Load Balancer (DigitalOcean LB)                                │
│ ├── SSL Termination                                             │
│ ├── Health Checks                                               │
│ └── Traffic Distribution                                         │
├─────────────────────────────────────────────────────────────────┤
│ Kubernetes Cluster (DOKS)                                      │
│ ├── Master Nodes (Managed by DO)                               │
│ ├── Worker Nodes (3x 4GB RAM, 2 vCPU)                         │
│ └── Auto-scaling (2-10 nodes)                                  │
├─────────────────────────────────────────────────────────────────┤
│ Database                                                        │
│ ├── Managed PostgreSQL (DigitalOcean Database)                 │
│ ├── Connection Pooling                                          │
│ ├── Automated Backups                                          │
│ └── Read Replicas (future)                                     │
├─────────────────────────────────────────────────────────────────┤
│ Storage                                                         │
│ ├── Block Storage for persistent volumes                       │
│ ├── Spaces (S3-compatible) for file storage                   │
│ └── CDN integration                                            │
├─────────────────────────────────────────────────────────────────┤
│ Monitoring & Logging                                           │
│ ├── DigitalOcean Monitoring                                   │
│ ├── Custom metrics via Prometheus                              │
│ └── Log aggregation                                            │
└─────────────────────────────────────────────────────────────────┘
```

## 📋 Deployment Methods

### 1. GitOps with GitHub Actions

**Automated CI/CD Pipeline:**

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Run tests
      - name: Security scanning
      - name: Code quality checks

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Build Docker images
      - name: Push to registry
      - name: Generate manifests

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to staging
      - name: Run integration tests
      - name: Deploy to production (manual approval)
```

### 2. Helm-based Deployment

**Helm Charts for Kubernetes:**

```bash
# Install/upgrade application
helm upgrade --install xploresg ./charts/xploresg \
  --namespace production \
  --values values-production.yaml
```

### 3. Infrastructure as Code (Terraform)

**DigitalOcean Infrastructure:**

```hcl
# terraform/main.tf
resource "digitalocean_kubernetes_cluster" "xploresg" {
  name    = "xploresg-production"
  region  = "sgp1"
  version = "1.28.2-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-4vcpu-8gb"
    node_count = 3
    auto_scale = true
    min_nodes  = 2
    max_nodes  = 10
  }
}
```

## 🔄 Deployment Process

### Staging Deployment

```bash
# 1. Automated via GitHub Actions on PR merge to staging
git checkout staging
git merge feature/new-feature
git push origin staging

# 2. CI/CD Pipeline runs:
#    - Tests
#    - Build images
#    - Deploy to staging
#    - Run integration tests
#    - Notify team
```

### Production Deployment

```bash
# 1. Create release PR
gh pr create --title "Release v1.2.0" --base main --head staging

# 2. Manual approval process
#    - Code review
#    - QA testing on staging
#    - Product owner approval

# 3. Merge to main triggers production deployment
#    - Blue-green deployment
#    - Health checks
#    - Automatic rollback on failure
```

## 🛠️ Deployment Tools

### Required Tools

```bash
# Kubernetes CLI
kubectl version --client

# Helm package manager
helm version

# Terraform (for infrastructure)
terraform version

# DigitalOcean CLI
doctl version

# Docker (for building images)
docker version
```

### Configuration Management

```bash
# Environment-specific configurations
configs/
├── base/                    # Common configurations
├── staging/                 # Staging overrides
└── production/             # Production overrides
    ├── kustomization.yaml
    ├── ingress-patch.yaml
    ├── resources-patch.yaml
    └── secrets/
```

## 🔐 Security & Compliance

### Security Measures

| Layer           | Security Controls                                            |
| --------------- | ------------------------------------------------------------ |
| **Network**     | TLS 1.3, Network Policies, Firewall Rules                    |
| **Application** | JWT Authentication, Input Validation, CORS                   |
| **Container**   | Non-root users, Security contexts, Image scanning            |
| **Data**        | Encryption at rest, Encrypted connections, Backup encryption |
| **Access**      | RBAC, Service accounts, Least privilege                      |

### Compliance Considerations

- **Data Privacy**: GDPR compliance for user data
- **Security Standards**: OWASP Top 10 mitigation
- **Audit Logging**: All access and changes logged
- **Backup & Recovery**: 30-day backup retention

## 📊 Monitoring & Observability

### Health Monitoring

```yaml
# Health check endpoints
/health/live     # Liveness probe
/health/ready    # Readiness probe
/health/startup  # Startup probe
/metrics         # Prometheus metrics
```

### Key Metrics

| Metric Type        | Examples                                            |
| ------------------ | --------------------------------------------------- |
| **Application**    | Response time, Error rate, Throughput               |
| **Infrastructure** | CPU usage, Memory usage, Disk I/O                   |
| **Business**       | User registrations, API calls, Feature usage        |
| **Database**       | Connection count, Query performance, Lock wait time |

### Alerting Rules

```yaml
# Critical alerts
- Database connection failures
- High error rates (>5%)
- Memory usage >90%
- Disk space <10%

# Warning alerts
- Response time >2s
- Memory usage >70%
- Unusual traffic patterns
```

## 🚢 Deployment Environments Detail

### Local Development

- **Purpose**: Individual developer testing
- **Infrastructure**: Docker Compose
- **Data**: SQLite or local PostgreSQL
- **Access**: `localhost:3000`

### Local Kubernetes

- **Purpose**: Kubernetes development and testing
- **Infrastructure**: Minikube
- **Data**: In-cluster PostgreSQL
- **Access**: `xploresg.local` (via hosts file)

### Staging Environment

- **Purpose**: Integration testing and QA
- **Infrastructure**: DigitalOcean Kubernetes (smaller cluster)
- **Data**: Managed PostgreSQL (development tier)
- **Access**: `https://staging.xploresg.com`

```yaml
# Staging resource limits
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi

replicas: 2
```

### Production Environment

- **Purpose**: Live application serving users
- **Infrastructure**: DigitalOcean Kubernetes (production cluster)
- **Data**: Managed PostgreSQL (production tier)
- **Access**: `https://xploresg.com`

```yaml
# Production resource limits
resources:
  requests:
    cpu: 200m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1Gi

replicas: 3
minReplicas: 3
maxReplicas: 10
```

## 📈 Scaling Strategy

### Horizontal Pod Autoscaler (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: xploresg-frontend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend-service
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

### Cluster Autoscaler

```yaml
# DigitalOcean Kubernetes node pool
node_pool {
name       = "worker-pool"
size       = "s-4vcpu-8gb"
auto_scale = true
min_nodes  = 3
max_nodes  = 15
}
```

## 🔄 Disaster Recovery

### Backup Strategy

```yaml
Database Backups:
  - Frequency: Daily automated backups
  - Retention: 30 days
  - Testing: Weekly restore tests
  - Location: Multiple regions

Application Backups:
  - Configuration: Git repository
  - Container images: Registry with replication
  - Persistent data: Block storage snapshots
```

### Recovery Procedures

1. **Database Recovery**: Restore from point-in-time backup
2. **Application Recovery**: Redeploy from Git + registry
3. **Infrastructure Recovery**: Terraform recreation
4. **DNS Failover**: Automated via health checks

## 📚 Deployment Guides

For detailed deployment instructions, see:

- [Local Development Deployment](local.md)
- [Minikube Deployment](minikube.md)
- [DigitalOcean Production Deployment](digitalocean.md)
- [CI/CD Pipeline Setup](cicd.md)

---

This deployment overview provides the foundation for scalable, reliable, and secure deployment of XploreSG across all environments! 🚀🇸🇬
