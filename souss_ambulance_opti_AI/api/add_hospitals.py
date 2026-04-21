import sqlite3
import os

db_path = 'ambulance_app.db'
if not os.path.exists(db_path):
    print(f"Error: {db_path} not found")
    exit(1)

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

hospitals = [
    # (name, address, city, region, phone, latitude, longitude)
    ('CHU Ibn Sina', 'Avenue des Hospitals', 'Rabat', 'Rabat-Salé-Kénitra', '+212 5376-76464', 33.9842, -6.8504),
    ('Hospital Cheikh Khalifa', 'Quartier Oulfa', 'Casablanca', 'Casablanca-Settat', '+212 5290-04444', 33.5604, -7.6321),
    ('CHU Hassan II', 'Route Sidi Harazem', 'Fez', 'Fès-Meknès', '+212 5356-14545', 34.0037, -4.9638),
    ('CHU Mohammed VI', 'Boulevard Al Kayrawan', 'Marrakech', 'Marrakech-Safi', '+212 5243-00700', 31.6295, -8.0132),
    ('Hospital Regional Hassan II', 'Quartier Industriel', 'Agadir', 'Souss-Massa', '+212 5288-41477', 30.4183, -9.5847),
    ('Hospital Provincial Saniat Rmel', 'Avenue du 9 Avril', 'Tetouan', 'Tanger-Tetouan-Al Hoceima', '+212 5399-72424', 35.5841, -5.3621),
    ('Hospital Al Farabi', 'Avenue Idriss Al Akbar', 'Oujda', 'Oriental', '+212 5366-82121', 34.6853, -1.9123),
    ('Clinique Internationale de Tanger', 'Route de Rabat', 'Tanger', 'Tanger-Tetouan-Al Hoceima', '+212 5393-22828', 35.7595, -5.8329),
    ('Polyclinique CNSS', 'Avenue Mohammed V', 'Kenitra', 'Rabat-Salé-Kénitra', '+212 5373-71456', 34.2570, -6.5890),
    ('Hospital Moulay Ismail', 'Quartier Hamria', 'Meknes', 'Fès-Meknès', '+212 5355-22805', 33.8935, -5.5547)
]

# Update "Main Hospital" with coordinates if it exists
cursor.execute("UPDATE hospitals SET latitude = 33.5731, longitude = -7.5898, address = '2 Rue des Hôpitaux', city = 'Casablanca' WHERE name = 'Main Hospital'")

# Insert new ones
for h in hospitals:
    # Check if exists by name
    cursor.execute("SELECT id FROM hospitals WHERE name = ?", (h[0],))
    if not cursor.fetchone():
        cursor.execute("""
            INSERT INTO hospitals (name, address, city, region, phone, latitude, longitude, emergency_capacity, is_active)
            VALUES (?, ?, ?, ?, ?, ?, ?, 50, 1)
        """, h)
        print(f"Added: {h[0]}")
    else:
        print(f"Skipped (exists): {h[0]}")

conn.commit()
conn.close()
