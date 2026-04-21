class Hospital {
  final String id;
  final String name;
  final String nameAr;
  final String address;
  final String? phone;
  final int bedsAvailable;
  final String distance;
  final double latitude;
  final double longitude;
  final String type;

  Hospital({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.address,
    this.phone,
    required this.bedsAvailable,
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.type,
  });
  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      // Convert bedsAvailable: if it's a String, parse to int
      bedsAvailable: json['bedsAvailable'] is int 
          ? json['bedsAvailable'] 
          : int.parse(json['bedsAvailable'].toString()),
      distance: json['distance'] as String,
      // Convert latitude: handle String or double
      latitude: json['latitude'] is double 
          ? json['latitude'] 
          : double.parse(json['latitude'].toString()),
      longitude: json['longitude'] is double 
          ? json['longitude'] 
          : double.parse(json['longitude'].toString()),
      type: json['type'] as String,
    );
  }

}