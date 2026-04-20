<?php
require 'config.php';

$data = json_decode(file_get_contents('php://input'), true);

$emergencyId = $data['emergency_id'] ?? $_POST['emergency_id'] ?? 0;
$status = $data['status'] ?? $_POST['status'] ?? ''; // 'in_progress', 'completed', 'cancelled'

try {
    $stmt = $pdo->prepare("UPDATE emergencies SET status = ? WHERE id = ?");
    $stmt->execute([$status, $emergencyId]);
    
    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
