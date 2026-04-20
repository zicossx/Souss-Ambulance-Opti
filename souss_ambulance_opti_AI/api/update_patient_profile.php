<?php
require 'config.php';

$data = json_decode(file_get_contents('php://input'), true);

$id = $data['id'] ?? 0;
$firstName = $data['first_name'] ?? '';
$lastName = $data['last_name'] ?? '';
$phone = $data['phone'] ?? '';
$age = $data['age'] ?? 0;
$bloodType = $data['blood_type'] ?? '';

try {
    $stmt = $pdo->prepare("UPDATE patients SET first_name = ?, last_name = ?, phone = ?, age = ?, blood_type = ? WHERE id = ?");
    $stmt->execute([$firstName, $lastName, $phone, $age, $bloodType, $id]);
    
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
