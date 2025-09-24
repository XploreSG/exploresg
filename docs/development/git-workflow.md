# Git Workflow & Collaboration Guide

## 🎯 Overview

This document establishes comprehensive Git workflow practices for XploreSG that demonstrate academic proficiency in version control, collaboration, and software engineering best practices. Our workflow ensures code quality, traceability, and seamless team collaboration while showcasing professional development standards.

## 🌟 Academic Excellence in Version Control

### Core Principles

- **Atomic Commits**: Each commit represents a single, complete change
- **Semantic History**: Git history tells the story of project evolution
- **Collaborative Excellence**: Workflow supports multiple developers efficiently
- **Quality Gates**: Every change goes through proper review and validation
- **Traceability**: Complete audit trail from requirement to deployment

## 🌊 Git Flow Strategy

### Branch Structure

```
main (production)
├── develop (integration)
│   ├── feature/user-authentication
│   ├── feature/location-search
│   ├── feature/review-system
│   └── hotfix/security-patch-2024-01
├── release/v1.2.0
└── hotfix/critical-bug-fix
```

### Branch Types & Naming Conventions

#### Main Branches

- **`main`**: Production-ready code, always deployable
- **`develop`**: Integration branch for features, reflects next release state

#### Supporting Branches

##### Feature Branches

```bash
# Naming convention: feature/<scope>-<description>
feature/auth-jwt-implementation
feature/ui-location-cards-redesign
feature/api-search-optimization
feature/db-user-profile-schema

# Branch from and merge to: develop
git checkout develop
git checkout -b feature/auth-jwt-implementation
```

##### Release Branches

```bash
# Naming convention: release/v<major>.<minor>.<patch>
release/v1.2.0
release/v2.0.0-beta

# Branch from: develop
# Merge to: main and develop
git checkout develop
git checkout -b release/v1.2.0
```

##### Hotfix Branches

```bash
# Naming convention: hotfix/<severity>-<description>
hotfix/critical-sql-injection
hotfix/minor-ui-bug-fix
hotfix/security-auth-bypass

# Branch from: main
# Merge to: main and develop
git checkout main
git checkout -b hotfix/critical-sql-injection
```

## 📝 Commit Message Standards

### Conventional Commits Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Commit Types

| Type         | Description              | Example                                            |
| ------------ | ------------------------ | -------------------------------------------------- |
| **feat**     | New feature              | `feat(auth): implement JWT authentication`         |
| **fix**      | Bug fix                  | `fix(api): resolve user search pagination issue`   |
| **docs**     | Documentation            | `docs(api): update authentication endpoints`       |
| **style**    | Code style changes       | `style(ui): format component files with prettier`  |
| **refactor** | Code refactoring         | `refactor(service): extract user validation logic` |
| **perf**     | Performance improvements | `perf(db): optimize location search queries`       |
| **test**     | Add or update tests      | `test(auth): add JWT validation test cases`        |
| **build**    | Build system changes     | `build(docker): update Node.js to v20 LTS`         |
| **ci**       | CI/CD changes            | `ci(github): add automated security scanning`      |
| **chore**    | Maintenance tasks        | `chore(deps): update typescript to v5.3.0`         |

### Commit Message Examples

#### ✅ Good Commit Messages

```bash
# Feature addition with scope and detailed description
feat(auth): implement OAuth2 social login integration

Add support for Google and Facebook OAuth2 authentication:
- Integrate passport-google-oauth20 and passport-facebook strategies
- Create OAuth callback handlers with proper error handling
- Update user schema to support social login profiles
- Add comprehensive test coverage for OAuth flows

Closes #123

# Bug fix with technical details
fix(api): resolve race condition in user registration

Fix concurrent user registration attempts with same email causing
database constraint violations. Add proper transaction handling
and optimistic locking to prevent duplicate user creation.

- Add database transaction wrapper for user creation
- Implement retry logic for concurrent registration attempts
- Update error handling to provide clear user feedback
- Add integration tests for concurrent registration scenarios

Fixes #456
Related to #789

# Performance improvement with metrics
perf(search): optimize location search with spatial indexing

Improve search performance from 2.5s to 150ms for location queries:
- Add PostGIS spatial indexes on coordinates columns
- Implement efficient radius-based search queries
- Add query result caching with Redis (5min TTL)
- Update API to support pagination for large result sets

Benchmarks:
- Before: 2.5s average, 5.2s p95
- After: 150ms average, 300ms p95

Addresses #321
```

#### ❌ Poor Commit Messages

```bash
# Too vague, no context
"fix bug"
"update code"
"changes"

# No type prefix, unclear scope
"updated user authentication stuff"
"made search work better"

# Missing details for complex changes
"refactor: code improvements"
"feat: new feature"
```

## 🔄 Workflow Processes

### Feature Development Workflow

#### 1. Create Feature Branch

```bash
# Ensure develop is up to date
git checkout develop
git pull origin develop

# Create and checkout feature branch
git checkout -b feature/user-profile-management

# Set up tracking
git push -u origin feature/user-profile-management
```

#### 2. Development Process

```bash
# Make atomic commits frequently
git add src/services/user.service.ts
git commit -m "feat(user): add user profile creation service

Implement UserService.createProfile method with validation:
- Add profile schema validation using Joi
- Implement secure image upload handling
- Add comprehensive error handling for invalid data
- Include JSDoc documentation for all public methods"

# Keep feature branch updated with develop
git fetch origin
git merge origin/develop

# Or use rebase for cleaner history (if no conflicts expected)
git rebase origin/develop
```

#### 3. Pre-Pull Request Checklist

```bash
# Run comprehensive checks before creating PR
npm run lint                # ESLint validation
npm run format:check        # Prettier formatting check
npm run type-check         # TypeScript compilation
npm run test               # Unit tests
npm run test:integration   # Integration tests
npm run test:e2e          # End-to-end tests
npm run build             # Production build verification

# Update documentation if needed
npm run docs:generate     # Generate API documentation
```

#### 4. Pull Request Creation

```markdown
<!-- Pull Request Template -->

## 🎯 Overview

Brief description of the changes and motivation.

## 📋 Changes Made

- [ ] Added user profile creation endpoint
- [ ] Implemented profile image upload with validation
- [ ] Added comprehensive test coverage (95%+)
- [ ] Updated API documentation

## 🧪 Testing

- [ ] Unit tests passing (96% coverage)
- [ ] Integration tests passing
- [ ] E2E tests passing
- [ ] Manual testing completed

## 📸 Screenshots

<!-- Include relevant screenshots for UI changes -->

## 🔗 Related Issues

Closes #123
Related to #456

## 📝 Review Checklist

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or properly documented)
```

### Code Review Process

#### Review Guidelines for Authors

```markdown
### Before Requesting Review

- [ ] Self-review completed thoroughly
- [ ] All tests pass locally
- [ ] Documentation is updated
- [ ] Code is properly formatted
- [ ] Commit messages follow conventions
- [ ] No commented-out code or debug statements
- [ ] Security considerations addressed

### During Review Process

- [ ] Respond to feedback promptly and professionally
- [ ] Ask clarifying questions when needed
- [ ] Make requested changes in separate commits
- [ ] Update tests when changing logic
- [ ] Acknowledge all feedback before dismissing
```

#### Review Guidelines for Reviewers

```markdown
### Review Focus Areas

- [ ] **Functionality**: Does the code work as intended?
- [ ] **Security**: Are there any security vulnerabilities?
- [ ] **Performance**: Are there performance implications?
- [ ] **Maintainability**: Is the code readable and maintainable?
- [ ] **Testing**: Is test coverage adequate and meaningful?
- [ ] **Documentation**: Is the code properly documented?

### Providing Feedback

- Use constructive, specific language
- Explain the "why" behind suggestions
- Distinguish between required changes and suggestions
- Acknowledge good practices and improvements
- Provide code examples when helpful

### Example Review Comments
```

#### ✅ Good Review Comments

````markdown
**Required Change - Security:**

```typescript
// Current code allows any file type upload
const uploadResult = await uploadFile(file);

// Suggested improvement for security
const allowedTypes = ["image/jpeg", "image/png", "image/webp"];
if (!allowedTypes.includes(file.mimetype)) {
  throw new ValidationError(
    "Invalid file type. Only JPEG, PNG, and WebP are allowed."
  );
}
```
````

**Suggestion - Performance:**
Consider using `Promise.all()` here to execute these independent database calls in parallel:

```typescript
// Instead of sequential calls
const user = await userRepository.findById(id);
const profile = await profileRepository.findByUserId(id);

// Use parallel execution
const [user, profile] = await Promise.all([
  userRepository.findById(id),
  profileRepository.findByUserId(id),
]);
```

**Nitpick - Code Style:**
Minor naming suggestion: `userData` might be more descriptive than `data` for this parameter.

**Praise:**
Great job implementing comprehensive error handling here! The custom error types make debugging much easier.

````

#### ❌ Poor Review Comments
```markdown
"This is wrong"
"Fix this"
"Use better naming"
"Add tests"
````

### Merge Strategies

#### For Feature Branches

```bash
# Use squash and merge for clean history
git checkout develop
git merge --squash feature/user-profile-management
git commit -m "feat(user): implement user profile management

Complete user profile management implementation:
- Add profile creation and update endpoints
- Implement secure image upload with validation
- Add comprehensive test coverage (96%)
- Update API documentation and user guides

Closes #123"
```

#### For Release Branches

```bash
# Use merge commit to preserve release history
git checkout main
git merge --no-ff release/v1.2.0
git tag -a v1.2.0 -m "Release v1.2.0

New Features:
- User profile management
- Enhanced location search
- Review system improvements

Bug Fixes:
- Fixed authentication session timeout
- Resolved search pagination issues

Performance:
- 40% improvement in search query response time
- Optimized image loading and caching"

# Also merge back to develop
git checkout develop
git merge main
```

## 🏷️ Tagging & Versioning

### Semantic Versioning (SemVer)

```
v<MAJOR>.<MINOR>.<PATCH>[-<PRE-RELEASE>][+<BUILD>]

Examples:
v1.0.0          # Initial release
v1.1.0          # New features, backward compatible
v1.1.1          # Bug fixes, backward compatible
v2.0.0          # Breaking changes
v2.0.0-beta.1   # Pre-release version
v2.0.0+20240115 # Build metadata
```

### Tagging Process

```bash
# Create annotated tag for release
git tag -a v1.2.0 -m "Release v1.2.0

Features Added:
- JWT authentication system
- Location-based search with maps integration
- User review and rating system
- Admin dashboard for content management

Improvements:
- 50% faster API response times
- Enhanced mobile responsive design
- Improved accessibility (WCAG 2.1 AA compliant)

Bug Fixes:
- Fixed user session timeout issues
- Resolved search result pagination
- Corrected map marker clustering

Breaking Changes:
- API endpoint restructure (/api/v1/ to /api/v2/)
- Updated authentication token format
- Changed user profile schema

Migration Guide: docs/migration/v1.1-to-v1.2.md
API Documentation: docs/api/v1.2.0/
"

# Push tags to remote
git push origin v1.2.0
git push origin --tags
```

## 🚀 Release Management

### Release Process

#### 1. Release Planning

```bash
# Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/v1.3.0

# Update version numbers
npm version minor  # Updates package.json
```

#### 2. Release Preparation

```bash
# Update CHANGELOG.md
echo "## [1.3.0] - $(date +%Y-%m-%d)

### Added
- New location recommendation engine
- Social sharing functionality
- Offline map caching

### Changed
- Improved search algorithm performance
- Updated UI design system
- Enhanced error messaging

### Fixed
- Memory leak in map component
- Authentication token refresh issue
- Mobile navigation bug

### Security
- Updated dependencies with security patches
- Enhanced input validation
- Implemented rate limiting" >> CHANGELOG.md

# Update documentation
npm run docs:generate
git add docs/ CHANGELOG.md package*.json
git commit -m "chore(release): prepare v1.3.0 release

- Update version to 1.3.0
- Generate updated API documentation
- Add comprehensive changelog
- Update dependency versions"
```

#### 3. Release Testing

```bash
# Comprehensive testing suite
npm run test:all          # All test suites
npm run test:security     # Security vulnerability scan
npm run test:performance  # Performance benchmarks
npm run build:production  # Production build validation

# Manual testing checklist
# - Authentication flows
# - Core user journeys
# - Mobile responsiveness
# - Cross-browser compatibility
# - API endpoint validation
```

#### 4. Release Deployment

```bash
# Merge to main and tag
git checkout main
git merge --no-ff release/v1.3.0
git tag -a v1.3.0 -m "Release v1.3.0 - Enhanced Location Discovery"
git push origin main --tags

# Merge back to develop
git checkout develop
git merge main
git push origin develop

# Clean up release branch
git branch -d release/v1.3.0
git push origin --delete release/v1.3.0
```

## 🔧 Git Configuration

### Repository Setup

```bash
# Clone with proper configuration
git clone https://github.com/xploresg/xploresg.git
cd xploresg

# Configure user information
git config user.name "Your Full Name"
git config user.email "your.email@example.com"

# Configure line endings (important for cross-platform development)
git config core.autocrlf input  # Linux/Mac
git config core.autocrlf true   # Windows

# Configure merge strategy
git config pull.rebase false
git config merge.ff false

# Configure helpful aliases
git config alias.st "status -sb"
git config alias.co "checkout"
git config alias.br "branch"
git config alias.ci "commit"
git config alias.unstage "reset HEAD --"
git config alias.last "log -1 HEAD"
git config alias.visual "!gitk"
git config alias.lg "log --oneline --graph --decorate --all"
```

### Git Hooks Setup

```bash
# Pre-commit hook to ensure code quality
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
# Pre-commit hook for XploreSG

echo "🔍 Running pre-commit checks..."

# Check for staged files
if git diff --staged --quiet; then
    echo "❌ No staged changes found. Use 'git add' to stage files."
    exit 1
fi

# Run linting
echo "📝 Running ESLint..."
npm run lint:staged
if [ $? -ne 0 ]; then
    echo "❌ ESLint failed. Please fix linting errors before committing."
    exit 1
fi

# Run formatting check
echo "🎨 Checking code formatting..."
npm run format:check:staged
if [ $? -ne 0 ]; then
    echo "❌ Code formatting issues found. Run 'npm run format' to fix."
    exit 1
fi

# Run type checking
echo "🔍 Running TypeScript type check..."
npm run type-check
if [ $? -ne 0 ]; then
    echo "❌ TypeScript type errors found. Please fix before committing."
    exit 1
fi

# Run tests for staged files
echo "🧪 Running tests..."
npm run test:staged
if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Please fix failing tests before committing."
    exit 1
fi

echo "✅ All pre-commit checks passed!"
EOF

# Make hook executable
chmod +x .git/hooks/pre-commit
```

### Commit Message Template

```bash
# Set up commit message template
cat > .gitmessage << 'EOF'
# <type>[optional scope]: <description>
#
# [optional body]
#
# [optional footer(s)]
#
# Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
# Scope: auth, api, ui, db, search, etc.
#
# Examples:
# feat(auth): implement OAuth2 Google login integration
# fix(api): resolve user search pagination issue
# docs(readme): update installation instructions
#
# Body should explain motivation, what changed, and impact:
# - Use imperative mood ("Add feature" not "Added feature")
# - Wrap at 72 characters
# - Reference issues and pull requests liberally after the first line
#
# Footer for breaking changes:
# BREAKING CHANGE: API endpoint /users is now /api/v2/users
#
# Footer for issues:
# Fixes #123
# Closes #456, #789
# Related to #321
EOF

# Configure Git to use the template
git config commit.template .gitmessage
```

## 📊 Git Analytics & Insights

### Useful Git Commands for Project Insights

#### Repository Statistics

```bash
# Contributor statistics
git shortlog -sn --all --no-merges

# File change frequency (most edited files)
git log --name-only --pretty=format: | grep -v '^$' | sort | uniq -c | sort -rn | head -20

# Lines of code by author
git log --author="Author Name" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }'

# Commit activity by date
git log --format='%ai' | cut -d' ' -f1 | sort | uniq -c

# Branch commit comparison
git log --oneline develop ^main  # Commits in develop not in main
```

#### Code Quality Analysis

```bash
# Find large files in repository
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | sed -n 's/^blob //p' | sort --numeric-sort --key=2 | tail -20

# Find commits that touch specific files
git log --follow --patch -- src/services/user.service.ts

# Search commit messages for keywords
git log --grep="security" --oneline --all

# Find commits by specific author in date range
git log --author="John Doe" --since="2024-01-01" --until="2024-01-31" --oneline
```

## 🔒 Security Best Practices

### Sensitive Data Protection

```bash
# .gitignore for security-sensitive files
cat > .gitignore << 'EOF'
# Environment files
.env
.env.local
.env.*.local

# Security keys and certificates
*.key
*.pem
*.p12
*.crt
secrets/
certs/

# Configuration files with sensitive data
config/production.json
config/local.json

# IDE and OS files
.vscode/settings.json
.idea/
*.swp
*.swo
*~

# Dependencies
node_modules/
npm-debug.log*

# Build outputs
dist/
build/
coverage/

# Temporary files
*.tmp
*.temp
*.log
EOF

# Configure Git to ignore file permission changes (if needed)
git config core.fileMode false
```

### Credential Management

```bash
# Use Git credential manager
git config credential.helper manager-core

# For SSH key setup (recommended for enhanced security)
ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/xploresg_ed25519
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/xploresg_ed25519

# Test SSH connection
ssh -T git@github.com
```

## 📈 Continuous Integration Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18.x, 20.x]

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0 # Full history for better analysis

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run linting
        run: npm run lint

      - name: Run type checking
        run: npm run type-check

      - name: Run unit tests
        run: npm run test:coverage

      - name: Run integration tests
        run: npm run test:integration

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run security audit
        run: npm audit --audit-level high

      - name: Run Snyk security scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

This comprehensive Git workflow guide establishes professional-grade version control practices that demonstrate academic proficiency while ensuring practical effectiveness for team collaboration and project management.
