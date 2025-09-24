#!/bin/bash

# ArgoCD Deployment Script for XploreSG K8s Development Environment
# This script deploys ArgoCD for GitOps in the local Kubernetes cluster

set -e

# Configuration
NAMESPACE="argocd"
KUBECTL_CONTEXT=${KUBECTL_CONTEXT:-"minikube"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
MANIFESTS_DIR="${SCRIPT_DIR}/../manifests/gitops"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed or not in PATH"
        exit 1
    fi
}

# Function to check if cluster is accessible
check_cluster() {
    log_info "Checking cluster connectivity..."
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        log_info "Please ensure your cluster is running and kubectl is configured correctly"
        exit 1
    fi
    
    local current_context=$(kubectl config current-context)
    log_success "Connected to cluster (context: ${current_context})"
}

# Function to create namespace if it doesn't exist
create_namespace() {
    log_info "Creating namespace ${NAMESPACE}..."
    if kubectl get namespace "${NAMESPACE}" &> /dev/null; then
        log_warning "Namespace ${NAMESPACE} already exists"
    else
        kubectl create namespace "${NAMESPACE}"
        log_success "Namespace ${NAMESPACE} created"
    fi
}

# Function to apply ArgoCD manifests
deploy_argocd() {
    log_info "Deploying ArgoCD components..."
    
    # Apply manifests in order
    local manifests=(
        "00-namespace.yaml"
        "01-argocd-rbac.yaml"
        "02-argocd-deployments.yaml"
        "03-argocd-services.yaml"
        "04-argocd-config.yaml"
    )
    
    for manifest in "${manifests[@]}"; do
        local file_path="${MANIFESTS_DIR}/${manifest}"
        if [[ -f "${file_path}" ]]; then
            log_info "Applying ${manifest}..."
            kubectl apply -f "${file_path}"
        else
            log_warning "Manifest ${manifest} not found, skipping..."
        fi
    done
    
    log_success "ArgoCD components deployed"
}

# Function to wait for ArgoCD to be ready
wait_for_argocd() {
    log_info "Waiting for ArgoCD components to be ready..."
    
    # Wait for deployments to be ready
    local deployments=(
        "argocd-application-controller"
        "argocd-repo-server"
        "argocd-server"
        "argocd-redis"
    )
    
    for deployment in "${deployments[@]}"; do
        log_info "Waiting for ${deployment} to be ready..."
        kubectl wait --for=condition=available --timeout=300s deployment/${deployment} -n ${NAMESPACE}
    done
    
    log_success "All ArgoCD components are ready"
}

# Function to get ArgoCD admin password
get_admin_password() {
    log_info "Retrieving ArgoCD admin password..."
    
    # Wait a bit for the secret to be created
    sleep 10
    
    local password
    password=$(kubectl -n ${NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d 2>/dev/null || echo "")
    
    if [[ -z "${password}" ]]; then
        log_warning "Admin password secret not found. ArgoCD might still be initializing."
        log_info "You can retrieve it later with:"
        echo "  kubectl -n ${NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
    else
        log_success "ArgoCD admin password: ${password}"
    fi
}

# Function to setup port forwarding
setup_port_forward() {
    log_info "Setting up port forwarding for ArgoCD UI..."
    
    # Check if port is already in use
    if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_warning "Port 8080 is already in use. Please stop the existing process or use a different port."
        return 1
    fi
    
    # Start port forwarding in background
    kubectl port-forward svc/argocd-server -n ${NAMESPACE} 8080:443 &
    local port_forward_pid=$!
    
    # Save PID for cleanup
    echo ${port_forward_pid} > /tmp/argocd-port-forward.pid
    
    log_success "Port forwarding started (PID: ${port_forward_pid})"
    log_info "ArgoCD UI will be available at: https://localhost:8080"
    log_warning "Note: You may need to accept the self-signed certificate in your browser"
}

# Function to deploy ArgoCD applications
deploy_applications() {
    log_info "Deploying ArgoCD applications..."
    
    local app_manifest="${MANIFESTS_DIR}/05-argocd-applications.yaml"
    if [[ -f "${app_manifest}" ]]; then
        # Wait a bit for ArgoCD to be fully ready
        sleep 30
        
        log_info "Applying ArgoCD applications manifest..."
        kubectl apply -f "${app_manifest}"
        log_success "ArgoCD applications deployed"
    else
        log_warning "ArgoCD applications manifest not found, skipping..."
    fi
}

# Function to display access information
display_access_info() {
    echo ""
    echo "================================================="
    echo "         ArgoCD Deployment Complete!"
    echo "================================================="
    echo ""
    echo "Access Information:"
    echo "  • ArgoCD UI: https://localhost:8080"
    echo "  • Username: admin"
    echo "  • Password: Use the command below to retrieve"
    echo ""
    echo "Retrieve admin password:"
    echo "  kubectl -n ${NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d && echo"
    echo ""
    echo "Stop port forwarding:"
    echo "  kill \$(cat /tmp/argocd-port-forward.pid)"
    echo ""
    echo "Useful commands:"
    echo "  • Check ArgoCD status: kubectl get pods -n ${NAMESPACE}"
    echo "  • View ArgoCD logs: kubectl logs -n ${NAMESPACE} deployment/argocd-server"
    echo "  • Access ArgoCD CLI: kubectl exec -it -n ${NAMESPACE} deployment/argocd-server -- argocd version"
    echo ""
}

# Function to cleanup on exit
cleanup() {
    local exit_code=$?
    if [[ ${exit_code} -ne 0 ]]; then
        log_error "Deployment failed with exit code ${exit_code}"
        
        # Kill port forwarding if it was started
        if [[ -f /tmp/argocd-port-forward.pid ]]; then
            local pid=$(cat /tmp/argocd-port-forward.pid)
            kill ${pid} 2>/dev/null || true
            rm -f /tmp/argocd-port-forward.pid
        fi
    fi
}

# Main deployment function
main() {
    log_info "Starting ArgoCD deployment for XploreSG..."
    
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Pre-flight checks
    check_kubectl
    check_cluster
    
    # Deploy ArgoCD
    create_namespace
    deploy_argocd
    wait_for_argocd
    
    # Post-deployment setup
    get_admin_password
    setup_port_forward
    deploy_applications
    
    # Display access information
    display_access_info
    
    log_success "ArgoCD deployment completed successfully!"
}

# Parse command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Deploy ArgoCD for XploreSG K8s development environment"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --cleanup      Remove ArgoCD deployment"
        echo ""
        echo "Environment Variables:"
        echo "  KUBECTL_CONTEXT  Kubernetes context to use (default: current context)"
        echo ""
        exit 0
        ;;
    --cleanup)
        log_info "Cleaning up ArgoCD deployment..."
        
        # Stop port forwarding
        if [[ -f /tmp/argocd-port-forward.pid ]]; then
            local pid=$(cat /tmp/argocd-port-forward.pid)
            kill ${pid} 2>/dev/null || true
            rm -f /tmp/argocd-port-forward.pid
            log_info "Port forwarding stopped"
        fi
        
        # Delete ArgoCD resources
        kubectl delete namespace ${NAMESPACE} --ignore-not-found=true
        log_success "ArgoCD cleanup completed"
        exit 0
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