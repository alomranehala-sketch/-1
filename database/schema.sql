-- ============================================
-- Healthcare Platform - مسار الصحة الذكي
-- National Smart Healthcare Platform (Jordan)
-- PostgreSQL 16+
-- ============================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- fuzzy text search for Arabic names

-- ============================================
-- ENUM TYPES
-- ============================================

CREATE TYPE user_role AS ENUM ('citizen', 'doctor', 'nurse', 'hospital_admin', 'moh_admin', 'pharmacist', 'paramedic');
CREATE TYPE auth_provider AS ENUM ('otp', 'biometric', 'national_id');
CREATE TYPE appointment_status AS ENUM ('scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show', 'rescheduled');
CREATE TYPE notification_type AS ENUM ('email', 'sms', 'push', 'whatsapp');
CREATE TYPE notification_status AS ENUM ('pending', 'sent', 'failed', 'read');
CREATE TYPE notification_severity AS ENUM ('info', 'warning', 'critical', 'emergency');
CREATE TYPE emergency_severity AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE emergency_status AS ENUM ('active', 'dispatched', 'acknowledged', 'resolved', 'false_alarm');
CREATE TYPE tracking_mood AS ENUM ('excellent', 'good', 'neutral', 'bad', 'terrible');
CREATE TYPE conversation_status AS ENUM ('active', 'archived');
CREATE TYPE hospital_type AS ENUM ('public', 'private', 'military', 'university');
CREATE TYPE agent_type AS ENUM ('personal', 'hospital', 'government');
CREATE TYPE agent_action_status AS ENUM ('pending', 'executing', 'completed', 'failed', 'cancelled');
CREATE TYPE prescription_status AS ENUM ('active', 'dispensed', 'expired', 'cancelled');
CREATE TYPE family_link_status AS ENUM ('pending', 'approved', 'rejected', 'revoked');
CREATE TYPE triage_level AS ENUM ('immediate', 'urgent', 'delayed', 'minor', 'expectant');

-- ============================================
-- USERS TABLE
-- ============================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    national_id VARCHAR(20) UNIQUE, -- الرقم الوطني الأردني
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255),
    phone VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    first_name_ar VARCHAR(100), -- الاسم بالعربي
    last_name_ar VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(20),
    avatar_url VARCHAR(500),
    role user_role NOT NULL DEFAULT 'citizen',
    auth_provider auth_provider NOT NULL DEFAULT 'otp',
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_phone_verified BOOLEAN NOT NULL DEFAULT false,
    is_identity_verified BOOLEAN NOT NULL DEFAULT false, -- verified via national ID system
    identity_verified_at TIMESTAMP WITH TIME ZONE,
    biometric_hash VARCHAR(500), -- hashed biometric data for session auth
    otp_secret VARCHAR(255), -- TOTP secret
    last_login_at TIMESTAMP WITH TIME ZONE,
    last_login_ip INET,
    preferred_language VARCHAR(10) DEFAULT 'ar',
    governorate VARCHAR(100), -- المحافظة
    city VARCHAR(100),
    address TEXT,
    blood_type VARCHAR(5), -- A+, B-, O+, etc.
    chronic_conditions JSONB DEFAULT '[]', -- preloaded from Hakimi
    insurance_provider VARCHAR(200),
    insurance_number VARCHAR(100),
    medical_wallet_qr TEXT, -- QR code data for offline identification
    refresh_token_hash VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_national_id ON users(national_id) WHERE national_id IS NOT NULL;
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active) WHERE is_active = true;
CREATE INDEX idx_users_governorate ON users(governorate);
CREATE INDEX idx_users_name_trgm ON users USING gin (first_name gin_trgm_ops);
CREATE INDEX idx_users_name_ar_trgm ON users USING gin (first_name_ar gin_trgm_ops);

-- ============================================
-- DOCTOR PROFILES TABLE
-- ============================================

CREATE TABLE doctor_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    specialization VARCHAR(200) NOT NULL,
    license_number VARCHAR(100) NOT NULL UNIQUE,
    hospital_affiliation VARCHAR(300),
    years_of_experience INTEGER NOT NULL DEFAULT 0,
    bio TEXT,
    consultation_fee DECIMAL(10,2),
    is_verified BOOLEAN NOT NULL DEFAULT false,
    is_available BOOLEAN NOT NULL DEFAULT true,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_doctor_profiles_user_id ON doctor_profiles(user_id);
CREATE INDEX idx_doctor_profiles_specialization ON doctor_profiles(specialization);
CREATE INDEX idx_doctor_profiles_available ON doctor_profiles(is_available) WHERE is_available = true;

-- ============================================
-- HOSPITALS TABLE
-- ============================================

CREATE TABLE hospitals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(300) NOT NULL,
    name_ar VARCHAR(300) NOT NULL,
    type hospital_type NOT NULL DEFAULT 'public',
    license_number VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(500),
    governorate VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address TEXT,
    address_ar TEXT,
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    total_beds INTEGER NOT NULL DEFAULT 0,
    available_beds INTEGER NOT NULL DEFAULT 0,
    icu_beds INTEGER NOT NULL DEFAULT 0,
    available_icu_beds INTEGER NOT NULL DEFAULT 0,
    er_capacity INTEGER NOT NULL DEFAULT 0,
    current_er_load INTEGER NOT NULL DEFAULT 0,
    specialties JSONB DEFAULT '[]', -- list of specializations offered
    operating_hours JSONB DEFAULT '{}', -- {"sun": {"open": "08:00", "close": "20:00"}, ...}
    accepts_insurance JSONB DEFAULT '[]', -- list of accepted insurance providers
    hakimi_facility_id VARCHAR(100), -- integration with Hakimi national system
    is_active BOOLEAN NOT NULL DEFAULT true,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,
    last_capacity_update TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_hospitals_governorate ON hospitals(governorate);
CREATE INDEX idx_hospitals_type ON hospitals(type);
CREATE INDEX idx_hospitals_active ON hospitals(is_active) WHERE is_active = true;
CREATE INDEX idx_hospitals_location ON hospitals(location_lat, location_lng);
CREATE INDEX idx_hospitals_specialties ON hospitals USING gin (specialties);
CREATE INDEX idx_hospitals_available_beds ON hospitals(available_beds) WHERE available_beds > 0;

-- ============================================
-- HOSPITAL DEPARTMENTS TABLE
-- ============================================

CREATE TABLE hospital_departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    name_ar VARCHAR(200) NOT NULL,
    specialization VARCHAR(200) NOT NULL,
    head_doctor_id UUID REFERENCES users(id),
    floor VARCHAR(50),
    phone_ext VARCHAR(20),
    max_daily_appointments INTEGER DEFAULT 50,
    current_queue_size INTEGER DEFAULT 0,
    average_wait_minutes INTEGER DEFAULT 30,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_hospital_departments_hospital ON hospital_departments(hospital_id);
CREATE INDEX idx_hospital_departments_spec ON hospital_departments(specialization);

-- ============================================
-- DOCTOR-HOSPITAL ASSIGNMENTS TABLE
-- ============================================

CREATE TABLE doctor_hospital_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    department_id UUID REFERENCES hospital_departments(id),
    schedule JSONB DEFAULT '{}', -- {"sun": [{"start": "08:00", "end": "14:00"}], ...}
    max_daily_patients INTEGER DEFAULT 20,
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(doctor_id, hospital_id)
);

CREATE INDEX idx_doctor_hospital_doctor ON doctor_hospital_assignments(doctor_id);
CREATE INDEX idx_doctor_hospital_hospital ON doctor_hospital_assignments(hospital_id);

-- ============================================
-- HEALTH RECORDS TABLE
-- ============================================

CREATE TABLE health_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    record_type VARCHAR(100) NOT NULL, -- e.g., 'lab_result', 'prescription', 'diagnosis'
    title VARCHAR(300) NOT NULL,
    description TEXT,
    data_encrypted BYTEA, -- encrypted health data (HIPAA compliance)
    file_url VARCHAR(500), -- S3 link to attached documents
    recorded_by UUID REFERENCES users(id), -- doctor who created the record
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_health_records_user_id ON health_records(user_id);
CREATE INDEX idx_health_records_type ON health_records(record_type);
CREATE INDEX idx_health_records_recorded_at ON health_records(recorded_at);
CREATE INDEX idx_health_records_user_type ON health_records(user_id, record_type);

-- ============================================
-- DAILY TRACKING TABLE
-- ============================================

CREATE TABLE daily_tracking (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tracking_date DATE NOT NULL,
    heart_rate INTEGER, -- bpm
    blood_pressure_systolic INTEGER,
    blood_pressure_diastolic INTEGER,
    blood_sugar DECIMAL(6,2), -- mg/dL
    weight DECIMAL(5,2), -- kg
    temperature DECIMAL(4,1), -- celsius
    oxygen_saturation DECIMAL(4,1), -- percentage
    steps_count INTEGER DEFAULT 0,
    sleep_hours DECIMAL(4,2),
    water_intake_ml INTEGER DEFAULT 0,
    calories_consumed INTEGER,
    mood tracking_mood,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, tracking_date)
);

CREATE INDEX idx_daily_tracking_user_id ON daily_tracking(user_id);
CREATE INDEX idx_daily_tracking_date ON daily_tracking(tracking_date);
CREATE INDEX idx_daily_tracking_user_date ON daily_tracking(user_id, tracking_date);

-- ============================================
-- APPOINTMENTS TABLE
-- ============================================

CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    hospital_id UUID REFERENCES hospitals(id),
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER NOT NULL DEFAULT 30,
    status appointment_status NOT NULL DEFAULT 'scheduled',
    reason TEXT,
    reason_ar TEXT, -- السبب بالعربي
    notes TEXT,
    ai_priority_score DECIMAL(5,2) DEFAULT 0, -- 0-100, computed by AI scheduler
    ai_scoring_factors JSONB DEFAULT '{}', -- breakdown of score factors
    triage_level triage_level,
    is_ai_scheduled BOOLEAN DEFAULT false,
    meeting_url VARCHAR(500),
    cancelled_reason TEXT,
    cancelled_by UUID REFERENCES users(id),
    rescheduled_from UUID REFERENCES appointments(id), -- chain link for rescheduling
    check_in_at TIMESTAMP WITH TIME ZONE,
    check_out_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_doctor_id ON appointments(doctor_id);
CREATE INDEX idx_appointments_scheduled_at ON appointments(scheduled_at);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_doctor_schedule ON appointments(doctor_id, scheduled_at, status);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    severity notification_severity NOT NULL DEFAULT 'info',
    title VARCHAR(300) NOT NULL,
    title_ar VARCHAR(300), -- العنوان بالعربي
    body TEXT NOT NULL,
    body_ar TEXT,
    data JSONB DEFAULT '{}',
    status notification_status NOT NULL DEFAULT 'pending',
    sent_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    retry_count INTEGER NOT NULL DEFAULT 0,
    max_retries INTEGER NOT NULL DEFAULT 3,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, status) WHERE status != 'read';
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- ============================================
-- EMERGENCY CONTACTS TABLE
-- ============================================

CREATE TABLE emergency_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    relationship VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_emergency_contacts_user_id ON emergency_contacts(user_id);

-- ============================================
-- EMERGENCY ALERTS TABLE
-- ============================================

CREATE TABLE emergency_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    severity emergency_severity NOT NULL DEFAULT 'medium',
    status emergency_status NOT NULL DEFAULT 'active',
    alert_type VARCHAR(100) NOT NULL, -- e.g., 'heart_rate_anomaly', 'fall_detected', 'manual'
    message TEXT NOT NULL,
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    vitals_snapshot JSONB, -- snapshot of vitals at time of alert
    acknowledged_by UUID REFERENCES users(id),
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_emergency_alerts_user_id ON emergency_alerts(user_id);
CREATE INDEX idx_emergency_alerts_status ON emergency_alerts(status);
CREATE INDEX idx_emergency_alerts_severity ON emergency_alerts(severity);
CREATE INDEX idx_emergency_alerts_active ON emergency_alerts(status) WHERE status = 'active';

-- ============================================
-- AI CONVERSATIONS TABLE
-- ============================================

CREATE TABLE ai_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(300),
    status conversation_status NOT NULL DEFAULT 'active',
    model VARCHAR(50) NOT NULL DEFAULT 'gpt-4',
    total_tokens_used INTEGER NOT NULL DEFAULT 0,
    context_summary TEXT, -- compressed context for long conversations
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_conversations_user_id ON ai_conversations(user_id);
CREATE INDEX idx_ai_conversations_status ON ai_conversations(status);

-- ============================================
-- AI MESSAGES TABLE
-- ============================================

CREATE TABLE ai_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL, -- 'user', 'assistant', 'system'
    content TEXT NOT NULL,
    tokens_used INTEGER NOT NULL DEFAULT 0,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_messages_conversation_id ON ai_messages(conversation_id);
CREATE INDEX idx_ai_messages_created_at ON ai_messages(created_at);

-- ============================================
-- AUDIT LOG TABLE (for HIPAA compliance)
-- ============================================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(100) NOT NULL,
    resource_id UUID,
    details JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- ============================================
-- FAMILY LINKING TABLE (proxy access)
-- ============================================

CREATE TABLE family_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guardian_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    dependent_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    relationship VARCHAR(50) NOT NULL, -- parent, spouse, child, caregiver
    status family_link_status NOT NULL DEFAULT 'pending',
    permissions JSONB DEFAULT '["view_records", "book_appointments"]', -- allowed actions
    approved_at TIMESTAMP WITH TIME ZONE,
    approved_by UUID REFERENCES users(id), -- can be self-approved or admin
    expires_at TIMESTAMP WITH TIME ZONE, -- optional expiry for temporary access
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(guardian_id, dependent_id)
);

CREATE INDEX idx_family_links_guardian ON family_links(guardian_id);
CREATE INDEX idx_family_links_dependent ON family_links(dependent_id);
CREATE INDEX idx_family_links_status ON family_links(status);

-- ============================================
-- PRESCRIPTIONS TABLE
-- ============================================

CREATE TABLE prescriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES users(id),
    hospital_id UUID REFERENCES hospitals(id),
    appointment_id UUID REFERENCES appointments(id),
    medication_name VARCHAR(300) NOT NULL,
    medication_name_ar VARCHAR(300),
    dosage VARCHAR(200) NOT NULL, -- e.g., "500mg twice daily"
    dosage_ar VARCHAR(200),
    quantity INTEGER NOT NULL DEFAULT 1,
    refills_allowed INTEGER DEFAULT 0,
    refills_used INTEGER DEFAULT 0,
    instructions TEXT,
    instructions_ar TEXT,
    status prescription_status NOT NULL DEFAULT 'active',
    prescribed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    dispensed_at TIMESTAMP WITH TIME ZONE,
    dispensed_by UUID REFERENCES users(id), -- pharmacist
    pharmacy_id UUID, -- FK to pharmacy when integrated
    barcode VARCHAR(200), -- for pharmacy scanning
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_prescriptions_patient ON prescriptions(patient_id);
CREATE INDEX idx_prescriptions_doctor ON prescriptions(doctor_id);
CREATE INDEX idx_prescriptions_status ON prescriptions(status);
CREATE INDEX idx_prescriptions_barcode ON prescriptions(barcode) WHERE barcode IS NOT NULL;

-- ============================================
-- AI AGENT ACTIONS LOG
-- ============================================

CREATE TABLE ai_agent_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_type agent_type NOT NULL,
    user_id UUID REFERENCES users(id), -- who triggered or is affected
    action_type VARCHAR(100) NOT NULL, -- 'book_appointment', 'triage', 'alert', 'reschedule'
    status agent_action_status NOT NULL DEFAULT 'pending',
    input_data JSONB NOT NULL DEFAULT '{}', -- what the agent received
    decision_reasoning TEXT, -- why the agent made this decision (explainability)
    output_data JSONB DEFAULT '{}', -- result of the action
    confidence_score DECIMAL(5,4), -- 0.0000-1.0000
    model_version VARCHAR(50),
    execution_time_ms INTEGER,
    error_message TEXT,
    parent_action_id UUID REFERENCES ai_agent_actions(id), -- chain of agent actions
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_ai_agent_actions_type ON ai_agent_actions(agent_type);
CREATE INDEX idx_ai_agent_actions_user ON ai_agent_actions(user_id);
CREATE INDEX idx_ai_agent_actions_status ON ai_agent_actions(status);
CREATE INDEX idx_ai_agent_actions_action ON ai_agent_actions(action_type);
CREATE INDEX idx_ai_agent_actions_created ON ai_agent_actions(created_at);

-- ============================================
-- DISEASE SURVEILLANCE TABLE (Government Agent)
-- ============================================

CREATE TABLE disease_surveillance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    disease_code VARCHAR(20) NOT NULL, -- ICD-10 code
    disease_name VARCHAR(200) NOT NULL,
    disease_name_ar VARCHAR(200),
    governorate VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    reported_cases INTEGER NOT NULL DEFAULT 0,
    confirmed_cases INTEGER NOT NULL DEFAULT 0,
    recovered INTEGER NOT NULL DEFAULT 0,
    deaths INTEGER NOT NULL DEFAULT 0,
    trend VARCHAR(20) DEFAULT 'stable', -- rising, falling, stable, spike
    alert_level VARCHAR(20) DEFAULT 'normal', -- normal, watch, warning, critical
    ai_prediction JSONB DEFAULT '{}', -- predicted spread, suggested actions
    reporting_period_start DATE NOT NULL,
    reporting_period_end DATE NOT NULL,
    reported_by UUID REFERENCES users(id),
    hospital_id UUID REFERENCES hospitals(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_disease_surv_disease ON disease_surveillance(disease_code);
CREATE INDEX idx_disease_surv_gov ON disease_surveillance(governorate);
CREATE INDEX idx_disease_surv_alert ON disease_surveillance(alert_level);
CREATE INDEX idx_disease_surv_period ON disease_surveillance(reporting_period_start, reporting_period_end);

-- ============================================
-- MEDICAL WALLET QR SESSIONS (offline access)
-- ============================================

CREATE TABLE medical_wallet_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    qr_token_hash VARCHAR(255) NOT NULL UNIQUE, -- hashed QR token
    session_type VARCHAR(50) NOT NULL DEFAULT 'standard', -- standard, emergency
    data_snapshot JSONB NOT NULL DEFAULT '{}', -- cached medical data for offline
    accessed_by UUID REFERENCES users(id), -- who scanned the QR
    accessed_at TIMESTAMP WITH TIME ZONE,
    access_location_lat DECIMAL(10, 8),
    access_location_lng DECIMAL(11, 8),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_revoked BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_wallet_sessions_user ON medical_wallet_sessions(user_id);
CREATE INDEX idx_wallet_sessions_token ON medical_wallet_sessions(qr_token_hash);
CREATE INDEX idx_wallet_sessions_expires ON medical_wallet_sessions(expires_at);

-- ============================================
-- HOSPITAL CAPACITY SNAPSHOTS (real-time tracking)
-- ============================================

CREATE TABLE hospital_capacity_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    total_beds INTEGER NOT NULL,
    available_beds INTEGER NOT NULL,
    icu_beds INTEGER NOT NULL,
    available_icu_beds INTEGER NOT NULL,
    er_capacity INTEGER NOT NULL,
    current_er_load INTEGER NOT NULL,
    er_wait_minutes INTEGER DEFAULT 0,
    ventilators_total INTEGER DEFAULT 0,
    ventilators_available INTEGER DEFAULT 0,
    staff_on_duty JSONB DEFAULT '{}', -- {"doctors": 12, "nurses": 30, ...}
    snapshot_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_capacity_snapshots_hospital ON hospital_capacity_snapshots(hospital_id);
CREATE INDEX idx_capacity_snapshots_time ON hospital_capacity_snapshots(snapshot_at);

-- ============================================
-- WEARABLE DEVICE DATA
-- ============================================

CREATE TABLE wearable_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_type VARCHAR(100) NOT NULL, -- 'apple_watch', 'fitbit', 'mi_band', etc.
    device_id VARCHAR(200),
    metric_type VARCHAR(50) NOT NULL, -- 'heart_rate', 'spo2', 'steps', 'sleep'
    value DECIMAL(10,4) NOT NULL,
    unit VARCHAR(20) NOT NULL, -- 'bpm', '%', 'steps', 'hours'
    is_anomaly BOOLEAN DEFAULT false,
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
    synced_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_wearable_user ON wearable_data(user_id);
CREATE INDEX idx_wearable_metric ON wearable_data(user_id, metric_type);
CREATE INDEX idx_wearable_anomaly ON wearable_data(is_anomaly) WHERE is_anomaly = true;
CREATE INDEX idx_wearable_recorded ON wearable_data(recorded_at);

-- Partition wearable data by month for performance
-- CREATE TABLE wearable_data_y2026m01 PARTITION OF wearable_data
--     FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');

-- ============================================
-- TRIGGER: Auto-update updated_at
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at
DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN
        SELECT table_name FROM information_schema.columns
        WHERE column_name = 'updated_at'
        AND table_schema = 'public'
    LOOP
        EXECUTE format('
            CREATE TRIGGER set_updated_at
            BEFORE UPDATE ON %I
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column()', t);
    END LOOP;
END;
$$;
