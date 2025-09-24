#!/bin/bash

# XploreSG Development Environment Shutdown Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Unicode symbols  
SUCCESS="✅"
ERROR="❌"
WARNING="⚠️"
INFO="ℹ️"
STOP="🛑"

print_header() {
    echo -e "\n${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                      ${WHITE}XploreSG Development Environment${RED}                        ║${NC}"
    echo -e "${RED}║                              ${CYAN}Shutdown Script${RED}                               ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_step() {
    echo -e "${BLUE}${STOP} ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}${SUCCESS} ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARNING} ${1}${NC}"
}

shutdown_services() {
    print_step "Stopping XploreSG development environment..."
    
    if docker-compose ps -q > /dev/null 2>&1; then
        # Stop all services
        docker-compose down
        
        # Optionally remove volumes (uncomment if you want to reset data)
        # print_warning "Removing volumes and resetting data..."
        # docker-compose down -v
        
        print_success "All services stopped successfully"
    else
        print_warning "No running services found"
    fi
}

cleanup_containers() {
    print_step "Cleaning up stopped containers..."
    
    # Remove stopped containers
    docker container prune -f > /dev/null 2>&1 || true
    
    print_success "Cleanup completed"
}

show_status() {
    print_step "Final status check..."
    
    local running_containers
    running_containers=$(docker ps --filter "name=xploresg-*" --format "table {{.Names}}\t{{.Status}}" | tail -n +2)
    
    if [ -z "$running_containers" ]; then
        print_success "No XploreSG containers running"
    else
        print_warning "Some containers are still running:"
        echo "$running_containers"
    fi
}

main() {
    print_header
    
    shutdown_services
    cleanup_containers
    show_status
    
    echo -e "\n${GREEN}${SUCCESS} XploreSG development environment shutdown complete!${NC}"
    echo -e "${CYAN}Use './dev-up.sh' to start the environment again.${NC}\n"
}

main "$@"