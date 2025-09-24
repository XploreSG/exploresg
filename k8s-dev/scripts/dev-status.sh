#!/bin/bash

# XploreSG Development Status Checker
# Shows the current status of all Kubernetes resources

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

# Check minikube status
check_minikube() {
    echo_info "Checking minikube status..."
    
    if ! command_exists minikube; then
        echo_error "minikube is not installed"
        return 1
    fi
    
    if minikube status >/dev/null 2>&1; then
        echo_success "Minikube is running"
        MINIKUBE_IP=$(minikube ip)
        echo "  IP: $MINIKUBE_IP"
    else
        echo_error "Minikube is not running"
        return 1
    fi
}

# Check namespace status
check_namespace() {
    echo_info "Checking namespace status..."
    
    if kubectl get namespace xploresg-dev >/dev/null 2>&1; then
        echo_success "Namespace 'xploresg-dev' exists"
    else
        echo_error "Namespace 'xploresg-dev' not found"
        return 1
    fi
}

# Check pods status
check_pods() {
    echo_info "Checking pods status..."
    echo ""
    
    # Get pods in a formatted table
    kubectl get pods -n xploresg-dev -o wide 2>/dev/null || {
        echo_warning "No pods found in namespace 'xploresg-dev'"
        return 0
    }
    
    echo ""
    
    # Check for non-ready pods
    NOT_READY=$(kubectl get pods -n xploresg-dev --no-headers 2>/dev/null | awk '$2 != "1/1" && $3 != "Completed" {print $1}' || true)
    if [ -n "$NOT_READY" ]; then
        echo_warning "Pods not ready:"
        echo "$NOT_READY"
    else
        echo_success "All pods are ready"
    fi
}

# Check services status
check_services() {
    echo_info "Checking services status..."
    echo ""
    
    kubectl get services -n xploresg-dev 2>/dev/null || {
        echo_warning "No services found in namespace 'xploresg-dev'"
        return 0
    }
}

# Check ingress status
check_ingress() {
    echo_info "Checking ingress status..."
    echo ""
    
    kubectl get ingress -n xploresg-dev 2>/dev/null || {
        echo_warning "No ingress found in namespace 'xploresg-dev'"
        return 0
    }
}

# Check persistent volumes
check_volumes() {
    echo_info "Checking persistent volumes..."
    echo ""
    
    kubectl get pvc -n xploresg-dev 2>/dev/null || {
        echo_warning "No persistent volume claims found"
        return 0
    }
}

# Show resource usage
show_resource_usage() {
    echo_info "Resource usage (if metrics-server is enabled)..."
    echo ""
    
    kubectl top pods -n xploresg-dev 2>/dev/null || {
        echo_warning "Metrics not available (metrics-server may not be enabled)"
        echo "Enable with: minikube addons enable metrics-server"
        return 0
    }
}

# Show access URLs
show_access_urls() {
    if [ -n "$MINIKUBE_IP" ]; then
        echo_info "Access URLs:"
        echo "  Frontend: http://$MINIKUBE_IP"
        echo "  API: http://$MINIKUBE_IP/api"
        echo "  With hosts file entries:"
        echo "    Frontend: http://xploresg.local"
        echo "    API: http://api.xploresg.local"
        echo ""
        echo_info "Dashboard: minikube dashboard"
    fi
}

# Show helpful commands
show_helpful_commands() {
    echo_info "Helpful commands:"
    echo "  Restart environment: ./dev-up.sh"
    echo "  Stop environment: ./dev-down.sh"
    echo "  View logs: kubectl logs -f deployment/<service-name> -n xploresg-dev"
    echo "  Port forward: kubectl port-forward service/<service-name> <local-port>:<service-port> -n xploresg-dev"
    echo "  Shell into pod: kubectl exec -it deployment/<service-name> -n xploresg-dev -- /bin/bash"
    echo "  Watch pods: kubectl get pods -n xploresg-dev -w"
}

# Main function
main() {
    echo_info "XploreSG Development Environment Status"
    echo "========================================"
    echo ""
    
    if check_minikube && check_namespace; then
        check_pods
        echo ""
        check_services
        echo ""
        check_ingress
        echo ""
        check_volumes
        echo ""
        show_resource_usage
        echo ""
        show_access_urls
    else
        echo_error "Environment is not properly set up"
        echo_info "Run './dev-up.sh' to start the development environment"
    fi
    
    echo ""
    show_helpful_commands
}

# Run main function
main "$@"