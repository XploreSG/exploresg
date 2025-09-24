# Monitoring and GitOps Stack

This directory contains the complete monitoring and GitOps infrastructure for the XploreSG Kubernetes development environment.

## 📊 Architecture Overview

### Monitoring Stack

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **Integration**: Pre-configured dashboards for Kubernetes and XploreSG metrics

### GitOps Stack

- **ArgoCD**: Continuous deployment and application lifecycle management
- **Git-based**: Declarative application management
- **Automated**: Self-healing and automated synchronization

## 🚀 Quick Start

### Deploy Complete Stack

```bash
# Deploy everything (apps + monitoring + GitOps)
./scripts/deploy-all.sh

# Or on Windows
deploy-all.bat
```

### Deploy Individual Components

```bash
# Applications only
./scripts/deploy-all.sh --apps-only

# Monitoring stack only
./scripts/deploy-all.sh --monitoring-only

# GitOps platform only
./scripts/deploy-all.sh --gitops-only
```

## 📁 Directory Structure

```
k8s-dev/
├── manifests/
│   ├── monitoring/           # Prometheus & Grafana
│   │   ├── 00-namespace.yaml
│   │   ├── 01-prometheus-config.yaml
│   │   ├── 02-prometheus.yaml
│   │   ├── 03-grafana-config.yaml
│   │   └── 04-grafana.yaml
│   └── gitops/              # ArgoCD
│       ├── 00-namespace.yaml
│       ├── 01-argocd-rbac.yaml
│       ├── 02-argocd-deployments.yaml
│       ├── 03-argocd-services.yaml
│       ├── 04-argocd-config.yaml
│       └── 05-argocd-applications.yaml
└── scripts/
    ├── deploy-all.sh        # Master deployment (Linux/macOS)
    ├── deploy-all.bat       # Master deployment (Windows)
    ├── deploy-argocd.sh     # ArgoCD deployment (Linux/macOS)
    └── deploy-argocd.bat    # ArgoCD deployment (Windows)
```

## 🔧 Configuration

### Prometheus Configuration

- **Scrape Interval**: 15 seconds
- **Targets**: Kubernetes components, XploreSG services
- **Alerting**: Basic alerting rules included
- **Storage**: 10Gi persistent volume
- **Retention**: 30 days

### Grafana Configuration

- **Default Credentials**: admin/admin
- **Datasources**: Prometheus (auto-configured)
- **Dashboards**: Kubernetes cluster metrics, XploreSG application metrics
- **Storage**: 5Gi persistent volume

### ArgoCD Configuration

- **Access**: NodePort service (30443/30444)
- **Authentication**: Local admin user
- **Repositories**: GitHub repositories support
- **Projects**: XploreSG project with RBAC
- **Applications**: Frontend, Backend, Database auto-configured

## 🌐 Access URLs

After deployment, access the services:

### Applications

- **Frontend**: `http://localhost:30080` (if deployed)
- **Backend**: `http://localhost:30090` (if deployed)

### Monitoring

- **Grafana**: `http://localhost:30300`
  - Username: `admin`
  - Password: `admin`
- **Prometheus**: `http://localhost:30900`

### GitOps

- **ArgoCD UI**: `https://localhost:8080` (via port-forward)
  - Username: `admin`
  - Password: Retrieve with command below

## 🔑 Credentials and Access

### Grafana

```bash
Username: admin
Password: admin
```

### ArgoCD

```bash
# Username
admin

# Get password (Linux/macOS)
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Get password (Windows PowerShell)
$password = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($password))
```

## 📈 Monitoring Features

### Prometheus Metrics

- **Kubernetes Metrics**: Cluster, nodes, pods, services
- **Application Metrics**: Custom XploreSG metrics (if instrumented)
- **System Metrics**: CPU, memory, disk, network
- **Alerting**: Resource utilization, pod restarts, service availability

### Grafana Dashboards

1. **Kubernetes Cluster Overview**

   - Node status and resources
   - Pod distribution and health
   - Service availability

2. **XploreSG Application Metrics**

   - Request rates and response times
   - Error rates and success metrics
   - Business-specific KPIs

3. **Infrastructure Monitoring**
   - Resource utilization trends
   - Capacity planning metrics
   - Performance bottlenecks

### Alert Rules

- High CPU usage (>80%)
- High memory usage (>85%)
- Pod restart frequency
- Service endpoint availability
- Persistent volume usage (>90%)

## 🔄 GitOps Workflow

### Application Management

1. **Git Repository**: Source of truth for application definitions
2. **ArgoCD**: Monitors repository for changes
3. **Automatic Sync**: Deploys changes automatically
4. **Self-Healing**: Corrects drift from desired state

### Deployment Process

```
Git Commit → ArgoCD Detection → Kubernetes Deployment
     ↓              ↓                    ↓
Repository → Sync Status → Running Application
```

### ArgoCD Applications

- **exploresg-frontend**: Frontend application
- **exploresg-backend**: Backend services
- **exploresg-database**: Database components
- **exploresg-platform**: Infrastructure components

## 🛠️ Management Commands

### Check Status

```bash
# All deployments
kubectl get pods --all-namespaces

# Monitoring stack
kubectl get pods -n monitoring

# ArgoCD stack
kubectl get pods -n argocd

# Applications
kubectl get pods -n exploresg
```

### View Logs

```bash
# Prometheus logs
kubectl logs -f deployment/prometheus -n monitoring

# Grafana logs
kubectl logs -f deployment/grafana -n monitoring

# ArgoCD server logs
kubectl logs -f deployment/argocd-server -n argocd
```

### Port Forwarding

```bash
# Grafana (if NodePort not accessible)
kubectl port-forward svc/grafana 3000:3000 -n monitoring

# Prometheus (if NodePort not accessible)
kubectl port-forward svc/prometheus 9090:9090 -n monitoring

# ArgoCD (automatic via deployment script)
kubectl port-forward svc/argocd-server 8080:443 -n argocd
```

## 🔧 Troubleshooting

### Common Issues

#### Prometheus Not Scraping Metrics

```bash
# Check Prometheus configuration
kubectl get configmap prometheus-config -n monitoring -o yaml

# Check Prometheus targets
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
# Open http://localhost:9090/targets
```

#### Grafana Dashboards Not Loading

```bash
# Check Grafana logs
kubectl logs deployment/grafana -n monitoring

# Verify datasource configuration
kubectl get configmap grafana-datasources -n monitoring -o yaml
```

#### ArgoCD Applications Not Syncing

```bash
# Check ArgoCD application status
kubectl get applications -n argocd

# View application details
kubectl describe application exploresg-frontend -n argocd

# Check ArgoCD server logs
kubectl logs deployment/argocd-server -n argocd
```

#### Persistent Volumes Issues

```bash
# Check PV status
kubectl get pv

# Check PVC status
kubectl get pvc -n monitoring
kubectl get pvc -n argocd
```

### Recovery Procedures

#### Reset Grafana Admin Password

```bash
# Delete Grafana pod to reset
kubectl delete pod -l app=grafana -n monitoring
```

#### Reset ArgoCD Admin Password

```bash
# Delete ArgoCD admin secret
kubectl delete secret argocd-initial-admin-secret -n argocd

# Restart ArgoCD server
kubectl rollout restart deployment/argocd-server -n argocd
```

#### Clean Restart Monitoring Stack

```bash
# Delete and recreate monitoring namespace
kubectl delete namespace monitoring
./scripts/deploy-all.sh --monitoring-only
```

## 📚 Additional Resources

### Prometheus

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Kubernetes Monitoring Guide](https://prometheus.io/docs/guides/kubernetes/)
- [PromQL Query Language](https://prometheus.io/docs/prometheus/latest/querying/basics/)

### Grafana

- [Grafana Documentation](https://grafana.com/docs/)
- [Dashboard Best Practices](https://grafana.com/docs/grafana/latest/best-practices/)
- [Kubernetes Dashboards](https://grafana.com/grafana/dashboards/?search=kubernetes)

### ArgoCD

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Patterns](https://argoproj.github.io/argo-cd/user-guide/best_practices/)
- [Application Configuration](https://argo-cd.readthedocs.io/en/stable/user-guide/application_sources/)

## 🤝 Contributing

When adding new monitoring metrics or GitOps applications:

1. **Metrics**: Add Prometheus scrape configurations to `01-prometheus-config.yaml`
2. **Dashboards**: Create JSON dashboard files in Grafana config
3. **Applications**: Add new ArgoCD application definitions to `05-argocd-applications.yaml`
4. **Documentation**: Update this README with new features

## 📝 License

This monitoring and GitOps configuration is part of the XploreSG project and follows the same license terms.
