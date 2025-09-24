# New Developer Onboarding Guide

Welcome to XploreSG! 🇸🇬 This guide will help you get up and running as a new developer on the team.

## 👋 Welcome to the Team!

As a new member of the XploreSG development team, you'll be contributing to Singapore's premier exploration platform. This guide will take you through everything you need to know to start contributing effectively.

## 📋 Pre-Onboarding Checklist

Before your first day, please ensure you have:

- [ ] **GitHub Account**: Access to the XploreSG organization
- [ ] **Development Machine**: Laptop with admin privileges
- [ ] **Communication Tools**: Slack, email access
- [ ] **Development Tools**: IDE preference (VS Code recommended)

## 🎯 Day 1: Environment Setup

### Morning Session (2-4 hours)

#### 1. System Setup (30 minutes)

```bash
# Install essential tools
# Windows (using Chocolatey)
choco install git nodejs docker-desktop vscode

# macOS (using Homebrew)
brew install git node docker
brew install --cask visual-studio-code docker

# Linux (Ubuntu)
sudo apt update
sudo apt install git nodejs npm docker.io
```

#### 2. Repository Access (15 minutes)

```bash
# Clone the main repository
git clone https://github.com/XploreSG/exploresg.git
cd exploresg

# Verify access to all repositories
./setup/setup.sh
```

#### 3. Development Environment (45 minutes)

```bash
# Start with Docker Compose (easiest)
cd dev/
./dev-up.sh

# Verify everything is working
curl http://localhost:3001/health
# Should return: {"status": "ok", "timestamp": "..."}
```

#### 4. IDE Setup (30 minutes)

**VS Code Extensions (Required):**

```json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-eslint",
    "ms-kubernetes-tools.vscode-kubernetes-tools",
    "ms-azuretools.vscode-docker"
  ]
}
```

**Configuration:**

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "typescript.preferences.importModuleSpecifier": "relative"
}
```

### Afternoon Session (2-3 hours)

#### 5. Architecture Overview (45 minutes)

Read through these documents:

- [System Architecture](../architecture/overview.md)
- [Database Design](../architecture/database.md)
- [API Documentation](../api/overview.md)

#### 6. First Code Change (60 minutes)

**Exercise: Add a new health check endpoint**

1. **Backend Change** (user-service):

   ```javascript
   // routes/health.js
   router.get("/detailed", async (req, res) => {
     res.json({
       status: "ok",
       timestamp: new Date().toISOString(),
       version: process.env.npm_package_version,
       environment: process.env.NODE_ENV,
       database: "connected", // Add actual DB check
       uptime: process.uptime(),
     });
   });
   ```

2. **Test the endpoint**:

   ```bash
   curl http://localhost:3001/api/v1/health/detailed
   ```

3. **Create your first PR**:
   ```bash
   git checkout -b feature/detailed-health-check
   git add .
   git commit -m "Add detailed health check endpoint"
   git push origin feature/detailed-health-check
   # Create PR on GitHub
   ```

#### 7. Team Introduction (30 minutes)

- **Team Slack Channel**: Join #xploresg-dev
- **Daily Standup**: Tomorrow at 9:00 AM SGT
- **Code Review Process**: All PRs need one approval
- **Questions**: Your buddy will answer any questions

## 📚 Week 1: Learning Path

### Day 2-3: Frontend Development

#### Learn the Frontend Stack

```bash
# Navigate to frontend repository
cd frontend/

# Install dependencies
npm install

# Start development server
npm start
```

**Key Concepts to Learn:**

- React/Vue.js architecture
- State management patterns
- API integration
- Component structure
- Styling approach

**Exercise: Create a simple component**

```jsx
// components/WelcomeCard.jsx
export const WelcomeCard = ({ userName }) => {
  return (
    <div className="welcome-card">
      <h2>Welcome to XploreSG, {userName}!</h2>
      <p>Start exploring Singapore's amazing attractions.</p>
    </div>
  );
};
```

### Day 4-5: Backend Development

#### Learn the Backend Stack

```bash
# Navigate to user-service repository
cd user-service/

# Install dependencies
npm install

# Start development server
npm run dev
```

**Key Concepts to Learn:**

- RESTful API design
- Authentication & authorization
- Database interactions
- Error handling
- Testing patterns

**Exercise: Add a new API endpoint**

```javascript
// controllers/userController.js
exports.getUserStats = async (req, res) => {
  try {
    const userId = req.user.id;
    const stats = await User.findById(userId).select("createdAt lastLoginAt");

    res.json({
      success: true,
      data: {
        memberSince: stats.createdAt,
        lastLogin: stats.lastLoginAt,
        daysAsMember: Math.floor(
          (Date.now() - stats.createdAt) / (1000 * 60 * 60 * 24)
        ),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: { message: "Failed to fetch user stats" },
    });
  }
};
```

## 🏗️ Week 2: Kubernetes & DevOps

### Day 1-2: Kubernetes Basics

```bash
# Setup local Kubernetes environment
cd k8s-dev/
./scripts/dev-up.sh

# Learn kubectl basics
kubectl get pods -n xploresg-dev
kubectl logs deployment/user-service -n xploresg-dev
kubectl describe pod <pod-name> -n xploresg-dev
```

**Key Concepts:**

- Pods, Deployments, Services
- ConfigMaps and Secrets
- Ingress and networking
- Health checks and monitoring

### Day 3-4: CI/CD Pipeline

```yaml
# .github/workflows/feature-branch.yml
name: Feature Branch Tests
on:
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "18"
      - name: Run tests
        run: |
          npm install
          npm run test
          npm run test:integration
```

### Day 5: Production Deployment

- Learn about DigitalOcean infrastructure
- Understand monitoring and alerting
- Practice deployment procedures
- Review security best practices

## 🧪 Week 3: Testing & Quality

### Testing Strategy

```javascript
// tests/integration/auth.test.js
describe("Authentication API", () => {
  test("should register new user", async () => {
    const response = await request(app).post("/api/v1/auth/register").send({
      email: "test@example.com",
      password: "SecurePass123!",
      firstName: "Test",
      lastName: "User",
    });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data.user.email).toBe("test@example.com");
  });
});
```

**Testing Goals:**

- Write unit tests for new features
- Understand integration testing
- Learn E2E testing with Cypress/Playwright
- Code coverage requirements (>80%)

## 🎯 Month 1: First Feature Implementation

### Feature Assignment

You'll be assigned a small feature to implement end-to-end:

**Example: User Preferences**

1. **Database**: Add preferences table
2. **Backend**: Create preferences API
3. **Frontend**: Build preferences UI
4. **Tests**: Write comprehensive tests
5. **Documentation**: Update API docs
6. **Deployment**: Deploy through staging

### Success Criteria

- [ ] Feature works in all environments
- [ ] Code follows team standards
- [ ] Tests pass with >80% coverage
- [ ] Documentation is updated
- [ ] Code review approved by 2 team members
- [ ] Successfully deployed to production

## 👥 Team Structure & Communication

### Team Members

| Role                 | Name   | Slack     | Responsibilities                  |
| -------------------- | ------ | --------- | --------------------------------- |
| **Tech Lead**        | [Name] | @techlead | Architecture, technical decisions |
| **Senior Developer** | [Name] | @senior1  | Code review, mentoring            |
| **DevOps Engineer**  | [Name] | @devops   | Infrastructure, CI/CD             |
| **Product Manager**  | [Name] | @pm       | Requirements, priorities          |

### Communication Channels

- **#xploresg-dev**: Development discussions
- **#xploresg-general**: General team updates
- **#xploresg-deployments**: Deployment notifications
- **#xploresg-alerts**: Production alerts

### Meeting Schedule

| Meeting             | Time             | Frequency | Purpose               |
| ------------------- | ---------------- | --------- | --------------------- |
| **Daily Standup**   | 9:00 AM SGT      | Daily     | Progress updates      |
| **Sprint Planning** | Monday 2:00 PM   | Bi-weekly | Plan upcoming work    |
| **Retrospective**   | Friday 3:00 PM   | Bi-weekly | Process improvement   |
| **Tech Review**     | Thursday 4:00 PM | Weekly    | Technical discussions |

## 📖 Learning Resources

### Required Reading

1. **Week 1**: [Development Setup](../development/setup.md)
2. **Week 2**: [Coding Standards](../development/coding-standards.md)
3. **Week 3**: [Git Workflow](../development/git-workflow.md)
4. **Week 4**: [Deployment Guide](../deployment/overview.md)

### Recommended Learning

- **React/Vue.js**: Official documentation and tutorials
- **Node.js**: Express.js best practices
- **PostgreSQL**: Database optimization techniques
- **Kubernetes**: Official Kubernetes tutorials
- **Testing**: Jest and Cypress documentation

### Internal Training

- **Security Best Practices** (Week 2)
- **Performance Optimization** (Week 4)
- **Singapore Market Knowledge** (Week 6)
- **Advanced Kubernetes** (Month 2)

## 🎯 30-60-90 Day Goals

### 30 Days

- [ ] Complete development environment setup
- [ ] Understand codebase architecture
- [ ] Complete first feature implementation
- [ ] Pass all onboarding assessments

### 60 Days

- [ ] Independently handle feature development
- [ ] Contribute to code reviews
- [ ] Improve existing code and documentation
- [ ] Handle on-call responsibilities

### 90 Days

- [ ] Lead a medium-sized feature implementation
- [ ] Mentor new team members
- [ ] Contribute to technical architecture decisions
- [ ] Identify and implement process improvements

## 🆘 Getting Help

### Your Onboarding Buddy

You've been assigned an onboarding buddy who will:

- Answer questions about code and processes
- Review your initial pull requests
- Help with environment setup issues
- Introduce you to other team members

### Escalation Path

1. **Technical Questions**: Ask your buddy or post in #xploresg-dev
2. **Process Questions**: Ask the Tech Lead or Scrum Master
3. **Urgent Issues**: Contact the on-call engineer
4. **Administrative**: Contact HR or your manager

### Common Issues & Solutions

| Issue                         | Solution                                       |
| ----------------------------- | ---------------------------------------------- |
| **Docker won't start**        | Restart Docker Desktop, check system resources |
| **Database connection fails** | Check if PostgreSQL container is running       |
| **Tests failing locally**     | Ensure test database is properly seeded        |
| **Kubectl access denied**     | Verify kubeconfig and namespace settings       |
| **PR failing CI**             | Check GitHub Actions logs for specific errors  |

## ✅ Onboarding Checklist

### Week 1

- [ ] Development environment working
- [ ] All repositories accessible
- [ ] First PR created and merged
- [ ] Team introductions completed
- [ ] Documentation read

### Week 2

- [ ] Frontend development comfort
- [ ] Backend development comfort
- [ ] Testing practices understood
- [ ] Code review process familiar

### Week 3

- [ ] Kubernetes environment setup
- [ ] CI/CD pipeline understood
- [ ] Production deployment observed
- [ ] Security training completed

### Week 4

- [ ] Independent feature development
- [ ] Code quality standards met
- [ ] Team processes mastered
- [ ] Ready for regular sprint work

## 🎉 Welcome to XploreSG!

Congratulations on joining our team! We're excited to have you help build Singapore's premier exploration platform. Remember:

- **Ask Questions**: No question is too small
- **Take Initiative**: Suggest improvements and new ideas
- **Collaborate**: We succeed as a team
- **Learn Continuously**: Technology and requirements evolve
- **Have Fun**: Building great software should be enjoyable!

Your journey with XploreSG starts now. Let's build something amazing together! 🚀🇸🇬

---

**Next Steps**: Schedule your first 1:1 with your manager and start Day 1 setup! 💪
