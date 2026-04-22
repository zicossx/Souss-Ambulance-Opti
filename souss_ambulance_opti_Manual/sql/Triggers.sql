-- UPDATE lits automatiquement 
CREATE OR REPLACE FUNCTION trg_update_beds()
RETURNS TRIGGER AS $$
BEGIN
    -- Only increment if changing TO Admitted
    IF (NEW.status = 'ADMITTED' AND (OLD.status IS DISTINCT FROM 'ADMITTED' OR TG_OP = 'INSERT')) THEN
        UPDATE hospital_service SET occupied_beds = occupied_beds + 1 WHERE service_id = NEW.service_id;
    
    -- Only decrement if changing FROM Admitted to something else
    ELSIF (OLD.status = 'ADMITTED' AND NEW.status IS DISTINCT FROM 'ADMITTED') THEN
        UPDATE hospital_service SET occupied_beds = occupied_beds - 1 WHERE service_id = NEW.service_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_admission_beds
AFTER INSERT OR UPDATE ON admissions
FOR EACH ROW
EXECUTE FUNCTION trg_update_beds();

-- BLOQUER si hôpital plein
CREATE OR REPLACE FUNCTION trg_check_capacity()
RETURNS TRIGGER AS $$
DECLARE
    total INT;
    occupied INT;
BEGIN
    SELECT total_beds, occupied_beds
    INTO total, occupied
    FROM hospital_service
    WHERE service_id = NEW.service_id;

    IF occupied >= total THEN
        RAISE EXCEPTION 'Service plein';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_capacity
BEFORE INSERT ON admissions
FOR EACH ROW
EXECUTE FUNCTION trg_check_capacity();

-- STATUT mission automatique
CREATE OR REPLACE FUNCTION trg_mission_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.arrive_scene_at IS NOT NULL THEN
        NEW.status := 'ON_SITE';
    ELSIF NEW.arrive_hospital_at IS NOT NULL THEN
        NEW.status := 'AT_HOSPITAL';
    ELSIF NEW.closed_at IS NOT NULL THEN
        NEW.status := 'COMPLETED';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mission_status
BEFORE UPDATE ON mission
FOR EACH ROW
EXECUTE FUNCTION trg_mission_status();

-- BLOQUER ambulance occupée
CREATE OR REPLACE FUNCTION trg_check_ambulance()
RETURNS TRIGGER AS $$
DECLARE
    st VARCHAR;
BEGIN
    SELECT status INTO st
    FROM ambulance
    WHERE ambulance_id = NEW.ambulance_id;

    IF st <> 'AVAILABLE' THEN
        RAISE EXCEPTION 'Ambulance non disponible';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ambulance_check
BEFORE INSERT ON mission
FOR EACH ROW
EXECUTE FUNCTION trg_check_ambulance();

-- MAJ statut ambulance
CREATE OR REPLACE FUNCTION trg_set_ambulance_busy()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE ambulance
    SET status = 'BUSY'
    WHERE ambulance_id = NEW.ambulance_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ambulance_busy
AFTER INSERT ON mission
FOR EACH ROW
EXECUTE FUNCTION trg_set_ambulance_busy();

-- VALIDATION GPS
CREATE OR REPLACE FUNCTION trg_check_gps()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.latitude NOT BETWEEN -90 AND 90 
       OR NEW.longitude NOT BETWEEN -180 AND 180 THEN
        RAISE EXCEPTION 'Coordonnées GPS invalides';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_gps_validation
BEFORE INSERT ON ambulance_position
FOR EACH ROW
EXECUTE FUNCTION trg_check_gps();

-- Function to reset ambulance status to AVAILABLE
CREATE OR REPLACE FUNCTION trg_release_ambulance()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the mission status has moved to a terminal state
    IF NEW.status IN ('COMPLETED', 'CANCELLED') THEN
        UPDATE ambulance
        SET status = 'AVAILABLE'
        WHERE ambulance_id = NEW.ambulance_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to fire whenever a mission is updated
CREATE TRIGGER trg_mission_completion
AFTER UPDATE ON mission
FOR EACH ROW
EXECUTE FUNCTION trg_release_ambulance();


-- AUDIT automatique
CREATE OR REPLACE FUNCTION trg_audit_mission()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_logs(user_id, action, entity, entity_id, meta_json)
    VALUES (
        NEW.dispatcher_id,
        TG_OP,
        'mission',
        NEW.mission_id,
        row_to_json(NEW)
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mission_audit
AFTER INSERT OR UPDATE ON mission
FOR EACH ROW
EXECUTE FUNCTION trg_audit_mission();