class Driver {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? licenseNumber;
  final String? vehicleNumber;
  final bool isOnline;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final int totalTrips;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  Driver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.licenseNumber,
    this.vehicleNumber,
    this.isOnline = false,
    this.latitude,
    this.longitude,
    this.rating,
    this.totalTrips = 0,
    required this.createdAt,
    this.lastUpdated,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    // Safe parsing helpers
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is String) return double.tryParse(value);
      if (value is int) return value.toDouble();
      return null;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

    return Driver(
      id: parseInt(json['id']),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      licenseNumber: json['license_number']?.toString(),
      vehicleNumber: json['vehicle_number']?.toString(),
      isOnline: parseBool(json['is_online']),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      rating: parseDouble(json['rating']),
      totalTrips: parseInt(json['total_trips']),
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
      'license_number': licenseNumber,
      'vehicle_number': vehicleNumber,
      'is_online': isOnline,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'total_trips': totalTrips,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}