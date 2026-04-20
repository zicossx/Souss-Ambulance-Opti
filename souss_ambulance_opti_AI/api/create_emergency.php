<?php
require 'config.php';

$data = json_decode(file_get_contents('php://input'), true);

$patientId = $data['patient_id'] ?? $_POST['patient_id'] ?? 0;
$latitude = $data['latitude'] ?? $_POST['latitude'] ?? 0;
$longitude = $data['longitude'] ?? $_POST['longitude'] ?? 0;
$status = 'pending';

try {
    $pdo->beginTransaction();

    // 1. Find nearest online driver who is NOT busy
    // A driver is busy if they have an emergency with status 'accepted' or 'in_progress'
    $stmt = $pdo->prepare("
        SELECT d.id, d.latitude, d.longitude,
        (
            ((? - d.latitude) * 111) * ((? - d.latitude) * 111) +
            ((? - d.longitude) * 111 * 0.8) * ((? - d.longitude) * 111 * 0.8)
        ) AS distance_sq
        FROM drivers d
        LEFT JOIN emergencies e ON d.id = e.driver_id AND e.status IN ('accepted', 'in_progress')
        WHERE d.is_online = 1 AND e.id IS NULL AND d.last_updated >= NOW() - INTERVAL 1 MINUTE
        ORDER BY distance_sq ASC, RAND() 
        LIMIT 1
        FOR UPDATE
    ");
    $stmt->execute([$latitude, $latitude, $longitude, $longitude]);
    $nearestDriver = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($nearestDriver) {
        $distance = round(sqrt($nearestDriver['distance_sq']), 2);
        
        // 2. Create emergency request directly assigned to driver
        $stmt = $pdo->prepare("INSERT INTO emergencies (patient_id, driver_id, latitude, longitude, status, created_at) VALUES (?, ?, ?, ?, 'accepted', NOW())");
        $stmt->execute([$patientId, $nearestDriver['id'], $latitude, $longitude]);
        $emergencyId = $pdo->lastInsertId();

        $pdo->commit();

        echo json_encode([
            'success' => true,
            'emergency_id' => $emergencyId,
            'driver_id' => $nearestDriver['id'],
            'distance' => $distance
        ]);
    } else {
        $pdo->rollBack();
        echo json_encode([
            'success' => false,
            'message' => 'No drivers available'
        ]);
    }
} catch (PDOException $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>