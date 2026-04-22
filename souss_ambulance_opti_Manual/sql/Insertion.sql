INSERT INTO hospital (name, address, city, phone, latitude, longitude, trauma_level)
VALUES 
('Hôpital Hassan II', 'Quartier Industriel', 'Agadir', '0528822000', 30.4278, -9.5981, 1),
('Clinique du Souss', 'Avenue du Prince Héritier', 'Agadir', '0528844000', 30.4150, -9.5800, 2),
('Hôpital Mokhtar Soussi', 'Avenue Moulay Rachid', 'Taroudant', '0528852024', 30.4714, -8.8753, 2);

INSERT INTO hospital_service (hospital_id, service_type, total_beds, occupied_beds)
VALUES 
(1, 'URGENCES', 30, 0),
(1, 'REANIMATION', 12, 0),
(2, 'URGENCES', 15, 0),
(2, 'TRAUMATOLOGIE', 20, 0),
(3, 'URGENCES', 25, 0),
(3, 'REANIMATION', 8, 0),
(3, 'PEDIATRIE', 20, 0);

INSERT INTO app_user (email, display_name, role)
VALUES 
('admin@souss.ma', 'Admin Souss', 'ADMIN'),
('dispatcher@souss.ma', 'Dispatcher 01', 'DISPATCHER'),
('driver@souss.ma', 'Chauffeur 01', 'DRIVER');


INSERT INTO incident_type(code, label, description) VALUES
('ACC_ROUTE', 'Accident de la route', 'Collision véhicule, piéton renversé'),
('MALAISE_CARD', 'Malaise cardiaque', 'Crise cardiaque, douleur thoracique'),
('ACC_DOMES', 'Accident domestique', 'Chute, brûlure, intoxication'),
('NOYADE', 'Noyade', 'Noyade ou quasi-noyade'),
('ACCOUCHEMENT', 'Accouchement', 'Accouchement inopiné'),
('TRAUMA_GRAVE', 'Traumatisme grave', 'Chute de hauteur, écrasement'),
('INCENDIE', 'Incendie', 'Victime d''incendie ou inhalation fumée'),
('AGRESSION', 'Agression', 'Blessure par arme, coups'),
('AUTRE', 'Autre urgence', 'Urgence non classifiée');


