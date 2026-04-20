<?php
require 'config.php';

// Get data (support both JSON and Form-Data)
$data = json_decode(file_get_contents('php://input'), true);

$first_name = $data['first_name'] ?? $_POST['first_name'] ?? '';
$last_name = $data['last_name'] ?? $_POST['last_name'] ?? '';
$email = $data['email'] ?? $_POST['email'] ?? '';
$phone = $data['phone'] ?? $_POST['phone'] ?? '';
$passwordRaw = $data['password'] ?? $_POST['password'] ?? '';
$license = $data['license_number'] ?? $_POST['license_number'] ?? '';
$vehicle = $data['vehicle_number'] ?? $_POST['vehicle_number'] ?? '';

// Validate
if (empty($first_name) || empty($last_name) || empty($email) || empty($passwordRaw)) {
    echo json_encode(['success' => false, 'message' => 'Missing required fields']);
    exit;
}

try {
    // Check email exists
    $stmt = $pdo->prepare("SELECT id FROM drivers WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        echo json_encode(['success' => false, 'message' => 'Email already registered']);
        exit;
    }
    
    // Insert
    $hash = password_hash($passwordRaw, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare("INSERT INTO drivers (first_name, last_name, email, phone, password, license_number, vehicle_number, is_online, total_trips, rating) VALUES (?, ?, ?, ?, ?, ?, ?, 0, 0, 5.00)");
    $stmt->execute([$first_name, $last_name, $email, $phone, $hash, $license, $vehicle]);
    
    $id = $pdo->lastInsertId();
    
    // Get the new driver
    $stmt = $pdo->prepare("SELECT * FROM drivers WHERE id = ?");
    $stmt->execute([$id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Use the helper from config.php to format the response
    echo json_encode([
        'success' => true,
        'message' => 'Driver registered successfully',
        'driver' => formatDriver($row)
    ], JSON_NUMERIC_CHECK);
    
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
