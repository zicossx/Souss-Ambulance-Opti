CREATE TABLE drivers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    license_number VARCHAR(50),
    vehicle_number VARCHAR(20),
    is_online BOOLEAN DEFAULT 0,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    rating DECIMAL(3,2) DEFAULT 5.00,
    total_trips INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_updated DATETIME
, destination_hospital_id INTEGER, patient_name VARCHAR(100), patient_condition TEXT, eta_minutes INTEGER)
CREATE TABLE sqlite_sequence(name,seq)
CREATE TABLE patients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8)
, age INTEGER, blood_type VARCHAR(10), cin VARCHAR(20), gender VARCHAR(1), address TEXT, condition TEXT, status VARCHAR(20) DEFAULT 'waiting', assigned_doctor_id INTEGER, ambulance_id INTEGER, hospital_id INTEGER)
CREATE TABLE emergencies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    patient_id INTEGER REFERENCES patients(id),
    driver_id INTEGER REFERENCES drivers(id),
    status VARCHAR(20) DEFAULT 'pending',
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
CREATE TABLE hospitals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(200) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    region VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(254),
    license_number VARCHAR(50) UNIQUE,
    emergency_capacity INTEGER DEFAULT 0,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
CREATE TABLE patient_medical_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name VARCHAR(200),
    age INTEGER,
    gender VARCHAR(1),
    cin VARCHAR(20),
    phone VARCHAR(20),
    address TEXT,
    medical_condition TEXT,
    status VARCHAR(20),
    admitted_at DATETIME,
    hospital_id INTEGER REFERENCES hospitals(id)
)
CREATE TABLE bed_availability (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hospital_id INTEGER REFERENCES hospitals(id),
    bed_type VARCHAR(20),
    total_beds INTEGER,
    available_beds INTEGER,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
, updated_by_id INTEGER)
CREATE TABLE medical_conditions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    severity VARCHAR(20),
    common_symptoms TEXT,
    treatment_protocol TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
, hospital_id INTEGER)
CREATE TABLE hospital_ambulances (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    vehicle_number VARCHAR(20) UNIQUE,
    driver_name VARCHAR(100),
    driver_phone VARCHAR(20),
    status VARCHAR(20),
    current_latitude DECIMAL,
    current_longitude DECIMAL,
    destination_hospital_id INTEGER REFERENCES hospitals(id)
)
CREATE TABLE "django_migrations" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "app" varchar(255) NOT NULL, "name" varchar(255) NOT NULL, "applied" datetime NOT NULL)
CREATE TABLE "auth_group_permissions" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "group_id" integer NOT NULL REFERENCES "auth_group" ("id") DEFERRABLE INITIALLY DEFERRED, "permission_id" integer NOT NULL REFERENCES "auth_permission" ("id") DEFERRABLE INITIALLY DEFERRED)
CREATE TABLE "auth_user_groups" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "group_id" integer NOT NULL REFERENCES "auth_group" ("id") DEFERRABLE INITIALLY DEFERRED)
CREATE TABLE "auth_user_user_permissions" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "permission_id" integer NOT NULL REFERENCES "auth_permission" ("id") DEFERRABLE INITIALLY DEFERRED)
CREATE UNIQUE INDEX "auth_group_permissions_group_id_permission_id_0cd325b0_uniq" ON "auth_group_permissions" ("group_id", "permission_id")
CREATE INDEX "auth_group_permissions_group_id_b120cbf9" ON "auth_group_permissions" ("group_id")
CREATE INDEX "auth_group_permissions_permission_id_84c5c92e" ON "auth_group_permissions" ("permission_id")
CREATE UNIQUE INDEX "auth_user_groups_user_id_group_id_94350c0c_uniq" ON "auth_user_groups" ("user_id", "group_id")
CREATE INDEX "auth_user_groups_user_id_6a12ed8b" ON "auth_user_groups" ("user_id")
CREATE INDEX "auth_user_groups_group_id_97559544" ON "auth_user_groups" ("group_id")
CREATE UNIQUE INDEX "auth_user_user_permissions_user_id_permission_id_14a6b632_uniq" ON "auth_user_user_permissions" ("user_id", "permission_id")
CREATE INDEX "auth_user_user_permissions_user_id_a95ead1b" ON "auth_user_user_permissions" ("user_id")
CREATE INDEX "auth_user_user_permissions_permission_id_1fbb5f2c" ON "auth_user_user_permissions" ("permission_id")
CREATE TABLE "django_admin_log" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "object_id" text NULL, "object_repr" varchar(200) NOT NULL, "action_flag" smallint unsigned NOT NULL CHECK ("action_flag" >= 0), "change_message" text NOT NULL, "content_type_id" integer NULL REFERENCES "django_content_type" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "action_time" datetime NOT NULL)
CREATE INDEX "django_admin_log_content_type_id_c4bce8eb" ON "django_admin_log" ("content_type_id")
CREATE INDEX "django_admin_log_user_id_c564eba6" ON "django_admin_log" ("user_id")
CREATE TABLE "django_content_type" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "app_label" varchar(100) NOT NULL, "model" varchar(100) NOT NULL)
CREATE UNIQUE INDEX "django_content_type_app_label_model_76bd3d3b_uniq" ON "django_content_type" ("app_label", "model")
CREATE TABLE "auth_permission" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "content_type_id" integer NOT NULL REFERENCES "django_content_type" ("id") DEFERRABLE INITIALLY DEFERRED, "codename" varchar(100) NOT NULL, "name" varchar(255) NOT NULL)
CREATE UNIQUE INDEX "auth_permission_content_type_id_codename_01ab375a_uniq" ON "auth_permission" ("content_type_id", "codename")
CREATE INDEX "auth_permission_content_type_id_2f476e4b" ON "auth_permission" ("content_type_id")
CREATE TABLE "auth_group" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(150) NOT NULL UNIQUE)
CREATE TABLE "auth_user" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "password" varchar(128) NOT NULL, "last_login" datetime NULL, "is_superuser" bool NOT NULL, "username" varchar(150) NOT NULL UNIQUE, "last_name" varchar(150) NOT NULL, "email" varchar(254) NOT NULL, "is_staff" bool NOT NULL, "is_active" bool NOT NULL, "date_joined" datetime NOT NULL, "first_name" varchar(150) NOT NULL)
CREATE TABLE "dashboard_hospital" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(200) NOT NULL, "address" text NOT NULL, "city" varchar(100) NOT NULL, "region" varchar(100) NOT NULL, "phone" varchar(20) NOT NULL, "email" varchar(254) NOT NULL, "license_number" varchar(50) NOT NULL UNIQUE, "emergency_capacity" integer NOT NULL, "created_at" datetime NOT NULL, "is_active" bool NOT NULL, "latitude" decimal NULL, "longitude" decimal NULL)
CREATE TABLE "dashboard_hospitaluser" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "role" varchar(20) NOT NULL, "phone" varchar(20) NOT NULL, "department" varchar(100) NOT NULL, "is_available" bool NOT NULL, "created_at" datetime NOT NULL, "hospital_id" bigint NOT NULL REFERENCES "dashboard_hospital" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL UNIQUE REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED)
CREATE TABLE "dashboard_medicalcondition" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "name" varchar(200) NOT NULL, "description" text NOT NULL, "severity" varchar(20) NOT NULL, "common_symptoms" text NOT NULL, "treatment_protocol" text NOT NULL, "is_active" bool NOT NULL, "created_at" datetime NOT NULL, "hospital_id" bigint NOT NULL REFERENCES "dashboard_hospital" ("id") DEFERRABLE INITIALLY DEFERRED)
CREATE TABLE "dashboard_bedavailability" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "bed_type" varchar(20) NOT NULL, "total_beds" integer NOT NULL, "available_beds" integer NOT NULL, "updated_at" datetime NOT NULL, "hospital_id" bigint NOT NULL REFERENCES "dashboard_hospital" ("id") DEFERRABLE INITIALLY DEFERRED, "updated_by_id" bigint NULL REFERENCES "dashboard_hospitaluser" ("id") DEFERRABLE INITIALLY DEFERRED)
CREATE INDEX "dashboard_hospitaluser_hospital_id_c92f4752" ON "dashboard_hospitaluser" ("hospital_id")
CREATE INDEX "dashboard_medicalcondition_hospital_id_b044be54" ON "dashboard_medicalcondition" ("hospital_id")
CREATE UNIQUE INDEX "dashboard_bedavailability_hospital_id_bed_type_45d88bab_uniq" ON "dashboard_bedavailability" ("hospital_id", "bed_type")
CREATE INDEX "dashboard_bedavailability_hospital_id_a54a1cd8" ON "dashboard_bedavailability" ("hospital_id")
CREATE INDEX "dashboard_bedavailability_updated_by_id_1b91f6fe" ON "dashboard_bedavailability" ("updated_by_id")
CREATE TABLE "django_session" ("session_key" varchar(40) NOT NULL PRIMARY KEY, "session_data" text NOT NULL, "expire_date" datetime NOT NULL)
CREATE INDEX "django_session_expire_date_a5c62663" ON "django_session" ("expire_date")
CREATE TABLE "dashboard_ambulance" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "vehicle_number" varchar(20) NOT NULL UNIQUE, "status" varchar(20) NOT NULL, "current_latitude" decimal NULL, "patient_name" varchar(100) NOT NULL, "patient_condition" text NOT NULL, "eta_minutes" integer NULL, "last_updated" datetime NOT NULL, "destination_hospital_id" bigint NULL REFERENCES "dashboard_hospital" ("id") DEFERRABLE INITIALLY DEFERRED, "phone" varchar(20) NOT NULL, "email" varchar(254) NULL UNIQUE, "first_name" varchar(50) NOT NULL, "is_online" bool NOT NULL, "last_name" varchar(50) NOT NULL, "license_number" varchar(50) NOT NULL, "password" varchar(255) NOT NULL, "rating" decimal NOT NULL, "total_trips" integer NOT NULL, "current_longitude" decimal NULL)
CREATE INDEX "dashboard_ambulance_destination_hospital_id_b43a5c71" ON "dashboard_ambulance" ("destination_hospital_id")
CREATE TABLE "dashboard_patient" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "age" integer NULL, "gender" varchar(1) NOT NULL, "cin" varchar(20) NOT NULL, "phone" varchar(20) NOT NULL, "address" text NOT NULL, "condition" text NOT NULL, "status" varchar(20) NOT NULL, "admitted_at" datetime NOT NULL, "ambulance_id" bigint NULL REFERENCES "dashboard_ambulance" ("id") DEFERRABLE INITIALLY DEFERRED, "assigned_doctor_id" bigint NULL REFERENCES "dashboard_hospitaluser" ("id") DEFERRABLE INITIALLY DEFERRED, "blood_type" varchar(5) NOT NULL, "email" varchar(254) NULL UNIQUE, "first_name" varchar(100) NOT NULL, "last_name" varchar(100) NOT NULL, "password" varchar(255) NOT NULL, "hospital_id" bigint NULL REFERENCES "dashboard_hospital" ("id") DEFERRABLE INITIALLY DEFERRED)
CREATE INDEX "dashboard_patient_ambulance_id_0e4a9c52" ON "dashboard_patient" ("ambulance_id")
CREATE INDEX "dashboard_patient_assigned_doctor_id_02325fd4" ON "dashboard_patient" ("assigned_doctor_id")
CREATE INDEX "dashboard_patient_hospital_id_c6290732" ON "dashboard_patient" ("hospital_id")
CREATE TABLE "dashboard_emergency" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "latitude" decimal NOT NULL, "longitude" decimal NOT NULL, "status" varchar(20) NOT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "driver_id" bigint NULL REFERENCES "dashboard_ambulance" ("id") DEFERRABLE INITIALLY DEFERRED, "patient_id" bigint NOT NULL REFERENCES "dashboard_patient" ("id") DEFERRABLE INITIALLY DEFERRED)
CREATE INDEX "dashboard_emergency_driver_id_bb74854d" ON "dashboard_emergency" ("driver_id")
CREATE INDEX "dashboard_emergency_patient_id_ded70a1a" ON "dashboard_emergency" ("patient_id")
