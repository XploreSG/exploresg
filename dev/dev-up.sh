#!/bin/bash

# XploreSG Development Environment Startup Script
# This script brings up the entire XploreSG development environment

set -e  # Exit on any error

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
ROCKET="🚀"
GEAR="⚙️"
DATABASE="🗄️"
WEB="🌐"

print_header() {
    echo -e "\n${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                          ${WHITE}XploreSG Development Environment${PURPLE}                    ║${NC}"
    echo -e "${PURPLE}║                          ${CYAN}Smart Auto-Detecting Startup${PURPLE}                        ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_step() {
    echo -e "${BLUE}${GEAR} ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}${SUCCESS} ${1}${NC}"
}

print_error() {
    echo -e "${RED}${ERROR} ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARNING} ${1}${NC}"
}

print_info() {
    echo -e "${CYAN}${INFO} ${1}${NC}"
}

check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker Desktop."
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available. Please ensure Docker Desktop is running."
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker Desktop."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

check_repositories() {
    print_step "Checking repository structure..."
    
    # Check for required MVP repos first
    local required_repos=("exploresg-frontend-service" "exploresg-user-service")
    local missing_required=()
    
    for repo in "${required_repos[@]}"; do
        if [ ! -d "../../${repo}" ]; then
            missing_required+=("${repo}")
        fi
    done
    
    if [ ${#missing_required[@]} -gt 0 ]; then
        print_error "Missing required repositories:"
        for repo in "${missing_required[@]}"; do
            echo -e "  ${RED}✗${NC} ${repo}"
        done
        echo
        print_info "Run the bootstrap setup first: cd ../setup && ./setup.sh"
        exit 1
    fi
    
    # Check which services are available and active in docker-compose.yml
    local active_services=()
    local commented_services=()
    
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*([a-z-]+):[[:space:]]*$ ]]; then
            service_name="${BASH_REMATCH[1]}"
            if [[ ! "$service_name" =~ ^(version|services|volumes|networks)$ ]]; then
                active_services+=("$service_name")
            fi
        elif [[ $line =~ ^[[:space:]]*#[[:space:]]*([a-z-]+):[[:space:]]*$ ]]; then
            service_name="${BASH_REMATCH[1]}"
            commented_services+=("$service_name")
        fi
    done < docker-compose.yml
    
    print_success "Found ${#active_services[@]} active services: ${active_services[*]}"
    if [ ${#commented_services[@]} -gt 0 ]; then
        print_info "Found ${#commented_services[@]} commented services ready for future phases"
    fi
}

setup_environment() {
    print_step "Setting up environment variables..."
    
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            print_warning "Created .env from template. Please configure your API keys in .env file."
        else
            print_error ".env.example file not found"
            exit 1
        fi
    else
        print_success "Environment file already exists"
    fi
}

create_init_db_scripts() {
    print_step "Creating database initialization scripts..."
    
    mkdir -p init-db
    
    cat > init-db/01-init.sql << 'EOF'
-- XploreSG Database Initialization
-- This script sets up the initial database structure

-- Create databases for different services
CREATE DATABASE IF NOT EXISTS xploresg_rental;
CREATE DATABASE IF NOT EXISTS xploresg_users;
CREATE DATABASE IF NOT EXISTS xploresg_gamification;

-- Create users for services (if needed)
-- Additional initialization can be added here

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE xploresg_rental TO postgres;
GRANT ALL PRIVILEGES ON DATABASE xploresg_users TO postgres;
GRANT ALL PRIVILEGES ON DATABASE xploresg_gamification TO postgres;

EOF

    print_success "Database initialization scripts created"
}

start_services() {
    print_step "Starting XploreSG services..."
    
    echo -e "${CYAN}This may take a few minutes on first run (building Docker images)...${NC}\n"
    
    # Get list of active services from docker-compose.yml
    local services=($(docker-compose config --services 2>/dev/null || echo ""))
    
    if [ ${#services[@]} -eq 0 ]; then
        print_error "No services found in docker-compose.yml"
        exit 1
    fi
    
    # Categorize services for smart startup order
    local databases=()
    local backends=()
    local gateways=()
    local frontends=()
    
    for service in "${services[@]}"; do
        case $service in
            postgres|mongodb|redis)
                databases+=("$service")
                ;;
            *-gateway|api-gateway)
                gateways+=("$service") 
                ;;
            frontend-*|*-frontend)
                frontends+=("$service")
                ;;
            *)
                backends+=("$service")
                ;;
        esac
    done
    
    # Start databases first
    if [ ${#databases[@]} -gt 0 ]; then
        print_info "${DATABASE} Starting databases: ${databases[*]}"
        docker-compose up -d "${databases[@]}"
        print_info "Waiting for databases to be ready..."
        sleep 8
    fi
    
    # Start backend services
    if [ ${#backends[@]} -gt 0 ]; then
        print_info "${GEAR} Starting backend services: ${backends[*]}"
        docker-compose up -d "${backends[@]}"
        print_info "Waiting for backend services..."
        sleep 10
    fi
    
    # Start gateways
    if [ ${#gateways[@]} -gt 0 ]; then
        print_info "${WEB} Starting gateways: ${gateways[*]}"
        docker-compose up -d "${gateways[@]}"
        sleep 8
    fi
    
    # Start frontends
    if [ ${#frontends[@]} -gt 0 ]; then
        print_info "${WEB} Starting frontends: ${frontends[*]}"
        docker-compose up -d "${frontends[@]}"
    fi
    
    print_success "All active services started successfully!"
}

show_service_status() {
    print_step "Checking service health..."
    echo
    
    docker-compose ps
    echo
}

show_access_info() {
    echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                              ${WHITE}🎉 DEVELOPMENT ENVIRONMENT READY! 🎉${GREEN}                  ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}\n"
    
    # Dynamically show running services
    local running_services=$(docker-compose ps --services --filter "status=running" 2>/dev/null || echo "")
    
    echo -e "${WHITE}� Active Services:${NC}"
    
    # Check each potential service and show if running
    if docker-compose ps frontend-service 2>/dev/null | grep -q "Up"; then
        echo -e "  ${CYAN}• Frontend:${NC}      http://localhost:3000"
    fi
    
    if docker-compose ps api-gateway 2>/dev/null | grep -q "Up"; then
        echo -e "  ${CYAN}• API Gateway:${NC}   http://localhost:3009"
    fi
    
    # Backend services
    local backend_services=("user-service:3002" "rental-service:3001" "route-service:3003" "calendar-service:3004" "weather-service:3005" "journal-service:3006" "ai-service:3007" "gamification-service:3008")
    local active_backends=()
    
    for service_port in "${backend_services[@]}"; do
        service_name="${service_port%:*}"
        port="${service_port#*:}"
        if docker-compose ps "$service_name" 2>/dev/null | grep -q "Up"; then
            active_backends+=("  ${CYAN}• ${service_name^}:${NC} http://localhost:$port")
        fi
    done
    
    if [ ${#active_backends[@]} -gt 0 ]; then
        echo
        echo -e "${WHITE}🔧 Backend Services:${NC}"
        printf '%s\n' "${active_backends[@]}"
    fi
    
    # Databases  
    echo
    echo -e "${WHITE}🗄️ Active Databases:${NC}"
    if docker-compose ps postgres 2>/dev/null | grep -q "Up"; then
        echo -e "  ${CYAN}• PostgreSQL:${NC}    localhost:5432 (postgres/postgres123)"
    fi
    if docker-compose ps mongodb 2>/dev/null | grep -q "Up"; then
        echo -e "  ${CYAN}• MongoDB:${NC}       localhost:27017 (mongo/mongo123)"
    fi
    if docker-compose ps redis 2>/dev/null | grep -q "Up"; then
        echo -e "  ${CYAN}• Redis:${NC}         localhost:6379 (password: redis123)"
    fi
    
    echo
    echo -e "${WHITE}🛠️ Development Commands:${NC}"
    echo -e "  ${CYAN}• View logs:${NC}      docker-compose logs -f [service-name]"
    echo -e "  ${CYAN}• Stop all:${NC}       docker-compose down"
    echo -e "  ${CYAN}• Restart:${NC}        docker-compose restart [service-name]"
    echo -e "  ${CYAN}• Rebuild:${NC}        docker-compose up --build [service-name]"
    echo
    
    # Check if this looks like MVP or full setup
    local service_count=$(docker-compose ps --services | wc -l)
    if [ "$service_count" -le 3 ]; then
        echo -e "${YELLOW}💡 MVP Mode: Add more services by uncommenting them in docker-compose.yml${NC}"
    else
        echo -e "${YELLOW}⚠️ Don't forget to configure your API keys in the .env file for full features!${NC}"
    fi
    echo
}

cleanup_on_exit() {
    echo
    print_info "Shutting down gracefully..."
    # Add any cleanup logic here if needed
}

# Trap Ctrl+C
trap cleanup_on_exit INT

# Main execution
main() {
    print_header
    
    check_prerequisites
    check_repositories 
    setup_environment
    create_init_db_scripts
    start_services
    show_service_status
    show_access_info
    
    echo -e "${GREEN}${ROCKET} XploreSG development environment is now running!${NC}"
    echo -e "${CYAN}Press Ctrl+C to stop all services or run 'docker-compose down'${NC}\n"
}

# Run main function
main "$@"