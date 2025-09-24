# XploreSG Documentation Hub

Welcome to the comprehensive documentation for XploreSG - a Singapore exploration and discovery platform. This documentation covers everything from getting started to production deployment.

## 📖 Table of Contents

### 🚀 Quick Start

- [Getting Started](#getting-started)
- [Development Setup](development/setup.md)
- [Project Structure](#project-structure)

### 🏗️ Architecture

- [System Architecture](architecture/overview.md)
- [Database Design](architecture/database.md)
- [API Design](architecture/api-design.md)
- [Security Architecture](architecture/security.md)

### 💻 Development

- [Development Environment](development/setup.md)
- [Docker Compose Development](development/docker-development.md)
- [Kubernetes Development](development/kubernetes-development.md)

### 🎯 Best Practices & Standards

- [Coding Standards](development/coding-standards.md) - Comprehensive coding standards and quality guidelines
- [Git Workflow](development/git-workflow.md) - Professional Git workflow and collaboration practices
- [Development Tools](development/development-tools.md) - Essential development tools and environment setup
- [Security & Performance](development/security-performance.md) - Security best practices and performance optimization

### 📚 API Documentation

- [API Overview](api/overview.md)
- [User Service API](api/user-service.md)
- [Authentication](api/authentication.md)
- [Error Handling](api/error-handling.md)

### 🚢 Deployment

- [Deployment Overview](deployment/overview.md)
- [Local Development](deployment/local.md)
- [Minikube Deployment](deployment/minikube.md)
- [DigitalOcean Kubernetes](deployment/digitalocean.md)
- [CI/CD Pipeline](deployment/cicd.md)

### 📋 Guides

- [New Developer Onboarding](guides/onboarding.md)
- [Troubleshooting Guide](guides/troubleshooting.md)
- [Performance Optimization](guides/performance.md)
- [Monitoring and Logging](guides/monitoring.md)

---

## 🚀 Getting Started

XploreSG is designed with a progressive development approach that takes you from local development to production deployment:

### Development Progression

1. **Docker Compose** - Local monolithic development
2. **Minikube** - Local Kubernetes development
3. **DigitalOcean Kubernetes** - Production deployment

### Quick Setup

```bash
# 1. Clone and setup repositories
cd setup/
./setup.sh

# 2. Start with Docker Compose (recommended for beginners)
cd ../dev/
./dev-up.sh

# 3. Progress to Kubernetes when ready
cd ../k8s-dev/
./scripts/dev-up.sh
```

---

## 📁 Project Structure

```
exploresg/
├── README.md                    # Project overview
├── setup/                       # Repository bootstrap
│   ├── setup.sh                # Cross-platform setup script
│   ├── setup.bat               # Windows batch script
│   └── repos.txt               # Repository list
├── dev/                         # Docker Compose development
│   ├── docker-compose.yml      # Development services
│   ├── dev-up.sh               # Smart startup script
│   └── README.md               # Docker development guide
├── k8s-dev/                     # Kubernetes development
│   ├── manifests/              # Kubernetes YAML files
│   ├── scripts/                # Automation scripts
│   ├── config/                 # Configuration files
│   └── README.md               # Kubernetes guide
├── k8s-prod/                    # Production Kubernetes (planned)
│   ├── terraform/              # Infrastructure as Code
│   ├── helm/                   # Helm charts
│   └── manifests/              # Production manifests
├── shared/                      # Shared configurations (planned)
│   ├── configs/                # Common config files
│   └── scripts/                # Shared scripts
└── docs/                        # Comprehensive documentation
    ├── architecture/           # System design
    ├── development/            # Development guides
    ├── deployment/             # Deployment guides
    ├── api/                    # API documentation
    └── guides/                 # How-to guides
```

---

## 🎯 Core Principles

### Infrastructure as Code

- All environments defined in code
- Version controlled configurations
- Reproducible deployments

### Progressive Complexity

- Start simple with Docker Compose
- Progress to Kubernetes development
- Scale to production with confidence

### Developer Experience

- Automated setup scripts
- Comprehensive documentation
- Clear troubleshooting guides

### Production Parity

- Development environments mirror production
- Consistent deployment patterns
- Shared configuration management

---

## 🤝 Contributing

We welcome contributions! Please follow our comprehensive guidelines that demonstrate academic proficiency and professional standards:

### 📋 Prerequisites

1. **Development Setup**: Configure your environment using [development tools guide](development/development-tools.md)
2. **Environment**: Follow the [development setup guide](development/setup.md)

### 🎯 Standards & Practices

3. **Coding Standards**: Adhere to our [comprehensive coding standards](development/coding-standards.md)
4. **Git Workflow**: Follow our [professional git workflow](development/git-workflow.md)
5. **Security & Performance**: Apply [security and performance best practices](development/security-performance.md)

### ✅ Quality Gates

6. **Code Quality**: Maintain >90% test coverage and pass all linting
7. **Security**: Pass security scans and vulnerability checks
8. **Documentation**: Update relevant documentation for all changes
9. **Testing**: Ensure all unit, integration, and E2E tests pass

---

## 📞 Support

### Documentation

- **Architecture Questions**: See [architecture docs](architecture/)
- **Development Issues**: Check [development guides](development/)
- **Deployment Problems**: Review [deployment guides](deployment/)
- **API Usage**: Consult [API documentation](api/)

### Community

- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and community support
- **Wiki**: For additional community-contributed documentation

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🔄 Recent Updates

- **v1.0.0**: Initial release with Docker Compose and Kubernetes development environments
- **Infrastructure**: Complete Kubernetes manifests with production-ready configurations
- **Documentation**: Comprehensive documentation structure established
- **Automation**: Setup scripts for cross-platform development

---

**Happy exploring with XploreSG!** 🇸🇬✨
