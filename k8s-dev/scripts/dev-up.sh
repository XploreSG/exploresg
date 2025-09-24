#!/bin/bash

# XploreSG Kubernetes Development Environment Setup
# This script sets up minikube and deploys the XploreSG development environment

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

echo_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    echo_info "Checking prerequisites..."
    
    # Check if minikube is installed
    if ! command_exists minikube; then
        echo_error "minikube is not installed. Please install minikube first."
        echo "Visit: https://minikube.sigs.k8s.io/docs/start/"
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command_exists kubectl; then
        echo_error "kubectl is not installed. Please install kubectl first."
        echo "Visit: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    
    echo_success "Prerequisites check completed"
}

# Start minikube if not running
start_minikube() {
    echo_info "Checking minikube status..."
    
    if ! minikube status >/dev/null 2>&1; then
        echo_info "Starting minikube..."
        minikube start --driver=docker --cpus=4 --memory=4096
        echo_success "Minikube started successfully"
    else
        echo_success "Minikube is already running"
    fi
    
    # Enable ingress addon
    echo_info "Enabling ingress addon..."
    minikube addons enable ingress
    
    # Enable metrics server for resource monitoring
    echo_info "Enabling metrics-server addon..."
    minikube addons enable metrics-server
}

# Deploy Kubernetes manifests
deploy_manifests() {
    echo_info "Deploying Kubernetes manifests..."
    
    # Apply namespace first
    echo_info "Creating namespace..."
    kubectl apply -f manifests/namespace.yaml
    
    # Apply databases
    echo_info "Deploying databases..."
    kubectl apply -f manifests/databases/
    
    # Wait for databases to be ready
    echo_info "Waiting for PostgreSQL to be ready..."
    kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=postgres -n xploresg-dev --timeout=300s
    
    # Apply services
    echo_info "Deploying services..."
    kubectl apply -f manifests/services/
    
    # Wait for services to be ready
    echo_info "Waiting for services to be ready..."
    kubectl wait --for=condition=Ready pod -l app.kubernetes.io/component=backend -n xploresg-dev --timeout=300s
    kubectl wait --for=condition=Ready pod -l app.kubernetes.io/component=frontend -n xploresg-dev --timeout=300s
    
    # Apply ingress
    echo_info "Deploying ingress..."
    kubectl apply -f manifests/ingress/
    
    echo_success "All manifests deployed successfully"
}

# Get access information
get_access_info() {
    echo_info "Getting access information..."
    
    # Get minikube IP
    MINIKUBE_IP=$(minikube ip)
    echo_success "Minikube IP: $MINIKUBE_IP"
    
    # Get ingress URL
    echo_info "Application URLs:"
    echo "  Frontend: http://$MINIKUBE_IP (or add 'xploresg.local' to your hosts file)"
    echo "  API: http://$MINIKUBE_IP/api (or add 'api.xploresg.local' to your hosts file)"
    
    echo ""
    echo_info "To add hosts file entries (for subdomain routing):"
    echo "  Linux/Mac: sudo echo '$MINIKUBE_IP xploresg.local api.xploresg.local' >> /etc/hosts"
    echo "  Windows: Add '$MINIKUBE_IP xploresg.local api.xploresg.local' to C:\\Windows\\System32\\drivers\\etc\\hosts"
    
    echo ""
    echo_info "Useful commands:"
    echo "  View pods: kubectl get pods -n xploresg-dev"
    echo "  View services: kubectl get services -n xploresg-dev"
    echo "  View logs: kubectl logs -f deployment/user-service -n xploresg-dev"
    echo "  Dashboard: minikube dashboard"
}

# Main function
main() {
    echo_info "Starting XploreSG Kubernetes development environment setup..."
    echo ""
    
    check_prerequisites
    start_minikube
    deploy_manifests
    get_access_info
    
    echo ""
    echo_success "XploreSG development environment is ready!"
    echo_info "Happy coding! 🚀"
}

# Run main function
main "$@"