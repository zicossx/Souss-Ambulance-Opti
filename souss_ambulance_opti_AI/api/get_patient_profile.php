<?php
require 'config.php';

$patientId = $_GET['id'] ?? 0;

try {
    $stmt = $pdo->prepare("SELECT id, first_name, last_name, email, phone, age, blood_type, created_at FROM patients WHERE id = ?");
    $stmt->execute([$patientId]);
    $patient = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($patient) {
        echo json_encode([
            'success' => true,
            'data' => $patient
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Patient not found'
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
