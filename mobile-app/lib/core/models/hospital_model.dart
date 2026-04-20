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
}