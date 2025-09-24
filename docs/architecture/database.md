# Database Design for XploreSG

## 🗄️ Database Architecture Overview

XploreSG uses a polyglot persistence approach with PostgreSQL as the primary database, complemented by Redis for caching and MongoDB for document storage (when needed).

## 📊 Database Schema

### Core User Management Schema

```sql
-- Users table - Core user information
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),

    -- Indexes
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- User profiles - Extended user information
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    display_name VARCHAR(100),
    bio TEXT,
    avatar_url VARCHAR(500),
    date_of_birth DATE,
    gender VARCHAR(20),
    nationality VARCHAR(50),
    preferred_language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'Asia/Singapore',

    -- Singapore-specific preferences
    interests TEXT[], -- Array of interest categories
    preferred_districts TEXT[], -- Singapore districts
    accessibility_needs TEXT[],

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Authentication sessions
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Indexes for performance
    INDEX idx_sessions_token_hash (token_hash),
    INDEX idx_sessions_user_id (user_id),
    INDEX idx_sessions_expires (expires_at)
);

-- Password reset tokens
CREATE TABLE password_resets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    INDEX idx_password_resets_token (token_hash),
    INDEX idx_password_resets_expires (expires_at)
);

-- Email verification tokens
CREATE TABLE email_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    INDEX idx_email_verifications_token (token_hash)
);
```

### Singapore Exploration Schema (Future Implementation)

```sql
-- Singapore locations and attractions
CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL, -- restaurant, attraction, shopping, etc.
    subcategory VARCHAR(50),

    -- Geographic data
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    address TEXT,
    postal_code VARCHAR(10),
    district VARCHAR(50),
    mrt_station VARCHAR(100),

    -- Business information
    phone VARCHAR(20),
    website VARCHAR(500),
    opening_hours JSONB,
    price_range VARCHAR(10), -- $, $$, $$$, $$$$

    -- Metadata
    images TEXT[],
    tags TEXT[],
    accessibility_features TEXT[],

    -- Status and timestamps
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints and indexes
    CONSTRAINT valid_coordinates CHECK (
        latitude BETWEEN 1.1 AND 1.5 AND
        longitude BETWEEN 103.6 AND 104.0
    ),
    INDEX idx_locations_category (category),
    INDEX idx_locations_district (district),
    INDEX idx_locations_coordinates (latitude, longitude)
);

-- User reviews and ratings
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,

    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(200),
    content TEXT,
    images TEXT[],

    -- Review metadata
    visit_date DATE,
    helpful_count INTEGER DEFAULT 0,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Ensure one review per user per location
    UNIQUE(user_id, location_id),
    INDEX idx_reviews_location (location_id),
    INDEX idx_reviews_user (user_id),
    INDEX idx_reviews_rating (rating)
);

-- User favorites/wishlist
CREATE TABLE user_favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,

    category VARCHAR(50), -- wishlist, visited, favorites
    notes TEXT,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(user_id, location_id, category),
    INDEX idx_favorites_user (user_id),
    INDEX idx_favorites_location (location_id)
);

-- User check-ins and visits
CREATE TABLE user_visits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,

    visit_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    duration_minutes INTEGER,
    notes TEXT,
    photos TEXT[],

    -- Optional: Social features
    is_public BOOLEAN DEFAULT FALSE,
    shared_with TEXT[], -- Array of user IDs or 'public'

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    INDEX idx_visits_user (user_id),
    INDEX idx_visits_location (location_id),
    INDEX idx_visits_date (visit_date)
);

-- Bookings for activities/restaurants (if applicable)
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,

    booking_date TIMESTAMP WITH TIME ZONE NOT NULL,
    party_size INTEGER DEFAULT 1,
    special_requests TEXT,

    -- Booking status
    status VARCHAR(20) DEFAULT 'pending' CHECK (
        status IN ('pending', 'confirmed', 'cancelled', 'completed', 'no_show')
    ),

    -- External booking reference (if integrated with third-party systems)
    external_booking_id VARCHAR(100),

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    INDEX idx_bookings_user (user_id),
    INDEX idx_bookings_location (location_id),
    INDEX idx_bookings_date (booking_date),
    INDEX idx_bookings_status (status)
);
```

## 🔧 Database Configuration

### PostgreSQL Configuration

```yaml
# Development Configuration
postgresql.conf:
  shared_buffers: 256MB
  effective_cache_size: 1GB
  work_mem: 4MB
  maintenance_work_mem: 64MB
  wal_buffers: 8MB
  checkpoint_completion_target: 0.9
  max_connections: 100

# Production Configuration
postgresql.conf:
  shared_buffers: 2GB
  effective_cache_size: 8GB
  work_mem: 16MB
  maintenance_work_mem: 256MB
  wal_buffers: 32MB
  max_connections: 200
  checkpoint_completion_target: 0.9
```

### Connection Pooling

```yaml
# PgBouncer Configuration
pgbouncer.ini:
  pool_mode: transaction
  max_client_conn: 200
  default_pool_size: 25
  server_round_robin: 1
  ignore_startup_parameters: extra_float_digits
```

## 📈 Performance Optimization

### Indexing Strategy

```sql
-- Essential indexes for performance
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_users_status ON users(status) WHERE status = 'active';
CREATE INDEX CONCURRENTLY idx_sessions_active ON user_sessions(user_id, expires_at)
  WHERE expires_at > NOW();

-- Composite indexes for common queries
CREATE INDEX CONCURRENTLY idx_reviews_location_rating ON reviews(location_id, rating);
CREATE INDEX CONCURRENTLY idx_locations_category_district ON locations(category, district);
CREATE INDEX CONCURRENTLY idx_visits_user_date ON user_visits(user_id, visit_date DESC);

-- Partial indexes for efficiency
CREATE INDEX CONCURRENTLY idx_active_locations ON locations(category, district)
  WHERE status = 'active';
```

### Query Optimization

```sql
-- Optimized user authentication query
SELECT u.id, u.email, u.password_hash, u.status, p.display_name
FROM users u
LEFT JOIN user_profiles p ON u.id = p.user_id
WHERE u.email = $1 AND u.status = 'active';

-- Optimized location search with filters
SELECT l.*, AVG(r.rating) as avg_rating, COUNT(r.id) as review_count
FROM locations l
LEFT JOIN reviews r ON l.id = r.location_id
WHERE l.category = $1
  AND l.district = ANY($2)
  AND l.status = 'active'
GROUP BY l.id
ORDER BY avg_rating DESC NULLS LAST, review_count DESC
LIMIT 20;
```

## 🗄️ Redis Cache Strategy

### Cache Keys Pattern

```redis
# User sessions
session:{token_hash} -> {user_id, expires_at, ...}

# User profiles (frequently accessed)
user:profile:{user_id} -> {profile_json}

# Location data cache
location:{location_id} -> {location_json}
location:search:{category}:{district} -> {location_ids_array}

# Aggregated data
stats:location:{location_id}:reviews -> {count, avg_rating}
trending:locations:{date} -> {location_ids_sorted_by_popularity}

# Rate limiting
rate_limit:api:{user_id}:{endpoint} -> {request_count}
rate_limit:ip:{ip_address} -> {request_count}
```

### Cache TTL Strategy

```redis
# Session data: 24 hours
session:* TTL 86400

# Profile data: 1 hour (frequently updated)
user:profile:* TTL 3600

# Location data: 4 hours (relatively stable)
location:* TTL 14400

# Search results: 15 minutes (dynamic)
location:search:* TTL 900

# Statistics: 30 minutes (can be slightly stale)
stats:* TTL 1800
```

## 🔄 Data Migration Strategy

### Migration Scripts Structure

```sql
-- Migration: 001_initial_users_table.sql
CREATE TABLE users (
    -- Initial schema
);

-- Migration: 002_add_user_profiles.sql
CREATE TABLE user_profiles (
    -- Profile schema
);

-- Migration: 003_add_sessions_table.sql
CREATE TABLE user_sessions (
    -- Sessions schema
);

-- Migration: 004_singapore_locations.sql
CREATE TABLE locations (
    -- Singapore-specific location data
);
```

### Data Seeding Strategy

```sql
-- Seed Singapore districts
INSERT INTO singapore_districts (name, region) VALUES
('Central Business District', 'Central'),
('Orchard Road', 'Central'),
('Marina Bay', 'Central'),
('Chinatown', 'Central'),
('Little India', 'Central'),
-- ... more districts

-- Seed popular locations
INSERT INTO locations (name, category, latitude, longitude, district) VALUES
('Marina Bay Sands', 'attraction', 1.2834, 103.8607, 'Marina Bay'),
('Gardens by the Bay', 'attraction', 1.2816, 103.8636, 'Marina Bay'),
-- ... more locations
```

## 🔐 Security Considerations

### Data Protection

```sql
-- Row Level Security (RLS) for user data
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_profiles_policy ON user_profiles
    FOR ALL TO application_role
    USING (user_id = current_setting('app.user_id')::uuid);

-- Sensitive data encryption
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Store encrypted phone numbers
ALTER TABLE users ADD COLUMN phone_encrypted BYTEA;
UPDATE users SET phone_encrypted = pgp_sym_encrypt(phone, 'encryption_key');
```

### Database Access Control

```sql
-- Application database user (limited permissions)
CREATE ROLE app_user WITH LOGIN PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE xploresg_prod TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Read-only user for analytics
CREATE ROLE analytics_user WITH LOGIN PASSWORD 'analytics_password';
GRANT CONNECT ON DATABASE xploresg_prod TO analytics_user;
GRANT USAGE ON SCHEMA public TO analytics_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytics_user;
```

## 📊 Monitoring and Maintenance

### Database Monitoring Queries

```sql
-- Monitor active connections
SELECT count(*) as active_connections, usename, application_name
FROM pg_stat_activity
WHERE state = 'active'
GROUP BY usename, application_name;

-- Monitor slow queries
SELECT query, mean_exec_time, calls, total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Monitor database size
SELECT schemaname, tablename,
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Backup Strategy

```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="xploresg_prod"
BACKUP_DIR="/backups"

# Full database backup
pg_dump -h localhost -U postgres -d $DB_NAME | gzip > "$BACKUP_DIR/full_backup_$DATE.sql.gz"

# Schema-only backup
pg_dump -h localhost -U postgres -d $DB_NAME --schema-only > "$BACKUP_DIR/schema_backup_$DATE.sql"

# Data-only backup
pg_dump -h localhost -U postgres -d $DB_NAME --data-only > "$BACKUP_DIR/data_backup_$DATE.sql"
```

---

This database design provides a solid foundation for XploreSG that can handle user management, Singapore location data, and social features while maintaining performance and security! 🇸🇬📊
