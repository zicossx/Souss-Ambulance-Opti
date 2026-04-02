
## 📁 Folder Structure

```
database/
├── schema/
│   ├── tables.sql              # Full schema — create all tables
│   ├── triggers.sql            # All database triggers (business rules & automation)
│   ├── procedures.sql          # Stored procedures (decision logic & calculations)
│   └── CHANGELOG.md            # Track every schema change with dates

├── diagrams/
│   └── erd.png                 # Entity-Relationship Diagram (pgAdmin generated)

└── docs/
    └── pgadmin_setup_demo.mp4  # Demo video
```

---

## ⚙️ Setup — How to Run

### Prerequisites
- PostgreSQL installed
- pgAdmin 4 (or any PostgreSQL client)

### Steps

**1. Create the database**  
Open pgAdmin → right-click *Databases* → *Create* → name it exactly:
```
souss_ambulance
```

**2. Run the schema**  
Open the Query Tool on `souss_ambulance` → open `schema/souss_ambulance.sql` → Run (F5)

All 13 tables will be created in the correct order.

> 📹 See `docs/pgadmin_setup_demo.mp4` for a full visual walkthrough.

---

## 🧱 Tables Overview

| # | Table | Description |
|---|-------|-------------|
| 1 | `app_user` | System users: admin, dispatcher, operator, doctor, viewer |
| 2 | `incident_type` | Incident categories (accident, fire, cardiac arrest…) |
| 3 | `hospital` | Hospitals that can receive patients |
| 4 | `hospital_service` | Hospital departments with real-time bed capacity |
| 5 | `incident` | Emergency events with location and severity |
| 6 | `emergency_call` | Calls or channels that reported an incident |
| 7 | `ambulance` | Available vehicles with GPS base position |
| 8 | `ambulance_position` | Full GPS history of each ambulance |
| 9 | `mission` | **Central table** — ambulance assignment to an incident |
| 10 | `routes` | Calculated/actual routes per mission segment |
| 11 | `patients` | Anonymized patient records |
| 12 | `admissions` | Patient admission into a hospital service |
| 13 | `audit_logs` | System-wide action audit trail |

---

## 🔗 Key Relationships

```
hospital ──< hospital_service ──< admissions
                                      │
incident_type ──< incident ──< mission >── ambulance
                                  │
                               routes
                               admissions ──< patients
app_user ──< audit_logs
app_user ──< emergency_call (operator)
app_user ──< mission (dispatcher)
```

---

## 📐 Design Decisions

- **`available_beds` is not stored** — it is always calculated as `total_beds - occupied_beds` to avoid inconsistencies
- **`occupied_beds` has a CHECK constraint** — `occupied_beds <= total_beds` enforced at DB level
- **Patient data is anonymized** — only `patient_ref` (pseudonym), `gender`, `birth_year`, and `triage_level` are stored (GDPR-friendly)
- **`audit_logs.user_id` is nullable** — to support system-generated actions with no human actor

---

## 📋 Conventions

| Convention | Rule |
|---|---|
| Table names | `snake_case` |
| Primary keys | `table_name_id` (SERIAL) |
| Foreign keys | same name as the PK they reference |
| Timestamps | `created_at` / `updated_at` on every mutable table |
| Soft delete | use `active = FALSE` on `app_user`, never hard delete |

---

## 📌 Schema Version

| Version | Date | Author | Notes |
|---------|------|--------|-------|
| 1.0.0 | 2026-03-09 | DB Team | Initial schema — 13 tables |

> For detailed change history see [`schema/CHANGELOG.md`](schema/CHANGELOG.md)
