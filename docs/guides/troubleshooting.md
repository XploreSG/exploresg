# Troubleshooting Guide

This comprehensive troubleshooting guide covers common issues you might encounter while developing, testing, or deploying XploreSG.

## 🚨 Quick Diagnostic Commands

Before diving into specific issues, run these commands to gather system information:

```bash
# Check system resources
df -h                    # Disk space
free -h                  # Memory usage
docker system df         # Docker disk usage
kubectl top nodes        # Kubernetes resource usage (if applicable)

# Check service status
docker ps               # Running containers
kubectl get pods -A     # All Kubernetes pods
systemctl status docker # Docker service status

# Check logs
docker-compose logs     # Docker Compose logs
kubectl logs -f <pod>   # Kubernetes pod logs
journalctl -u docker    # Docker system logs
```

## 🐳 Docker & Docker Compose Issues

### Container Won't Start

**Symptoms:**

- Container exits immediately
- "Container exited with code 1" error
- Services not accessible

**Diagnostic Steps:**

```bash
# Check container logs
docker-compose logs service-name

# Check container status
docker ps -a

# Inspect container configuration
docker inspect container-name

# Check resource usage
docker system df
docker stats
```

**Common Solutions:**

1. **Port Already in Use:**

   ```bash
   # Find process using port
   lsof -i :3000  # Linux/macOS
   netstat -ano | findstr :3000  # Windows

   # Kill process
   kill -9 <PID>  # Linux/macOS
   taskkill /PID <PID> /F  # Windows
   ```

2. **Insufficient Memory:**

   ```bash
   # Increase Docker memory limit (Docker Desktop)
   # Settings > Resources > Memory > Increase to 4GB+

   # Clean up unused containers
   docker system prune -a
   ```

3. **Environment Variables Missing:**

   ```bash
   # Check .env file exists
   ls -la .env

   # Verify environment variables
   docker-compose config
   ```

### Database Connection Issues

**Symptoms:**

- "Connection refused" errors
- Application can't connect to database
- Intermittent connection drops

**Solutions:**

1. **Check Database Container:**

   ```bash
   # Verify database is running
   docker-compose ps postgres

   # Check database logs
   docker-compose logs postgres

   # Test connection
   docker-compose exec postgres psql -U postgres -d xploresg_dev -c "SELECT 1;"
   ```

2. **Network Issues:**

   ```bash
   # Check Docker networks
   docker network ls
   docker network inspect dev_default

   # Restart networking
   docker-compose down
   docker-compose up
   ```

3. **Database Not Ready:**
   ```yaml
   # Add health check to docker-compose.yml
   services:
     user-service:
       depends_on:
         postgres:
           condition: service_healthy
     postgres:
       healthcheck:
         test: ["CMD-SHELL", "pg_isready -U postgres"]
         interval: 30s
         timeout: 10s
         retries: 3
   ```

## ☸️ Kubernetes Issues

### Pod Stuck in Pending State

**Symptoms:**

- Pods show "Pending" status
- Events show scheduling issues

**Diagnostic Steps:**

```bash
# Check pod events
kubectl describe pod <pod-name> -n xploresg-dev

# Check node resources
kubectl top nodes
kubectl describe nodes

# Check persistent volume claims
kubectl get pvc -n xploresg-dev
```

**Common Solutions:**

1. **Insufficient Resources:**

   ```bash
   # Check node capacity
   kubectl describe nodes

   # Reduce resource requests temporarily
   # Edit deployment and reduce CPU/memory requests
   ```

2. **PVC Issues:**

   ```bash
   # Check PVC status
   kubectl get pvc -n xploresg-dev

   # Delete and recreate PVC if stuck
   kubectl delete pvc postgres-pvc -n xploresg-dev
   kubectl apply -f manifests/databases/postgres.yaml
   ```

3. **Image Pull Issues:**

   ```bash
   # Check image pull secrets
   kubectl get secrets -n xploresg-dev

   # Pull image manually to verify
   docker pull xploresg/user-service:latest
   ```

### Service Not Accessible

**Symptoms:**

- Cannot access application via browser
- Connection timeouts
- "Service Unavailable" errors

**Solutions:**

1. **Check Service Configuration:**

   ```bash
   # List services
   kubectl get svc -n xploresg-dev

   # Check service endpoints
   kubectl get endpoints -n xploresg-dev

   # Describe service
   kubectl describe svc frontend-service -n xploresg-dev
   ```

2. **Ingress Issues:**

   ```bash
   # Check ingress status
   kubectl get ingress -n xploresg-dev

   # Check ingress controller
   kubectl get pods -n ingress-nginx

   # Test service directly
   kubectl port-forward svc/frontend-service 8080:80 -n xploresg-dev
   ```

3. **DNS Resolution:**
   ```bash
   # Add to /etc/hosts (Linux/macOS) or C:\Windows\System32\drivers\etc\hosts (Windows)
   echo "$(minikube ip) xploresg.local api.xploresg.local" | sudo tee -a /etc/hosts
   ```

### Persistent Volume Issues

**Symptoms:**

- Database data not persisting
- "Volume mount failed" errors
- Storage-related pod failures

**Solutions:**

1. **Check Storage Class:**

   ```bash
   # List storage classes
   kubectl get storageclass

   # Check PV status
   kubectl get pv

   # Check PVC binding
   kubectl get pvc -n xploresg-dev
   ```

2. **Minikube Storage Issues:**

   ```bash
   # Enable storage addon
   minikube addons enable default-storageclass
   minikube addons enable storage-provisioner

   # Restart minikube if needed
   minikube stop
   minikube start
   ```

## 🗄️ Database Issues

### PostgreSQL Connection Problems

**Symptoms:**

- "Connection refused" errors
- Authentication failures
- Timeout errors

**Diagnostic Steps:**

```bash
# Check if PostgreSQL is running
docker-compose ps postgres  # Docker Compose
kubectl get pods -l app.kubernetes.io/name=postgres -n xploresg-dev  # Kubernetes

# Check PostgreSQL logs
docker-compose logs postgres  # Docker Compose
kubectl logs deployment/postgres -n xploresg-dev  # Kubernetes

# Test connection
psql -h localhost -U postgres -d xploresg_dev  # Direct connection
```

**Solutions:**

1. **Authentication Issues:**

   ```sql
   -- Check user permissions
   \du  -- List users

   -- Grant permissions if needed
   GRANT ALL PRIVILEGES ON DATABASE xploresg_dev TO xploresg_user;
   GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO xploresg_user;
   ```

2. **Connection Pool Exhaustion:**

   ```bash
   # Check active connections
   docker-compose exec postgres psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"

   # Kill idle connections
   docker-compose exec postgres psql -U postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE state = 'idle' AND query_start < now() - interval '5 minutes';"
   ```

3. **Database Corruption:**

   ```bash
   # Check database integrity
   docker-compose exec postgres psql -U postgres -d xploresg_dev -c "SELECT pg_database_size('xploresg_dev');"

   # Restore from backup (if available)
   docker-compose exec postgres pg_restore -U postgres -d xploresg_dev /backup/latest.sql
   ```

### Migration Issues

**Symptoms:**

- Migration scripts fail
- Schema inconsistencies
- Data corruption during migration

**Solutions:**

1. **Check Migration Status:**

   ```bash
   # Run migration status command
   npm run migrate:status

   # Check migration table
   docker-compose exec postgres psql -U postgres -d xploresg_dev -c "SELECT * FROM migrations ORDER BY id DESC LIMIT 10;"
   ```

2. **Rollback Failed Migration:**

   ```bash
   # Rollback last migration
   npm run migrate:rollback

   # Or rollback to specific version
   npm run migrate:rollback -- --to 20231201000000
   ```

3. **Fresh Migration:**

   ```bash
   # Drop and recreate database (development only!)
   npm run migrate:fresh

   # Seed test data
   npm run seed:run
   ```

## 🌐 Network & API Issues

### API Endpoints Not Responding

**Symptoms:**

- 404 errors for existing endpoints
- Timeouts on API calls
- CORS errors in browser

**Solutions:**

1. **Check API Server Status:**

   ```bash
   # Test health endpoint
   curl http://localhost:3001/health
   curl http://localhost:3001/api/v1/health

   # Check server logs
   docker-compose logs user-service
   kubectl logs deployment/user-service -n xploresg-dev
   ```

2. **CORS Issues:**

   ```javascript
   // Check CORS configuration
   const cors = require("cors");
   app.use(
     cors({
       origin: ["http://localhost:3000", "https://xploresg.local"],
       credentials: true,
     })
   );
   ```

3. **Routing Problems:**

   ```bash
   # Check route registration
   curl -X OPTIONS http://localhost:3001/api/v1/users

   # Verify request headers
   curl -H "Content-Type: application/json" -H "Authorization: Bearer <token>" http://localhost:3001/api/v1/users/me
   ```

### Frontend Build Issues

**Symptoms:**

- Build process fails
- Assets not loading
- JavaScript errors in console

**Solutions:**

1. **Clear Cache and Rebuild:**

   ```bash
   # Clear npm cache
   npm cache clean --force

   # Delete node_modules and reinstall
   rm -rf node_modules package-lock.json
   npm install

   # Clear build cache
   rm -rf dist/ build/ .next/
   npm run build
   ```

2. **Environment Variable Issues:**

   ```bash
   # Check environment variables
   cat .env

   # Verify build-time variables
   echo $REACT_APP_API_BASE_URL
   echo $VUE_APP_API_BASE_URL
   ```

## 🔐 Authentication & Authorization Issues

### JWT Token Problems

**Symptoms:**

- "Token expired" errors
- Authentication failures
- Infinite redirect loops

**Solutions:**

1. **Check Token Validity:**

   ```bash
   # Decode JWT token (without verification)
   echo "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." | base64 -d

   # Check token expiration
   # Use online JWT decoder or create a simple script
   ```

2. **Token Storage Issues:**

   ```javascript
   // Check localStorage/sessionStorage
   console.log(localStorage.getItem("accessToken"));
   console.log(localStorage.getItem("refreshToken"));

   // Clear stored tokens
   localStorage.clear();
   sessionStorage.clear();
   ```

3. **Secret Key Mismatch:**

   ```bash
   # Verify JWT secret is consistent
   echo $JWT_SECRET

   # Check if secret changed between services
   docker-compose exec user-service env | grep JWT_SECRET
   ```

## 🔍 Performance Issues

### Slow Database Queries

**Symptoms:**

- High response times
- Database timeouts
- Poor application performance

**Solutions:**

1. **Analyze Slow Queries:**

   ```sql
   -- Enable query logging (PostgreSQL)
   ALTER SYSTEM SET log_min_duration_statement = 1000;  -- Log queries > 1s
   SELECT pg_reload_conf();

   -- Check current running queries
   SELECT query, state, query_start
   FROM pg_stat_activity
   WHERE state = 'active' AND query NOT LIKE '%pg_stat_activity%';
   ```

2. **Add Database Indexes:**

   ```sql
   -- Analyze query performance
   EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';

   -- Add missing indexes
   CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
   CREATE INDEX CONCURRENTLY idx_sessions_user_id ON user_sessions(user_id);
   ```

3. **Connection Pooling:**
   ```javascript
   // Configure connection pool
   const pool = new Pool({
     host: "localhost",
     user: "postgres",
     database: "xploresg_dev",
     password: "postgres123",
     port: 5432,
     max: 20, // Maximum connections
     idleTimeoutMillis: 30000,
     connectionTimeoutMillis: 2000,
   });
   ```

### Memory Leaks

**Symptoms:**

- Memory usage continuously increasing
- Out of memory errors
- Container restarts

**Solutions:**

1. **Monitor Memory Usage:**

   ```bash
   # Check container memory usage
   docker stats
   kubectl top pods -n xploresg-dev

   # Profile Node.js memory usage
   node --inspect app.js
   # Connect Chrome DevTools to analyze memory
   ```

2. **Fix Common Memory Leaks:**

   ```javascript
   // Ensure event listeners are cleaned up
   process.on("SIGTERM", () => {
     server.close(() => {
       database.close();
     });
   });

   // Clear intervals and timeouts
   const interval = setInterval(() => {}, 1000);
   // Remember to: clearInterval(interval);
   ```

## 🚀 Deployment Issues

### CI/CD Pipeline Failures

**Symptoms:**

- GitHub Actions failing
- Build process errors
- Deployment rollbacks

**Solutions:**

1. **Check Action Logs:**

   ```bash
   # View workflow runs
   gh run list

   # View specific run logs
   gh run view <run-id>

   # Re-run failed jobs
   gh run rerun <run-id>
   ```

2. **Docker Build Issues:**

   ```dockerfile
   # Multi-stage build optimization
   FROM node:18-alpine AS builder
   WORKDIR /app
   COPY package*.json ./
   RUN npm ci --only=production

   FROM node:18-alpine AS runtime
   WORKDIR /app
   COPY --from=builder /app/node_modules ./node_modules
   COPY . .
   CMD ["npm", "start"]
   ```

3. **Environment Secrets:**

   ```bash
   # Check GitHub secrets
   gh secret list

   # Set required secrets
   gh secret set DATABASE_URL --body "postgresql://..."
   gh secret set JWT_SECRET --body "your-secret-key"
   ```

## 🛠️ Development Tools Issues

### VS Code Problems

**Symptoms:**

- Extensions not working
- TypeScript errors
- Debugging issues

**Solutions:**

1. **Reset VS Code Configuration:**

   ```bash
   # Reset user settings (backup first!)
   mv ~/.vscode/extensions ~/.vscode/extensions.backup

   # Reinstall extensions
   code --install-extension ms-vscode.vscode-typescript-next
   code --install-extension esbenp.prettier-vscode
   ```

2. **TypeScript Issues:**

   ```bash
   # Restart TypeScript server
   # Ctrl+Shift+P -> "TypeScript: Restart TS Server"

   # Check TypeScript version
   npm list typescript

   # Update TypeScript
   npm install typescript@latest --save-dev
   ```

### Git Issues

**Symptoms:**

- Merge conflicts
- Push/pull failures
- Branch synchronization problems

**Solutions:**

1. **Resolve Merge Conflicts:**

   ```bash
   # Check conflict status
   git status

   # Use merge tool
   git mergetool

   # Or resolve manually and commit
   git add .
   git commit -m "Resolve merge conflicts"
   ```

2. **Reset Branch State:**

   ```bash
   # Discard local changes
   git reset --hard HEAD

   # Reset to remote state
   git fetch origin
   git reset --hard origin/main
   ```

## 📞 Getting Help

### Escalation Path

1. **Self-Service**: Check this troubleshooting guide
2. **Documentation**: Review relevant documentation sections
3. **Team Chat**: Ask in #xploresg-dev Slack channel
4. **Senior Developer**: Tag senior team members
5. **On-Call**: Contact on-call engineer for production issues
6. **External Support**: Contact vendor support if needed

### Useful Debug Commands Reference

```bash
# System Information
uname -a                 # System info
df -h                   # Disk usage
free -h                 # Memory usage
top                     # Process usage

# Docker
docker ps -a            # All containers
docker logs <container> # Container logs
docker exec -it <container> sh  # Shell into container
docker system prune -a  # Clean up all Docker data

# Kubernetes
kubectl get all -n xploresg-dev  # All resources
kubectl describe pod <pod>       # Pod details
kubectl logs -f <pod>           # Follow logs
kubectl exec -it <pod> -- sh    # Shell into pod
kubectl port-forward svc/<service> 8080:80  # Port forward

# Network
netstat -tulpn          # Open ports
nslookup domain.com     # DNS lookup
curl -I http://example.com  # HTTP headers
telnet host port        # Test port connectivity

# Database
psql -h host -U user -d database  # Connect to PostgreSQL
\l                      # List databases
\dt                     # List tables
\q                      # Quit psql
```

---

Remember: When troubleshooting, always check logs first, verify configuration, and don't hesitate to ask for help! 🚀🛠️
