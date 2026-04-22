-- =============================================================
-- NOM DE LA DB : souss_ambulance (À créer graphiquement avant d'exécuter ce script)
-- =============================================================

-- 1. System User 
CREATE TABLE app_user (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Incident Categories
CREATE TABLE incident_type (
    incident_type_id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    label VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Hospital
CREATE TABLE hospital (
    hospital_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    phone VARCHAR(20),
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    trauma_level INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Hospital Departments
CREATE TABLE hospital_service (
    service_id SERIAL PRIMARY KEY,
    hospital_id INTEGER REFERENCES hospital(hospital_id),
    service_type VARCHAR(100) NOT NULL,
    total_beds INTEGER NOT NULL,
    occupied_beds INTEGER DEFAULT 0 CHECK (occupied_beds <= total_beds),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Emergencies
CREATE TABLE incident (
    incident_id SERIAL PRIMARY KEY,
    incident_type_id INTEGER REFERENCES incident_type(incident_type_id),
    description TEXT,
    severity INTEGER,
    estimated_victims INTEGER,
    address TEXT,
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Emergency Calls
CREATE TABLE emergency_call (
    call_id SERIAL PRIMARY KEY,
    incident_id INTEGER REFERENCES incident(incident_id),
    channel VARCHAR(50),
    caller_number VARCHAR(20),
    operator_id INTEGER REFERENCES app_user(user_id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Ambulance
CREATE TABLE ambulance (
    ambulance_id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    license_plate VARCHAR(50),
    ambulance_type VARCHAR(50),
    status VARCHAR(50),
    base_latitude DECIMAL(10, 7),
    base_longitude DECIMAL(10, 7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Ambulance Tracking (GPS history)
CREATE TABLE ambulance_position (
    position_id SERIAL PRIMARY KEY,
    ambulance_id INTEGER REFERENCES ambulance(ambulance_id),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL,
    speed_kmh DECIMAL(6, 2),
    accuracy_m DECIMAL(6, 2),
    source VARCHAR(50)
);

-- 9. Mission Assignment (Central Table)
CREATE TABLE mission (
    mission_id SERIAL PRIMARY KEY,
    incident_id INTEGER REFERENCES incident(incident_id),
    ambulance_id INTEGER REFERENCES ambulance(ambulance_id),
    dispatcher_id INTEGER REFERENCES app_user(user_id),
    target_service_id INTEGER REFERENCES hospital_service(service_id),
    decision_code VARCHAR(50),
    decision_message TEXT,
    distance_score DECIMAL(3, 2),
    saturation_score DECIMAL(3, 2),
    algorithm_version VARCHAR(20),
    status VARCHAR(50),
    decided_at TIMESTAMP,
    depart_base_at TIMESTAMP,
    arrive_scene_at TIMESTAMP,
    depart_scene_at TIMESTAMP,
    arrive_hospital_at TIMESTAMP,
    closed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. Route Tracking
CREATE TABLE routes (
    route_id SERIAL PRIMARY KEY,
    mission_id INTEGER REFERENCES mission(mission_id),
    segment VARCHAR(50),
    provider VARCHAR(50),
    distance_km DECIMAL(8, 3),
    estimated_duration_min INTEGER,
    actual_duration_min INTEGER,
    polyline TEXT,
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. Patient Information (Anonymized)
CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    patient_ref VARCHAR(100) UNIQUE NOT NULL,
    gender VARCHAR(10),
    birth_year INTEGER,
    triage_level VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Admission Management
CREATE TABLE admissions (
    admission_id SERIAL PRIMARY KEY,
    mission_id INTEGER REFERENCES mission(mission_id),
    patient_id INTEGER REFERENCES patients(patient_id),
    service_id INTEGER REFERENCES hospital_service(service_id),
    status VARCHAR(50),
    admitted_at TIMESTAMP,
    discharged_at TIMESTAMP,
    medical_note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. System Audit Log
CREATE TABLE audit_logs (
    audit_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES app_user(user_id),
    action VARCHAR(50),
    entity VARCHAR(50),
    entity_id INTEGER,
    occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    meta_json JSONB
);