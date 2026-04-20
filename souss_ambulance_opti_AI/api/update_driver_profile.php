<?php
require 'config.php';

$data = json_decode(file_get_contents('php://input'), true);

$id = $data['id'] ?? 0;
$firstName = $data['first_name'] ?? '';
$lastName = $data['last_name'] ?? '';
$phone = $data['phone'] ?? '';
$licenseNumber = $data['license_number'] ?? '';
$vehicleNumber = $data['vehicle_number'] ?? '';
$isOnline = $data['is_online'] ?? 0;

try {
    $stmt = $pdo->prepare("UPDATE drivers SET first_name = ?, last_name = ?, phone = ?, license_number = ?, vehicle_number = ?, is_online = ? WHERE id = ?");
    $stmt->execute([$firstName, $lastName, $phone, $licenseNumber, $vehicleNumber, $isOnline, $id]);
    
    echo json_encode([
        'success' => true,
        'message' => 'Profile updated successfully'
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
