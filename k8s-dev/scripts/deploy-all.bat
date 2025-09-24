@echo off
setlocal enabledelayedexpansion

REM Master Deployment Script for XploreSG K8s Development Environment (Windows)
REM This script deploys the complete stack: Apps + Monitoring + GitOps

REM Configuration
set KUBECTL_CONTEXT=%KUBECTL_CONTEXT%
if "%KUBECTL_CONTEXT%"=="" set KUBECTL_CONTEXT=minikube
set SCRIPT_DIR=%~dp0

REM Logging functions
:log_info
echo [INFO] %~1
goto :eof

:log_success
echo [SUCCESS] %~1
goto :eof

:log_warning
echo [WARNING] %~1
goto :eof

:log_error
echo [ERROR] %~1
goto :eof

:log_step
echo [STEP] %~1
goto :eof

REM Function to print banner
:print_banner
echo =======================================================
echo     XploreSG Kubernetes Development Environment
echo =======================================================
echo   Complete Stack Deployment:
echo   • Application Services (Frontend, Backend, Database)
echo   • Monitoring Stack (Prometheus, Grafana)
echo   • GitOps Platform (ArgoCD)
echo =======================================================
echo.
goto :eof

REM Function to check prerequisites
:check_prerequisites
call :log_step "Checking prerequisites..."

REM Check kubectl
kubectl version --client >nul 2>&1
if errorlevel 1 (
    call :log_error "kubectl is not installed or not in PATH"
    exit /b 1
)

REM Check cluster connectivity
kubectl cluster-info >nul 2>&1
if errorlevel 1 (
    call :log_error "Cannot connect to Kubernetes cluster"
    call :log_info "Please ensure your cluster is running and kubectl is configured correctly"
    exit /b 1
)

for /f "tokens=*" %%i in ('kubectl config current-context') do set CURRENT_CONTEXT=%%i
call :log_success "Prerequisites check passed (context: !CURRENT_CONTEXT!)"
goto :eof

REM Function to deploy applications
:deploy_applications
call :log_step "Deploying XploreSG applications..."

if exist "%SCRIPT_DIR%dev-up.sh" (
    bash "%SCRIPT_DIR%dev-up.sh"
    if not errorlevel 1 (
        call :log_success "Applications deployed successfully"
    ) else (
        call :log_error "Failed to deploy applications"
        exit /b 1
    )
) else (
    call :log_error "Application deployment script not found"
    exit /b 1
)
goto :eof

REM Function to deploy monitoring stack
:deploy_monitoring
call :log_step "Deploying monitoring stack (Prometheus & Grafana)..."

if exist "%SCRIPT_DIR%deploy-monitoring.sh" (
    bash "%SCRIPT_DIR%deploy-monitoring.sh"
    if not errorlevel 1 (
        call :log_success "Monitoring stack deployed successfully"
    ) else (
        call :log_error "Failed to deploy monitoring stack"
        exit /b 1
    )
) else (
    call :log_warning "Monitoring deployment script not found, skipping..."
    call :log_info "You can deploy monitoring later using: bash deploy-monitoring.sh"
)
goto :eof

REM Function to deploy ArgoCD GitOps
:deploy_gitops
call :log_step "Deploying GitOps platform (ArgoCD)..."

if exist "%SCRIPT_DIR%deploy-argocd.bat" (
    call "%SCRIPT_DIR%deploy-argocd.bat"
    if not errorlevel 1 (
        call :log_success "ArgoCD deployed successfully"
    ) else (
        call :log_error "Failed to deploy ArgoCD"
        exit /b 1
    )
) else (
    call :log_warning "ArgoCD deployment script not found, skipping..."
    call :log_info "You can deploy ArgoCD later using: deploy-argocd.bat"
)
goto :eof

REM Function to display final status
:display_final_status
echo.
echo =======================================================
echo     XploreSG K8s Environment Deployment Complete!
echo =======================================================
echo.

call :log_info "Checking deployment status..."

REM Check application pods
echo Application Services:
kubectl get pods -n exploresg --no-headers 2>nul
if errorlevel 1 echo   • No application pods found

REM Check monitoring pods
echo Monitoring Stack:
kubectl get pods -n monitoring --no-headers 2>nul
if errorlevel 1 echo   • No monitoring pods found

REM Check ArgoCD pods
echo GitOps Platform:
kubectl get pods -n argocd --no-headers 2>nul
if errorlevel 1 echo   • No ArgoCD pods found

echo.
echo Access Information:

REM Get service ports
for /f "tokens=*" %%i in ('kubectl get svc exploresg-frontend-service -n exploresg -o jsonpath="{.spec.ports[0].nodePort}" 2^>nul') do set FRONTEND_PORT=%%i
if defined FRONTEND_PORT (
    echo   • XploreSG Frontend: http://localhost:!FRONTEND_PORT!
)

for /f "tokens=*" %%i in ('kubectl get svc exploresg-backend-service -n exploresg -o jsonpath="{.spec.ports[0].nodePort}" 2^>nul') do set BACKEND_PORT=%%i
if defined BACKEND_PORT (
    echo   • XploreSG Backend: http://localhost:!BACKEND_PORT!
)

for /f "tokens=*" %%i in ('kubectl get svc grafana -n monitoring -o jsonpath="{.spec.ports[0].nodePort}" 2^>nul') do set GRAFANA_PORT=%%i
if defined GRAFANA_PORT (
    echo   • Grafana Dashboard: http://localhost:!GRAFANA_PORT!
    echo     - Username: admin, Password: admin
)

for /f "tokens=*" %%i in ('kubectl get svc prometheus -n monitoring -o jsonpath="{.spec.ports[0].nodePort}" 2^>nul') do set PROMETHEUS_PORT=%%i
if defined PROMETHEUS_PORT (
    echo   • Prometheus: http://localhost:!PROMETHEUS_PORT!
)

echo   • ArgoCD UI: https://localhost:8080 (via port-forward)
echo     - Username: admin
echo     - Password: Use PowerShell to decode base64

echo.
echo Useful Commands:
echo   • Check all pods: kubectl get pods --all-namespaces
echo   • View logs: kubectl logs -f deployment/^<deployment-name^> -n ^<namespace^>
echo   • Access services: kubectl get services --all-namespaces
echo   • Stop environment: bash dev-down.sh
echo   • Check status: bash dev-status.sh
echo.
goto :eof

REM Main deployment function
:main
call :print_banner

REM Run deployment steps
call :check_prerequisites
if errorlevel 1 exit /b 1

REM Deploy core applications first
call :deploy_applications
if errorlevel 1 exit /b 1

REM Wait a bit for applications to stabilize
timeout /t 10 /nobreak >nul

REM Deploy monitoring stack
call :deploy_monitoring

REM Wait a bit for monitoring to stabilize
timeout /t 10 /nobreak >nul

REM Deploy GitOps platform
call :deploy_gitops

REM Display final status
call :display_final_status

call :log_success "Complete stack deployment finished successfully!"
goto :eof

REM Parse command line arguments
if "%1"=="--help" goto :help
if "%1"=="-h" goto :help
if "%1"=="--apps-only" goto :apps_only
if "%1"=="--monitoring-only" goto :monitoring_only
if "%1"=="--gitops-only" goto :gitops_only
if "%1"=="--status" goto :status
if "%1"=="" goto :main

call :log_error "Unknown option: %1"
echo Use --help for usage information
exit /b 1

:help
echo Usage: %0 [OPTIONS]
echo.
echo Deploy complete XploreSG K8s development environment
echo.
echo Options:
echo   --help, -h        Show this help message
echo   --apps-only       Deploy only applications (skip monitoring & GitOps)
echo   --monitoring-only Deploy only monitoring stack
echo   --gitops-only     Deploy only ArgoCD GitOps
echo   --status          Show deployment status
echo.
echo Environment Variables:
echo   KUBECTL_CONTEXT   Kubernetes context to use (default: current context)
echo.
exit /b 0

:apps_only
call :print_banner
call :check_prerequisites
if errorlevel 1 exit /b 1
call :deploy_applications
call :log_success "Applications deployment completed!"
exit /b 0

:monitoring_only
call :print_banner
call :check_prerequisites
if errorlevel 1 exit /b 1
call :deploy_monitoring
call :log_success "Monitoring deployment completed!"
exit /b 0

:gitops_only
call :print_banner
call :check_prerequisites
if errorlevel 1 exit /b 1
call :deploy_gitops
call :log_success "GitOps deployment completed!"
exit /b 0

:status
call :display_final_status
exit /b 0