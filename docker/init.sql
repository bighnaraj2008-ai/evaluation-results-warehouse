-- =============================================================================
-- docker/init.sql
-- Database initialization script for PostgreSQL evaluation warehouse container
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

SET timezone = 'UTC';

-- Ensure schema public exists and default permissions are standard
GRANT ALL ON SCHEMA public TO eval;