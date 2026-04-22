# 🚑 Souss-Ambulance — Manual Dispatch Module

## 📌 Description
This module provides a **web-based manual dispatch interface** for emergency coordination in the Souss-Massa region. It complements the automated system with a human-operated dashboard for dispatchers and a mobile-friendly interface for ambulance drivers, backed by a Flask API and a PostgreSQL database.

---

## 📁 Folder Structure
```
souss_ambulance_opti_Manual/
├── app.py                  # Flask REST API
├── requirements.txt        # Python dependencies
├── dispatcher.html         # Operator / dispatch desk UI
├── driver.html             # Ambulance driver UI (mobile-friendly)
├── diagrams/               # Architecture & database diagrams
├── report/                 # Project report (French)
└── sql/
    ├── Tables.sql          # Database schema (13 tables)
    ├── Procedures.sql      # Stored procedures
    ├── Triggers.sql        # Database triggers
    └── Insertion.sql       # Seed data
```

---

## 🏗️ Architecture

```
[ dispatcher.html ]  [ driver.html ]
         |                  |
         └──────┬───────────┘
                ▼
         [ Flask API ]
         app.py :5000
                |
                ▼
         [ PostgreSQL ]
       souss_ambulance DB
```

---

## ⚙️ Setup

### 1. Database
Create a database named `souss_ambulance` in pgAdmin or DBeaver, then run the SQL files in order:
```bash
psql -U postgres -d souss_ambulance -f sql/Tables.sql
psql -U postgres -d souss_ambulance -f sql/Procedures.sql
psql -U postgres -d souss_ambulance -f sql/Triggers.sql
psql -U postgres -d souss_ambulance -f sql/Insertion.sql
```

### 2. Backend
```bash
pip install -r requirements.txt
python app.py
```
> Edit the DB password on line 10 of `app.py` if needed. API runs on `http://localhost:5000`.

### 3. Frontend
Open directly in a browser — no build step needed:
- `dispatcher.html` → for operators at the dispatch desk
- `driver.html` → for ambulance drivers (optimized for mobile)

---

## 🖥️ Interfaces

### Dispatcher Dashboard (`dispatcher.html`)
- Create and manage emergency incidents (type, severity, GPS location)
- View all ambulances and their real-time statuses
- Assign available ambulances to incidents
- Monitor active missions and hospital bed availability
- Track each mission through its full lifecycle

### Driver App (`driver.html`)
- Select your ambulance from the list
- View your active assigned mission
- Step through the mission flow with one tap:
  - 🚀 Depart base → 📍 Arrive on scene → 🏥 Depart to hospital → ✅ Arrive at hospital → 🔒 Close mission
- Automatic GPS tracking with manual coordinate override
- View personal mission history

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/stats` | Dashboard KPIs |
| GET / POST | `/api/incidents` | List / create incidents |
| GET | `/api/ambulances` | All ambulances |
| GET | `/api/ambulances/available` | Available ambulances only |
| POST | `/api/ambulances/:id/position` | Update GPS position |
| GET / POST | `/api/missions` | List missions / auto-create |
| PATCH | `/api/missions/:id/status` | Advance mission step |
| GET | `/api/hospitals` | Hospitals with services & beds |
| POST | `/api/calls` | Log an emergency call |
| POST | `/api/admissions` | Admit a patient |
| PATCH | `/api/admissions/:id/discharge` | Discharge a patient |
| GET | `/api/incident-types` | Incident categories |
| GET | `/api/users` | System users |

---

## 🗄️ Database

13-table PostgreSQL schema covering users, incidents, ambulances, hospitals, missions, admissions, GPS history, and audit logs.

**Stored Procedures:**
- `find_best_hospital(lat, lon)` — scores hospitals by available capacity and proximity
- `create_mission_auto(incident_id, ambulance_id, lat, lon)` — creates a mission assigned to the best hospital
- `estimate_route(a_lat, a_lon, h_lat, h_lon)` — estimates distance and travel time

**Triggers:**
- Auto-update bed counts on patient admission / discharge
- Block admission if service is at full capacity
- Auto-update mission status based on timestamp fields
- Block mission creation if ambulance is not available
- Auto-set ambulance to BUSY on mission assignment / AVAILABLE on completion
- GPS coordinate validation
- Automatic audit logging for all mission changes

---

## 🛠️ Technologies

| Layer | Technology |
|-------|------------|
| Frontend | HTML / CSS / JavaScript (no framework) |
| Backend | Python 3, Flask, Flask-CORS |
| Database | PostgreSQL |
| DB Driver | psycopg2 |
