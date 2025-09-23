# XploreSG: Ride & Reflect

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/XploreSG/exploresg)

## 🌟 Overview

XploreSG: Ride & Reflect is a smart travel companion application designed specifically for tourists exploring Singapore. This repository serves as the **core infrastructure and orchestration hub** for the XploreSG ecosystem, providing the entry point and management layer for the entire application suite.

Our mission is to revolutionize how tourists experience Singapore by combining practical logistics with immersive exploration, powered by intelligent technology and local insights.

## 🚀 What is XploreSG?

XploreSG transforms the traditional tourist experience by integrating:

- **🏍️ Smart Vehicle Rental**: Seamless motorcycle and car rental logistics
- **🗺️ Curated Route Discovery**: Expertly crafted exploration routes showcasing Singapore's hidden gems
- **📅 Intelligent Calendar Integration**: Smart scheduling that adapts to your travel plans
- **🌤️ Weather-Aware Planning**: Real-time weather integration for optimal trip timing
- **📖 Personal Journey Documentation**: Digital journaling to capture and reflect on experiences
- **🤖 AI-Powered Contextual Intelligence**: Personalized recommendations and insights

## 🏗️ Architecture Overview

This repository serves as the **core infrastructure layer** that orchestrates the entire XploreSG ecosystem:

```
┌─────────────────────────────────────────────────────────┐
│                    XploreSG Core                        │
│              (This Repository)                          │
├─────────────────────────────────────────────────────────┤
│  🎯 Application Orchestration                           │
│  🔄 Service Coordination                                │
│  🌐 API Gateway & Routing                               │
│  🔐 Authentication & Authorization                       │
│  📊 Central Configuration Management                     │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────┬─────────────────┬─────────────────────┐
│   🏍️ Rental     │   🗺️ Routes     │   📱 Mobile App     │
│   Service       │   Service       │   Frontend          │
└─────────────────┴─────────────────┴─────────────────────┘
                              │
                              ▼
┌─────────────────┬─────────────────┬─────────────────────┐
│   🌤️ Weather    │   📖 Journal    │   🤖 AI Insights   │
│   Service       │   Service       │   Service           │
└─────────────────┴─────────────────┴─────────────────────┘
```

## 🛠️ Core Features

### 🎯 Infrastructure Management
- **Service Discovery**: Automatic service registration and health monitoring
- **Load Balancing**: Intelligent request distribution across services
- **Configuration Management**: Centralized configuration for all services
- **API Gateway**: Unified entry point with authentication and rate limiting

### 🔧 Developer Experience
- **Hot Reloading**: Instant development feedback
- **Comprehensive Logging**: Structured logging across all services  
- **Monitoring & Alerting**: Real-time system health and performance metrics
- **Development Environment**: Containerized development setup

### 🔐 Security & Reliability
- **OAuth 2.0 Integration**: Secure authentication flows
- **Rate Limiting**: API protection and fair usage policies
- **Data Encryption**: End-to-end data security
- **Backup & Recovery**: Automated backup strategies

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ (for local development)
- Git

### 🐳 Docker Development (Recommended)
```bash
# Clone the repository
git clone https://github.com/XploreSG/exploresg.git
cd exploresg

# Start the development environment
docker-compose up -d

# View logs
docker-compose logs -f
```

### 💻 Local Development
```bash
# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration

# Start development server
npm run dev

# Run tests
npm test
```

## 📋 Environment Setup

### Required Environment Variables
```env
# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/exploresg
REDIS_URL=redis://localhost:6379

# API Keys
WEATHER_API_KEY=your_weather_service_key
MAPS_API_KEY=your_maps_api_key
AI_SERVICE_KEY=your_ai_service_key

# Security
JWT_SECRET=your_jwt_secret_key
ENCRYPTION_KEY=your_encryption_key

# External Services
RENTAL_SERVICE_URL=http://localhost:3001
ROUTES_SERVICE_URL=http://localhost:3002
JOURNAL_SERVICE_URL=http://localhost:3003
```

## 🔧 Development Workflow

### 1. Service Development
```bash
# Create new service
npm run create:service <service-name>

# Register service
npm run register:service <service-name>

# Start service in development
npm run dev:service <service-name>
```

### 2. API Development
```bash
# Generate API documentation
npm run docs:generate

# Validate API schemas
npm run validate:schemas

# Test API endpoints
npm run test:api
```

### 3. Deployment
```bash
# Build for production
npm run build

# Deploy to staging
npm run deploy:staging

# Deploy to production
npm run deploy:production
```

## 📚 Service Integration

### Adding New Services
1. **Create Service Definition**: Define service contract in `/services/definitions/`
2. **Register Routes**: Add routing configuration in `/routes/`
3. **Configure Health Checks**: Add health check endpoints
4. **Update Documentation**: Document API endpoints and data flows

### Service Communication
Services communicate through:
- **HTTP APIs**: RESTful API calls between services
- **Message Queues**: Asynchronous event processing
- **Shared Database**: Common data access patterns
- **Cache Layer**: Redis-based caching for performance

## 🧪 Testing

```bash
# Unit tests
npm run test:unit

# Integration tests  
npm run test:integration

# End-to-end tests
npm run test:e2e

# Performance tests
npm run test:performance

# Coverage report
npm run test:coverage
```

## 📊 Monitoring & Observability

### Health Monitoring
- Service health checks at `/health`
- Database connectivity monitoring
- External service dependency checks

### Logging
- Structured JSON logging
- Request/response logging
- Error tracking and alerting
- Performance metrics

### Metrics
- API response times
- Service throughput
- Error rates
- Resource utilization

## 🤝 Contributing

We welcome contributions to the XploreSG ecosystem! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards
- Follow ESLint configuration
- Write comprehensive tests
- Update documentation
- Follow semantic versioning

## 📖 Documentation

- [API Documentation](docs/api/README.md)
- [Service Architecture](docs/architecture/README.md)
- [Deployment Guide](docs/deployment/README.md)
- [Troubleshooting](docs/troubleshooting/README.md)

## 🔗 Related Repositories

- [exploresg-mobile](https://github.com/XploreSG/exploresg-mobile) - Mobile application frontend
- [exploresg-rental-service](https://github.com/XploreSG/exploresg-rental-service) - Vehicle rental management
- [exploresg-routes-service](https://github.com/XploreSG/exploresg-routes-service) - Route recommendation engine
- [exploresg-ai-service](https://github.com/XploreSG/exploresg-ai-service) - AI-powered insights and recommendations

## 🆘 Support

- **Documentation**: Check our [docs](docs/) directory
- **Issues**: Report bugs and feature requests in [GitHub Issues](https://github.com/XploreSG/exploresg/issues)
- **Discussions**: Join conversations in [GitHub Discussions](https://github.com/XploreSG/exploresg/discussions)
- **Email**: Contact us at dev@exploresg.com

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Singapore Tourism Board for destination insights
- Local tour operators and guides for route recommendations
- Open source community for amazing tools and libraries
- Beta testers and early users for valuable feedback

---

**Made with ❤️ for Singapore travelers**

*XploreSG: Where every journey becomes a story*