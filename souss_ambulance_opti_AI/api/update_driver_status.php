<?php
require 'config.php';

// Support both JSON and Form-Data
$data = json_decode(file_get_contents('php://input'), true);

$driverId = $data['id'] ?? $_POST['id'] ?? null;
$isOnlineRaw = $data['is_online'] ?? $_POST['is_online'] ?? null;

if (!$driverId || $isOnlineRaw === null) {
    echo json_encode(['success' => false, 'error' => 'Missing id or is_online']);
    exit;
}

// Ensure is_online is treated as integer/boolean for the DB
$isOnline = ($isOnlineRaw === 'true' || $isOnlineRaw === true || $isOnlineRaw == 1) ? 1 : 0;

try {
    // Note: The column name in your database is 'is_online' (lowercase)
    $sql = "UPDATE drivers SET is_online = :isonline WHERE id = :id";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([':isonline' => $isOnline, ':id' => $driverId]);

    echo json_encode(['success' => true, 'message' => 'Status updated']);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => 'Update failed: ' . $e->getMessage()]);
}
?>