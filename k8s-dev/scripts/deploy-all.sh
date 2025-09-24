#!/bin/bash

# Master Deployment Script for XploreSG K8s Development Environment
# This script deploys the complete stack: Apps + Monitoring + GitOps

set -e

# Configuration
KUBECTL_CONTEXT=${KUBECTL_CONTEXT:-"minikube"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Function to print banner
print_banner() {
    echo -e "${CYAN}"
    echo "======================================================="
    echo "    XploreSG Kubernetes Development Environment"
    echo "======================================================="
    echo "  Complete Stack Deployment:"
    echo "  • Application Services (Frontend, Backend, Database)"
    echo "  • Monitoring Stack (Prometheus, Grafana)"
    echo "  • GitOps Platform (ArgoCD)"
    echo "======================================================="
    echo -e "${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Check cluster connectivity
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        log_info "Please ensure your cluster is running and kubectl is configured correctly"
        exit 1
    fi
    
    local current_context=$(kubectl config current-context)
    log_success "Prerequisites check passed (context: ${current_context})"
}

# Function to deploy applications
deploy_applications() {
    log_step "Deploying XploreSG applications..."
    
    if [[ -x "${SCRIPTS_DIR}/dev-up.sh" ]]; then
        "${SCRIPTS_DIR}/dev-up.sh"
        if [[ $? -eq 0 ]]; then
            log_success "Applications deployed successfully"
        else
            log_error "Failed to deploy applications"
            return 1
        fi
    else
        log_error "Application deployment script not found or not executable"
        return 1
    fi
}

# Function to deploy monitoring stack
deploy_monitoring() {
    log_step "Deploying monitoring stack (Prometheus & Grafana)..."
    
    if [[ -x "${SCRIPTS_DIR}/deploy-monitoring.sh" ]]; then
        "${SCRIPTS_DIR}/deploy-monitoring.sh"
        if [[ $? -eq 0 ]]; then
            log_success "Monitoring stack deployed successfully"
        else
            log_error "Failed to deploy monitoring stack"
            return 1
        fi
    else
        log_warning "Monitoring deployment script not found, skipping..."
        log_info "You can deploy monitoring later using: ./deploy-monitoring.sh"
    fi
}

# Function to deploy ArgoCD GitOps
deploy_gitops() {
    log_step "Deploying GitOps platform (ArgoCD)..."
    
    if [[ -x "${SCRIPTS_DIR}/deploy-argocd.sh" ]]; then
        "${SCRIPTS_DIR}/deploy-argocd.sh"
        if [[ $? -eq 0 ]]; then
            log_success "ArgoCD deployed successfully"
        else
            log_error "Failed to deploy ArgoCD"
            return 1
        fi
    else
        log_warning "ArgoCD deployment script not found, skipping..."
        log_info "You can deploy ArgoCD later using: ./deploy-argocd.sh"
    fi
}

# Function to display final status
display_final_status() {
    echo ""
    echo -e "${CYAN}=======================================================${NC}"
    echo -e "${GREEN}    XploreSG K8s Environment Deployment Complete!${NC}"
    echo -e "${CYAN}=======================================================${NC}"
    echo ""
    
    log_info "Checking deployment status..."
    
    # Check application pods
    echo -e "${BLUE}Application Services:${NC}"
    kubectl get pods -n exploresg --no-headers 2>/dev/null | while read line; do
        echo "  • $line"
    done || echo "  • No application pods found"
    
    # Check monitoring pods
    echo -e "${BLUE}Monitoring Stack:${NC}"
    kubectl get pods -n monitoring --no-headers 2>/dev/null | while read line; do
        echo "  • $line"
    done || echo "  • No monitoring pods found"
    
    # Check ArgoCD pods
    echo -e "${BLUE}GitOps Platform:${NC}"
    kubectl get pods -n argocd --no-headers 2>/dev/null | while read line; do
        echo "  • $line"
    done || echo "  • No ArgoCD pods found"
    
    echo ""
    echo -e "${YELLOW}Access Information:${NC}"
    
    # Application access
    local frontend_port=$(kubectl get svc exploresg-frontend-service -n exploresg -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "N/A")
    if [[ "${frontend_port}" != "N/A" ]]; then
        echo "  • XploreSG Frontend: http://localhost:${frontend_port}"
    fi
    
    local backend_port=$(kubectl get svc exploresg-backend-service -n exploresg -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "N/A")
    if [[ "${backend_port}" != "N/A" ]]; then
        echo "  • XploreSG Backend: http://localhost:${backend_port}"
    fi
    
    # Monitoring access
    local grafana_port=$(kubectl get svc grafana -n monitoring -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "N/A")
    if [[ "${grafana_port}" != "N/A" ]]; then
        echo "  • Grafana Dashboard: http://localhost:${grafana_port}"
        echo "    - Username: admin, Password: admin"
    fi
    
    local prometheus_port=$(kubectl get svc prometheus -n monitoring -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "N/A")
    if [[ "${prometheus_port}" != "N/A" ]]; then
        echo "  • Prometheus: http://localhost:${prometheus_port}"
    fi
    
    # ArgoCD access
    echo "  • ArgoCD UI: https://localhost:8080 (via port-forward)"
    echo "    - Username: admin"
    echo "    - Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
    
    echo ""
    echo -e "${YELLOW}Useful Commands:${NC}"
    echo "  • Check all pods: kubectl get pods --all-namespaces"
    echo "  • View logs: kubectl logs -f deployment/<deployment-name> -n <namespace>"
    echo "  • Access services: kubectl get services --all-namespaces"
    echo "  • Stop environment: ./dev-down.sh"
    echo "  • Check status: ./dev-status.sh"
    echo ""
}

# Function to handle cleanup on failure
cleanup_on_failure() {
    local exit_code=$?
    if [[ ${exit_code} -ne 0 ]]; then
        log_error "Deployment failed with exit code ${exit_code}"
        echo ""
        log_info "You can check the status with: kubectl get pods --all-namespaces"
        log_info "To clean up, run: ./dev-down.sh"
    fi
}

# Main deployment function
main() {
    print_banner
    
    # Set up cleanup trap
    trap cleanup_on_failure EXIT
    
    # Run deployment steps
    check_prerequisites
    
    # Deploy core applications first
    deploy_applications || exit 1
    
    # Wait a bit for applications to stabilize
    sleep 10
    
    # Deploy monitoring stack
    deploy_monitoring
    
    # Wait a bit for monitoring to stabilize
    sleep 10
    
    # Deploy GitOps platform
    deploy_gitops
    
    # Display final status
    display_final_status
    
    log_success "Complete stack deployment finished successfully!"
}

# Parse command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Deploy complete XploreSG K8s development environment"
        echo ""
        echo "Options:"
        echo "  --help, -h        Show this help message"
        echo "  --apps-only       Deploy only applications (skip monitoring & GitOps)"
        echo "  --monitoring-only Deploy only monitoring stack"
        echo "  --gitops-only     Deploy only ArgoCD GitOps"
        echo "  --status          Show deployment status"
        echo ""
        echo "Environment Variables:"
        echo "  KUBECTL_CONTEXT   Kubernetes context to use (default: current context)"
        echo ""
        exit 0
        ;;
    --apps-only)
        print_banner
        check_prerequisites
        deploy_applications
        log_success "Applications deployment completed!"
        ;;
    --monitoring-only)
        print_banner
        check_prerequisites
        deploy_monitoring
        log_success "Monitoring deployment completed!"
        ;;
    --gitops-only)
        print_banner
        check_prerequisites
        deploy_gitops
        log_success "GitOps deployment completed!"
        ;;
    --status)
        display_final_status
        ;;
    "")
        main
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac