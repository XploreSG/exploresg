# XploreSG: Ride & Reflect

## A Modular, Context-Aware Travel Companion

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Architecture](https://img.shields.io/badge/Architecture-Microservices-blue.svg)](https://microservices.io/)
[![DDD](https://img.shields.io/badge/Design-Domain%20Driven-green.svg)](https://domainlanguage.com/ddd/)

**XploreSG** is a smart travel companion app designed for tourists in Singapore. It combines motorcycle and car rental logistics with curated route exploration, calendar integration, weather awareness, journaling, and AI-powered contextual intelligence.



## Project Status 
Frontend Service   : [![CI Frontend - Build, Test & Security Scan](https://github.com/XploreSG/exploresg-frontend-service/actions/workflows/ci.yml/badge.svg)](https://github.com/XploreSG/exploresg-frontend-service/actions/workflows/ci.yml)
<br>
Auth Service       : [![CI Backend - Build, Test & Security Scan](https://github.com/XploreSG/exploresg-auth-service/actions/workflows/ci-java.yml/badge.svg)](https://github.com/XploreSG/exploresg-auth-service/actions/workflows/ci-java.yml)


## 🎯 Project Overview

This capstone project demonstrates mastery of **Software Engineering Principles** (SWE5001) and **Software Architecture & Design** (SWE5006) through a modular, scalable travel companion application.

### Key Features

- 🏍️ **Multi-Modal Rentals**: Motorcycle and car booking with license verification
- 🗺️ **Route Explorer**: Curated scenic routes with POIs and map overlays
- 📅 **Calendar Integration**: Google Calendar sync with contextual planning
- 🌤️ **Weather Awareness**: Real-time forecasts and ride/drive suitability
- 📝 **AI-Powered Journaling**: Gemini-powered summaries and suggestions
- 🏆 **Gamification**: Route completion medals and achievements
- 📊 **Unified Dashboard**: Integrated view of bookings, weather, and notes

## 🏗️ Architecture

### Domain-Driven Design (DDD)

- **Aggregates**: Rental, Route, JourneyLog, User
- **Value Objects**: LicenseClass, WeatherSnapshot
- **Services**: RouteComposer, CalendarSyncService, AIJournalist

### Microservices Architecture

| Service                  | Purpose                            | Technology          |
| ------------------------ | ---------------------------------- | ------------------- |
| **User Service**         | Customer profiles & authentication | Node.js, PostgreSQL |
| **Payment Service**      | Secure payments & billing          | Node.js, PostgreSQL |
| **Rental Service**       | Vehicle booking & fleet management | Node.js, PostgreSQL |
| **Inventory Service**    | Fleet tracking & equipment add-ons | Node.js, PostgreSQL |
| **Notification Service** | Alerts, confirmations & messaging  | Node.js, Redis      |
| **Route Explorer**       | Map overlays & curated routes      | React, MongoDB      |
| **Calendar Sync**        | OAuth2 & event integration         | Python, Redis       |
| **Weather Service**      | Forecasts & suitability alerts     | Go, External APIs   |
| **Journaling**           | Note-taking & sentiment analysis   | Node.js, MongoDB    |
| **AI Assistant**         | Gemini-powered summaries           | Python, Gemini API  |
| **Gamification**         | Medals & achievements              | Node.js, Redis      |
| **Dashboard**            | Unified UI & orchestration         | React, GraphQL      |

### Polyglot Persistence

- **PostgreSQL**: Booking data, user profiles, fleet management
- **MongoDB**: Routes, notes, journaling data
- **Redis**: Caching, sessions, fleet status

## 🚀 Quick Start

### Prerequisites

- **Git** installed and configured
- **SSH keys** set up with GitHub
- **Docker** and **Docker Compose** (for local development)
- **Node.js 18+**, **Python 3.9+**, **Go 1.19+**

### 1. Bootstrap Development Environment

```bash
# Clone this bootstrap repository
git clone git@github.com:XploreSG/exploresg.git
cd exploresg/setup

# Run automated setup to clone all project repositories
chmod +x setup.sh && ./setup.sh
```

This will automatically clone all project repositories to the parent directory:

```
project-exploresg/
├── exploresg/                    # This bootstrap repo
├── exploresg-frontend-service/   # React frontend
├── exploresg-user-service/       # Customer profiles & authentication
├── exploresg-payment-service/    # Secure payments & billing
├── exploresg-rental-service/     # Vehicle booking & fleet management
├── exploresg-inventory-service/  # Fleet tracking & equipment add-ons
├── exploresg-notification-service/ # Alerts, confirmations & messaging
├── exploresg-route-service/      # Route exploration & map overlays
├── exploresg-calendar-service/   # Calendar integration & OAuth2
├── exploresg-weather-service/    # Weather forecasts & alerts
├── exploresg-journal-service/    # Journaling & AI summaries
├── exploresg-gamification-service/ # Medals & achievements
└── exploresg-api-gateway/        # API orchestration & routing
```

### 2. Local Development Setup

```bash
# Navigate to development environment
cd dev/

# Start all services (databases, backend, frontend)
./dev-up.sh

# Access the application
# Frontend: http://localhost:3000
# API Gateway: http://localhost:3009
```

**What the dev environment includes:**

- 🗄️ **Databases**: PostgreSQL, MongoDB, Redis
- 🔧 **8 Backend Services**: All microservices running with hot reload
- 🌐 **Frontend**: React app with live development server
- ⚙️ **API Gateway**: Service orchestration and routing

**Stop the environment:**

```bash
./dev-down.sh
```

## 📋 Use Cases

| ID  | Use Case         | SWE5001 Focus               | SWE5006 Focus                 |
| --- | ---------------- | --------------------------- | ----------------------------- |
| UC1 | Book Motorcycle  | Requirements, BDD, CI/CD    | DDD, API orchestration        |
| UC2 | Book Car         | Requirements, BDD, CI/CD    | DDD, polymorphic booking      |
| UC3 | Explore Route    | UX modeling, testable flows | Map overlays, modular service |
| UC4 | Calendar Sync    | OAuth, user context         | External API integration      |
| UC5 | Weather Planning | Alerting, fallback logic    | Value object modeling         |
| UC6 | Daily Briefing   | AI prompt engineering       | Gemini orchestration          |
| UC7 | Journal Ride     | Sentiment analysis, UX      | Domain enrichment             |
| UC8 | Earn Medals      | Gamification logic          | Event-driven architecture     |
| UC9 | Dashboard View   | Aggregated UX               | Cross-service orchestration   |

## 🛠️ Development Workflow

### Software Engineering Principles (SWE5001)

- **BDD/TDD**: Behavior-driven scenarios with testable acceptance criteria
- **Version Control**: Trunk-based development with semantic versioning
- **CI/CD**: Automated testing, PR workflow, deployment pipelines
- **Documentation**: Structured domain models and architectural diagrams

### Architecture & Design (SWE5006)

- **Domain-Driven Design**: Clear bounded contexts and aggregates
- **OOAD Patterns**: Strategy, Observer, Factory patterns
- **API Integration**: Google Calendar, Weather API, Stripe, Gemini
- **Scalability**: Designed for multilingual UX and guided tours

## 📊 Sprint Timeline

| Week       | Sprint Goal                                |
| ---------- | ------------------------------------------ |
| **Week 1** | Architecture, domain modeling, MVP scoping |
| **Week 2** | Motorcycle and car booking flow            |
| **Week 3** | Route explorer and map overlays            |
| **Week 4** | Calendar and weather integration           |
| **Week 5** | Journaling and AI summaries                |
| **Week 6** | Dashboard, polish, demo preparation        |

## 🧪 Testing Strategy

### Behavior-Driven Development

```gherkin
Feature: Motorcycle Booking
  Scenario: Valid license verification
    Given a user with valid Class 2B license
    When they select a motorcycle for rental
    Then the booking should be confirmed
    And fleet availability should be updated
```

### Test Coverage

- **Unit Tests**: Individual service logic
- **Integration Tests**: API contracts and database interactions
- **E2E Tests**: Complete user journeys
- **Performance Tests**: Sub-300ms response targets

## 🌟 Key Differentiators

### Technical Excellence

- **Modular Architecture**: 10-12 cleanly bounded services
- **Contextual Intelligence**: Calendar and weather-aware planning
- **AI Integration**: Gemini-powered insights and summaries
- **Multi-Modal Support**: Motorcycles and cars with unified UX

### Software Engineering Rigor

- **Clean Code**: SOLID principles and design patterns
- **Process Alignment**: JIRA workflow with PR checklist
- **Documentation**: Comprehensive domain models
- **Extensibility**: Plugin architecture for future features

## 📚 Documentation

- **[Architecture Documentation](./docs/architecture.md)** - System design and patterns
- **[API Documentation](./docs/api.md)** - Service contracts and endpoints
- **[Development Guide](./docs/development.md)** - Setup and contribution guidelines
- **[Domain Models](./docs/domain.md)** - DDD aggregates and value objects

## 🤝 Contributing

1. **Fork** the relevant service repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** changes: `git commit -m 'Add amazing feature'`
4. **Push** to branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request with detailed description

See our [Contribution Guidelines](./CONTRIBUTING.md) for detailed workflow.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## 🎓 Academic Context

**Course**: Software Engineering Principles (SWE5001) & Software Architecture & Design (SWE5006)  
**Duration**: 6-week Capstone Sprint  
**Focus**: Modular design, behavioral depth, architectural clarity

## 📞 Contact

**Team Lead & Architect**: Sreeraj  
**Email**: sreeraj_ec@hotmail.com  
**GitHub**: [@XploreSG](https://github.com/XploreSG)

---

_XploreSG: Where technology meets exploration in the Lion City_ 🦁🚀
