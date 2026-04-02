-- Choisir le meilleur hôpital
CREATE OR REPLACE FUNCTION find_best_hospital(
    p_lat DECIMAL,
    p_lon DECIMAL
)
RETURNS TABLE (
    service_id INT,
    hospital_id INT,
    score DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hs.service_id,
        h.hospital_id,
        (1 - (hs.occupied_beds::DECIMAL / hs.total_beds)) * 0.6
        + (1 / (1 + ABS(h.latitude - p_lat) + ABS(h.longitude - p_lon))) * 0.4
        AS score
    FROM hospital_service hs
    JOIN hospital h ON hs.hospital_id = h.hospital_id
    WHERE hs.total_beds > hs.occupied_beds
    ORDER BY score DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Procédure : Calcul trajet estimé (simplifié)
CREATE OR REPLACE FUNCTION find_best_hospital(
    p_lat DECIMAL,
    p_lon DECIMAL
)
RETURNS TABLE (
    service_id INT,
    hospital_id INT,
    score DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        hs.service_id,
        h.hospital_id,
        (1 - (hs.occupied_beds::DECIMAL / hs.total_beds)) * 0.6
        + (1 / (1 + ABS(h.latitude - p_lat) + ABS(h.longitude - p_lon))) * 0.4
        AS score
    FROM hospital_service hs
    JOIN hospital h ON hs.hospital_id = h.hospital_id
    WHERE hs.total_beds > hs.occupied_beds
    ORDER BY score DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Création automatique mission
CREATE OR REPLACE FUNCTION create_mission_auto(
    p_incident_id INT,
    p_ambulance_id INT,
    p_lat DECIMAL,
    p_lon DECIMAL
)
RETURNS VOID AS $$
DECLARE
    best_service RECORD;
BEGIN
    -- Trouver meilleur hôpital
    SELECT * INTO best_service
    FROM find_best_hospital(p_lat, p_lon);

    -- Créer mission
    INSERT INTO mission(
        incident_id,
        ambulance_id,
        target_service_id,
        status,
        decided_at
    )
    VALUES (
        p_incident_id,
        p_ambulance_id,
        best_service.service_id,
        'DISPATCHED',
        NOW()
    );
END;
$$ LANGUAGE plpgsql;