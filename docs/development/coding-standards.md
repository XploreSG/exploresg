# Coding Standards & Best Practices

## 🎯 Overview

This document establishes comprehensive coding standards for XploreSG that demonstrate academic proficiency, professional software development practices, and industry-leading quality standards. These guidelines ensure code maintainability, readability, performance, and security across all project components.

## 🏛️ Academic Excellence Principles

### Software Engineering Fundamentals

- **SOLID Principles**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **Design Patterns**: Implement proven patterns (Repository, Factory, Observer, Strategy, etc.)
- **Clean Architecture**: Separation of concerns, dependency injection, testability
- **Domain-Driven Design**: Clear domain boundaries, ubiquitous language
- **Test-Driven Development**: Write tests first, maintain high coverage

### Code Quality Metrics

| Metric                    | Target           | Tool                   |
| ------------------------- | ---------------- | ---------------------- |
| **Code Coverage**         | >90%             | Jest, Cypress          |
| **Maintainability Index** | >70              | SonarQube, CodeClimate |
| **Cyclomatic Complexity** | <10 per function | ESLint, SonarQube      |
| **Technical Debt Ratio**  | <5%              | SonarQube              |
| **Duplication**           | <3%              | SonarQube              |
| **Security Hotspots**     | 0                | Snyk, SonarQube        |

## 📚 Language-Specific Standards

### TypeScript/JavaScript Standards

#### File Structure & Naming

```typescript
// ✅ Good: PascalCase for classes and interfaces
export class UserService implements IUserService {
  // camelCase for methods and variables
  private readonly databaseConnection: DatabaseConnection;

  async createUser(userData: CreateUserDto): Promise<User> {
    // Implementation
  }
}

// ✅ Good: camelCase for files, kebab-case for components
user - service.ts;
user - profile.component.ts;
database - connection.interface.ts;
create - user.dto.ts;
```

#### Code Organization

```typescript
// ✅ File structure template
/**
 * @fileoverview User service for managing user operations
 * @author XploreSG Team
 * @version 1.0.0
 */

// 1. External imports (third-party libraries)
import { Injectable, Logger } from "@nestjs/common";
import { Repository } from "typeorm";
import bcrypt from "bcrypt";

// 2. Internal imports (project modules)
import { User } from "../entities/user.entity";
import { CreateUserDto } from "../dto/create-user.dto";
import { UserRepository } from "../repositories/user.repository";

// 3. Type definitions and interfaces
interface UserServiceOptions {
  readonly hashRounds: number;
  readonly sessionTimeout: number;
}

// 4. Constants
const DEFAULT_HASH_ROUNDS = 12;
const SESSION_TIMEOUT_MS = 24 * 60 * 60 * 1000; // 24 hours

// 5. Main class/function implementation
@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);

  constructor(
    private readonly userRepository: UserRepository,
    private readonly options: UserServiceOptions = {
      hashRounds: DEFAULT_HASH_ROUNDS,
      sessionTimeout: SESSION_TIMEOUT_MS,
    }
  ) {}

  /**
   * Creates a new user with validated data
   * @param userData - User creation data following CreateUserDto schema
   * @returns Promise resolving to created User entity
   * @throws {ValidationError} When user data is invalid
   * @throws {ConflictError} When email already exists
   */
  async createUser(userData: CreateUserDto): Promise<User> {
    this.logger.debug(`Creating user with email: ${userData.email}`);

    try {
      // Validation
      await this.validateUserData(userData);

      // Business logic
      const hashedPassword = await this.hashPassword(userData.password);
      const user = this.userRepository.create({
        ...userData,
        password: hashedPassword,
      });

      const savedUser = await this.userRepository.save(user);
      this.logger.log(`User created successfully: ${savedUser.id}`);

      return savedUser;
    } catch (error) {
      this.logger.error(`Failed to create user: ${error.message}`, error.stack);
      throw error;
    }
  }

  private async validateUserData(userData: CreateUserDto): Promise<void> {
    // Implementation with proper error handling
  }

  private async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, this.options.hashRounds);
  }
}
```

#### Error Handling Standards

```typescript
// ✅ Custom error hierarchy
export abstract class AppError extends Error {
  abstract readonly statusCode: number;
  abstract readonly isOperational: boolean;

  constructor(message: string, public readonly context?: Record<string, any>) {
    super(message);
    Object.setPrototypeOf(this, new.target.prototype);
    Error.captureStackTrace(this);
  }
}

export class ValidationError extends AppError {
  readonly statusCode = 400;
  readonly isOperational = true;

  constructor(message: string, public readonly field?: string) {
    super(message, { field });
  }
}

export class NotFoundError extends AppError {
  readonly statusCode = 404;
  readonly isOperational = true;
}

// ✅ Error handling in services
async findUserById(id: string): Promise<User> {
  try {
    const user = await this.userRepository.findById(id);
    if (!user) {
      throw new NotFoundError(`User with ID ${id} not found`);
    }
    return user;
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }

    this.logger.error(`Unexpected error finding user ${id}`, error);
    throw new InternalServerError('Failed to retrieve user');
  }
}
```

### React/Frontend Standards

#### Component Structure

```typescript
// ✅ Functional component with TypeScript
import React, { useState, useEffect, useCallback, memo } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { User, CreateUserRequest } from "../types/user.types";
import { userService } from "../services/user.service";
import { LoadingSpinner } from "../components/ui/LoadingSpinner";
import { ErrorBoundary } from "../components/error/ErrorBoundary";

/**
 * UserProfile component for displaying and editing user information
 *
 * @param userId - The ID of the user to display
 * @param onUserUpdate - Callback fired when user data is updated
 * @returns React functional component
 */
interface UserProfileProps {
  readonly userId: string;
  readonly onUserUpdate?: (user: User) => void;
}

export const UserProfile = memo<UserProfileProps>(
  ({ userId, onUserUpdate }) => {
    // ✅ State management with proper typing
    const [isEditing, setIsEditing] = useState(false);
    const [formData, setFormData] = useState<Partial<CreateUserRequest>>({});

    // ✅ Data fetching with error handling
    const {
      data: user,
      isLoading,
      error,
      refetch,
    } = useQuery({
      queryKey: ["user", userId],
      queryFn: () => userService.findById(userId),
      enabled: !!userId,
      staleTime: 5 * 60 * 1000, // 5 minutes
    });

    // ✅ Mutations with optimistic updates
    const updateUserMutation = useMutation({
      mutationFn: (data: Partial<CreateUserRequest>) =>
        userService.update(userId, data),
      onSuccess: (updatedUser) => {
        setIsEditing(false);
        onUserUpdate?.(updatedUser);
      },
      onError: (error) => {
        console.error("Failed to update user:", error);
      },
    });

    // ✅ Event handlers with useCallback for performance
    const handleEditToggle = useCallback(() => {
      setIsEditing(!isEditing);
      if (!isEditing && user) {
        setFormData({
          firstName: user.profile.firstName,
          lastName: user.profile.lastName,
          bio: user.profile.bio,
        });
      }
    }, [isEditing, user]);

    const handleFormSubmit = useCallback(
      async (event: React.FormEvent) => {
        event.preventDefault();

        if (!formData.firstName?.trim()) {
          return; // Add proper validation
        }

        updateUserMutation.mutate(formData);
      },
      [formData, updateUserMutation]
    );

    // ✅ Loading and error states
    if (isLoading) {
      return <LoadingSpinner aria-label="Loading user profile" />;
    }

    if (error) {
      return (
        <div role="alert" className="error-container">
          <h2>Failed to load user profile</h2>
          <button onClick={() => refetch()} className="retry-button">
            Try Again
          </button>
        </div>
      );
    }

    if (!user) {
      return <div>User not found</div>;
    }

    return (
      <ErrorBoundary>
        <div className="user-profile" data-testid="user-profile">
          <header className="profile-header">
            <h1>{user.profile.displayName}</h1>
            <button
              onClick={handleEditToggle}
              aria-label={isEditing ? "Cancel editing" : "Edit profile"}
              className="edit-toggle-button"
            >
              {isEditing ? "Cancel" : "Edit"}
            </button>
          </header>

          {isEditing ? (
            <form onSubmit={handleFormSubmit} className="edit-form">
              {/* Form fields with proper accessibility */}
              <div className="form-group">
                <label htmlFor="firstName">First Name</label>
                <input
                  id="firstName"
                  type="text"
                  value={formData.firstName || ""}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      firstName: e.target.value,
                    }))
                  }
                  required
                  aria-describedby="firstName-error"
                />
              </div>

              <button
                type="submit"
                disabled={updateUserMutation.isPending}
                className="save-button"
              >
                {updateUserMutation.isPending ? "Saving..." : "Save Changes"}
              </button>
            </form>
          ) : (
            <div className="profile-display">
              <p>
                <strong>Email:</strong> {user.email}
              </p>
              <p>
                <strong>Name:</strong> {user.profile.firstName}{" "}
                {user.profile.lastName}
              </p>
              {user.profile.bio && (
                <p>
                  <strong>Bio:</strong> {user.profile.bio}
                </p>
              )}
            </div>
          )}
        </div>
      </ErrorBoundary>
    );
  }
);

UserProfile.displayName = "UserProfile";
```

#### State Management Standards

```typescript
// ✅ Zustand store with TypeScript
import { create } from "zustand";
import { devtools, persist } from "zustand/middleware";
import { User, AuthTokens } from "../types/auth.types";

interface AuthState {
  // State
  user: User | null;
  tokens: AuthTokens | null;
  isAuthenticated: boolean;
  isLoading: boolean;

  // Actions
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => void;
  refreshToken: () => Promise<void>;
  updateUser: (updates: Partial<User>) => void;
}

export const useAuthStore = create<AuthState>()(
  devtools(
    persist(
      (set, get) => ({
        // Initial state
        user: null,
        tokens: null,
        isAuthenticated: false,
        isLoading: false,

        // Actions with proper error handling
        login: async (credentials) => {
          set({ isLoading: true });
          try {
            const response = await authService.login(credentials);
            set({
              user: response.user,
              tokens: response.tokens,
              isAuthenticated: true,
              isLoading: false,
            });
          } catch (error) {
            set({ isLoading: false });
            throw error;
          }
        },

        logout: () => {
          set({
            user: null,
            tokens: null,
            isAuthenticated: false,
            isLoading: false,
          });
          // Clear persisted state
          localStorage.removeItem("auth-storage");
        },

        refreshToken: async () => {
          const { tokens } = get();
          if (!tokens?.refreshToken) {
            throw new Error("No refresh token available");
          }

          try {
            const newTokens = await authService.refreshToken(
              tokens.refreshToken
            );
            set({ tokens: newTokens });
          } catch (error) {
            // Auto-logout on refresh failure
            get().logout();
            throw error;
          }
        },

        updateUser: (updates) => {
          set((state) => ({
            user: state.user ? { ...state.user, ...updates } : null,
          }));
        },
      }),
      {
        name: "auth-storage",
        partialize: (state) => ({
          user: state.user,
          tokens: state.tokens,
          isAuthenticated: state.isAuthenticated,
        }),
      }
    ),
    { name: "AuthStore" }
  )
);
```

## 🧪 Testing Standards

### Unit Testing Best Practices

```typescript
// ✅ Comprehensive unit test example
import { Test, TestingModule } from "@nestjs/testing";
import { getRepositoryToken } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { UserService } from "./user.service";
import { User } from "../entities/user.entity";
import { CreateUserDto } from "../dto/create-user.dto";
import { ValidationError, ConflictError } from "../errors";

describe("UserService", () => {
  let service: UserService;
  let userRepository: jest.Mocked<Repository<User>>;

  // ✅ Proper test setup with mocking
  beforeEach(async () => {
    const mockRepository = {
      create: jest.fn(),
      save: jest.fn(),
      findOne: jest.fn(),
      findOneBy: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserService,
        {
          provide: getRepositoryToken(User),
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<UserService>(UserService);
    userRepository = module.get(getRepositoryToken(User));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe("createUser", () => {
    const mockUserData: CreateUserDto = {
      email: "test@example.com",
      password: "SecurePass123!",
      firstName: "John",
      lastName: "Doe",
    };

    const mockUser: User = {
      id: "123e4567-e89b-12d3-a456-426614174000",
      email: mockUserData.email,
      profile: {
        firstName: mockUserData.firstName,
        lastName: mockUserData.lastName,
        displayName: "John Doe",
      },
      createdAt: new Date(),
      updatedAt: new Date(),
    } as User;

    it("should create user successfully with valid data", async () => {
      // Arrange
      userRepository.findOneBy.mockResolvedValue(null); // Email not exists
      userRepository.create.mockReturnValue(mockUser);
      userRepository.save.mockResolvedValue(mockUser);

      // Act
      const result = await service.createUser(mockUserData);

      // Assert
      expect(result).toEqual(mockUser);
      expect(userRepository.findOneBy).toHaveBeenCalledWith({
        email: mockUserData.email,
      });
      expect(userRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({
          email: mockUserData.email,
          profile: expect.objectContaining({
            firstName: mockUserData.firstName,
            lastName: mockUserData.lastName,
          }),
        })
      );
      expect(userRepository.save).toHaveBeenCalledWith(mockUser);
    });

    it("should throw ConflictError when email already exists", async () => {
      // Arrange
      userRepository.findOneBy.mockResolvedValue(mockUser);

      // Act & Assert
      await expect(service.createUser(mockUserData)).rejects.toThrow(
        ConflictError
      );
      expect(userRepository.create).not.toHaveBeenCalled();
      expect(userRepository.save).not.toHaveBeenCalled();
    });

    it("should throw ValidationError for invalid email format", async () => {
      // Arrange
      const invalidData = { ...mockUserData, email: "invalid-email" };

      // Act & Assert
      await expect(service.createUser(invalidData)).rejects.toThrow(
        ValidationError
      );
    });

    it("should hash password before saving", async () => {
      // Arrange
      userRepository.findOneBy.mockResolvedValue(null);
      userRepository.create.mockReturnValue(mockUser);
      userRepository.save.mockResolvedValue(mockUser);

      // Act
      await service.createUser(mockUserData);

      // Assert
      const createCall = userRepository.create.mock.calls[0][0];
      expect(createCall.password).not.toBe(mockUserData.password);
      expect(createCall.password).toMatch(
        /^\$2[aby]\$\d{1,2}\$[./A-Za-z0-9]{53}$/
      );
    });
  });

  describe("findById", () => {
    it("should return user when found", async () => {
      // Arrange
      const userId = "123e4567-e89b-12d3-a456-426614174000";
      const mockUser = { id: userId, email: "test@example.com" } as User;
      userRepository.findOneBy.mockResolvedValue(mockUser);

      // Act
      const result = await service.findById(userId);

      // Assert
      expect(result).toEqual(mockUser);
      expect(userRepository.findOneBy).toHaveBeenCalledWith({ id: userId });
    });

    it("should throw NotFoundError when user not found", async () => {
      // Arrange
      const userId = "123e4567-e89b-12d3-a456-426614174000";
      userRepository.findOneBy.mockResolvedValue(null);

      // Act & Assert
      await expect(service.findById(userId)).rejects.toThrow(NotFoundError);
    });
  });
});
```

### Integration Testing

```typescript
// ✅ Integration test example
import { Test, TestingModule } from "@nestjs/testing";
import { INestApplication } from "@nestjs/common";
import request from "supertest";
import { AppModule } from "../app.module";
import { DatabaseService } from "../database/database.service";

describe("UserController (Integration)", () => {
  let app: INestApplication;
  let databaseService: DatabaseService;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    databaseService = moduleFixture.get<DatabaseService>(DatabaseService);

    await app.init();
  });

  beforeEach(async () => {
    // Clean database before each test
    await databaseService.cleanDatabase();
  });

  afterAll(async () => {
    await app.close();
  });

  describe("POST /api/v1/auth/register", () => {
    it("should register new user successfully", async () => {
      const userData = {
        email: "test@example.com",
        password: "SecurePass123!",
        firstName: "John",
        lastName: "Doe",
      };

      const response = await request(app.getHttpServer())
        .post("/api/v1/auth/register")
        .send(userData)
        .expect(201);

      expect(response.body).toMatchObject({
        success: true,
        data: {
          user: {
            email: userData.email,
            profile: {
              firstName: userData.firstName,
              lastName: userData.lastName,
            },
          },
        },
      });

      // Verify password is not returned
      expect(response.body.data.user.password).toBeUndefined();
    });

    it("should return 409 when email already exists", async () => {
      const userData = {
        email: "existing@example.com",
        password: "SecurePass123!",
        firstName: "Jane",
        lastName: "Smith",
      };

      // Create user first
      await request(app.getHttpServer())
        .post("/api/v1/auth/register")
        .send(userData)
        .expect(201);

      // Try to create same user again
      const response = await request(app.getHttpServer())
        .post("/api/v1/auth/register")
        .send(userData)
        .expect(409);

      expect(response.body).toMatchObject({
        success: false,
        error: {
          code: "CONFLICT_ERROR",
          message: expect.stringContaining("already exists"),
        },
      });
    });
  });
});
```

### E2E Testing with Playwright

```typescript
// ✅ E2E test example
import { test, expect, Page } from "@playwright/test";

test.describe("User Authentication Flow", () => {
  test.beforeEach(async ({ page }) => {
    // Setup: Navigate to home page
    await page.goto("/");
  });

  test("should complete full registration and login flow", async ({ page }) => {
    // Test user data
    const userData = {
      email: `test${Date.now()}@example.com`,
      password: "SecurePass123!",
      firstName: "John",
      lastName: "Doe",
    };

    // Step 1: Navigate to registration
    await page.getByRole("link", { name: "Sign Up" }).click();
    await expect(page).toHaveURL("/auth/register");

    // Step 2: Fill registration form
    await page.getByLabel("Email").fill(userData.email);
    await page.getByLabel("Password").fill(userData.password);
    await page.getByLabel("Confirm Password").fill(userData.password);
    await page.getByLabel("First Name").fill(userData.firstName);
    await page.getByLabel("Last Name").fill(userData.lastName);

    // Step 3: Submit registration
    await page.getByRole("button", { name: "Create Account" }).click();

    // Step 4: Verify success message
    await expect(page.getByText("Account created successfully")).toBeVisible();
    await expect(page).toHaveURL("/auth/verify-email");

    // Step 5: Simulate email verification (in real test, check email)
    // For demo, we'll go directly to login
    await page.goto("/auth/login");

    // Step 6: Login with new credentials
    await page.getByLabel("Email").fill(userData.email);
    await page.getByLabel("Password").fill(userData.password);
    await page.getByRole("button", { name: "Sign In" }).click();

    // Step 7: Verify successful login
    await expect(page).toHaveURL("/dashboard");
    await expect(
      page.getByText(`Welcome, ${userData.firstName}!`)
    ).toBeVisible();

    // Step 8: Verify user profile
    await page.getByRole("button", { name: "Profile" }).click();
    await expect(page.getByText(userData.email)).toBeVisible();
    await expect(
      page.getByText(`${userData.firstName} ${userData.lastName}`)
    ).toBeVisible();
  });

  test("should handle login with invalid credentials", async ({ page }) => {
    await page.goto("/auth/login");

    await page.getByLabel("Email").fill("nonexistent@example.com");
    await page.getByLabel("Password").fill("wrongpassword");
    await page.getByRole("button", { name: "Sign In" }).click();

    await expect(page.getByText("Invalid email or password")).toBeVisible();
    await expect(page).toHaveURL("/auth/login");
  });
});

test.describe("Responsive Design", () => {
  test("should work correctly on mobile devices", async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto("/");

    // Test mobile navigation
    await expect(page.getByRole("button", { name: "Menu" })).toBeVisible();
    await page.getByRole("button", { name: "Menu" }).click();
    await expect(page.getByRole("navigation")).toBeVisible();
  });
});
```

## 🔐 Security Standards

### Input Validation & Sanitization

```typescript
// ✅ Comprehensive validation with class-validator
import {
  IsEmail,
  IsString,
  MinLength,
  MaxLength,
  Matches,
  IsOptional,
  Transform,
} from "class-validator";
import { ApiProperty } from "@nestjs/swagger";
import { Transform as ClassTransform } from "class-transformer";

export class CreateUserDto {
  @ApiProperty({
    description: "User email address",
    example: "john.doe@example.com",
    format: "email",
  })
  @IsEmail({}, { message: "Please provide a valid email address" })
  @Transform(({ value }) => value?.toLowerCase().trim())
  email: string;

  @ApiProperty({
    description: "User password",
    minLength: 8,
    maxLength: 128,
    pattern:
      "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]",
  })
  @IsString()
  @MinLength(8, { message: "Password must be at least 8 characters long" })
  @MaxLength(128, { message: "Password must not exceed 128 characters" })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/, {
    message:
      "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character",
  })
  password: string;

  @ApiProperty({
    description: "User first name",
    minLength: 1,
    maxLength: 50,
  })
  @IsString()
  @MinLength(1, { message: "First name is required" })
  @MaxLength(50, { message: "First name must not exceed 50 characters" })
  @Transform(({ value }) => value?.trim())
  @Matches(/^[a-zA-Z\s'-]+$/, {
    message:
      "First name can only contain letters, spaces, hyphens, and apostrophes",
  })
  firstName: string;

  @ApiProperty({
    description: "User last name",
    minLength: 1,
    maxLength: 50,
  })
  @IsString()
  @MinLength(1, { message: "Last name is required" })
  @MaxLength(50, { message: "Last name must not exceed 50 characters" })
  @Transform(({ value }) => value?.trim())
  @Matches(/^[a-zA-Z\s'-]+$/, {
    message:
      "Last name can only contain letters, spaces, hyphens, and apostrophes",
  })
  lastName: string;

  @ApiProperty({
    description: "User bio (optional)",
    required: false,
    maxLength: 500,
  })
  @IsOptional()
  @IsString()
  @MaxLength(500, { message: "Bio must not exceed 500 characters" })
  @Transform(({ value }) => value?.trim() || null)
  bio?: string;
}
```

### Authentication & Authorization

```typescript
// ✅ JWT authentication guard
import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { Request } from "express";

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<Request>();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      throw new UnauthorizedException("Access token is required");
    }

    try {
      const payload = await this.jwtService.verifyAsync(token, {
        secret: process.env.JWT_SECRET,
        algorithms: ["HS256"],
      });

      // Attach user info to request
      request.user = {
        id: payload.sub,
        email: payload.email,
        roles: payload.roles || [],
      };

      return true;
    } catch (error) {
      if (error.name === "TokenExpiredError") {
        throw new UnauthorizedException("Access token has expired");
      }

      throw new UnauthorizedException("Invalid access token");
    }
  }

  private extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(" ") ?? [];
    return type === "Bearer" ? token : undefined;
  }
}

// ✅ Role-based authorization
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>("roles", [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!requiredRoles) {
      return true;
    }

    const { user } = context.switchToHttp().getRequest();

    return requiredRoles.some((role) => user.roles?.includes(role));
  }
}

// Usage in controllers
@Controller("admin")
@UseGuards(JwtAuthGuard, RolesGuard)
export class AdminController {
  @Get("users")
  @Roles("admin", "moderator")
  async getUsers() {
    // Only admin and moderator roles can access
  }
}
```

## 📊 Code Quality Tools Configuration

### ESLint Configuration

```json
// .eslintrc.json
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "project": "./tsconfig.json",
    "ecmaVersion": 2022,
    "sourceType": "module"
  },
  "plugins": ["@typescript-eslint", "import", "security", "sonarjs", "unicorn"],
  "extends": [
    "eslint:recommended",
    "@typescript-eslint/recommended",
    "@typescript-eslint/recommended-requiring-type-checking",
    "plugin:import/recommended",
    "plugin:import/typescript",
    "plugin:security/recommended",
    "plugin:sonarjs/recommended",
    "plugin:unicorn/recommended"
  ],
  "rules": {
    // TypeScript specific
    "@typescript-eslint/no-unused-vars": [
      "error",
      { "argsIgnorePattern": "^_" }
    ],
    "@typescript-eslint/explicit-function-return-type": "error",
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/prefer-readonly": "error",
    "@typescript-eslint/prefer-nullish-coalescing": "error",
    "@typescript-eslint/prefer-optional-chain": "error",

    // Import organization
    "import/order": [
      "error",
      {
        "groups": [
          "builtin",
          "external",
          "internal",
          "parent",
          "sibling",
          "index"
        ],
        "newlines-between": "always",
        "alphabetize": {
          "order": "asc",
          "caseInsensitive": true
        }
      }
    ],

    // Code quality
    "complexity": ["error", 10],
    "max-depth": ["error", 4],
    "max-lines": ["error", 300],
    "max-lines-per-function": ["error", 50],
    "max-params": ["error", 4],

    // Security
    "security/detect-object-injection": "error",
    "security/detect-non-literal-regexp": "error",

    // SonarJS code smells
    "sonarjs/cognitive-complexity": ["error", 15],
    "sonarjs/no-duplicate-string": ["error", 3],
    "sonarjs/no-identical-functions": "error",

    // General best practices
    "prefer-const": "error",
    "no-var": "error",
    "no-console": "warn",
    "eqeqeq": "error"
  },
  "overrides": [
    {
      "files": ["*.test.ts", "*.spec.ts"],
      "rules": {
        "@typescript-eslint/no-explicit-any": "off",
        "sonarjs/no-duplicate-string": "off"
      }
    }
  ]
}
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
  "bracketSameLine": false
}
```

### SonarQube Quality Gate

```yaml
# sonar-project.properties
sonar.projectKey=xploresg
sonar.projectName=XploreSG
sonar.projectVersion=1.0.0

# Source and test configurations
sonar.sources=src
sonar.tests=src
sonar.test.inclusions=**/*.test.ts,**/*.spec.ts
sonar.coverage.exclusions=**/*.test.ts,**/*.spec.ts,**/node_modules/**

# TypeScript specific
sonar.typescript.lcov.reportPaths=coverage/lcov.info

# Quality gate rules
sonar.qualitygate.wait=true

# Coverage requirements
sonar.coverage.minimum=90

# Duplication threshold
sonar.cpd.exclusions=**/*.test.ts,**/*.spec.ts

# Security hotspots
sonar.security.hotspots.inheritFromParent=true
```

## 🎨 UI/UX Standards

### Accessibility (WCAG 2.1 AA Compliance)

```typescript
// ✅ Accessible form component
export const AccessibleForm: React.FC = () => {
  const [errors, setErrors] = useState<Record<string, string>>({});
  const emailRef = useRef<HTMLInputElement>(null);

  return (
    <form onSubmit={handleSubmit} noValidate>
      <fieldset>
        <legend>User Registration</legend>

        {/* Email field with proper labeling and error handling */}
        <div className="form-group">
          <label htmlFor="email" className="required">
            Email Address
          </label>
          <input
            ref={emailRef}
            id="email"
            type="email"
            name="email"
            required
            aria-describedby="email-error email-help"
            aria-invalid={errors.email ? "true" : "false"}
            className={errors.email ? "error" : ""}
          />
          <div id="email-help" className="help-text">
            We'll never share your email address
          </div>
          {errors.email && (
            <div id="email-error" className="error-message" role="alert">
              {errors.email}
            </div>
          )}
        </div>

        {/* Password with strength indicator */}
        <div className="form-group">
          <label htmlFor="password" className="required">
            Password
          </label>
          <input
            id="password"
            type="password"
            name="password"
            required
            aria-describedby="password-requirements password-error"
            aria-invalid={errors.password ? "true" : "false"}
          />
          <div id="password-requirements" className="help-text">
            Password must contain at least 8 characters, including uppercase,
            lowercase, number, and special character
          </div>
          <PasswordStrengthIndicator password={password} />
          {errors.password && (
            <div id="password-error" className="error-message" role="alert">
              {errors.password}
            </div>
          )}
        </div>

        <button
          type="submit"
          disabled={isSubmitting}
          aria-describedby={isSubmitting ? "submit-status" : undefined}
        >
          {isSubmitting ? "Creating Account..." : "Create Account"}
        </button>

        {isSubmitting && (
          <div id="submit-status" className="sr-only" aria-live="polite">
            Creating your account, please wait...
          </div>
        )}
      </fieldset>
    </form>
  );
};
```

### Design System Integration

```css
/* ✅ CSS Custom Properties for consistent theming */
:root {
  /* Color palette - Singapore themed */
  --color-primary-50: #fff7ed;
  --color-primary-500: #f97316; /* Singapore orange */
  --color-primary-600: #ea580c;
  --color-primary-700: #c2410c;

  --color-secondary-50: #f0f9ff;
  --color-secondary-500: #0ea5e9; /* Singapore blue */
  --color-secondary-600: #0284c7;

  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-error: #ef4444;

  /* Typography */
  --font-family-sans: "Inter", system-ui, -apple-system, sans-serif;
  --font-family-mono: "JetBrains Mono", "Fira Code", monospace;

  /* Spacing scale (based on 4px grid) */
  --space-1: 0.25rem; /* 4px */
  --space-2: 0.5rem; /* 8px */
  --space-3: 0.75rem; /* 12px */
  --space-4: 1rem; /* 16px */
  --space-6: 1.5rem; /* 24px */
  --space-8: 2rem; /* 32px */
  --space-12: 3rem; /* 48px */

  /* Border radius */
  --radius-sm: 0.125rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  --radius-xl: 0.75rem;

  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);

  /* Transitions */
  --transition-fast: 150ms ease;
  --transition-normal: 250ms ease;
  --transition-slow: 350ms ease;
}

/* Component styles using design tokens */
.btn {
  /* Base button styles */
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-2) var(--space-4);
  font-family: var(--font-family-sans);
  font-size: 0.875rem;
  font-weight: 500;
  line-height: 1.25rem;
  border-radius: var(--radius-md);
  border: 1px solid transparent;
  transition: all var(--transition-fast);
  cursor: pointer;

  /* Focus styles for accessibility */
  &:focus {
    outline: 2px solid var(--color-primary-500);
    outline-offset: 2px;
  }

  /* Disabled state */
  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

.btn--primary {
  background-color: var(--color-primary-500);
  color: white;

  &:hover:not(:disabled) {
    background-color: var(--color-primary-600);
  }

  &:active:not(:disabled) {
    background-color: var(--color-primary-700);
  }
}

/* Responsive design with mobile-first approach */
.container {
  width: 100%;
  margin: 0 auto;
  padding: 0 var(--space-4);

  @media (min-width: 640px) {
    max-width: 640px;
  }

  @media (min-width: 768px) {
    max-width: 768px;
    padding: 0 var(--space-6);
  }

  @media (min-width: 1024px) {
    max-width: 1024px;
    padding: 0 var(--space-8);
  }
}
```

## 🚀 Performance Standards

### Core Web Vitals Targets

| Metric                             | Target | Measurement                 |
| ---------------------------------- | ------ | --------------------------- |
| **Largest Contentful Paint (LCP)** | <2.5s  | Lighthouse, Core Web Vitals |
| **First Input Delay (FID)**        | <100ms | Real User Monitoring        |
| **Cumulative Layout Shift (CLS)**  | <0.1   | Lighthouse, RUM             |
| **First Contentful Paint (FCP)**   | <1.8s  | Lighthouse                  |
| **Time to Interactive (TTI)**      | <3.8s  | Lighthouse                  |

### Performance Optimization Techniques

```typescript
// ✅ Code splitting and lazy loading
import { lazy, Suspense } from "react";
import { ErrorBoundary } from "./components/ErrorBoundary";
import { LoadingSpinner } from "./components/LoadingSpinner";

// Lazy load heavy components
const UserProfile = lazy(() => import("./pages/UserProfile"));
const LocationMap = lazy(() =>
  import("./components/LocationMap").then((module) => ({
    default: module.LocationMap,
  }))
);

// Route-based code splitting
const AppRoutes = () => (
  <Routes>
    <Route
      path="/profile"
      element={
        <ErrorBoundary>
          <Suspense fallback={<LoadingSpinner />}>
            <UserProfile />
          </Suspense>
        </ErrorBoundary>
      }
    />
  </Routes>
);

// ✅ Memoization for expensive calculations
const ExpensiveComponent = memo(({ data, filters }) => {
  const processedData = useMemo(() => {
    return data
      .filter((item) => filters.every((filter) => filter.predicate(item)))
      .sort((a, b) => b.score - a.score);
  }, [data, filters]);

  const handleItemClick = useCallback((itemId: string) => {
    // Event handler logic
  }, []);

  return (
    <div>
      {processedData.map((item) => (
        <ExpensiveItem key={item.id} item={item} onClick={handleItemClick} />
      ))}
    </div>
  );
});

// ✅ Virtual scrolling for large lists
import { FixedSizeList as List } from "react-window";

const VirtualizedLocationList = ({ locations }) => {
  const Row = ({ index, style }) => (
    <div style={style}>
      <LocationCard location={locations[index]} />
    </div>
  );

  return (
    <List height={600} itemCount={locations.length} itemSize={120} width="100%">
      {Row}
    </List>
  );
};
```

### Database Performance

```sql
-- ✅ Optimized queries with proper indexing
-- Create composite indexes for common query patterns
CREATE INDEX CONCURRENTLY idx_users_email_status
ON users(email, status) WHERE status = 'active';

CREATE INDEX CONCURRENTLY idx_locations_category_district
ON locations(category, district, latitude, longitude);

CREATE INDEX CONCURRENTLY idx_reviews_location_rating
ON reviews(location_id, rating, created_at DESC);

-- ✅ Query optimization example
-- Instead of this (N+1 query problem)
SELECT * FROM locations WHERE category = 'restaurant';
-- Then for each location: SELECT AVG(rating) FROM reviews WHERE location_id = ?

-- Use this (single optimized query)
SELECT
  l.*,
  COALESCE(r.avg_rating, 0) as average_rating,
  COALESCE(r.review_count, 0) as review_count
FROM locations l
LEFT JOIN (
  SELECT
    location_id,
    AVG(rating) as avg_rating,
    COUNT(*) as review_count
  FROM reviews
  GROUP BY location_id
) r ON l.id = r.location_id
WHERE l.category = 'restaurant'
  AND l.status = 'active'
ORDER BY r.avg_rating DESC NULLS LAST, r.review_count DESC
LIMIT 20;
```

## 📝 Documentation Standards

### Code Documentation

````typescript
/**
 * Service for managing user operations including registration, authentication,
 * and profile management. Implements comprehensive validation, security measures,
 * and error handling following academic best practices.
 *
 * @author XploreSG Development Team
 * @version 1.0.0
 * @since 2024-01-15
 *
 * @example
 * ```typescript
 * const userService = new UserService(userRepository, hashService);
 * const user = await userService.createUser({
 *   email: 'john.doe@example.com',
 *   password: 'SecurePass123!',
 *   firstName: 'John',
 *   lastName: 'Doe'
 * });
 * ```
 */
@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);

  /**
   * Creates a new user account with comprehensive validation and security measures.
   *
   * This method performs the following operations:
   * 1. Validates input data against business rules
   * 2. Checks for existing email addresses to prevent duplicates
   * 3. Securely hashes the password using bcrypt
   * 4. Creates user profile with normalized data
   * 5. Sends email verification (if email service is configured)
   *
   * @param userData - User registration data conforming to CreateUserDto
   * @param userData.email - Valid email address (will be normalized to lowercase)
   * @param userData.password - Password meeting security requirements
   * @param userData.firstName - First name (1-50 characters, letters only)
   * @param userData.lastName - Last name (1-50 characters, letters only)
   * @param userData.bio - Optional biography (max 500 characters)
   *
   * @returns Promise resolving to the created User entity (excluding password)
   *
   * @throws {ValidationError} When input data fails validation rules
   * @throws {ConflictError} When email address already exists
   * @throws {InternalServerError} When database or external service fails
   *
   * @example
   * ```typescript
   * try {
   *   const user = await userService.createUser({
   *     email: 'jane.smith@example.com',
   *     password: 'MySecurePassword123!',
   *     firstName: 'Jane',
   *     lastName: 'Smith',
   *     bio: 'Travel enthusiast exploring Singapore'
   *   });
   *
   *   console.log(`User created: ${user.id}`);
   * } catch (error) {
   *   if (error instanceof ConflictError) {
   *     console.log('Email already registered');
   *   } else if (error instanceof ValidationError) {
   *     console.log(`Invalid data: ${error.message}`);
   *   }
   * }
   * ```
   *
   * @see {@link CreateUserDto} for input validation schema
   * @see {@link User} for returned entity structure
   * @see {@link https://example.com/api-docs#user-creation} for API documentation
   */
  async createUser(userData: CreateUserDto): Promise<User> {
    // Implementation with detailed logging
  }
}
````

### API Documentation with OpenAPI

```typescript
// ✅ Comprehensive Swagger/OpenAPI documentation
@ApiTags("User Management")
@Controller("api/v1/users")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UserController {
  @Post("register")
  @Public() // Override auth guard for registration
  @ApiOperation({
    summary: "Register a new user account",
    description: `
      Creates a new user account with comprehensive validation and security measures.
      
      This endpoint:
      - Validates all input data against business rules
      - Checks for email uniqueness
      - Securely hashes passwords
      - Sends email verification
      - Returns user data (excluding password)
      
      **Rate Limiting**: 5 requests per 15 minutes per IP address
      
      **Security**: Passwords must meet complexity requirements:
      - Minimum 8 characters
      - At least one uppercase letter
      - At least one lowercase letter  
      - At least one number
      - At least one special character
    `,
  })
  @ApiBody({
    type: CreateUserDto,
    description: "User registration data",
    examples: {
      valid: {
        summary: "Valid registration data",
        value: {
          email: "john.doe@example.com",
          password: "MySecurePass123!",
          firstName: "John",
          lastName: "Doe",
          bio: "Singapore travel enthusiast",
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: "User created successfully",
    type: UserResponseDto,
    schema: {
      example: {
        success: true,
        data: {
          user: {
            id: "123e4567-e89b-12d3-a456-426614174000",
            email: "john.doe@example.com",
            emailVerified: false,
            profile: {
              firstName: "John",
              lastName: "Doe",
              displayName: "John Doe",
              bio: "Singapore travel enthusiast",
            },
            createdAt: "2024-01-15T10:30:00Z",
          },
        },
        meta: {
          timestamp: "2024-01-15T10:30:00Z",
          requestId: "req_123456789",
        },
      },
    },
  })
  @ApiResponse({
    status: 400,
    description: "Validation error",
    schema: {
      example: {
        success: false,
        error: {
          code: "VALIDATION_ERROR",
          message: "Invalid input data",
          details: [
            {
              field: "email",
              message: "Please provide a valid email address",
            },
            {
              field: "password",
              message: "Password must contain at least one uppercase letter",
            },
          ],
        },
      },
    },
  })
  @ApiResponse({
    status: 409,
    description: "Email already exists",
    schema: {
      example: {
        success: false,
        error: {
          code: "CONFLICT_ERROR",
          message: "An account with this email already exists",
        },
      },
    },
  })
  async register(@Body() userData: CreateUserDto): Promise<UserResponseDto> {
    return this.userService.createUser(userData);
  }
}
```

## 🔄 Continuous Improvement

### Code Review Checklist

```markdown
# Code Review Checklist

## Functionality

- [ ] Code works as expected and meets requirements
- [ ] Edge cases are properly handled
- [ ] Error handling is comprehensive and appropriate
- [ ] No obvious bugs or logical errors

## Code Quality

- [ ] Code follows established style guidelines
- [ ] Functions are single-purpose and well-named
- [ ] Complex logic is adequately commented
- [ ] No code duplication (DRY principle)
- [ ] Magic numbers/strings are replaced with named constants

## Security

- [ ] Input validation is present and thorough
- [ ] No sensitive data in logs or responses
- [ ] Authentication and authorization are properly implemented
- [ ] SQL injection and other common vulnerabilities are prevented

## Performance

- [ ] No obvious performance issues
- [ ] Database queries are optimized
- [ ] Large datasets are paginated
- [ ] Unnecessary API calls are avoided

## Testing

- [ ] Adequate test coverage (>90% for new code)
- [ ] Tests are meaningful and test edge cases
- [ ] Tests are readable and maintainable
- [ ] Integration tests cover happy path and error scenarios

## Documentation

- [ ] Code is self-documenting with clear naming
- [ ] Complex logic has explanatory comments
- [ ] API documentation is updated (if applicable)
- [ ] README or relevant docs are updated

## Accessibility (Frontend)

- [ ] Semantic HTML is used
- [ ] ARIA attributes are properly implemented
- [ ] Keyboard navigation works correctly
- [ ] Color contrast meets WCAG standards

## Mobile/Responsive (Frontend)

- [ ] Layout works on mobile devices
- [ ] Touch targets are adequately sized
- [ ] Text is readable on small screens
- [ ] No horizontal scrolling on mobile
```

### Performance Monitoring

```typescript
// ✅ Performance monitoring setup
import { Injectable, Logger } from "@nestjs/common";
import { performance } from "perf_hooks";

@Injectable()
export class PerformanceMonitor {
  private readonly logger = new Logger(PerformanceMonitor.name);

  /**
   * Decorator to monitor method execution time
   */
  static Monitor(
    target: any,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    const originalMethod = descriptor.value;

    descriptor.value = async function (...args: any[]) {
      const startTime = performance.now();
      const className = target.constructor.name;
      const methodName = propertyKey;

      try {
        const result = await originalMethod.apply(this, args);
        const duration = performance.now() - startTime;

        // Log slow operations
        if (duration > 1000) {
          // > 1 second
          Logger.warn(
            `Slow operation detected: ${className}.${methodName} took ${duration.toFixed(
              2
            )}ms`,
            "PerformanceMonitor"
          );
        }

        // Send metrics to monitoring service
        this.recordMetric?.({
          operation: `${className}.${methodName}`,
          duration,
          success: true,
          timestamp: new Date(),
        });

        return result;
      } catch (error) {
        const duration = performance.now() - startTime;

        // Record failed operation metrics
        this.recordMetric?.({
          operation: `${className}.${methodName}`,
          duration,
          success: false,
          error: error.message,
          timestamp: new Date(),
        });

        throw error;
      }
    };

    return descriptor;
  }
}

// Usage example
@Injectable()
export class UserService {
  @PerformanceMonitor.Monitor
  async createUser(userData: CreateUserDto): Promise<User> {
    // Method implementation
  }

  @PerformanceMonitor.Monitor
  async findUsersByLocation(location: string): Promise<User[]> {
    // Complex database query that should be monitored
  }
}
```

This comprehensive coding standards document establishes academic-level proficiency while maintaining practical applicability for real-world development. The standards cover all aspects from code organization to security, performance, and continuous improvement practices that showcase professional software development excellence.
