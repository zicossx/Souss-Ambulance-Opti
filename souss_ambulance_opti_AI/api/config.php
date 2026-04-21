<?php
// Handle OPTIONS immediately - BEFORE anything else
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
    http_response_code(200);
    exit;
}

// Regular headers
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

// Database - Unified SQLite
define('DB_PATH', __DIR__ . '/ambulance_app.db');

function getDB() {
    try {
        $pdo = new PDO('sqlite:' . DB_PATH);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        // Enable WAL mode for better concurrency
        $pdo->exec('PRAGMA journal_mode=WAL;');
        $pdo->exec('PRAGMA foreign_keys=ON;');

        // Register math functions for distance calculation in SQLite
        $pdo->sqliteCreateFunction('acos', 'acos', 1);
        $pdo->sqliteCreateFunction('cos', 'cos', 1);
        $pdo->sqliteCreateFunction('sin', 'sin', 1);
        $pdo->sqliteCreateFunction('radians', 'deg2rad', 1);

        return $pdo;
    } catch (Exception $e) {
        die(json_encode(['success'=>false,'message'=>'DB error: ' . $e->getMessage()]));
    }
}

function jsonResponse($data) {
    echo json_encode($data, JSON_NUMERIC_CHECK);
    exit;
}

function formatDriver($row) {
    return [
        'id' => (int)$row['id'],
        'first_name' => $row['first_name'],
        'last_name' => $row['last_name'],
        'email' => $row['email'],
        'phone' => $row['phone'],
        'license_number' => $row['license_number'],
        'vehicle_number' => $row['vehicle_number'],
        'is_online' => (bool)$row['is_online'],
        'latitude' => $row['latitude'] ? (float)$row['latitude'] : null,
        'longitude' => $row['longitude'] ? (float)$row['longitude'] : null,
        'rating' => $row['rating'] ? (float)$row['rating'] : null,
        'total_trips' => (int)$row['total_trips'],
        'created_at' => $row['created_at'],
        'last_updated' => $row['last_updated']
    ];
}

// Initialize the global connection variable
$pdo = getDB();
?>
