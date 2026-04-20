<?php
require 'config.php';

$driverId = $_GET['driver_id'] ?? 0;

try {
    // Update last_updated as a heartbeat so the system knows the driver is actively online
    $updateStmt = $pdo->prepare("UPDATE drivers SET last_updated = NOW() WHERE id = ?");
    $updateStmt->execute([$driverId]);

    $stmt = $pdo->prepare("
        SELECT e.*, p.first_name, p.last_name, p.phone, p.blood_type
        FROM emergencies e
        JOIN patients p ON e.patient_id = p.id
        WHERE e.driver_id = ? AND e.status IN ('accepted', 'in_progress')
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
