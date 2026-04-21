<?php
require 'config.php';

$data = json_decode(file_get_contents('php://input'), true);

$driverId = $data['driver_id'] ?? $_POST['driver_id'] ?? 0;
$latitude = $data['latitude'] ?? $_POST['latitude'] ?? 0;
$longitude = $data['longitude'] ?? $_POST['longitude'] ?? 0;

try {
    $stmt = $pdo->prepare("UPDATE drivers SET latitude = ?, longitude = ?, last_updated = CURRENT_TIMESTAMP WHERE id = ?");
    $stmt->execute([$latitude, $longitude, $driverId]);
    
    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
