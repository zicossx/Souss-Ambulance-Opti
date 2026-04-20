<?php
require 'config.php';

$lat = (float)($_GET['lat'] ?? 0);
$lng = (float)($_GET['lng'] ?? 0);

if ($lat == 0 || $lng == 0) {
    echo json_encode(['success' => false, 'message' => 'Invalid coordinates']);
    exit;
}

try {
    // Haversine formula approximation (works in MySQL)
    // distance in km = sqrt((dlat*111)^2 + (dlng*111*cos(lat))^2)
    $stmt = $pdo->prepare("
        SELECT id, name, address, city, phone, emergency_capacity,
               latitude, longitude,
               (
                   ((:lat - latitude) * 111) * ((:lat - latitude) * 111) +
                   ((:lng - longitude) * 111 * 0.8) * ((:lng - longitude) * 111 * 0.8)
               ) AS dist_sq
        FROM hospitals
        WHERE is_active = 1 AND latitude IS NOT NULL AND longitude IS NOT NULL
        ORDER BY dist_sq ASC
        LIMIT 1
    ");
    $stmt->execute([':lat' => $lat, ':lng' => $lng]);
    $hospital = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($hospital) {
        $hospital['id']                = (int)$hospital['id'];
        $hospital['emergency_capacity']= (int)$hospital['emergency_capacity'];
        $hospital['latitude']          = (float)$hospital['latitude'];
        $hospital['longitude']         = (float)$hospital['longitude'];
        $hospital['distance_km']       = round(sqrt((float)$hospital['dist_sq']), 2);
        unset($hospital['dist_sq']);

        echo json_encode(['success' => true, 'hospital' => $hospital]);
    } else {
        echo json_encode(['success' => false, 'message' => 'No hospitals found']);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
