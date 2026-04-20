<?php
require 'config.php';

try {
    $stmt = $pdo->query("
        SELECT id, name, address, city, region, phone, email,
               emergency_capacity, latitude, longitude, is_active
        FROM hospitals
        WHERE is_active = 1 AND latitude IS NOT NULL AND longitude IS NOT NULL
        ORDER BY name ASC
    ");
    $hospitals = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Cast types
    foreach ($hospitals as &$h) {
        $h['id']                = (int)$h['id'];
        $h['emergency_capacity']= (int)$h['emergency_capacity'];
        $h['is_active']         = (bool)$h['is_active'];
        $h['latitude']          = $h['latitude'] !== null ? (float)$h['latitude'] : null;
        $h['longitude']         = $h['longitude'] !== null ? (float)$h['longitude'] : null;
    }

    echo json_encode([
        'success'   => true,
        'hospitals' => $hospitals,
        'count'     => count($hospitals),
    ]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
