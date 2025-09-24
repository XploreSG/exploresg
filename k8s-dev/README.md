# XploreSG Kubernetes Development Environment

This directory contains Kubernetes manifests and scripts for running the XploreSG application in a local development environment using minikube.

## 🏗️ Architecture Overview

The development environment consists of:

### Application Services

- **Frontend Service**: React/Vue/Angular application
- **User Service**: Node.js/Python backend for user management
- **PostgreSQL**: Primary database for user data
- **Redis**: (Optional) Cache and session storage
- **MongoDB**: (Optional) Document storage for content
- **API Gateway**: (Optional) Central routing and load balancing
- **Ingress**: HTTP routing to services

### Monitoring Stack

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization dashboards with pre-built Kubernetes and application metrics
- **Alert Manager**: (Configured) Alert routing and management

### GitOps Platform

- **ArgoCD**: Continuous deployment and application lifecycle management
- **Git Integration**: Declarative application management from repository
- **Self-Healing**: Automated synchronization and drift correction

## 📁 Directory Structure

```
k8s-dev/
├── README.md                     # This file
├── docs/
│   └── monitoring-gitops.md     # Monitoring & GitOps documentation
├── manifests/                    # Kubernetes YAML manifests
│   ├── namespace.yaml           # Namespace and shared resources
│   ├── databases/               # Database deployments
│   │   ├── postgres.yaml       # PostgreSQL with persistent storage
│   │   ├── mongodb.yaml        # MongoDB (commented out)
│   │   └── redis.yaml          # Redis cache (commented out)
│   ├── services/                # Application services
│   │   ├── user-service.yaml   # User management backend
│   │   ├── frontend-service.yaml # Frontend application
│   │   └── api-gateway.yaml    # API gateway (commented out)
│   ├── ingress/                 # External access
│   │   └── ingress.yaml        # HTTP routing configuration
│   ├── monitoring/              # Monitoring stack (Prometheus, Grafana)
│   │   ├── 00-namespace.yaml   # Monitoring namespace
│   │   ├── 01-prometheus-config.yaml # Prometheus configuration
│   │   ├── 02-prometheus.yaml  # Prometheus deployment
│   │   ├── 03-grafana-config.yaml # Grafana configuration & dashboards
│   │   └── 04-grafana.yaml     # Grafana deployment
│   └── gitops/                  # GitOps platform (ArgoCD)
│       ├── 00-namespace.yaml   # ArgoCD namespace
│       ├── 01-argocd-rbac.yaml # RBAC configuration
│       ├── 02-argocd-deployments.yaml # ArgoCD components
│       ├── 03-argocd-services.yaml # Service definitions
│       ├── 04-argocd-config.yaml # ArgoCD configuration
│       └── 05-argocd-applications.yaml # Application definitions
├── scripts/                     # Automation scripts
│   ├── deploy-all.sh           # Deploy complete stack (Linux/macOS)
│   ├── deploy-all.bat          # Deploy complete stack (Windows)
│   ├── deploy-argocd.sh        # Deploy ArgoCD (Linux/macOS)
│   ├── deploy-argocd.bat       # Deploy ArgoCD (Windows)
│   ├── dev-up.sh               # Start development environment
│   ├── dev-down.sh             # Stop and cleanup
│   └── dev-status.sh           # Check environment status
└── config/                      # Configuration files
    ├── .env                    # Environment variables
    └── kustomization.yaml      # Kustomize configuration
```

## 🚀 Quick Start

### Prerequisites

1. **Install minikube**:

   ```bash
   # macOS
   brew install minikube

   # Windows (using Chocolatey)
   choco install minikube

   # Linux
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube
   ```

2. **Install kubectl**:

   ```bash
   # macOS
   brew install kubectl

   # Windows (using Chocolatey)
   choco install kubernetes-cli

   # Linux
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   ```

3. **Docker** (required by minikube):
   - Install Docker Desktop or Docker Engine

### Start Development Environment

#### Complete Stack (Recommended)

```bash
# Navigate to the k8s-dev directory
cd k8s-dev

# Deploy everything: Apps + Monitoring + GitOps
./scripts/deploy-all.sh

# On Windows
deploy-all.bat
```

#### Individual Components

```bash
# Applications only
./scripts/deploy-all.sh --apps-only

# Monitoring stack only (Prometheus + Grafana)
./scripts/deploy-all.sh --monitoring-only

# GitOps platform only (ArgoCD)
./scripts/deploy-all.sh --gitops-only

# Traditional app deployment
./scripts/dev-up.sh
```

The complete deployment will:

1. Start minikube if not running
2. Enable required addons (ingress, metrics-server)
3. Deploy all application manifests
4. Deploy monitoring stack (Prometheus, Grafana)
5. Deploy GitOps platform (ArgoCD)
6. Wait for services to be ready
7. Display access URLs and credentials

### Check Status

```bash
# Check the status of all services
./scripts/dev-status.sh
```

### Stop Development Environment

```bash
# Stop and cleanup the development environment
./scripts/dev-down.sh
```

## 🌐 Accessing the Services

After starting the environment, you can access:

### Application Services

- **Frontend**: `http://<minikube-ip>:30080` or `http://xploresg.local`
- **Backend API**: `http://<minikube-ip>:30090` or `http://api.xploresg.local`

### Monitoring Stack

- **Grafana Dashboard**: `http://<minikube-ip>:30300`
  - Username: `admin` | Password: `admin`
- **Prometheus**: `http://<minikube-ip>:30900`

### GitOps Platform

- **ArgoCD UI**: `https://localhost:8080` (via port-forward)
  - Username: `admin`
  - Password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

### DNS Setup (Optional)

For subdomain routing, add entries to your hosts file:

**Linux/macOS**:

```bash
echo "$(minikube ip) xploresg.local api.xploresg.local" | sudo tee -a /etc/hosts
```

**Windows**:
Add to `C:\Windows\System32\drivers\etc\hosts`:

```
<minikube-ip> xploresg.local api.xploresg.local
```

## 🔧 Configuration

### Environment Variables

Edit `config/.env` to modify application settings:

- Database credentials
- JWT secrets
- API endpoints
- Resource limits

### Kubernetes Resources

Modify resource requests and limits in individual manifest files based on your development machine capabilities.

### Enable Optional Services

Uncomment services in the manifest files:

1. **Redis**: Uncomment in `manifests/databases/redis.yaml`
2. **MongoDB**: Uncomment in `manifests/databases/mongodb.yaml`
3. **API Gateway**: Uncomment in `manifests/services/api-gateway.yaml`

Then update `config/kustomization.yaml` to include the new resources.

## 📊 Monitoring and Debugging

### View Logs

```bash
# View user service logs
kubectl logs -f deployment/user-service -n xploresg-dev

# View frontend logs
kubectl logs -f deployment/frontend-service -n xploresg-dev

# View PostgreSQL logs
kubectl logs -f deployment/postgres -n xploresg-dev
```

### Pod Status

```bash
# List all pods
kubectl get pods -n xploresg-dev

# Describe a specific pod
kubectl describe pod <pod-name> -n xploresg-dev

# Get pod resource usage
kubectl top pods -n xploresg-dev
```

### Access Pod Shell

```bash
# Access user service container
kubectl exec -it deployment/user-service -n xploresg-dev -- /bin/bash

# Access PostgreSQL container
kubectl exec -it deployment/postgres -n xploresg-dev -- psql -U postgres -d xploresg_dev
```

### Port Forwarding

```bash
# Forward PostgreSQL port for direct database access
kubectl port-forward service/postgres-service 5432:5432 -n xploresg-dev

# Forward user service port for direct API access
kubectl port-forward service/user-service 3001:3001 -n xploresg-dev
```

## 🐛 Troubleshooting

### Common Issues

1. **Minikube won't start**:

   ```bash
   minikube delete
   minikube start --driver=docker
   ```

2. **Pods stuck in Pending state**:

   - Check resource constraints: `kubectl describe pod <pod-name> -n xploresg-dev`
   - Verify PVC status: `kubectl get pvc -n xploresg-dev`

3. **Services not accessible**:

   - Check ingress status: `kubectl get ingress -n xploresg-dev`
   - Verify service endpoints: `kubectl get endpoints -n xploresg-dev`

4. **Database connection issues**:
   - Check PostgreSQL pod logs
   - Verify secret configurations
   - Test database connectivity from app pods

### Reset Environment

```bash
# Complete reset
./scripts/dev-down.sh
minikube delete
./scripts/dev-up.sh
```

## 🔄 Development Workflow

### Code Changes

1. **Build new image**:

   ```bash
   # Build and tag your service image
   docker build -t xploresg/user-service:dev-latest ./user-service

   # Load image into minikube
   minikube image load xploresg/user-service:dev-latest
   ```

2. **Update deployment**:
   ```bash
   kubectl rollout restart deployment/user-service -n xploresg-dev
   ```

### Database Changes

1. **Access database**:

   ```bash
   kubectl exec -it deployment/postgres -n xploresg-dev -- psql -U postgres -d xploresg_dev
   ```

2. **Run migrations** (application-specific)

### Configuration Changes

1. **Update ConfigMap**:

   ```bash
   kubectl create configmap app-config --from-env-file=config/.env -n xploresg-dev --dry-run=client -o yaml | kubectl apply -f -
   ```

2. **Restart deployments**:
   ```bash
   kubectl rollout restart deployment/user-service -n xploresg-dev
   ```

## � Monitoring & GitOps Features

### Monitoring Stack

- **Prometheus**: Collects metrics from Kubernetes and applications
- **Grafana**: Provides visualization dashboards and alerting
- **Pre-built Dashboards**: Kubernetes cluster overview, application metrics
- **Alerting**: Resource usage, pod health, service availability

### GitOps Platform

- **ArgoCD**: Manages application deployments from Git repositories
- **Automated Sync**: Continuous deployment from repository changes
- **Self-Healing**: Automatically corrects configuration drift
- **Multi-Application**: Manages frontend, backend, and database deployments

For detailed information, see: [Monitoring & GitOps Documentation](./docs/monitoring-gitops.md)

## �📈 Next Steps

This development environment is designed to prepare you for:

1. **Production Deployment**: Similar manifests can be adapted for production with proper secrets management
2. **CI/CD Integration**: Scripts can be integrated into GitHub Actions or similar CI/CD pipelines
3. **Advanced Monitoring**: Extend Prometheus metrics and Grafana dashboards for custom KPIs
4. **GitOps Workflow**: Implement full GitOps pipeline with ArgoCD for automated deployments
5. **Security Hardening**: Implement proper RBAC, network policies, and security contexts

## 🤝 Contributing

When adding new services:

1. Create manifest files in appropriate directories
2. Update `config/kustomization.yaml`
3. Add to deployment scripts
4. Update this README
5. Test the complete environment

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kustomize Documentation](https://kubectl.docs.kubernetes.io/references/kustomize/)

---

Happy developing with Kubernetes! 🎉
