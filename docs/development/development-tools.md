# Development Tools & Environment Setup

## 🎯 Overview

This guide establishes a comprehensive development environment for XploreSG that showcases academic proficiency through industry-leading tools, automated workflows, and best practices. Our development environment ensures consistency, productivity, and code quality across all team members while demonstrating professional software engineering standards.

## 🏛️ Academic Excellence Through Tooling

### Development Philosophy

- **Consistency**: Standardized environments prevent "works on my machine" issues
- **Automation**: Reduce manual tasks and human error through tooling
- **Quality**: Enforce standards through automated checking and validation
- **Productivity**: Optimize developer experience and workflow efficiency
- **Collaboration**: Enable seamless team development and knowledge sharing

## 💻 Required Development Environment

### System Requirements

#### Hardware Specifications

- **CPU**: 8+ cores recommended (4+ cores minimum)
- **RAM**: 16GB+ recommended (8GB minimum)
- **Storage**: 512GB+ SSD (256GB minimum)
- **Display**: 1920x1080+ resolution (dual monitors recommended)

#### Operating System Support

- **Windows**: Windows 10/11 with WSL2
- **macOS**: macOS 12+ (Monterey or newer)
- **Linux**: Ubuntu 20.04+ / Fedora 35+ / Arch Linux

### Core Development Tools

#### 1. Node.js & Package Management

```bash
# Install Node.js via Node Version Manager (recommended)

# For Windows (using nvm-windows)
# Download and install from: https://github.com/coreybutler/nvm-windows
nvm install 20.10.0
nvm use 20.10.0
nvm alias default 20.10.0

# For macOS/Linux (using nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20.10.0
nvm use 20.10.0
nvm alias default 20.10.0

# Verify installation
node --version  # Should output v20.10.0
npm --version   # Should output 10.2.x+

# Configure npm for better security and performance
npm config set fund false
npm config set audit-level moderate
npm config set cache ~/.npm-cache
npm config set registry https://registry.npmjs.org/

# Install pnpm for better dependency management (optional but recommended)
npm install -g pnpm@latest
```

#### 2. Git Version Control

```bash
# Install Git (if not already installed)
# Windows: Download from https://git-scm.com/
# macOS: brew install git
# Ubuntu/Debian: sudo apt install git
# Fedora: sudo dnf install git

# Verify installation
git --version  # Should be 2.40.0+

# Global Git configuration
git config --global user.name "Your Full Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.autocrlf input  # Linux/Mac
# git config --global core.autocrlf true   # Windows

# Configure Git aliases for productivity
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.lg 'log --oneline --graph --decorate --all'
git config --global alias.contributors 'shortlog -sn --all --no-merges'
```

#### 3. Visual Studio Code Setup

```bash
# Install VS Code
# Download from: https://code.visualstudio.com/

# Essential Extensions (install via command palette or CLI)
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension bradlc.vscode-tailwindcss
code --install-extension ms-vscode.vscode-json
code --install-extension redhat.vscode-yaml
code --install-extension ms-vscode.vscode-markdown
code --install-extension yzhang.markdown-all-in-one
code --install-extension shd101wyy.markdown-preview-enhanced
code --install-extension ms-playwright.playwright
code --install-extension ms-vscode.vscode-jest
code --install-extension humao.rest-client
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension github.vscode-pull-request-github
code --install-extension github.copilot
code --install-extension github.copilot-chat
code --install-extension eamodio.gitlens
code --install-extension christian-kohler.path-intellisense
code --install-extension bradlc.vscode-tailwindcss
code --install-extension prisma.prisma
code --install-extension ms-vscode.vscode-docker
```

#### VS Code Settings Configuration

```json
// .vscode/settings.json
{
  // Editor Configuration
  "editor.fontSize": 14,
  "editor.fontFamily": "'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace",
  "editor.fontLigatures": true,
  "editor.lineHeight": 1.6,
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false,
  "editor.wordWrap": "bounded",
  "editor.wordWrapColumn": 100,
  "editor.rulers": [80, 120],
  "editor.minimap.enabled": true,
  "editor.minimap.maxColumn": 100,

  // File Management
  "files.autoSave": "onFocusChange",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "files.eol": "\n",
  "files.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/.git": true,
    "**/.DS_Store": true,
    "**/Thumbs.db": true,
    "**/.next": true,
    "**/.nuxt": true,
    "**/coverage": true
  },

  // Search Configuration
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/coverage": true,
    "**/*.log": true
  },

  // TypeScript Configuration
  "typescript.preferences.quoteStyle": "single",
  "typescript.preferences.importModuleSpecifier": "relative",
  "typescript.updateImportsOnFileMove.enabled": "always",
  "typescript.suggest.autoImports": true,
  "typescript.suggest.paths": true,

  // JavaScript Configuration
  "javascript.preferences.quoteStyle": "single",
  "javascript.updateImportsOnFileMove.enabled": "always",
  "javascript.suggest.autoImports": true,

  // Formatting Configuration
  "editor.formatOnSave": true,
  "editor.formatOnPaste": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true,
    "source.organizeImports": true,
    "source.removeUnusedImports": true
  },

  // Prettier Configuration
  "prettier.configPath": "./.prettierrc",
  "prettier.requireConfig": true,
  "prettier.useEditorConfig": false,
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[yaml]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[markdown]": {
    "editor.defaultFormatter": "yzhang.markdown-all-in-one"
  },

  // ESLint Configuration
  "eslint.workingDirectories": ["./"],
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],

  // Terminal Configuration
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.fontFamily": "'JetBrains Mono', 'Fira Code', monospace",
  "terminal.integrated.shell.windows": "powershell.exe",

  // Git Configuration
  "git.autofetch": true,
  "git.confirmSync": false,
  "git.enableSmartCommit": true,
  "git.suggestSmartCommit": false,
  "gitlens.showWelcomeOnInstall": false,
  "gitlens.showWhatsNewAfterUpgrades": false,

  // Explorer Configuration
  "explorer.confirmDragAndDrop": false,
  "explorer.confirmDelete": false,
  "explorer.fileNesting.enabled": true,
  "explorer.fileNesting.patterns": {
    "*.ts": "${capture}.js, ${capture}.d.ts, ${capture}.js.map",
    "*.tsx": "${capture}.js, ${capture}.jsx",
    "package.json": "package-lock.json, pnpm-lock.yaml, yarn.lock",
    "tsconfig.json": "tsconfig.*.json",
    ".eslintrc.js": ".eslintrc.*, .eslintignore",
    ".prettierrc": ".prettierignore",
    "README.md": "README.*, CHANGELOG.md, LICENSE*",
    "docker-compose.yml": "docker-compose.*.yml, Dockerfile*",
    ".env": ".env.*"
  },

  // Language-specific settings
  "emmet.includeLanguages": {
    "typescript": "html",
    "typescriptreact": "html"
  },

  // Theme and UI
  "workbench.colorTheme": "Default Dark Modern",
  "workbench.iconTheme": "vs-seti",
  "workbench.editor.enablePreview": false,
  "workbench.editor.closeOnFileDelete": true,
  "workbench.startupEditor": "newUntitledFile",

  // Security
  "security.workspace.trust.untrustedFiles": "prompt",
  "extensions.ignoreRecommendations": false,

  // Performance
  "typescript.disableAutomaticTypeAcquisition": false,
  "search.searchOnType": false,
  "search.smartCase": true
}
```

#### VS Code Extensions Configuration

```json
// .vscode/extensions.json
{
  "recommendations": [
    // Essential Development
    "ms-vscode.vscode-typescript-next",
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",

    // React & Frontend
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-react-native",
    "formulahendry.auto-rename-tag",
    "christian-kohler.path-intellisense",

    // Testing & Quality
    "ms-playwright.playwright",
    "ms-vscode.vscode-jest",
    "humao.rest-client",
    "streetsidesoftware.code-spell-checker",

    // Git & Collaboration
    "eamodio.gitlens",
    "github.vscode-pull-request-github",
    "github.copilot",
    "github.copilot-chat",

    // Documentation
    "yzhang.markdown-all-in-one",
    "shd101wyy.markdown-preview-enhanced",
    "bierner.jsdoc-markdown-highlighting",

    // DevOps & Containers
    "ms-vscode-remote.remote-containers",
    "ms-vscode-remote.remote-wsl",
    "ms-vscode.vscode-docker",

    // Database & Backend
    "prisma.prisma",
    "ms-vscode.vscode-postgresql",

    // Productivity
    "ms-vscode.vscode-thunder-client",
    "alefragnani.bookmarks",
    "gruntfuggly.todo-tree"
  ],
  "unwantedRecommendations": ["ms-vscode.vscode-typescript"]
}
```

## 🛠️ Project Development Setup

### 1. Initial Project Setup

```bash
# Clone the repository
git clone https://github.com/xploresg/xploresg.git
cd xploresg

# Checkout to develop branch
git checkout develop

# Install dependencies
npm install  # or pnpm install

# Copy environment configuration
cp .env.example .env.local

# Set up Git hooks
npm run prepare  # Installs husky git hooks

# Verify setup
npm run dev  # Should start development server
npm run test  # Should run test suite
npm run lint  # Should run linting
```

### 2. Environment Configuration

```bash
# .env.local (local development)
NODE_ENV=development
PORT=3000

# Database Configuration
DATABASE_URL="postgresql://username:password@localhost:5432/xploresg_dev"
DATABASE_SSL=false

# Redis Configuration (for caching)
REDIS_URL="redis://localhost:6379"

# Authentication
JWT_SECRET="your-super-secure-jwt-secret-here"
JWT_EXPIRATION="7d"
REFRESH_TOKEN_EXPIRATION="30d"

# External APIs
GOOGLE_MAPS_API_KEY="your-google-maps-api-key"
OPENAI_API_KEY="your-openai-api-key"
SENDGRID_API_KEY="your-sendgrid-api-key"

# File Upload
CLOUDINARY_CLOUD_NAME="your-cloudinary-cloud-name"
CLOUDINARY_API_KEY="your-cloudinary-api-key"
CLOUDINARY_API_SECRET="your-cloudinary-api-secret"

# Monitoring & Analytics
SENTRY_DSN="your-sentry-dsn"
GA_TRACKING_ID="your-google-analytics-id"

# Development Tools
LOG_LEVEL="debug"
ENABLE_SWAGGER=true
ENABLE_CORS=true
```

### 3. Database Setup

```bash
# Install PostgreSQL locally
# Windows: Download from https://www.postgresql.org/download/windows/
# macOS: brew install postgresql
# Linux: sudo apt install postgresql postgresql-contrib

# Start PostgreSQL service
# Windows: Start via Services app
# macOS: brew services start postgresql
# Linux: sudo systemctl start postgresql

# Create development database
createdb xploresg_dev
createdb xploresg_test

# Run database migrations
npm run db:migrate

# Seed development data
npm run db:seed

# Verify database connection
npm run db:status
```

### 4. Redis Setup (for caching)

```bash
# Install Redis
# Windows: Use Redis Stack (https://redis.io/docs/stack/get-started/install/on-windows/)
# macOS: brew install redis
# Linux: sudo apt install redis-server

# Start Redis service
# Windows: redis-server
# macOS: brew services start redis
# Linux: sudo systemctl start redis

# Verify Redis connection
redis-cli ping  # Should return PONG
```

## 🔧 Development Tools Configuration

### Package.json Scripts

```json
{
  "scripts": {
    // Development
    "dev": "next dev",
    "dev:debug": "NODE_OPTIONS='--inspect' next dev",
    "build": "next build",
    "start": "next start",
    "clean": "rimraf .next dist coverage",

    // Testing
    "test": "jest --passWithNoTests",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:integration": "jest --config jest.integration.config.js",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:all": "npm run test:coverage && npm run test:integration && npm run test:e2e",

    // Code Quality
    "lint": "next lint",
    "lint:fix": "next lint --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "type-check": "tsc --noEmit",
    "validate": "npm run type-check && npm run lint && npm run test",

    // Database
    "db:generate": "prisma generate",
    "db:migrate": "prisma migrate dev",
    "db:migrate:deploy": "prisma migrate deploy",
    "db:seed": "prisma db seed",
    "db:studio": "prisma studio",
    "db:reset": "prisma migrate reset",
    "db:status": "prisma migrate status",

    // Documentation
    "docs:dev": "vitepress dev docs",
    "docs:build": "vitepress build docs",
    "docs:serve": "vitepress serve docs",
    "docs:api": "typedoc --out docs/api src",

    // Utilities
    "prepare": "husky install",
    "precommit": "lint-staged",
    "analyze": "cross-env ANALYZE=true next build",
    "bundle-analyzer": "cross-env ANALYZE=true BUNDLE_ANALYZE=both next build",

    // Production
    "start:prod": "NODE_ENV=production next start",
    "pm2:start": "pm2 start ecosystem.config.js",
    "pm2:stop": "pm2 stop ecosystem.config.js"
  }
}
```

### ESLint Configuration

```javascript
// .eslintrc.js
module.exports = {
  root: true,
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: "./tsconfig.json",
    ecmaVersion: 2022,
    sourceType: "module",
    ecmaFeatures: {
      jsx: true,
    },
  },
  env: {
    browser: true,
    es6: true,
    node: true,
    jest: true,
  },
  plugins: [
    "@typescript-eslint",
    "react",
    "react-hooks",
    "import",
    "jsx-a11y",
    "security",
    "sonarjs",
    "unicorn",
    "prettier",
  ],
  extends: [
    "eslint:recommended",
    "@typescript-eslint/recommended",
    "@typescript-eslint/recommended-requiring-type-checking",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
    "plugin:jsx-a11y/recommended",
    "plugin:import/recommended",
    "plugin:import/typescript",
    "plugin:security/recommended",
    "plugin:sonarjs/recommended",
    "plugin:unicorn/recommended",
    "next/core-web-vitals",
    "prettier",
  ],
  settings: {
    react: {
      version: "detect",
    },
    "import/resolver": {
      typescript: {
        alwaysTryTypes: true,
        project: "./tsconfig.json",
      },
    },
  },
  rules: {
    // TypeScript Rules
    "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/explicit-module-boundary-types": "off",
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/prefer-readonly": "error",
    "@typescript-eslint/prefer-nullish-coalescing": "error",
    "@typescript-eslint/prefer-optional-chain": "error",
    "@typescript-eslint/no-floating-promises": "error",
    "@typescript-eslint/await-thenable": "error",

    // React Rules
    "react/react-in-jsx-scope": "off",
    "react/prop-types": "off",
    "react/no-unescaped-entities": "off",
    "react-hooks/exhaustive-deps": "warn",

    // Import Rules
    "import/order": [
      "error",
      {
        groups: [
          "builtin",
          "external",
          "internal",
          "parent",
          "sibling",
          "index",
        ],
        "newlines-between": "always",
        alphabetize: {
          order: "asc",
          caseInsensitive: true,
        },
      },
    ],
    "import/no-duplicates": "error",
    "import/no-unused-modules": "warn",

    // Code Quality
    complexity: ["error", 10],
    "max-depth": ["error", 4],
    "max-lines": ["error", 300],
    "max-lines-per-function": ["error", 50],
    "max-params": ["error", 4],

    // Security
    "security/detect-object-injection": "error",

    // General
    "prefer-const": "error",
    "no-var": "error",
    "no-console": process.env.NODE_ENV === "production" ? "error" : "warn",
    eqeqeq: "error",

    // Accessibility
    "jsx-a11y/alt-text": "error",
    "jsx-a11y/aria-props": "error",
    "jsx-a11y/aria-proptypes": "error",
    "jsx-a11y/aria-unsupported-elements": "error",

    // Prettier Integration
    "prettier/prettier": "error",

    // Unicorn Rules (selective)
    "unicorn/filename-case": [
      "error",
      {
        cases: {
          kebabCase: true,
          pascalCase: true,
        },
      },
    ],
    "unicorn/prevent-abbreviations": "off",
    "unicorn/no-null": "off",
  },
  overrides: [
    {
      files: ["*.test.ts", "*.test.tsx", "*.spec.ts", "*.spec.tsx"],
      env: {
        jest: true,
      },
      rules: {
        "@typescript-eslint/no-explicit-any": "off",
        "sonarjs/no-duplicate-string": "off",
        "max-lines-per-function": "off",
      },
    },
    {
      files: ["*.config.js", "*.config.ts"],
      rules: {
        "import/no-default-export": "off",
      },
    },
  ],
};
```

### Prettier Configuration

```json
// .prettierrc
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "avoid",
  "endOfLine": "lf",
  "quoteProps": "as-needed",
  "jsxSingleQuote": true,
  "bracketSameLine": false,
  "plugins": ["prettier-plugin-tailwindcss"]
}
```

### Husky Git Hooks

```json
// .husky/pre-commit
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

echo "🔍 Running pre-commit checks..."

# Run lint-staged
npx lint-staged

# Run type checking
echo "🔍 Type checking..."
npm run type-check

# Run tests for staged files
echo "🧪 Running tests..."
npm run test -- --bail --passWithNoTests --findRelatedTests
```

### Lint-staged Configuration

```json
// .lintstagedrc.json
{
  "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
  "*.{json,yaml,yml,md}": ["prettier --write"],
  "*.{css,scss,less}": ["prettier --write"]
}
```

## 🧪 Testing Environment

### Jest Configuration

```javascript
// jest.config.js
const nextJest = require("next/jest");

const createJestConfig = nextJest({
  dir: "./",
});

const customJestConfig = {
  setupFilesAfterEnv: ["<rootDir>/jest.setup.js"],
  testEnvironment: "jest-environment-jsdom",
  testPathIgnorePatterns: [
    "<rootDir>/.next/",
    "<rootDir>/node_modules/",
    "<rootDir>/e2e/",
  ],
  collectCoverageFrom: [
    "src/**/*.{js,jsx,ts,tsx}",
    "!src/**/*.d.ts",
    "!src/**/*.stories.{js,jsx,ts,tsx}",
    "!src/pages/_app.tsx",
    "!src/pages/_document.tsx",
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  moduleNameMapping: {
    "^@/(.*)$": "<rootDir>/src/$1",
    "^@/components/(.*)$": "<rootDir>/src/components/$1",
    "^@/pages/(.*)$": "<rootDir>/src/pages/$1",
    "^@/lib/(.*)$": "<rootDir>/src/lib/$1",
    "^@/hooks/(.*)$": "<rootDir>/src/hooks/$1",
    "^@/types/(.*)$": "<rootDir>/src/types/$1",
    "^@/utils/(.*)$": "<rootDir>/src/utils/$1",
  },
  testTimeout: 10000,
  verbose: true,
};

module.exports = createJestConfig(customJestConfig);
```

### Playwright Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ["html"],
    ["json", { outputFile: "test-results/results.json" }],
    ["junit", { outputFile: "test-results/results.xml" }],
  ],
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL || "http://localhost:3000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
    {
      name: "firefox",
      use: { ...devices["Desktop Firefox"] },
    },
    {
      name: "webkit",
      use: { ...devices["Desktop Safari"] },
    },
    {
      name: "Mobile Chrome",
      use: { ...devices["Pixel 5"] },
    },
    {
      name: "Mobile Safari",
      use: { ...devices["iPhone 12"] },
    },
  ],
  webServer: {
    command: "npm run dev",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },
});
```

## 🐳 Container Development Environment

### Docker Development Setup

```dockerfile
# Dockerfile.dev
FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Copy package files
COPY package.json package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f pnpm-lock.yaml ]; then npm install -g pnpm && pnpm install --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  else echo "No lockfile found." && exit 1; \
  fi

# Development image
FROM base AS dev
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Install additional development tools
RUN npm install -g @playwright/test

# Expose port and set environment
EXPOSE 3000
ENV NODE_ENV=development

# Start development server with hot reload
CMD ["npm", "run", "dev"]
```

### Docker Compose Development

```yaml
# docker-compose.dev.yml
version: "3.8"

services:
  # Main application
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://xploresg:password@postgres:5432/xploresg_dev
      - REDIS_URL=redis://redis:6379
    volumes:
      - .:/app
      - /app/node_modules
      - /app/.next
    depends_on:
      - postgres
      - redis
    networks:
      - xploresg-network

  # Database
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: xploresg_dev
      POSTGRES_USER: xploresg
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./docker/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - xploresg-network

  # Redis for caching
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - xploresg-network

  # Database administration
  pgadmin:
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@xploresg.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "8080:80"
    depends_on:
      - postgres
    networks:
      - xploresg-network

  # Redis administration
  redis-commander:
    image: rediscommander/redis-commander:latest
    environment:
      - REDIS_HOSTS=local:redis:6379
    ports:
      - "8081:8081"
    depends_on:
      - redis
    networks:
      - xploresg-network

volumes:
  postgres_data:
  redis_data:

networks:
  xploresg-network:
    driver: bridge
```

## 🚀 Production Optimization Tools

### Bundle Analyzer Configuration

```javascript
// next.config.js
const withBundleAnalyzer = require("@next/bundle-analyzer")({
  enabled: process.env.ANALYZE === "true",
});

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,

  // Performance optimizations
  compress: true,
  poweredByHeader: false,

  // Image optimization
  images: {
    domains: ["res.cloudinary.com", "images.unsplash.com"],
    formats: ["image/webp", "image/avif"],
  },

  // Webpack optimization
  webpack: (config, { dev, isServer }) => {
    if (!dev && !isServer) {
      // Bundle analyzer
      if (process.env.ANALYZE) {
        config.plugins.push(
          new (require("webpack-bundle-analyzer").BundleAnalyzerPlugin)({
            analyzerMode: "static",
            openAnalyzer: false,
          })
        );
      }

      // Optimization for production
      config.optimization.splitChunks = {
        chunks: "all",
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: "vendors",
            chunks: "all",
          },
        },
      };
    }

    return config;
  },

  // Environment variables
  env: {
    CUSTOM_KEY: process.env.CUSTOM_KEY,
  },

  // Headers for security and performance
  async headers() {
    return [
      {
        source: "/:path*",
        headers: [
          {
            key: "X-DNS-Prefetch-Control",
            value: "on",
          },
          {
            key: "Strict-Transport-Security",
            value: "max-age=63072000; includeSubDomains; preload",
          },
          {
            key: "X-Frame-Options",
            value: "DENY",
          },
          {
            key: "X-Content-Type-Options",
            value: "nosniff",
          },
          {
            key: "Referrer-Policy",
            value: "origin-when-cross-origin",
          },
        ],
      },
    ];
  },
};

module.exports = withBundleAnalyzer(nextConfig);
```

## 🔍 Monitoring & Analytics

### Sentry Error Tracking

```typescript
// sentry.client.config.ts
import { init } from "@sentry/nextjs";

init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: process.env.NODE_ENV === "production" ? 0.1 : 1.0,
  debug: process.env.NODE_ENV === "development",

  beforeSend(event, hint) {
    // Filter out development errors in production
    if (process.env.NODE_ENV === "production") {
      const error = hint.originalException;

      // Don't send network errors to Sentry in development
      if (error?.message?.includes("Network Error")) {
        return null;
      }
    }

    return event;
  },

  integrations: [
    // Add custom integrations
  ],
});
```

### Performance Monitoring

```typescript
// lib/monitoring.ts
import { getCLS, getFID, getFCP, getLCP, getTTFB } from "web-vitals";

export function reportWebVitals(metric: any) {
  // Log to console in development
  if (process.env.NODE_ENV === "development") {
    console.log(metric);
  }

  // Send to analytics service
  if (process.env.NODE_ENV === "production") {
    // Google Analytics
    if (window.gtag) {
      window.gtag("event", metric.name, {
        event_category: "Web Vitals",
        value: Math.round(metric.value),
        event_label: metric.id,
        non_interaction: true,
      });
    }

    // Custom analytics endpoint
    fetch("/api/analytics/web-vitals", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(metric),
    });
  }
}

// Initialize web vitals monitoring
export function initWebVitals() {
  getCLS(reportWebVitals);
  getFID(reportWebVitals);
  getFCP(reportWebVitals);
  getLCP(reportWebVitals);
  getTTFB(reportWebVitals);
}
```

This comprehensive development tools and environment setup guide ensures that all team members have consistent, productive development environments while showcasing academic proficiency through industry-leading tooling and best practices. The configuration promotes code quality, developer productivity, and maintainable software development processes.
