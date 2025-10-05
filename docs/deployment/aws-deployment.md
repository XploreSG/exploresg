# ExploreSG AWS EKS Deployment Guide

**Project:** ExploreSG E-commerce Platform  
**Architecture Pattern:** AWS E-commerce Reference Architecture  
**Last Updated:** October 5, 2025  
**Owner:** Sree

---

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Infrastructure Checklist](#infrastructure-checklist)
3. [Terraform Setup Checklist](#terraform-setup-checklist)
4. [AWS Deployment Checklist](#aws-deployment-checklist)
5. [Troubleshooting Guide](#troubleshooting-guide)

---

## Architecture Overview

### High-Level Design
- **VPC:** 10.0.0.0/16
- **Availability Zones:** 2 (ap-southeast-1a, ap-southeast-1b)
- **Tier Architecture:**
  - Web Tier (Public Subnets) - ALB
  - App Tier (Private Subnets) - EKS Worker Nodes
  - DB Tier (Private Subnets) - RDS Instances

### Services Architecture
- **Frontend Service:** User-facing web application
- **Auth Service:** Authentication and authorization
- **Fleet Service:** Fleet management backend
- **Databases:** 
  - Auth DB (RDS)
  - Fleet DB (RDS)

---

## Infrastructure Checklist

### ✅ Completed Components

#### Network Infrastructure
- [x] VPC created (vpc-039426dee5531cdb8)
- [x] Internet Gateway attached (igw-005f62220de25e79a)
- [x] Public Subnets (2 AZs)
  - [x] subnet-0913ad40ab3b5f8d7 (AZ-A, 10.0.100.0/24)
  - [x] subnet-0999cd8dfae27770e (AZ-B, 10.0.101.0/24)
- [x] Private Subnets (2 AZs)
  - [x] subnet-099112b951c1cad0c (AZ-A, 10.0.0.0/24)
  - [x] subnet-0433a39fd26bdb1c3 (AZ-B, 10.0.1.0/24)
- [x] NAT Gateways (HA - one per AZ)
  - [x] nat-0b748a60da48e9c6e (AZ-A)
  - [x] nat-037ebf24fdc974f44 (AZ-B)
- [x] Route Tables configured
  - [x] Public route table with IGW route
  - [x] Private route tables with NAT routes
- [x] EKS subnet tags applied

#### Compute Infrastructure
- [x] EKS Cluster (exploresg-prod-cluster, v1.29)
- [x] Node Group (2 nodes, t3.small)
  - [x] ip-10-0-0-225 (Ready)
  - [x] ip-10-0-1-212 (Ready)
- [x] IAM Roles configured
  - [x] Cluster role with policies
  - [x] Node group role with policies

### ⏳ Pending Components

#### Database Tier
- [ ] RDS Subnet Groups
- [ ] Auth Database (PostgreSQL/MySQL)
- [ ] Fleet Database (PostgreSQL/MySQL)
- [ ] Database Security Groups
- [ ] Database backup configuration
- [ ] Database monitoring

#### Load Balancing
- [ ] AWS Load Balancer Controller installed
- [ ] Application Load Balancer
- [ ] Target Groups
- [ ] SSL/TLS Certificates (ACM)
- [ ] WAF (optional)

#### Application Deployment
- [ ] ECR Repositories created
- [ ] Docker images built and pushed
- [ ] Kubernetes Deployments
  - [ ] Frontend service
  - [ ] Auth service
  - [ ] Fleet service
- [ ] Kubernetes Services
- [ ] Ingress resources
- [ ] ConfigMaps
- [ ] Secrets (sealed-secrets or External Secrets)

#### DNS & Networking
- [ ] Route53 Hosted Zone
- [ ] DNS records for ALB
- [ ] External DNS (optional)

#### Security
- [ ] Security groups review
- [ ] Network policies
- [ ] Pod security policies/standards
- [ ] Secrets management
- [ ] IAM roles for service accounts (IRSA)

#### Observability
- [ ] CloudWatch Container Insights
- [ ] Application logging
- [ ] Metrics collection
- [ ] Alerting setup
- [ ] Dashboard creation

#### CI/CD
- [ ] Pipeline setup (GitHub Actions/GitLab CI)
- [ ] Build automation
- [ ] Deployment automation
- [ ] Rollback procedures

---

## Terraform Setup Checklist

### Directory Structure
```
infra/
├── modules/
│   ├── vpc/          ✅ Complete
│   ├── eks/          ✅ Complete
│   ├── rds/          ⏳ To create
│   └── alb/          ⏳ To create
└── environments/
    ├── dev/          ⏳ To setup
    └── prod/         ✅ Active
```

### Module: VPC ✅
- [x] VPC resource
- [x] Internet Gateway
- [x] Public subnets (2 AZs)
- [x] Private subnets (2 AZs)
- [x] NAT Gateways (HA)
- [x] Route tables
- [x] Security groups
- [x] EKS tags on subnets
- [x] Outputs defined

### Module: EKS ✅
- [x] Cluster IAM role
- [x] Node group IAM role
- [x] EKS cluster
- [x] Node group
- [x] Policy attachments
- [x] Outputs defined

### Module: RDS ⏳
- [ ] Create module structure
- [ ] Subnet group resource
- [ ] RDS instance resources
- [ ] Security group for DB
- [ ] Parameter groups
- [ ] Backup configuration
- [ ] Monitoring setup
- [ ] Outputs defined

### Module: ALB ⏳
- [ ] Create module structure
- [ ] Security group for ALB
- [ ] ALB resource
- [ ] Target groups
- [ ] Listeners (HTTP/HTTPS)
- [ ] Outputs defined

### Terraform State Management
- [x] Local state (current)
- [ ] Remote state (S3 + DynamoDB) - recommended for prod

---

## AWS Deployment Checklist

### Phase 1: Foundation (✅ Complete)
- [x] AWS Account setup
- [x] IAM credentials configured
- [x] VPC deployed
- [x] EKS cluster deployed
- [x] kubectl access configured
- [x] Nodes verified as Ready

### Phase 2: Database Layer (Next)
**Priority: HIGH**

#### Setup Tasks
- [ ] Create RDS Terraform module
- [ ] Define database subnet groups
- [ ] Create Auth DB instance
  - [ ] Engine: PostgreSQL/MySQL
  - [ ] Instance class: db.t3.micro (start small)
  - [ ] Multi-AZ: Yes (for HA)
  - [ ] Backup retention: 7 days
- [ ] Create Fleet DB instance
  - [ ] Same configuration as Auth DB
- [ ] Configure security groups
  - [ ] Allow port 5432/3306 from EKS nodes
  - [ ] No public access
- [ ] Create database secrets in Kubernetes
- [ ] Test connectivity from pods

**Estimated Time:** 2-3 hours  
**Dependencies:** VPC, Private subnets

### Phase 3: Load Balancer Setup (After Phase 2)
**Priority: HIGH**

#### Setup Tasks
- [ ] Install AWS Load Balancer Controller
  ```bash
  helm repo add eks https://aws.github.io/eks-charts
  helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=exploresg-prod-cluster
  ```
- [ ] Create IAM policy for LB controller
- [ ] Configure IRSA for LB controller
- [ ] Request ACM certificate
- [ ] Validate certificate
- [ ] Create Terraform module for ALB (optional)

**Estimated Time:** 1-2 hours  
**Dependencies:** EKS cluster

### Phase 4: Container Registry (After Phase 3)
**Priority: MEDIUM**

#### Setup Tasks
- [ ] Create ECR repositories
  - [ ] exploresg/frontend
  - [ ] exploresg/auth-service
  - [ ] exploresg/fleet-service
- [ ] Configure ECR lifecycle policies
- [ ] Setup ECR pull permissions
- [ ] Document image tagging strategy

**Estimated Time:** 30 minutes  
**Dependencies:** None

### Phase 5: Application Deployment (After Phase 4)
**Priority: HIGH**

#### Containerization
- [ ] Dockerfile for frontend service
- [ ] Dockerfile for auth service
- [ ] Dockerfile for fleet service
- [ ] Build and test images locally
- [ ] Push to ECR

#### Kubernetes Manifests
- [ ] Create namespace: `exploresg-prod`
- [ ] Frontend deployment & service
- [ ] Auth service deployment & service
- [ ] Fleet service deployment & service
- [ ] ConfigMaps for configuration
- [ ] Secrets for sensitive data
- [ ] Ingress resource with ALB annotations
- [ ] HPA (Horizontal Pod Autoscaler) - optional

**Estimated Time:** 4-6 hours  
**Dependencies:** ECR, RDS, ALB Controller

### Phase 6: DNS & Domain (After Phase 5)
**Priority: MEDIUM**

#### Setup Tasks
- [ ] Register domain (if needed)
- [ ] Create Route53 hosted zone
- [ ] Point domain to ALB
- [ ] Configure External DNS (optional)
- [ ] Test DNS resolution

**Estimated Time:** 1 hour  
**Dependencies:** ALB deployed

### Phase 7: Security Hardening (Ongoing)
**Priority: HIGH**

#### Tasks
- [ ] Review security groups (least privilege)
- [ ] Implement network policies
- [ ] Setup pod security standards
- [ ] Configure secrets encryption
- [ ] Enable audit logging
- [ ] Implement IRSA for all services
- [ ] Setup WAF rules (optional)

**Estimated Time:** 2-3 hours  
**Dependencies:** All services deployed

### Phase 8: Observability (After Phase 7)
**Priority: MEDIUM**

#### Tasks
- [ ] Enable Container Insights
- [ ] Configure log aggregation
- [ ] Setup CloudWatch dashboards
- [ ] Configure alerts
  - [ ] Node CPU/Memory
  - [ ] Pod restart count
  - [ ] Database connections
  - [ ] ALB 5xx errors
- [ ] Setup distributed tracing (optional)

**Estimated Time:** 2-3 hours  
**Dependencies:** Applications running

### Phase 9: CI/CD Pipeline (Final)
**Priority: MEDIUM**

#### Tasks
- [ ] Choose CI/CD platform
- [ ] Configure pipeline for each service
- [ ] Implement automated testing
- [ ] Setup deployment automation
- [ ] Configure rollback procedures
- [ ] Implement approval gates for prod

**Estimated Time:** 4-8 hours  
**Dependencies:** All infrastructure complete

---

## Troubleshooting Guide

### Issue: Nodes Failed to Join Cluster ✅ RESOLVED

**Symptom:** 
```
NodeCreationFailure: Instances failed to join the kubernetes cluster
```

**Root Cause:** No internet connectivity in private subnets

**Solution Applied:**
1. Created Internet Gateway
2. Created NAT Gateways in public subnets
3. Updated route tables to route 0.0.0.0/0 to NAT Gateway
4. Recreated node group

**Prevention:** Always ensure private subnets have NAT Gateway routes before deploying EKS

---

### Issue: Connection Timeout to AWS APIs ✅ RESOLVED

**Symptom:**
```
Connect timeout on endpoint URL: "https://ec2.ap-southeast-1.amazonaws.com/"
```

**Root Cause:** Same as above - no internet access

**Solution:** Same as above

---

### Common Issues (Future Reference)

#### Pods in ImagePullBackOff
- **Check:** ECR permissions on node role
- **Check:** Image name/tag is correct
- **Solution:** Ensure AmazonEC2ContainerRegistryReadOnly policy attached

#### ALB Not Creating
- **Check:** AWS LB Controller is running
- **Check:** Subnets have correct tags
- **Check:** IRSA configured correctly
- **Solution:** Review controller logs: `kubectl logs -n kube-system deployment/aws-load-balancer-controller`

#### Database Connection Failures
- **Check:** Security group rules
- **Check:** Database endpoint is correct
- **Check:** Secrets are properly mounted
- **Solution:** Test connectivity using a debug pod

---

## Next Steps

### Updated Implementation Plan

**Strategy:** Build modular Terraform for daily spin-up/down to minimize costs

#### Phase A: Enhanced VPC (1-2 hours)
- [ ] Add DB tier subnets (10.0.200.x, 10.0.201.x)
- [ ] Create DB subnet group for RDS
- [ ] Add VPC Endpoints (S3 Gateway, ECR Interface)
- [ ] Update security groups for 3-tier isolation
- [ ] Update outputs with DB subnet IDs

#### Phase B: Database Layer (1-2 hours)
- [ ] Create reusable RDS module
  - [ ] Support Multi-AZ configuration
  - [ ] PostgreSQL 16
  - [ ] Automated backups (7 days)
  - [ ] Security group (port 5432 from EKS only)
- [ ] Deploy Auth DB (db.t3.micro Multi-AZ)
- [ ] Deploy Fleet DB (db.t3.micro Multi-AZ)
- [ ] Create ElastiCache Redis module
- [ ] Deploy Redis cluster (cache.t4g.micro)

#### Phase C: Load Balancer & Ingress (1 hour)
- [ ] Install AWS Load Balancer Controller (Helm)
- [ ] Create IAM policy and IRSA for controller
- [ ] Request ACM certificate for domain
- [ ] Document ALB ingress annotations

#### Phase D: Additional Services (2-3 hours)
- [ ] CloudFront distribution (optional - can skip to save cost)
- [ ] WAF with basic OWASP rules (optional)
- [ ] Route53 hosted zone and records
- [ ] VPC Flow Logs to S3

#### Phase E: Observability (1 hour)
- [ ] Enable Container Insights
- [ ] CloudWatch Log Groups for each service
- [ ] Basic CloudWatch alarms (CPU, memory, 5xx errors)
- [ ] SNS topic for alerts

#### Phase F: Application Deployment (2-4 hours)
- [ ] Create ECR repositories (frontend, auth, fleet)
- [ ] Build and push Docker images
- [ ] Create Kubernetes manifests:
  - [ ] Deployments (with resource limits)
  - [ ] Services (ClusterIP for internal, LoadBalancer via Ingress for external)
  - [ ] Ingress with ALB annotations
  - [ ] ConfigMaps and Secrets
- [ ] Deploy to cluster
- [ ] Verify connectivity

#### Phase G: Documentation (1-2 hours)
- [ ] Architecture diagram (current Mermaid)
- [ ] Security architecture documentation
- [ ] Cost breakdown and optimization strategies
- [ ] DR and failover procedures (theoretical)
- [ ] Future enhancements (ArgoCD, Service Mesh, etc.)

### Total Estimated Time: 10-15 hours
### Total Estimated Cost (1 week, 3-4 hrs/day): ~$35-60

### Daily Workflow
```bash
# Morning: Spin up demo components
cd infra/environments/prod
terraform apply -target=module.eks -target=module.rds -target=module.elasticache

# Demo/Development (3-4 hours)

# Evening: Tear down expensive components
terraform destroy -target=module.elasticache -target=module.rds -target=module.eks

# Keep running (minimal cost): VPC, subnets, route tables, ECR repos
```

---

## Useful Commands

### Terraform
```bash
# Initialize
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy
```

### Kubernetes
```bash
# Get nodes
kubectl get nodes

# Get all resources
kubectl get all -n exploresg-prod

# Describe pod
kubectl describe pod <pod-name> -n exploresg-prod

# View logs
kubectl logs <pod-name> -n exploresg-prod

# Port forward for testing
kubectl port-forward svc/<service-name> 8080:80 -n exploresg-prod
```

### AWS CLI
```bash
# Update kubeconfig
aws eks update-kubeconfig --name exploresg-prod-cluster --region ap-southeast-1

# Get cluster info
aws eks describe-cluster --name exploresg-prod-cluster

# List ECR repos
aws ecr describe-repositories
```

---

## Resources & References

- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)

---

**Document Status:** Living Document - Update as infrastructure evolves