<?php
require 'config.php';

$data = json_decode(file_get_contents('php://input'), true);

$firstName = $data['first_name'] ?? $_POST['first_name'] ?? '';
$lastName = $data['last_name'] ?? $_POST['last_name'] ?? '';
$email = $data['email'] ?? $_POST['email'] ?? '';
$phone = $data['phone'] ?? $_POST['phone'] ?? '';
$passwordRaw = $data['password'] ?? $_POST['password'] ?? '';
$password = password_hash($passwordRaw, PASSWORD_BCRYPT);
$age = $data['age'] ?? $_POST['age'] ?? 0;
$bloodType = $data['blood_type'] ?? $_POST['blood_type'] ?? '';

try {
    $stmt = $pdo->prepare("INSERT INTO patients (first_name, last_name, email, phone, password, age, blood_type) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$firstName, $lastName, $email, $phone, $password, $age, $bloodType]);
    
    $userId = (int)$pdo->lastInsertId();
    
    // Get the full user object
    $stmt = $pdo->prepare("SELECT * FROM patients WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Clean up sensitive data
    unset($user['password']);
    
    // Ensure numeric fields are correctly typed
    $user['id'] = (int)$user['id'];
    $user['age'] = (int)$user['age'];
    
    echo json_encode([
        'success' => true,
        'message' => 'Patient registered successfully',
        'user_id' => $userId,
        'user' => $user
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
