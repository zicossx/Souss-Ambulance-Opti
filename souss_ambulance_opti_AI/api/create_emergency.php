<?php
require 'config.php';

$data = json_decode(file_get_contents('php://input'), true);

$patientId = $data['patient_id'] ?? $_POST['patient_id'] ?? 0;
$latitude = $data['latitude'] ?? $_POST['latitude'] ?? 0;
$longitude = $data['longitude'] ?? $_POST['longitude'] ?? 0;
$status = 'pending';

try {
    // Create emergency request
    $stmt = $pdo->prepare("INSERT INTO emergencies (patient_id, latitude, longitude, status, created_at) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)");
    $stmt->execute([$patientId, $latitude, $longitude, $status]);
    $emergencyId = $pdo->lastInsertId();
    
    // Find nearest online driver
    $stmt = $pdo->prepare("
        SELECT id, latitude, longitude,
        (6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) AS distance
        FROM drivers 
        WHERE is_online = 1 
        AND latitude IS NOT NULL 
        AND longitude IS NOT NULL
        ORDER BY distance 
        LIMIT 1
    ");
    $stmt->execute([$latitude, $longitude, $latitude]);
    $nearestDriver = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($nearestDriver) {
        // Assign driver
        $stmt = $pdo->prepare("UPDATE emergencies SET driver_id = ?, status = 'accepted' WHERE id = ?");
        $stmt->execute([$nearestDriver['id'], $emergencyId]);
        
        echo json_encode([
            'success' => true,
            'emergency_id' => $emergencyId,
            'driver_id' => $nearestDriver['id'],
            'distance' => round($nearestDriver['distance'], 2)
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Did not find any driver'
        ]);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
