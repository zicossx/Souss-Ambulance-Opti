from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
import psycopg2.extras

app = Flask(__name__)
CORS(app)

# ── DB CONNECTION ─────────────────────────────────────────────────────────────
def get_db():
    return psycopg2.connect(
        host="localhost",
        database="souss_ambulance",
        user="postgres",
        password="anas1234",  
        cursor_factory=psycopg2.extras.RealDictCursor
    )

# ── HELPER ────────────────────────────────────────────────────────────────────
def query(sql, params=None, fetch="all"):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(sql, params)
    if fetch == "all":
        result = cur.fetchall()
    elif fetch == "one":
        result = cur.fetchone()
    else:
        result = None
    conn.commit()
    cur.close()
    conn.close()
    return result


# INCIDENTS


@app.route("/api/incidents", methods=["GET"])
def get_incidents():
    rows = query("""
        SELECT i.*, it.label AS incident_type_label
        FROM incident i
        LEFT JOIN incident_type it ON i.incident_type_id = it.incident_type_id
        ORDER BY i.created_at DESC
    """)
    return jsonify([dict(r) for r in rows])

@app.route("/api/incidents", methods=["POST"])
def create_incident():
    d = request.json
    query("""
        INSERT INTO incident (incident_type_id, description, severity, estimated_victims, address, latitude, longitude, status)
        VALUES (%s, %s, %s, %s, %s, %s, %s, 'OPEN')
    """, (d["incident_type_id"], d["description"], d["severity"], d.get("estimated_victims"), d["address"], d["latitude"], d["longitude"]), fetch=None)
    return jsonify({"message": "Incident créé"}), 201

@app.route("/api/incidents/<int:id>", methods=["GET"])
def get_incident(id):
    row = query("SELECT * FROM incident WHERE incident_id = %s", (id,), fetch="one")
    if not row:
        return jsonify({"error": "Incident not found"}), 404 
    return jsonify(dict(row))


# AMBULANCES


@app.route("/api/ambulances", methods=["GET"])
def get_ambulances():
    rows = query("SELECT * FROM ambulance ORDER BY ambulance_id")
    return jsonify([dict(r) for r in rows])

@app.route("/api/ambulances/available", methods=["GET"])
def get_available_ambulances():
    rows = query("SELECT * FROM ambulance WHERE status = 'AVAILABLE'")
    return jsonify([dict(r) for r in rows])

@app.route("/api/ambulances", methods=["POST"])
def create_ambulance():
    d = request.json
    query("""
        INSERT INTO ambulance (code, license_plate, ambulance_type, status, base_latitude, base_longitude)
        VALUES (%s, %s, %s, 'AVAILABLE', %s, %s)
    """, (d["code"], d["license_plate"], d["ambulance_type"], d["base_latitude"], d["base_longitude"]), fetch=None)
    return jsonify({"message": "Ambulance ajoutée"}), 201

@app.route("/api/ambulances/<int:id>/position", methods=["POST"])
def update_position(id):
    d = request.json
    query("""
        INSERT INTO ambulance_position (ambulance_id, latitude, longitude, speed_kmh, source)
        VALUES (%s, %s, %s, %s, 'GPS')
    """, (id, d["latitude"], d["longitude"], d.get("speed_kmh", 0)), fetch=None)
    return jsonify({"message": "Position enregistrée"}), 201

@app.route("/api/ambulances/<int:id>/positions", methods=["GET"])
def get_positions(id):
    rows = query("SELECT * FROM ambulance_position WHERE ambulance_id = %s ORDER BY recorded_at DESC LIMIT 50", (id,))
    return jsonify([dict(r) for r in rows])


# HOSPITALS


@app.route("/api/hospitals", methods=["GET"])
def get_hospitals():
    rows = query("""
        SELECT h.*, 
               json_agg(json_build_object(
                   'service_id', hs.service_id,
                   'service_type', hs.service_type,
                   'total_beds', hs.total_beds,
                   'occupied_beds', hs.occupied_beds
               )) AS services
        FROM hospital h
        LEFT JOIN hospital_service hs ON h.hospital_id = hs.hospital_id
        GROUP BY h.hospital_id
    """)
    return jsonify([dict(r) for r in rows])

@app.route("/api/hospitals", methods=["POST"])
def create_hospital():
    d = request.json
    query("""
        INSERT INTO hospital (name, address, city, phone, latitude, longitude, trauma_level)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (d["name"], d["address"], d["city"], d.get("phone"), d["latitude"], d["longitude"], d.get("trauma_level")), fetch=None)
    return jsonify({"message": "Hôpital ajouté"}), 201

@app.route("/api/hospitals/<int:id>/services", methods=["POST"])
def add_service(id):
    d = request.json
    query("""
        INSERT INTO hospital_service (hospital_id, service_type, total_beds, occupied_beds)
        VALUES (%s, %s, %s, %s)
    """, (id, d["service_type"], d["total_beds"], d.get("occupied_beds", 0)), fetch=None)
    return jsonify({"message": "Service ajouté"}), 201


# MISSIONS


@app.route("/api/missions", methods=["GET"])
def get_missions():
    rows = query("""
        SELECT m.*, 
               i.address AS incident_address, i.severity,
               a.code AS ambulance_code,
               h.name AS hospital_name
        FROM mission m
        LEFT JOIN incident i ON m.incident_id = i.incident_id
        LEFT JOIN ambulance a ON m.ambulance_id = a.ambulance_id
        LEFT JOIN hospital_service hs ON m.target_service_id = hs.service_id
        LEFT JOIN hospital h ON hs.hospital_id = h.hospital_id
        ORDER BY m.created_at DESC
    """)
    return jsonify([dict(r) for r in rows])

@app.route("/api/missions/auto", methods=["POST"])
def create_mission_auto():
    d = request.json
    try:
        query("""
            SELECT create_mission_auto(%s, %s, %s, %s)
        """, (d["incident_id"], d["ambulance_id"], d["latitude"], d["longitude"]), fetch=None)
        query("UPDATE incident SET status = 'ASSIGNED' WHERE incident_id = %s", (d["incident_id"],), fetch=None)
        return jsonify({"message": "Mission créée automatiquement"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/api/missions/<int:id>/status", methods=["PATCH"])
def update_mission_status(id):
    d = request.json
    field = d.get("field")  
    
    if field == 'closed_at':
        query("""
            UPDATE ambulance SET status = 'AVAILABLE' 
            WHERE ambulance_id = (SELECT ambulance_id FROM mission WHERE mission_id = %s)
        """, (id,), fetch=None)
        
        query("UPDATE mission SET status = 'COMPLETED', closed_at = NOW() WHERE mission_id = %s", (id,), fetch=None)
        return jsonify({"message": "Mission clôturée et ambulance libérée"})
    
    allowed = ["depart_base_at", "arrive_scene_at", "depart_scene_at", "arrive_hospital_at", "closed_at"]
    if field not in allowed:
        return jsonify({"error": "Champ invalide"}), 400
    query(f"UPDATE mission SET {field} = NOW() WHERE mission_id = %s", (id,), fetch=None)
    return jsonify({"message": f"{field} mis à jour"})

@app.route("/api/missions/<int:id>", methods=["GET"])
def get_mission(id):
    row = query("""
        SELECT m.*, 
               i.address AS incident_address, i.severity, i.latitude AS inc_lat, i.longitude AS inc_lon,
               a.code AS ambulance_code, a.license_plate,
               h.name AS hospital_name, h.address AS hospital_address
        FROM mission m
        LEFT JOIN incident i ON m.incident_id = i.incident_id
        LEFT JOIN ambulance a ON m.ambulance_id = a.ambulance_id
        LEFT JOIN hospital_service hs ON m.target_service_id = hs.service_id
        LEFT JOIN hospital h ON hs.hospital_id = h.hospital_id
        WHERE m.mission_id = %s
    """, (id,), fetch="one")
    if not row:
        return jsonify({"error": "Mission not found"}), 404 
    return jsonify(dict(row))


# EMERGENCY CALLS


@app.route("/api/calls", methods=["GET"])
def get_calls():
    rows = query("""
        SELECT ec.*, i.address AS incident_address, u.display_name AS operator_name
        FROM emergency_call ec
        LEFT JOIN incident i ON ec.incident_id = i.incident_id
        LEFT JOIN app_user u ON ec.operator_id = u.user_id
        ORDER BY ec.created_at DESC
    """)
    return jsonify([dict(r) for r in rows])

@app.route("/api/calls", methods=["POST"])
def create_call():
    d = request.json
    query("""
        INSERT INTO emergency_call (incident_id, channel, caller_number, operator_id, notes)
        VALUES (%s, %s, %s, %s, %s)
    """, (d["incident_id"], d.get("channel", "PHONE"), d.get("caller_number"), d.get("operator_id"), d.get("notes")), fetch=None)
    return jsonify({"message": "Appel enregistré"}), 201


# ADMISSIONS


@app.route("/api/admissions", methods=["POST"])
def create_admission():
    d = request.json
    try:
        query("""
            INSERT INTO admissions (mission_id, patient_id, service_id, status, admitted_at)
            VALUES (%s, %s, %s, 'ADMITTED', NOW())
        """, (d["mission_id"], d.get("patient_id"), d["service_id"]), fetch=None)
        return jsonify({"message": "Admission créée"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/api/admissions/<int:id>/discharge", methods=["PATCH"])
def discharge(id):
    query("""
        UPDATE admissions SET status = 'DISCHARGED', discharged_at = NOW()
        WHERE admission_id = %s
    """, (id,), fetch=None)
    return jsonify({"message": "Patient sorti"})


# INCIDENT TYPES & USERS


@app.route("/api/incident-types", methods=["GET"])
def get_incident_types():
    rows = query("SELECT * FROM incident_type")
    return jsonify([dict(r) for r in rows])

@app.route("/api/users", methods=["GET"])
def get_users():
    rows = query("SELECT user_id, display_name, role, active FROM app_user")
    return jsonify([dict(r) for r in rows])


# DASHBOARD STATS


@app.route("/api/stats", methods=["GET"])
def get_stats():
    active_missions = query("SELECT COUNT(*) AS count FROM mission WHERE status NOT IN ('COMPLETED', 'CANCELLED')", fetch="one")
    available_ambulances = query("SELECT COUNT(*) AS count FROM ambulance WHERE status = 'AVAILABLE'", fetch="one")
    open_incidents = query("SELECT COUNT(*) AS count FROM incident WHERE status = 'OPEN'", fetch="one")
    total_beds = query("SELECT SUM(total_beds) AS total, SUM(occupied_beds) AS occupied FROM hospital_service", fetch="one")
    return jsonify({
        "active_missions": active_missions["count"],
        "available_ambulances": available_ambulances["count"],
        "open_incidents": open_incidents["count"],
        "total_beds": total_beds["total"],
        "occupied_beds": total_beds["occupied"]
    })

if __name__ == "__main__":
    app.run(debug=True, port=5000)
