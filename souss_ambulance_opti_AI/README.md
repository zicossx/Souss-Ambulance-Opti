# 🚑 Souss Ambulance Opti

![Souss Ambulance Hero](mobile-app/assets/hero.png)

## 🌐 Overview
**Souss Ambulance Opti** is a cutting-edge, integrated emergency medical response system designed to revolutionize ambulance dispatching and hospital coordination. By combining real-time geolocation, advanced driver-patient matching, and a robust hospital management dashboard, we ensure that every second counts when saving lives.

---

## 🚀 Key Features

### 📱 Mobile Application (Flutter)
- **Role Selection**: Dedicated interfaces for Patients and Drivers.
- **Real-time Tracking**: Live GPS tracking of ambulances on a map.
- **Emergency Dispatch**: One-tap emergency requests with instant driver notification.
- **Visual Excellence**: Modern "Cyber-Medical" UI with Midnight Blue and Vibrant Rose accents.

### 📊 Hospital Dashboard (Django)
- **Live Monitoring**: Real-time view of all active emergencies and ambulance locations.
- **Resource Management**: Manage hospital capacity and staff.
- **Administrative Control**: Manage users, drivers, and system configurations.

### ⚙️ Backend API (PHP)
- **High Performance**: Lightweight PHP scripts for rapid data handling.
- **Secure Communication**: Robust PDO-based database interactions.
- **Geolocation Services**: Custom algorithms for finding the nearest hospitals.

---

## 🛠️ Technology Stack

| Component | Technology | Role |
| :--- | :--- | :--- |
| **Mobile** | Flutter / Dart | Cross-platform mobile app |
| **Dashboard** | Django / Python | Web-based management portal |
| **API** | PHP / MySQL | Backend service layer |

---

## 📥 Installation & Setup

### 1. Mobile App
```bash
cd mobile-app
flutter pub get
flutter run
```

### 2. Hospital Dashboard
```bash
cd dashboard
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### 3. API
- Configure database credentials in `api/config.php`.
- Import `api/schema_dump.sql` into your MySQL database.

---
