<?php
require 'config.php';

$driverId = $_GET['driver_id'] ?? 0;

try {
    $stmt = $pdo->prepare("
        SELECT e.*, p.first_name, p.last_name, p.phone, p.blood_type
        FROM emergencies e
        JOIN patients p ON e.patient_id = p.id
        WHERE e.driver_id = ? 
        AND e.status IN ('accepted', 'in_progress')
        AND e.created_at > datetime('now', '-1 hour')
        ORDER BY e.created_at DESC
    ");
    $stmt->execute([$driverId]);
    $emergencies = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'emergencies' => $emergencies
    ]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
