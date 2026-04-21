class Patient {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final int? age;
  final String? bloodType;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.age,
    this.bloodType,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.lastUpdated,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is String) return double.tryParse(value);
      if (value is int) return value.toDouble();
      return null;
    }

    return Patient(
      id: parseInt(json['id']),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      age: json['age'] != null ? parseInt(json['age']) : null,
      bloodType: json['blood_type']?.toString(),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      lastUpdated: json['last_updated'] != null 
          ? DateTime.tryParse(json['last_updated'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'age': age,
      'blood_type': bloodType,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}