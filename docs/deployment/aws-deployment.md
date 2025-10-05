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

### Technology Stack & Approach

| Category | Technology | Approach |
|----------|-----------|----------|
| **Infrastructure as Code** | Terraform | All AWS resources defined in .tf files |
| **Container Orchestration** | Amazon EKS | Kubernetes v1.29 |
| **Application Deployment** | kubectl + YAML manifests | Manual deployment, no GitOps |
| **CI/CD** | GitHub Actions (basic) | Build → ECR → Manual kubectl apply |
| **Configuration Management** | Terraform only | No Helm, CDK, or Pulumi |

### High-Level Design

| Component | Specification | Details |
|-----------|--------------|---------|
| **VPC** | 10.0.0.0/16 | Single VPC in ap-southeast-1 |
| **Availability Zones** | 2 AZs | ap-southeast-1a, ap-southeast-1b |
| **Web Tier** | Public Subnets | 10.0.100.0/24, 10.0.101.0/24 - ALB, NAT Gateways |
| **App Tier** | Private Subnets | 10.0.0.0/24, 10.0.1.0/24 - EKS Worker Nodes |
| **DB Tier** | Private Subnets | 10.0.200.0/24, 10.0.201.0/24 - RDS, ElastiCache |

### Microservices Architecture

| Service | Type | Database | Deployment |
|---------|------|----------|------------|
| **Frontend** | React/Next.js | None (static) | EKS pods in both AZs |
| **Auth Service** | Backend API | Auth PostgreSQL | EKS pods in both AZs |
| **Fleet Service** | Backend API | Fleet PostgreSQL | EKS pods in both AZs |

### Infrastructure Deployment Strategy

| Phase | Components | Method | Persistence |
|-------|-----------|--------|-------------|
| **Base (Always On)** | VPC, Subnets, Routes, ECR, S3 | Terraform apply once | Keep running (~$5/month) |
| **Demo (Daily)** | EKS, RDS, ElastiCache, NAT, ALB | Terraform apply/destroy daily | Spin up for 3-4 hrs (~$2-3/session) |
| **Application** | Pods, Services, Ingress | kubectl apply -f manifests/ | Deploy after infra is up |

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
│   ├── vpc/          ✅ Complete (needs DB tier update)
│   ├── eks/          ✅ Complete
│   ├── rds/          ⏳ To create
│   ├── elasticache/  ⏳ To create
│   └── monitoring/   ⏳ To create
└── environments/
    ├── dev/          ⏳ Future
    └── prod/         ✅ Active
```

### Terraform Modules Status

| Module | Status | Resources | Outputs |
|--------|--------|-----------|---------|
| **vpc** | ✅ Partially Complete | VPC, IGW, Public/Private subnets, NAT, Routes, SGs | vpc_id, public_subnet_ids, private_subnet_ids |
| **vpc** (DB tier) | ⏳ Needs Update | DB subnets, DB subnet group, VPC Endpoints | db_subnet_ids, db_subnet_group_name |
| **eks** | ✅ Complete | Cluster, Node Group, IAM roles | cluster_id, cluster_endpoint, node_group_id |
| **rds** | ⏳ To Build | RDS instances, SG, Parameter groups, Backups | auth_db_endpoint, fleet_db_endpoint |
| **elasticache** | ⏳ To Build | Redis cluster, Subnet group, SG | redis_endpoint, redis_port |
| **monitoring** | ⏳ To Build | CloudWatch Log Groups, Dashboards, Alarms, SNS | log_group_names, sns_topic_arn |

### Terraform Workflow

| Task | Command | When to Run | Cost Impact |
|------|---------|-------------|-------------|
| **Initialize** | `terraform init` | First time & after adding modules | Free |
| **Plan Changes** | `terraform plan` | Before every apply | Free |
| **Deploy Base Infra** | `terraform apply` | Once (VPC, Subnets, ECR) | ~$5/month (keep running) |
| **Deploy Demo Stack** | `terraform apply -target=module.eks -target=module.rds` | Daily for demos | ~$2-3/session |
| **Destroy Demo Stack** | `terraform destroy -target=module.elasticache -target=module.rds -target=module.eks` | After each demo | Stops hourly charges |
| **Validate** | `terraform validate` | Before commit | Free |
| **Format** | `terraform fmt -recursive` | Before commit | Free |

---

## AWS Deployment Checklist

### Deployment Phases (Terraform-Based Workflow)

| Phase | Priority | Tasks | Terraform Modules | Time | Cost Impact |
|-------|----------|-------|-------------------|------|-------------|
| **Phase 1: Foundation** | ✅ COMPLETE | VPC, EKS cluster, Nodes | vpc, eks | 2-3 hrs | ~$100/month base |
| **Phase 2: Enhanced VPC** | 🔄 NEXT | DB subnets, VPC Endpoints, SGs | vpc (update) | 1-2 hrs | +$10/month |
| **Phase 3: Database Layer** | ⏳ TODO | RDS Multi-AZ, ElastiCache | rds, elasticache | 2-3 hrs | +$80/month |
| **Phase 4: Load Balancer** | ⏳ TODO | ALB Controller, IRSA, ACM cert | kubernetes | 1 hr | +$20/month |
| **Phase 5: Observability** | ⏳ TODO | CloudWatch, SNS, Dashboards | monitoring | 1 hr | +$10/month |
| **Phase 6: Application** | ⏳ TODO | ECR, Dockerfiles, K8s manifests | N/A (manual) | 3-4 hrs | +$5/month |
| **Phase 7: Edge (Optional)** | ⏳ TODO | CloudFront, WAF | cdn, waf | 1-2 hrs | +$50/month |

### Phase 2: Enhanced VPC (Next Steps)

| Task | Method | Files to Update | Verification |
|------|--------|-----------------|--------------|
| Add DB subnets | Update `modules/vpc/main.tf` | Add `aws_subnet.database` resource | `terraform plan` shows 2 new subnets |
| Create DB subnet group | Add to `modules/vpc/main.tf` | Add `aws_db_subnet_group` | Output: `db_subnet_group_name` |
| Add VPC Endpoints | Add to `modules/vpc/main.tf` | S3 gateway, ECR interface endpoints | `aws ec2 describe-vpc-endpoints` |
| Update security groups | Modify `modules/vpc/main.tf` | Add SG for databases, cache | `terraform plan` shows new SGs |
| Update outputs | Modify `modules/vpc/outputs.tf` | Export DB subnet IDs | Check with `terraform output` |

### Phase 3: Database Layer

| Component | Terraform Resource | Configuration | Multi-AZ | Backup |
|-----------|-------------------|---------------|----------|--------|
| **Auth DB** | `aws_db_instance.auth` | PostgreSQL 16, db.t3.micro | ✅ Yes | 7 days |
| **Fleet DB** | `aws_db_instance.fleet` | PostgreSQL 16, db.t3.micro | ✅ Yes | 7 days |
| **Redis Cache** | `aws_elasticache_replication_group` | Redis 7.x, cache.t4g.micro | ✅ Yes | Snapshots |
| **DB Security Group** | `aws_security_group.database` | Port 5432 from EKS SG only | N/A | N/A |
| **Cache Security Group** | `aws_security_group.cache` | Port 6379 from EKS SG only | N/A | N/A |

### Phase 4: Load Balancer Setup

| Task | Method | Command/Config | Verification |
|------|--------|----------------|--------------|
| Install LB Controller | Helm chart | `helm install aws-load-balancer-controller` | `kubectl get pods -n kube-system` |
| Create IRSA | Terraform + kubectl | IAM policy + service account | `kubectl describe sa -n kube-system` |
| Request ACM cert | Terraform | `aws_acm_certificate` | Check in AWS Console |
| Create Ingress | K8s manifest | `ingress.yaml` with ALB annotations | `kubectl get ingress` |

### Phase 6: Application Deployment (kubectl Workflow)

| Step | Tool | Command | Output |
|------|------|---------|--------|
| **1. Build Images** | Docker | `docker build -t frontend:v1 .` | Local image |
| **2. Tag for ECR** | Docker | `docker tag frontend:v1 <account>.dkr.ecr.<region>.amazonaws.com/frontend:v1` | Tagged image |
| **3. Push to ECR** | Docker | `docker push <account>.dkr.ecr.<region>.amazonaws.com/frontend:v1` | Image in ECR |
| **4. Create Namespace** | kubectl | `kubectl create namespace exploresg-prod` | Namespace created |
| **5. Apply ConfigMaps** | kubectl | `kubectl apply -f configmap.yaml` | ConfigMap created |
| **6. Apply Secrets** | kubectl | `kubectl apply -f secrets.yaml` | Secret created |
| **7. Deploy Services** | kubectl | `kubectl apply -f deployment.yaml` | Pods running |
| **8. Create Services** | kubectl | `kubectl apply -f service.yaml` | Services created |
| **9. Create Ingress** | kubectl | `kubectl apply -f ingress.yaml` | ALB provisioned |
| **10. Verify** | kubectl | `kubectl get all -n exploresg-prod` | All resources up |

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

## Implementation Timeline

| Phase | Date Started | Date Completed | Status | Duration | Key Deliverables | Notes |
|-------|--------------|----------------|--------|----------|------------------|-------|
| **Phase 1: Foundation** | Oct 4, 2025 | Oct 4, 2025 | ✅ Complete | 3 hours | VPC (2-tier), EKS cluster, 2 worker nodes | Resolved node join issue with NAT Gateway |
| **Phase 2: Enhanced VPC** | Oct 5, 2025 | ___ | 🔄 In Progress | 1-2 hours | DB tier subnets, VPC Endpoints, 3-tier SGs | Adding DB subnets (10.0.200.x, 10.0.201.x) |
| **Phase 3: Database Layer** | ___ | ___ | ⏳ Pending | 2-3 hours | RDS Multi-AZ (auth, fleet), ElastiCache Redis | Reusable modules for future services |
| **Phase 4: Load Balancer** | ___ | ___ | ⏳ Pending | 1 hour | AWS LB Controller, IRSA, ACM cert | Helm-based controller installation |
| **Phase 5: Observability** | ___ | ___ | ⏳ Pending | 1 hour | Container Insights, CloudWatch, SNS alerts | Basic monitoring for demo |
| **Phase 6: Application** | ___ | ___ | ⏳ Pending | 3-4 hours | ECR repos, Docker images, K8s manifests | kubectl-based deployment |
| **Phase 7: Edge Services** | ___ | ___ | ⏳ Optional | 1-2 hours | CloudFront, WAF, Route53 | Skip if budget/time constrained |
| **Phase 8: Documentation** | ___ | ___ | ⏳ Pending | 1-2 hours | Architecture docs, cost analysis, DR plan | For capstone presentation |

**Total Estimated Time:** 10-15 hours  
**Total Estimated Cost:** ~$35-60 (1 week, 3-4 hrs/day)  
**Target Completion:** Oct 12, 2025

### Phase Transition Checklist

| From Phase | To Phase | Prerequisites | Validation Command |
|------------|----------|---------------|-------------------|
| Phase 1 → 2 | Foundation → Enhanced VPC | VPC and EKS operational | `terraform state list \| grep vpc` |
| Phase 2 → 3 | Enhanced VPC → Database | DB subnets created | `aws ec2 describe-subnets --filters "Name=tag:Tier,Values=database"` |
| Phase 3 → 4 | Database → Load Balancer | RDS endpoints available | `aws rds describe-db-instances` |
| Phase 4 → 5 | Load Balancer → Observability | ALB provisioned | `kubectl get ingress` |
| Phase 5 → 6 | Observability → Application | Monitoring configured | `aws cloudwatch list-dashboards` |
| Phase 6 → 7 | Application → Edge | Pods running | `kubectl get pods -n exploresg-prod` |
| Phase 7 → 8 | Edge → Documentation | All services accessible | Test application endpoint |

### Daily Operations Log

| Date | Action | Duration | Cost | Notes |
|------|--------|----------|------|-------|
| Oct 4, 2025 | Initial VPC + EKS setup | 3 hours | ~$8 | Fixed node join issue |
| Oct 5, 2025 | VPC enhancement work | TBD | TBD | Adding DB tier |
| ___ | ___ | ___ | ___ | ___ |
| ___ | ___ | ___ | ___ | ___ |

**Daily Workflow Template:**
```bash
# Morning: Spin up demo stack
terraform apply -target=module.eks -target=module.rds -target=module.elasticache

# Work/Demo: 3-4 hours

# Evening: Tear down
terraform destroy -target=module.elasticache -target=module.rds -target=module.eks

# Total daily cost: ~$2-3 for 4-hour session
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