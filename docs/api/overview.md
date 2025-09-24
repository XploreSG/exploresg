# XploreSG API Documentation

## 🌐 API Overview

XploreSG provides a RESTful API that follows OpenAPI 3.0 specifications. The API is designed to be intuitive, consistent, and developer-friendly.

## 🔗 Base URLs

```
Development:  http://localhost:3001/api/v1
Staging:      https://api-staging.xploresg.com/v1
Production:   https://api.xploresg.com/v1
```

## 🔐 Authentication

### JWT Bearer Token Authentication

All authenticated endpoints require a JWT token in the Authorization header:

```http
Authorization: Bearer <jwt_token>
```

### Getting an Access Token

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "email": "user@example.com",
      "profile": {
        "firstName": "John",
        "lastName": "Doe"
      }
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expiresIn": 86400
    }
  }
}
```

## 📋 API Standards

### HTTP Status Codes

| Code | Description           | Usage                      |
| ---- | --------------------- | -------------------------- |
| 200  | OK                    | Successful GET, PUT, PATCH |
| 201  | Created               | Successful POST            |
| 204  | No Content            | Successful DELETE          |
| 400  | Bad Request           | Validation errors          |
| 401  | Unauthorized          | Authentication required    |
| 403  | Forbidden             | Insufficient permissions   |
| 404  | Not Found             | Resource not found         |
| 409  | Conflict              | Resource already exists    |
| 422  | Unprocessable Entity  | Business logic errors      |
| 429  | Too Many Requests     | Rate limit exceeded        |
| 500  | Internal Server Error | Server errors              |

### Response Format

All API responses follow a consistent structure:

#### Success Response

```json
{
  "success": true,
  "data": {
    // Response data here
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "requestId": "req_123456789"
  }
}
```

#### Error Response

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      }
    ]
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "requestId": "req_123456789"
  }
}
```

### Pagination

For endpoints that return lists, pagination is implemented using cursor-based pagination:

```http
GET /api/v1/locations?limit=20&cursor=eyJpZCI6IjEyMyJ9
```

**Response:**

```json
{
  "success": true,
  "data": {
    "items": [...],
    "pagination": {
      "hasNext": true,
      "nextCursor": "eyJpZCI6IjE0NSJ9",
      "limit": 20,
      "total": 150
    }
  }
}
```

## 🏷️ API Endpoints

### Authentication Endpoints

#### Register User

```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123",
  "firstName": "John",
  "lastName": "Doe"
}
```

#### Login User

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

#### Refresh Token

```http
POST /api/v1/auth/refresh
Authorization: Bearer <refresh_token>
```

#### Logout

```http
POST /api/v1/auth/logout
Authorization: Bearer <access_token>
```

#### Forgot Password

```http
POST /api/v1/auth/forgot-password
Content-Type: application/json

{
  "email": "user@example.com"
}
```

#### Reset Password

```http
POST /api/v1/auth/reset-password
Content-Type: application/json

{
  "token": "reset_token_here",
  "newPassword": "newSecurePassword123"
}
```

### User Management Endpoints

#### Get Current User

```http
GET /api/v1/users/me
Authorization: Bearer <access_token>
```

#### Update User Profile

```http
PUT /api/v1/users/me
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "profile": {
    "firstName": "John",
    "lastName": "Smith",
    "displayName": "Johnny",
    "bio": "Love exploring Singapore!",
    "interests": ["food", "culture", "nature"],
    "preferredDistricts": ["Orchard", "Marina Bay"]
  }
}
```

#### Upload Avatar

```http
POST /api/v1/users/me/avatar
Authorization: Bearer <access_token>
Content-Type: multipart/form-data

{
  "avatar": <file>
}
```

#### Change Password

```http
PUT /api/v1/users/me/password
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "currentPassword": "currentPassword123",
  "newPassword": "newPassword123"
}
```

### Location Endpoints (Future Implementation)

#### Get Locations

```http
GET /api/v1/locations?category=restaurant&district=Orchard&limit=20
```

**Query Parameters:**

| Parameter | Type   | Description                                                 |
| --------- | ------ | ----------------------------------------------------------- |
| category  | string | Filter by category (restaurant, attraction, shopping, etc.) |
| district  | string | Filter by Singapore district                                |
| latitude  | number | Latitude for proximity search                               |
| longitude | number | Longitude for proximity search                              |
| radius    | number | Search radius in kilometers                                 |
| limit     | number | Number of results (max 100)                                 |
| cursor    | string | Pagination cursor                                           |

#### Get Location Details

```http
GET /api/v1/locations/{locationId}
```

#### Search Locations

```http
GET /api/v1/locations/search?q=marina bay sands&limit=10
```

#### Create Review

```http
POST /api/v1/locations/{locationId}/reviews
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "rating": 5,
  "title": "Amazing experience!",
  "content": "Had a wonderful time visiting this place...",
  "visitDate": "2024-01-10"
}
```

#### Get Location Reviews

```http
GET /api/v1/locations/{locationId}/reviews?limit=20&sort=newest
```

### User Favorites Endpoints (Future)

#### Add to Favorites

```http
POST /api/v1/users/me/favorites
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "locationId": "123e4567-e89b-12d3-a456-426614174000",
  "category": "wishlist"
}
```

#### Get User Favorites

```http
GET /api/v1/users/me/favorites?category=wishlist&limit=20
Authorization: Bearer <access_token>
```

#### Remove from Favorites

```http
DELETE /api/v1/users/me/favorites/{locationId}
Authorization: Bearer <access_token>
```

## 🔍 Request/Response Examples

### User Registration Flow

**1. Register User**

```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "alice@example.com",
  "password": "SecurePass123!",
  "firstName": "Alice",
  "lastName": "Tan",
  "acceptsTerms": true
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "alice@example.com",
      "emailVerified": false,
      "profile": {
        "firstName": "Alice",
        "lastName": "Tan",
        "displayName": "Alice Tan"
      },
      "createdAt": "2024-01-15T10:30:00Z"
    },
    "message": "Registration successful. Please check your email to verify your account."
  }
}
```

**2. Login After Email Verification**

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "alice@example.com",
  "password": "SecurePass123!"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "alice@example.com",
      "emailVerified": true,
      "profile": {
        "firstName": "Alice",
        "lastName": "Tan",
        "displayName": "Alice Tan",
        "bio": null,
        "avatarUrl": null,
        "interests": [],
        "preferredDistricts": []
      }
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJlbWFpbCI6ImFsaWNlQGV4YW1wbGUuY29tIiwiaWF0IjoxNzA1MzIxODAwLCJleHAiOjE3MDU0MDgyMDB9.signature",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.refresh_payload.signature",
      "expiresIn": 86400,
      "tokenType": "Bearer"
    }
  }
}
```

## 📝 Data Models

### User Model

```json
{
  "id": "uuid",
  "email": "string",
  "emailVerified": "boolean",
  "phone": "string|null",
  "status": "active|inactive|suspended",
  "profile": {
    "firstName": "string",
    "lastName": "string",
    "displayName": "string",
    "bio": "string|null",
    "avatarUrl": "string|null",
    "dateOfBirth": "date|null",
    "gender": "string|null",
    "nationality": "string|null",
    "preferredLanguage": "string",
    "timezone": "string",
    "interests": ["string"],
    "preferredDistricts": ["string"],
    "accessibilityNeeds": ["string"]
  },
  "createdAt": "datetime",
  "updatedAt": "datetime",
  "lastLoginAt": "datetime|null"
}
```

### Location Model (Future)

```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "category": "restaurant|attraction|shopping|entertainment|transport",
  "subcategory": "string",
  "coordinates": {
    "latitude": "number",
    "longitude": "number"
  },
  "address": {
    "street": "string",
    "postalCode": "string",
    "district": "string",
    "mrtStation": "string|null"
  },
  "contact": {
    "phone": "string|null",
    "website": "string|null",
    "email": "string|null"
  },
  "businessInfo": {
    "openingHours": "object",
    "priceRange": "$|$$|$$$|$$$$",
    "paymentMethods": ["string"]
  },
  "media": {
    "images": ["string"],
    "videos": ["string"]
  },
  "tags": ["string"],
  "accessibilityFeatures": ["string"],
  "rating": {
    "average": "number",
    "count": "number"
  },
  "status": "active|inactive|pending",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

## 🛡️ Rate Limiting

API endpoints are protected by rate limiting:

| Endpoint Type  | Rate Limit   | Window     |
| -------------- | ------------ | ---------- |
| Authentication | 5 requests   | 15 minutes |
| General API    | 100 requests | 1 hour     |
| Search         | 50 requests  | 5 minutes  |
| Upload         | 10 requests  | 10 minutes |

Rate limit headers are included in responses:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705408200
```

## 🔧 Development Tools

### Postman Collection

Import our Postman collection for easy API testing:

```json
{
  "info": {
    "name": "XploreSG API",
    "version": "1.0.0"
  },
  "variable": [
    {
      "key": "baseUrl",
      "value": "http://localhost:3001/api/v1"
    },
    {
      "key": "accessToken",
      "value": ""
    }
  ]
}
```

### OpenAPI Specification

The complete OpenAPI 3.0 specification is available at:

- **Development**: `http://localhost:3001/api-docs`
- **Production**: `https://api.xploresg.com/api-docs`

### SDK Generation

Generate client SDKs using the OpenAPI specification:

```bash
# JavaScript/TypeScript SDK
npx @openapitools/openapi-generator-cli generate \
  -i http://localhost:3001/api-docs.json \
  -g typescript-fetch \
  -o ./sdk/typescript

# Python SDK
openapi-generator generate \
  -i http://localhost:3001/api-docs.json \
  -g python \
  -o ./sdk/python
```

---

This API documentation provides a comprehensive guide for developers to integrate with XploreSG's backend services! 🚀🇸🇬
