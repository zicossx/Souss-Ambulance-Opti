<?php
require 'config.php';

$driverId = $_GET['id'] ?? 0;

try {
    $stmt = $pdo->prepare("SELECT id, first_name, last_name, email, phone, license_number, vehicle_number, is_online, rating, total_trips, created_at FROM drivers WHERE id = ?");
    $stmt->execute([$driverId]);
    $driver = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($driver) {
        echo json_encode([
            'success' => true,
            'data' => $driver
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Driver not found'
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
