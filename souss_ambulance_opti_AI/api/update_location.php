<?php
require 'config.php';

$data = json_decode(file_get_contents('php://input'), true);

$userId = $data['user_id'] ?? $_POST['user_id'] ?? 0;
$userType = $data['user_type'] ?? $_POST['user_type'] ?? ''; // 'patient' or 'driver'
$latitude = $data['latitude'] ?? $_POST['latitude'] ?? 0;
$longitude = $data['longitude'] ?? $_POST['longitude'] ?? 0;

// Validate user type
if (!in_array($userType, ['patient', 'driver'])) {
    echo json_encode(['success' => false, 'message' => 'Invalid user type']);
    exit;
}

$table = $userType . 's'; // patients or drivers

try {
    $stmt = $pdo->prepare("UPDATE $table SET latitude = ?, longitude = ?, last_updated = CURRENT_TIMESTAMP WHERE id = ?");
    $stmt->execute([$latitude, $longitude, $userId]);
    
    echo json_encode([
        'success' => true,
        'message' => 'Location updated'
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
