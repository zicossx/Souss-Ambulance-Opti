# 🚑 Souss-Ambulance Opti

## 📌 Description

**Souss-Ambulance Opti** is an intelligent emergency logistics system designed to optimize ambulance dispatching in real time.  
It assigns ambulances to the least saturated hospitals while considering hospital capacity, distance, and emergency severity.

---

## 📑 Table of Contents

- [About the Project](#about-the-project)
- [Objectives](#objectives)
- [System Architecture](#system-architecture)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Demo Video](#demo-video)
- [Team](#team)
- [Security](#security)
- [Testing](#testing)

---

## 📖 About the Project

This project aims to improve emergency response efficiency in the Souss-Massa region by building a distributed smart system for ambulance coordination and hospital load management.

The system connects hospitals, ambulances, and patients through real-time data exchange.

---

## 🎯 Objectives

- Reduce ambulance response time 🚑  
- Prevent hospital overcrowding 🏥  
- Optimize ambulance allocation  
- Improve coordination between hospitals and emergency services  
- Provide real-time decision support  

---

## 🏗️ System Architecture

The system is built using a multi-layer architecture:

### 🟦 Hospital Dashboard (Django)
- Used by doctors and hospital staff
- Manage hospital capacity (beds, availability)
- Update real-time hospital status
- Monitor incoming emergency cases

### 🟨 Backend API (PHP)
- Core system logic
- Handles communication between all modules
- Processes ambulance routing decisions
- Provides RESTful services

### 🟩 Mobile Applications (Flutter)

**🚑 Driver App (Ambulance Team)**
- Receives emergency missions
- Displays optimal hospital destination
- Provides navigation support

**🧑‍⚕️ Patient App**
- Requests ambulance service
- Tracks emergency request status

---

## ⚙️ Features

- 📊 Real-time hospital monitoring  
- 🚑 Smart ambulance routing system  
- 🏥 Dynamic hospital dashboard (Django)  
- 📍 Location-based decision making  
- 🔄 PHP REST API integration  
- 📱 Flutter mobile apps (driver + patient)  
- 🚨 Critical case prioritization  

---

## 🛠️ Technologies Used

- **Django** – Hospital dashboard system  
- **PHP** – Backend API  
- **Flutter** – Mobile applications  
- **SQLite** – Lightweight database used for data storage  
- **REST API** – System communication between modules  

---

## 🎥 Demo Video

👉 Watch the demo:  
https://www.youtube.com/watch?v=pM72y3rL0tg

---

## 👥 Team

- **Architects:** OUKHOUYA Anas – REGRAGUI M. – SIOUDA Nour – SOUAK RABAB  
- **Augmented Team:** WANAIM Abdelhakim – Yahiaoui Zakaria – YOUSFI A. Salma  
- **Red Team:** SENANE Y. – SODKI Abla  
- **Blue Team:** TARIQ S. – TAWFIK Y. M.  
- **QA / AI Engineers:** Younsi Safae – Znadi Malake  

---

## 🔐 Security

- Role-Based Access Control (RBAC) 🔑  
- SQL Injection protection 🛡️  
- Secure API communication  
- Data anonymization for sensitive information  

---

## 🧪 Testing

- Load and stress testing  
- Hospital saturation simulations  
- Emergency scenario validation  
- API integration testing (PHP / Django / Flutter)  

---
