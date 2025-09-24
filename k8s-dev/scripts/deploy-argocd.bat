@echo off
setlocal enabledelayedexpansion

REM ArgoCD Deployment Script for Windows
REM This script deploys ArgoCD for GitOps in the local Kubernetes cluster

REM Configuration
set NAMESPACE=argocd
set KUBECTL_CONTEXT=%KUBECTL_CONTEXT%
if "%KUBECTL_CONTEXT%"=="" set KUBECTL_CONTEXT=minikube
set SCRIPT_DIR=%~dp0
set MANIFESTS_DIR=%SCRIPT_DIR%..\manifests\gitops

REM Colors (Windows CMD doesn't support colors natively, but we'll use echo)
set "RED=[31m"
set "GREEN=[32m"
set "YELLOW=[33m"
set "BLUE=[34m"
set "NC=[0m"

REM Function to display colored output
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

REM Function to check if kubectl is available
:check_kubectl
kubectl version --client >nul 2>&1
if errorlevel 1 (
    call :log_error "kubectl is not installed or not in PATH"
    exit /b 1
)
goto :eof

REM Function to check if cluster is accessible
:check_cluster
call :log_info "Checking cluster connectivity..."
kubectl cluster-info >nul 2>&1
if errorlevel 1 (
    call :log_error "Cannot connect to Kubernetes cluster"
    call :log_info "Please ensure your cluster is running and kubectl is configured correctly"
    exit /b 1
)

for /f "tokens=*" %%i in ('kubectl config current-context') do set CURRENT_CONTEXT=%%i
call :log_success "Connected to cluster (context: !CURRENT_CONTEXT!)"
goto :eof

REM Function to create namespace if it doesn't exist
:create_namespace
call :log_info "Creating namespace %NAMESPACE%..."
kubectl get namespace %NAMESPACE% >nul 2>&1
if not errorlevel 1 (
    call :log_warning "Namespace %NAMESPACE% already exists"
) else (
    kubectl create namespace %NAMESPACE%
    call :log_success "Namespace %NAMESPACE% created"
)
goto :eof

REM Function to apply ArgoCD manifests
:deploy_argocd
call :log_info "Deploying ArgoCD components..."

REM Apply manifests in order
set MANIFESTS=00-namespace.yaml 01-argocd-rbac.yaml 02-argocd-deployments.yaml 03-argocd-services.yaml 04-argocd-config.yaml

for %%m in (%MANIFESTS%) do (
    set FILE_PATH=%MANIFESTS_DIR%\%%m
    if exist "!FILE_PATH!" (
        call :log_info "Applying %%m..."
        kubectl apply -f "!FILE_PATH!"
    ) else (
        call :log_warning "Manifest %%m not found, skipping..."
    )
)

call :log_success "ArgoCD components deployed"
goto :eof

REM Function to wait for ArgoCD to be ready
:wait_for_argocd
call :log_info "Waiting for ArgoCD components to be ready..."

REM Wait for deployments to be ready
set DEPLOYMENTS=argocd-application-controller argocd-repo-server argocd-server argocd-redis

for %%d in (%DEPLOYMENTS%) do (
    call :log_info "Waiting for %%d to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/%%d -n %NAMESPACE%
    if errorlevel 1 (
        call :log_error "Timeout waiting for %%d to be ready"
        exit /b 1
    )
)

call :log_success "All ArgoCD components are ready"
goto :eof

REM Function to get ArgoCD admin password
:get_admin_password
call :log_info "Retrieving ArgoCD admin password..."

REM Wait a bit for the secret to be created
timeout /t 10 /nobreak >nul

kubectl -n %NAMESPACE% get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" >temp_password.b64 2>nul
if errorlevel 1 (
    call :log_warning "Admin password secret not found. ArgoCD might still be initializing."
    call :log_info "You can retrieve it later with:"
    echo   kubectl -n %NAMESPACE% get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" ^| base64 -d
) else (
    REM Windows doesn't have base64 command, so we'll show the encoded version
    set /p PASSWORD=<temp_password.b64
    call :log_success "ArgoCD admin password (base64 encoded): !PASSWORD!"
    call :log_info "Decode this password using an online base64 decoder or PowerShell:"
    echo   [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("!PASSWORD!"))
    del temp_password.b64 >nul 2>&1
)
goto :eof

REM Function to setup port forwarding
:setup_port_forward
call :log_info "Setting up port forwarding for ArgoCD UI..."

REM Check if port is already in use (basic check)
netstat -an | find ":8080" | find "LISTENING" >nul 2>&1
if not errorlevel 1 (
    call :log_warning "Port 8080 appears to be in use. Please stop the existing process or use a different port."
    goto :eof
)

REM Start port forwarding in background (Windows style)
call :log_info "Starting port forwarding in a new window..."
start "ArgoCD Port Forward" /min kubectl port-forward svc/argocd-server -n %NAMESPACE% 8080:443

call :log_success "Port forwarding started in a new window"
call :log_info "ArgoCD UI will be available at: https://localhost:8080"
call :log_warning "Note: You may need to accept the self-signed certificate in your browser"
goto :eof

REM Function to deploy ArgoCD applications
:deploy_applications
call :log_info "Deploying ArgoCD applications..."

set APP_MANIFEST=%MANIFESTS_DIR%\05-argocd-applications.yaml
if exist "%APP_MANIFEST%" (
    REM Wait a bit for ArgoCD to be fully ready
    timeout /t 30 /nobreak >nul
    
    call :log_info "Applying ArgoCD applications manifest..."
    kubectl apply -f "%APP_MANIFEST%"
    call :log_success "ArgoCD applications deployed"
) else (
    call :log_warning "ArgoCD applications manifest not found, skipping..."
)
goto :eof

REM Function to display access information
:display_access_info
echo.
echo =================================================
echo          ArgoCD Deployment Complete!
echo =================================================
echo.
echo Access Information:
echo   • ArgoCD UI: https://localhost:8080
echo   • Username: admin
echo   • Password: Use the command below to retrieve
echo.
echo Retrieve admin password (PowerShell):
echo   $password = kubectl -n %NAMESPACE% get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
echo   [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($password))
echo.
echo Useful commands:
echo   • Check ArgoCD status: kubectl get pods -n %NAMESPACE%
echo   • View ArgoCD logs: kubectl logs -n %NAMESPACE% deployment/argocd-server
echo.
goto :eof

REM Main deployment function
:main
call :log_info "Starting ArgoCD deployment for XploreSG..."

REM Pre-flight checks
call :check_kubectl
if errorlevel 1 exit /b 1

call :check_cluster
if errorlevel 1 exit /b 1

REM Deploy ArgoCD
call :create_namespace
call :deploy_argocd
call :wait_for_argocd
if errorlevel 1 exit /b 1

REM Post-deployment setup
call :get_admin_password
call :setup_port_forward
call :deploy_applications

REM Display access information
call :display_access_info

call :log_success "ArgoCD deployment completed successfully!"
goto :eof

REM Parse command line arguments
if "%1"=="--help" goto :help
if "%1"=="-h" goto :help
if "%1"=="--cleanup" goto :cleanup
if "%1"=="" goto :main

call :log_error "Unknown option: %1"
echo Use --help for usage information
exit /b 1

:help
echo Usage: %0 [OPTIONS]
echo.
echo Deploy ArgoCD for XploreSG K8s development environment
echo.
echo Options:
echo   --help, -h     Show this help message
echo   --cleanup      Remove ArgoCD deployment
echo.
echo Environment Variables:
echo   KUBECTL_CONTEXT  Kubernetes context to use (default: current context)
echo.
exit /b 0

:cleanup
call :log_info "Cleaning up ArgoCD deployment..."

REM Delete ArgoCD resources
kubectl delete namespace %NAMESPACE% --ignore-not-found=true >nul 2>&1
call :log_success "ArgoCD cleanup completed"

REM Note about port forwarding cleanup
call :log_info "Note: Please manually close any ArgoCD port forwarding windows"
exit /b 0