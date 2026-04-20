<?php
require 'config.php';

$patientId = $_GET['patient_id'] ?? 0;

try {
    // We only care about emergencies that are not 'completed' or 'cancelled'
    $stmt = $pdo->prepare("
        SELECT e.*, 
               d.first_name as driver_first_name, 
               d.last_name as driver_last_name, 
               d.latitude as driver_latitude, 
               d.longitude as driver_longitude,
               d.phone as driver_phone
        FROM emergencies e
        LEFT JOIN drivers d ON e.driver_id = d.id
        WHERE e.patient_id = ? AND e.status IN ('pending', 'accepted', 'in_progress')
        ORDER BY e.created_at DESC
        LIMIT 1
    ");
    $stmt->execute([$patientId]);
    $emergency = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($emergency) {
        echo json_encode([
            'success' => true,
            'emergency' => $emergency
        ]);
    } else {
        echo json_encode([
            'success' => true, // Successful request, but no active emergency
            'emergency' => null
        ]);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
