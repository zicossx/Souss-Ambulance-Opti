<?php
require 'config.php';

$data = json_decode(file_get_contents('php://input'), true);

$patientId = $data['patient_id'] ?? $_POST['patient_id'] ?? 0;

try {
    // Find the active emergency
    $stmt = $pdo->prepare("SELECT id FROM emergencies WHERE patient_id = ? AND status IN ('pending', 'accepted', 'in_progress') ORDER BY created_at DESC LIMIT 1");
    $stmt->execute([$patientId]);
    $emergency = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($emergency) {
        // Cancel it
        $updateStmt = $pdo->prepare("UPDATE emergencies SET status = 'cancelled' WHERE id = ?");
        $updateStmt->execute([$emergency['id']]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Emergency request cancelled successfully'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'No active emergency found to cancel'
        ]);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
