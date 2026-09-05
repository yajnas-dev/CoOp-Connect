-- ============================================================
-- CO-OP CONNECT
-- Database Schema
-- PostgreSQL / Supabase
-- ============================================================

-- ============================================================
-- 1. COOPERATIVES
-- ============================================================

CREATE TABLE cooperatives (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    registration_number VARCHAR(100) UNIQUE,
    address TEXT,
    city VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(150),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 2. USERS
-- Common authentication table for CUSTOMER, WORKER and ADMIN
-- ============================================================

CREATE TABLE users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    cooperative_id BIGINT
        REFERENCES cooperatives(id)
        ON DELETE SET NULL,

    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password_hash TEXT NOT NULL,

    role VARCHAR(20) NOT NULL
        CHECK (role IN ('CUSTOMER', 'WORKER', 'ADMIN')),

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'BLOCKED')),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 3. CUSTOMERS
-- ============================================================

CREATE TABLE customers (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_id BIGINT NOT NULL UNIQUE
        REFERENCES users(id)
        ON DELETE CASCADE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 4. WORKERS
-- ============================================================

CREATE TABLE workers (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_id BIGINT NOT NULL UNIQUE
        REFERENCES users(id)
        ON DELETE CASCADE,

    cooperative_id BIGINT
        REFERENCES cooperatives(id)
        ON DELETE SET NULL,

    bio TEXT,

    experience_years INTEGER NOT NULL DEFAULT 0
        CHECK (experience_years >= 0),

    verification_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (
            verification_status
            IN ('PENDING', 'APPROVED', 'REJECTED')
        ),

    availability_status VARCHAR(20) NOT NULL DEFAULT 'OFFLINE'
        CHECK (
            availability_status
            IN ('AVAILABLE', 'BUSY', 'OFFLINE')
        ),

    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),

    service_area VARCHAR(150),

    average_rating DECIMAL(3,2) DEFAULT 0
        CHECK (average_rating >= 0 AND average_rating <= 5),

    total_services INTEGER NOT NULL DEFAULT 0
        CHECK (total_services >= 0),

    completion_rate DECIMAL(5,2) DEFAULT 0
        CHECK (completion_rate >= 0 AND completion_rate <= 100),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 5. SERVICES
-- ============================================================

CREATE TABLE services (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(20),

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'INACTIVE')),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 6. WORKER SERVICES
-- Many-to-many relationship between workers and services
-- ============================================================

CREATE TABLE worker_services (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    worker_id BIGINT NOT NULL
        REFERENCES workers(id)
        ON DELETE CASCADE,

    service_id BIGINT NOT NULL
        REFERENCES services(id)
        ON DELETE CASCADE,

    skill_level VARCHAR(20) NOT NULL
        CHECK (
            skill_level
            IN ('BEGINNER', 'INTERMEDIATE', 'EXPERT')
        ),

    years_experience INTEGER NOT NULL DEFAULT 0
        CHECK (years_experience >= 0),

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(worker_id, service_id)
);


-- ============================================================
-- 7. WORKER DOCUMENTS
-- ============================================================

CREATE TABLE worker_documents (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    worker_id BIGINT NOT NULL
        REFERENCES workers(id)
        ON DELETE CASCADE,

    document_type VARCHAR(30) NOT NULL
        CHECK (
            document_type
            IN (
                'IDENTITY',
                'SKILL_CERTIFICATE',
                'COOPERATIVE_MEMBERSHIP',
                'OTHER'
            )
        ),

    document_name VARCHAR(150) NOT NULL,
    document_path TEXT NOT NULL,

    verification_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (
            verification_status
            IN ('PENDING', 'VERIFIED', 'REJECTED')
        ),

    verified_by BIGINT
        REFERENCES users(id)
        ON DELETE SET NULL,

    verified_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 8. WAGE RULES
-- Fair Wage Engine
-- ============================================================

CREATE TABLE wage_rules (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    service_id BIGINT NOT NULL
        REFERENCES services(id)
        ON DELETE CASCADE,

    skill_level VARCHAR(20) NOT NULL
        CHECK (
            skill_level
            IN ('BEGINNER', 'INTERMEDIATE', 'EXPERT')
        ),

    complexity_level VARCHAR(20) NOT NULL
        CHECK (
            complexity_level
            IN ('BASIC', 'STANDARD', 'COMPLEX')
        ),

    base_wage DECIMAL(10,2) NOT NULL DEFAULT 0
        CHECK (base_wage >= 0),

    skill_premium DECIMAL(10,2) NOT NULL DEFAULT 0
        CHECK (skill_premium >= 0),

    travel_rate_per_km DECIMAL(10,2) NOT NULL DEFAULT 0
        CHECK (travel_rate_per_km >= 0),

    complexity_charge DECIMAL(10,2) NOT NULL DEFAULT 0
        CHECK (complexity_charge >= 0),

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'INACTIVE')),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(service_id, skill_level, complexity_level)
);


-- ============================================================
-- 9. CUSTOMER ADDRESSES
-- ============================================================

CREATE TABLE customer_addresses (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id BIGINT NOT NULL
        REFERENCES customers(id)
        ON DELETE CASCADE,

    label VARCHAR(50),
    address TEXT NOT NULL,
    city VARCHAR(100),

    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),

    is_default BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 10. WORKER LOCATIONS
-- Stores latest worker location only
-- NOT live GPS tracking
-- ============================================================

CREATE TABLE worker_locations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    worker_id BIGINT NOT NULL UNIQUE
        REFERENCES workers(id)
        ON DELETE CASCADE,

    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 11. BOOKINGS
-- ============================================================

CREATE TABLE bookings (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id BIGINT NOT NULL
        REFERENCES customers(id)
        ON DELETE RESTRICT,

    worker_id BIGINT NOT NULL
        REFERENCES workers(id)
        ON DELETE RESTRICT,

    service_id BIGINT NOT NULL
        REFERENCES services(id)
        ON DELETE RESTRICT,

    booking_date DATE NOT NULL,
    booking_time TIME NOT NULL,

    description TEXT,

    complexity_level VARCHAR(20) NOT NULL
        CHECK (
            complexity_level
            IN ('BASIC', 'STANDARD', 'COMPLEX')
        ),

    service_address TEXT NOT NULL,

    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),

    -- Fair Wage snapshot
    base_wage DECIMAL(10,2) NOT NULL DEFAULT 0,
    skill_premium DECIMAL(10,2) NOT NULL DEFAULT 0,
    travel_charge DECIMAL(10,2) NOT NULL DEFAULT 0,
    complexity_charge DECIMAL(10,2) NOT NULL DEFAULT 0,
    fair_wage DECIMAL(10,2) NOT NULL DEFAULT 0,

    status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (
            status IN (
                'PENDING',
                'ACCEPTED',
                'IN_PROGRESS',
                'COMPLETED',
                'CANCELLED'
            )
        ),

    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (
            payment_status
            IN ('PENDING', 'PAID', 'FAILED')
        ),

    cancellation_reason TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);


-- ============================================================
-- 12. BOOKING STATUS HISTORY
-- ============================================================

CREATE TABLE booking_status_history (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    booking_id BIGINT NOT NULL
        REFERENCES bookings(id)
        ON DELETE CASCADE,

    status VARCHAR(20) NOT NULL
        CHECK (
            status IN (
                'PENDING',
                'ACCEPTED',
                'IN_PROGRESS',
                'COMPLETED',
                'CANCELLED'
            )
        ),

    changed_by BIGINT
        REFERENCES users(id)
        ON DELETE SET NULL,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 13. PAYMENTS
-- ============================================================

CREATE TABLE payments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    booking_id BIGINT NOT NULL UNIQUE
        REFERENCES bookings(id)
        ON DELETE RESTRICT,

    customer_id BIGINT NOT NULL
        REFERENCES customers(id)
        ON DELETE RESTRICT,

    amount DECIMAL(10,2) NOT NULL
        CHECK (amount >= 0),

    payment_method VARCHAR(20) NOT NULL DEFAULT 'SIMULATED'
        CHECK (
            payment_method
            IN ('SIMULATED', 'CASH', 'UPI', 'CARD')
        ),

    transaction_reference VARCHAR(150) UNIQUE,

    status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (
            status IN ('PENDING', 'PAID', 'FAILED')
        ),

    paid_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 14. REVIEWS
-- ============================================================

CREATE TABLE reviews (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    booking_id BIGINT NOT NULL UNIQUE
        REFERENCES bookings(id)
        ON DELETE CASCADE,

    customer_id BIGINT NOT NULL
        REFERENCES customers(id)
        ON DELETE RESTRICT,

    worker_id BIGINT NOT NULL
        REFERENCES workers(id)
        ON DELETE RESTRICT,

    rating INTEGER NOT NULL
        CHECK (rating >= 1 AND rating <= 5),

    review_text TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 15. COMPLAINTS
-- ============================================================

CREATE TABLE complaints (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    booking_id BIGINT
        REFERENCES bookings(id)
        ON DELETE SET NULL,

    customer_id BIGINT NOT NULL
        REFERENCES customers(id)
        ON DELETE RESTRICT,

    worker_id BIGINT
        REFERENCES workers(id)
        ON DELETE SET NULL,

    category VARCHAR(40) NOT NULL
        CHECK (
            category IN (
                'WORKER_DID_NOT_ARRIVE',
                'POOR_SERVICE',
                'OVERCHARGING',
                'WORKER_BEHAVIOUR',
                'SERVICE_DELAY',
                'OTHER'
            )
        ),

    subject VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,

    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM'
        CHECK (
            priority IN ('LOW', 'MEDIUM', 'HIGH')
        ),

    status VARCHAR(20) NOT NULL DEFAULT 'OPEN'
        CHECK (
            status IN (
                'OPEN',
                'IN_PROGRESS',
                'RESOLVED',
                'REJECTED'
            )
        ),

    admin_response TEXT,

    resolved_by BIGINT
        REFERENCES users(id)
        ON DELETE SET NULL,

    resolved_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 16. NOTIFICATIONS
-- ============================================================

CREATE TABLE notifications (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_id BIGINT NOT NULL
        REFERENCES users(id)
        ON DELETE CASCADE,

    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,

    type VARCHAR(20) NOT NULL
        CHECK (
            type IN (
                'BOOKING',
                'PAYMENT',
                'SERVICE',
                'REVIEW',
                'COMPLAINT',
                'SYSTEM'
            )
        ),

    related_booking_id BIGINT
        REFERENCES bookings(id)
        ON DELETE CASCADE,

    is_read BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_users_role
ON users(role);

CREATE INDEX idx_users_cooperative
ON users(cooperative_id);

CREATE INDEX idx_workers_verification
ON workers(verification_status);

CREATE INDEX idx_workers_availability
ON workers(availability_status);

CREATE INDEX idx_worker_services_worker
ON worker_services(worker_id);

CREATE INDEX idx_worker_services_service
ON worker_services(service_id);

CREATE INDEX idx_worker_documents_worker
ON worker_documents(worker_id);

CREATE INDEX idx_wage_rules_service
ON wage_rules(service_id);

CREATE INDEX idx_bookings_customer
ON bookings(customer_id);

CREATE INDEX idx_bookings_worker
ON bookings(worker_id);

CREATE INDEX idx_bookings_service
ON bookings(service_id);

CREATE INDEX idx_bookings_status
ON bookings(status);

CREATE INDEX idx_bookings_date
ON bookings(booking_date);

CREATE INDEX idx_booking_history_booking
ON booking_status_history(booking_id);

CREATE INDEX idx_payments_customer
ON payments(customer_id);

CREATE INDEX idx_reviews_worker
ON reviews(worker_id);

CREATE INDEX idx_complaints_customer
ON complaints(customer_id);

CREATE INDEX idx_complaints_worker
ON complaints(worker_id);

CREATE INDEX idx_complaints_status
ON complaints(status);

CREATE INDEX idx_notifications_user
ON notifications(user_id);

CREATE INDEX idx_notifications_unread
ON notifications(user_id, is_read);


-- ============================================================
-- UPDATED_AT TRIGGER FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- UPDATED_AT TRIGGERS
-- ============================================================

CREATE TRIGGER update_cooperatives_updated_at
BEFORE UPDATE ON cooperatives
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at
BEFORE UPDATE ON customers
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workers_updated_at
BEFORE UPDATE ON workers
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at
BEFORE UPDATE ON services
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_wage_rules_updated_at
BEFORE UPDATE ON wage_rules
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customer_addresses_updated_at
BEFORE UPDATE ON customer_addresses
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
BEFORE UPDATE ON bookings
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at
BEFORE UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_complaints_updated_at
BEFORE UPDATE ON complaints
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();