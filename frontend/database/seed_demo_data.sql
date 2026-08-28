-- ============================================================
-- CO-OP CONNECT
-- Demo / Seed Data
-- PostgreSQL / Supabase
-- ============================================================

-- ============================================================
-- 1. COOPERATIVE
-- ============================================================

INSERT INTO cooperatives
(
    name,
    registration_number,
    address,
    city,
    phone,
    email,
    status
)
VALUES
(
    'Co-Op Connect Labour Cooperative',
    'COOP001',
    'Tisaiyanvilai',
    'Tirunelveli',
    '+91 90000 00000',
    'coopconnect@example.com',
    'ACTIVE'
)
ON CONFLICT (registration_number) DO NOTHING;


-- ============================================================
-- 2. SERVICES
-- ============================================================

INSERT INTO services
(
    name,
    description,
    icon,
    status
)
VALUES
(
    'Electrical',
    'Electrical wiring, installation, repair and maintenance services.',
    '⚡',
    'ACTIVE'
),
(
    'Plumbing',
    'Pipe repair, leakage fixing, water system and plumbing services.',
    '🔧',
    'ACTIVE'
),
(
    'Carpentry',
    'Furniture, doors, woodwork and carpentry services.',
    '🪚',
    'ACTIVE'
),
(
    'Cleaning',
    'Home, office and deep cleaning services.',
    '🧹',
    'ACTIVE'
),
(
    'Painting',
    'Interior, exterior and wall painting services.',
    '🎨',
    'ACTIVE'
),
(
    'Gardening',
    'Gardening, pruning, landscaping and plant maintenance.',
    '🌱',
    'ACTIVE'
),
(
    'Caregiving',
    'Home-based caregiving and assistance services.',
    '❤️',
    'ACTIVE'
)
ON CONFLICT (name) DO NOTHING;


-- ============================================================
-- 3. WAGE RULES
-- Fair Wage:
-- Base Wage
-- + Skill Premium
-- + Distance × Travel Rate
-- + Complexity Charge
-- ============================================================

INSERT INTO wage_rules
(
    service_id,
    skill_level,
    complexity_level,
    base_wage,
    skill_premium,
    travel_rate_per_km,
    complexity_charge,
    status
)
SELECT
    s.id,
    sl.skill_level,
    cl.complexity_level,

    CASE s.name
        WHEN 'Electrical' THEN 400
        WHEN 'Plumbing' THEN 400
        WHEN 'Carpentry' THEN 450
        WHEN 'Cleaning' THEN 350
        WHEN 'Painting' THEN 400
        WHEN 'Gardening' THEN 350
        WHEN 'Caregiving' THEN 400
    END,

    CASE sl.skill_level
        WHEN 'BEGINNER' THEN 0
        WHEN 'INTERMEDIATE' THEN 50
        WHEN 'EXPERT' THEN 100
    END,

    20,

    CASE cl.complexity_level
        WHEN 'BASIC' THEN 0
        WHEN 'STANDARD' THEN 100
        WHEN 'COMPLEX' THEN 200
    END,

    'ACTIVE'

FROM services s

CROSS JOIN
(
    VALUES
        ('BEGINNER'),
        ('INTERMEDIATE'),
        ('EXPERT')
) AS sl(skill_level)

CROSS JOIN
(
    VALUES
        ('BASIC'),
        ('STANDARD'),
        ('COMPLEX')
) AS cl(complexity_level)

WHERE s.status = 'ACTIVE'

ON CONFLICT (service_id, skill_level, complexity_level)
DO NOTHING;


-- ============================================================
-- 4. DEMO USERS
--
-- IMPORTANT:
-- These password_hash values are placeholders only.
-- Backend must replace them with real bcrypt hashes.
-- ============================================================

INSERT INTO users
(
    cooperative_id,
    name,
    email,
    phone,
    password_hash,
    role,
    status
)
SELECT
    c.id,
    u.name,
    u.email,
    u.phone,
    u.password_hash,
    u.role,
    'ACTIVE'
FROM cooperatives c

CROSS JOIN
(
    VALUES
    (
        'Co-Op Admin',
        'admin@coopconnect.com',
        '+91 90000 00001',
        'TEMP_ADMIN_HASH',
        'ADMIN'
    ),
    (
        'Raj Kumar',
        'raj@coopconnect.com',
        '+91 90000 00002',
        'TEMP_WORKER_HASH',
        'WORKER'
    ),
    (
        'Varsha',
        'varsha@coopconnect.com',
        '+91 90000 00003',
        'TEMP_CUSTOMER_HASH',
        'CUSTOMER'
    )
) AS u(name, email, phone, password_hash, role)

WHERE c.registration_number = 'COOP001'

ON CONFLICT (email) DO NOTHING;


-- ============================================================
-- 5. CUSTOMER PROFILE
-- ============================================================

INSERT INTO customers
(
    user_id
)
SELECT
    u.id
FROM users u
WHERE u.email = 'varsha@coopconnect.com'
AND NOT EXISTS
(
    SELECT 1
    FROM customers c
    WHERE c.user_id = u.id
);


-- ============================================================
-- 6. WORKER PROFILE
-- ============================================================

INSERT INTO workers
(
    user_id,
    cooperative_id,
    bio,
    experience_years,
    verification_status,
    availability_status,
    latitude,
    longitude,
    service_area,
    average_rating,
    total_services,
    completion_rate
)
SELECT
    u.id,
    c.id,
    'Experienced plumbing and home maintenance professional.',
    8,
    'APPROVED',
    'AVAILABLE',
    8.4140,
    77.7560,
    'Tirunelveli',
    4.90,
    124,
    98.00

FROM users u

JOIN cooperatives c
    ON c.registration_number = 'COOP001'

WHERE u.email = 'raj@coopconnect.com'

AND NOT EXISTS
(
    SELECT 1
    FROM workers w
    WHERE w.user_id = u.id
);


-- ============================================================
-- 7. WORKER SERVICE
-- Raj → Plumbing → Expert
-- ============================================================

INSERT INTO worker_services
(
    worker_id,
    service_id,
    skill_level,
    years_experience,
    description
)
SELECT
    w.id,
    s.id,
    'EXPERT',
    8,
    'Expert in pipe repair, leakage, water systems and plumbing maintenance.'

FROM workers w

JOIN users u
    ON u.id = w.user_id

JOIN services s
    ON s.name = 'Plumbing'

WHERE u.email = 'raj@coopconnect.com'

ON CONFLICT (worker_id, service_id)
DO NOTHING;


-- ============================================================
-- 8. WORKER DOCUMENTS
-- Demo documents only.
-- Do NOT use real identity documents in the prototype.
-- ============================================================

INSERT INTO worker_documents
(
    worker_id,
    document_type,
    document_name,
    document_path,
    verification_status
)
SELECT
    w.id,
    d.document_type,
    d.document_name,
    d.document_path,
    'VERIFIED'

FROM workers w

JOIN users u
    ON u.id = w.user_id

CROSS JOIN
(
    VALUES
    (
        'IDENTITY',
        'Identity Proof',
        '/documents/raj/identity-proof.pdf'
    ),
    (
        'SKILL_CERTIFICATE',
        'Plumbing Skill Certificate',
        '/documents/raj/plumbing-certificate.pdf'
    ),
    (
        'COOPERATIVE_MEMBERSHIP',
        'Cooperative Membership Certificate',
        '/documents/raj/cooperative-membership.pdf'
    )
) AS d(document_type, document_name, document_path)

WHERE u.email = 'raj@coopconnect.com'

AND NOT EXISTS
(
    SELECT 1
    FROM worker_documents wd
    WHERE wd.worker_id = w.id
    AND wd.document_name = d.document_name
);


-- ============================================================
-- 9. CUSTOMER ADDRESS
-- ============================================================

INSERT INTO customer_addresses
(
    customer_id,
    label,
    address,
    city,
    latitude,
    longitude,
    is_default
)
SELECT
    c.id,
    'Home',
    'Tisaiyanvilai',
    'Tirunelveli',
    8.3370,
    77.8350,
    TRUE

FROM customers c

JOIN users u
    ON u.id = c.user_id

WHERE u.email = 'varsha@coopconnect.com'

AND NOT EXISTS
(
    SELECT 1
    FROM customer_addresses ca
    WHERE ca.customer_id = c.id
    AND ca.label = 'Home'
);


-- ============================================================
-- 10. WORKER LOCATION
-- Latest location only.
-- This is NOT live GPS tracking.
-- ============================================================

INSERT INTO worker_locations
(
    worker_id,
    latitude,
    longitude
)
SELECT
    w.id,
    8.3400,
    77.8300

FROM workers w

JOIN users u
    ON u.id = w.user_id

WHERE u.email = 'raj@coopconnect.com'

ON CONFLICT (worker_id)
DO UPDATE SET
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    updated_at = NOW();


-- ============================================================
-- 11. DEMO BOOKING
-- ============================================================

INSERT INTO bookings
(
    customer_id,
    worker_id,
    service_id,
    booking_date,
    booking_time,
    description,
    complexity_level,
    service_address,
    latitude,
    longitude,
    base_wage,
    skill_premium,
    travel_charge,
    complexity_charge,
    fair_wage,
    status,
    payment_status
)
SELECT
    c.id,
    w.id,
    s.id,

    CURRENT_DATE + INTERVAL '1 day',

    '10:00:00',

    'Kitchen pipe leakage repair',

    'STANDARD',

    ca.address,
    ca.latitude,
    ca.longitude,

    wr.base_wage,
    wr.skill_premium,

    -- Demo travel charge
    50,

    wr.complexity_charge,

    wr.base_wage
        + wr.skill_premium
        + 50
        + wr.complexity_charge,

    'COMPLETED',
    'PENDING'

FROM customers c

JOIN users cu
    ON cu.id = c.user_id

JOIN workers w
    ON w.user_id = (
        SELECT id
        FROM users
        WHERE email = 'raj@coopconnect.com'
    )

JOIN services s
    ON s.name = 'Plumbing'

JOIN customer_addresses ca
    ON ca.customer_id = c.id
    AND ca.is_default = TRUE

JOIN wage_rules wr
    ON wr.service_id = s.id
    AND wr.skill_level = 'EXPERT'
    AND wr.complexity_level = 'STANDARD'

WHERE cu.email = 'varsha@coopconnect.com'

AND NOT EXISTS
(
    SELECT 1
    FROM bookings b
    WHERE b.customer_id = c.id
    AND b.worker_id = w.id
    AND b.service_id = s.id
    AND b.description = 'Kitchen pipe leakage repair'
);


-- ============================================================
-- 12. BOOKING STATUS HISTORY
-- ============================================================

INSERT INTO booking_status_history
(
    booking_id,
    status,
    changed_by,
    remarks
)
SELECT
    b.id,
    h.status,
    u.id,
    h.remarks

FROM bookings b

JOIN users u
    ON u.email = 'raj@coopconnect.com'

CROSS JOIN
(
    VALUES
    (
        'PENDING',
        'Booking request submitted.'
    ),
    (
        'ACCEPTED',
        'Worker accepted the booking.'
    ),
    (
        'IN_PROGRESS',
        'Worker started the service.'
    ),
    (
        'COMPLETED',
        'Service completed successfully.'
    )
) AS h(status, remarks)

WHERE b.description = 'Kitchen pipe leakage repair'

AND NOT EXISTS
(
    SELECT 1
    FROM booking_status_history bsh
    WHERE bsh.booking_id = b.id
    AND bsh.status = h.status
);


-- ============================================================
-- 13. DEMO PAYMENT
-- ============================================================

INSERT INTO payments
(
    booking_id,
    customer_id,
    amount,
    payment_method,
    transaction_reference,
    status
)
SELECT
    b.id,
    b.customer_id,
    b.fair_wage,
    'SIMULATED',
    'PENDING-' || b.id,
    'PENDING'

FROM bookings b

WHERE b.description = 'Kitchen pipe leakage repair'

AND NOT EXISTS
(
    SELECT 1
    FROM payments p
    WHERE p.booking_id = b.id
);


-- ============================================================
-- 14. DEMO COMPLAINT
-- ============================================================

INSERT INTO complaints
(
    booking_id,
    customer_id,
    worker_id,
    category,
    subject,
    description,
    priority,
    status
)
SELECT
    b.id,
    b.customer_id,
    b.worker_id,
    'SERVICE_DELAY',
    'Service started late',
    'Demo complaint for testing the complaint management workflow.',
    'MEDIUM',
    'OPEN'

FROM bookings b

WHERE b.description = 'Kitchen pipe leakage repair'

AND NOT EXISTS
(
    SELECT 1
    FROM complaints c
    WHERE c.booking_id = b.id
    AND c.subject = 'Service started late'
);


-- ============================================================
-- 15. DEMO NOTIFICATION
-- ============================================================

INSERT INTO notifications
(
    user_id,
    title,
    message,
    type,
    related_booking_id,
    is_read
)
SELECT
    u.id,
    'Booking Request Created',
    'Your plumbing service booking request has been submitted successfully.',
    'BOOKING',
    b.id,
    FALSE

FROM users u

JOIN bookings b
    ON b.description = 'Kitchen pipe leakage repair'

WHERE u.email = 'varsha@coopconnect.com'

AND NOT EXISTS
(
    SELECT 1
    FROM notifications n
    WHERE n.user_id = u.id
    AND n.related_booking_id = b.id
    AND n.title = 'Booking Request Created'
);


-- ============================================================
-- 16. DEMO REVIEW
-- Booking is already COMPLETED in this demo seed.
-- ============================================================

INSERT INTO reviews
(
    booking_id,
    customer_id,
    worker_id,
    rating,
    review_text
)
SELECT
    b.id,
    b.customer_id,
    b.worker_id,
    5,
    'Excellent plumbing service. The worker was professional and completed the work on time.'

FROM bookings b

WHERE b.description = 'Kitchen pipe leakage repair'
AND b.status = 'COMPLETED'

AND NOT EXISTS
(
    SELECT 1
    FROM reviews r
    WHERE r.booking_id = b.id
);


-- ============================================================
-- END OF DEMO DATA
-- ============================================================
-- ============================================================
-- CoopGig - Demo Seed Data
-- File: seed_demo_data.sql
-- ============================================================

-- ============================================================
-- WORKERS
-- ============================================================

INSERT INTO workers
    (id, name, phone, email, experience, address, skills, service_area, availability, status)
VALUES
    (1,
     'Worker',
     '+91 9876543210',
     'worker@email.com',
     '3 Years',
     'Tirunelveli, Tamil Nadu',
     'Electrical, Wiring, Maintenance',
     'Tirunelveli',
     TRUE,
     'Approved');


-- ============================================================
-- CUSTOMERS
-- ============================================================

INSERT INTO customers
    (id, name, phone, email, location)
VALUES
    (1, 'Varsha', '+91 9000000001', 'varsha@email.com', 'Tirunelveli'),
    (2, 'Arun', '+91 9000000002', 'arun@email.com', 'Valliyur'),
    (3, 'Kumar', '+91 9000000003', 'kumar@email.com', 'Tirunelveli');


-- ============================================================
-- JOBS
-- ============================================================

INSERT INTO jobs
    (id, customer_id, title, skill, location, job_date, job_time,
     description, wage, status)
VALUES
    (1,
     1,
     'Electrical Repair',
     'Electrician',
     'Tirunelveli',
     '2026-09-10',
     '10:00:00',
     'Electrical repair and wiring.',
     550,
     'Open'),

    (2,
     2,
     'Plumbing Repair',
     'Plumber',
     'Valliyur',
     '2026-09-12',
     '11:00:00',
     'Pipe and bathroom maintenance.',
     700,
     'Open'),

    (3,
     3,
     'Carpenter Work',
     'Carpenter',
     'Tirunelveli',
     '2026-09-15',
     '09:30:00',
     'General carpenter work.',
     900,
     'Open');


-- ============================================================
-- JOB APPLICATIONS
-- ============================================================

INSERT INTO applications
    (id, worker_id, job_id, applied_date, status)
VALUES
    (1,
     1,
     1,
     '2026-09-05',
     'Accepted'),

    (2,
     1,
     2,
     '2026-09-06',
     'Pending');


-- ============================================================
-- WORKER DOCUMENTS
-- ============================================================

INSERT INTO worker_documents
    (id, worker_id, document_type, document_name, status)
VALUES
    (1,
     1,
     'ID Proof',
     'Government ID / Aadhaar',
     'Approved'),

    (2,
     1,
     'Skill Certificate',
     'Electrical / Technical Certificate',
     'Approved'),

    (3,
     1,
     'Address Proof',
     'Address Verification Document',
     'Pending');


-- ============================================================
-- WORKER JOB STATUS
-- ============================================================

INSERT INTO worker_jobs
    (id, worker_id, job_id, job_status)
VALUES
    (1,
     1,
     1,
     'Requested');


-- ============================================================
-- EARNINGS
-- ============================================================

INSERT INTO earnings
    (id, worker_id, job_id, amount, earning_date, status)
VALUES
    (1,
     1,
     1,
     550,
     '2026-09-05',
     'Paid'),

    (2,
     1,
     2,
     2000,
     '2026-08-28',
     'Paid');


-- ============================================================
-- PAYMENTS
-- ============================================================

INSERT INTO payments
    (id, worker_id, job_id, amount, payment_date, status)
VALUES
    (1,
     1,
     1,
     2500,
     '2026-09-01',
     'Paid'),

    (2,
     1,
     2,
     2000,
     '2026-08-28',
     'Paid'),

    (3,
     1,
     NULL,
     3000,
     '2026-09-04',
     'Pending');


-- ============================================================
-- NOTIFICATIONS
-- ============================================================

INSERT INTO notifications
    (id, worker_id, title, message, notification_type, is_read)
VALUES
    (1,
     1,
     'New Job Request',
     'Varsha sent you an Electrical Repair request in Tirunelveli.',
     'Job Request',
     FALSE),

    (2,
     1,
     'Job Accepted',
     'Your Electrical Repair job has been accepted.',
     'Job Update',
     FALSE),

    (3,
     1,
     'Payment Received',
     '₹550 payment has been added to your earnings.',
     'Payment',
     FALSE),

    (4,
     1,
     'New Rating',
     'Customer gave you a 5-star rating.',
     'Rating',
     FALSE),

    (5,
     1,
     'Profile Verified',
     'Your worker profile has been approved.',
     'Verification',
     TRUE);


-- ============================================================
-- FEEDBACK & RATINGS
-- ============================================================

INSERT INTO ratings
    (id, worker_id, customer_id, job_id, rating, feedback)
VALUES
    (1,
     1,
     1,
     1,
     5,
     'Good quality work and completed on time.'),

    (2,
     1,
     2,
     2,
     5,
     'Professional and friendly worker.'),

    (3,
     1,
     3,
     NULL,
     4,
     'Good service.');


-- ============================================================
-- WORKING HOURS
-- ============================================================

INSERT INTO worker_working_hours
    (id, worker_id, start_time, end_time)
VALUES
    (1,
     1,
     '09:00:00',
     '18:00:00');


-- ============================================================
-- END OF DEMO DATA
-- ============================================================