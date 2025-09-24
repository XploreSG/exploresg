#!/bin/bash

# XploreSG Kubernetes Development Environment Teardown
# This script cleans up the development environment

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

# Function to prompt for confirmation
confirm() {
    read -p "Are you sure you want to tear down the development environment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Teardown cancelled."
        exit 0
    fi
}

# Delete Kubernetes resources
teardown_manifests() {
    echo_info "Removing Kubernetes manifests..."
    
    # Delete in reverse order for clean teardown
    if kubectl get namespace xploresg-dev >/dev/null 2>&1; then
        # Delete ingress
        echo_info "Removing ingress..."
        kubectl delete -f manifests/ingress/ --ignore-not-found=true
        
        # Delete services
        echo_info "Removing services..."
        kubectl delete -f manifests/services/ --ignore-not-found=true
        
        # Delete databases
        echo_info "Removing databases..."
        kubectl delete -f manifests/databases/ --ignore-not-found=true
        
        # Delete namespace (this will remove everything else)
        echo_info "Removing namespace..."
        kubectl delete -f manifests/namespace.yaml --ignore-not-found=true
        
        echo_success "All Kubernetes resources removed"
    else
        echo_info "Namespace 'xploresg-dev' not found, nothing to remove"
    fi
}

# Stop minikube (optional)
stop_minikube() {
    echo_warning "Do you want to stop minikube as well? (y/N): "
    read -p "" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo_info "Stopping minikube..."
        minikube stop
        echo_success "Minikube stopped"
        
        echo_warning "Do you want to delete the minikube cluster entirely? (y/N): "
        read -p "" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo_info "Deleting minikube cluster..."
            minikube delete
            echo_success "Minikube cluster deleted"
        fi
    fi
}

# Clean up Docker images (optional)
cleanup_images() {
    echo_warning "Do you want to clean up Docker images? (y/N): "
    read -p "" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo_info "Cleaning up Docker images..."
        docker system prune -f
        echo_success "Docker images cleaned up"
    fi
}

# Main function
main() {
    echo_info "XploreSG Kubernetes development environment teardown"
    echo ""
    
    confirm
    
    teardown_manifests
    stop_minikube
    cleanup_images
    
    echo ""
    echo_success "Teardown completed successfully!"
    echo_info "To restart the environment, run: ./dev-up.sh"
}

# Run main function
main "$@"