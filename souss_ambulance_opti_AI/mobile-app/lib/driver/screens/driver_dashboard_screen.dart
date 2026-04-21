import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/providers/app_provider.dart';
import '../../core/screens/role_selection_screen.dart';
import '../../core/services/api_service.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/routing_service.dart';
import 'driver_profile_screen.dart';
import 'dart:async';

class DriverDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? driverData;  // 🔴 ADDED: Receive driver data
  
  const DriverDashboardScreen({super.key, this.driverData});  // 🔴 ADDED: Constructor parameter

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _isOnline = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Map
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(30.4720, -8.8770);

  bool _isAutoGPS = true; // Added
  StreamSubscription<Position>? _locationSubscription; // Added
  
  // Hospital data
  List<Map<String, dynamic>> _hospitals = [];
  Map<String, dynamic>? _nearestHospital;
  bool _isLoadingHospitals = false;

  // Emergency requests
  List<dynamic> _activeEmergencies = [];
  bool _isLoadingEmergencies = false;
  Timer? _emergencyTimer;
  bool _isShowingDialog = false; // Added to prevent dialog stacking
  List<LatLng> _routePoints = []; // Added for routing
  bool _isTransporting = false; // Added to track mission phase

  // 🔴 ADDED: Get driver info from widget
  Map<String, dynamic>? get _driver => widget.driverData;
  
  String get _driverName {
    if (_driver == null) return 'Unknown Driver';
    return '${_driver?['first_name'] ?? ''} ${_driver?['last_name'] ?? ''}'.trim();
  }
  
  String get _driverEmail => _driver?['email'] ?? 'No email';
  String get _driverPhone => _driver?['phone'] ?? 'No phone';
  String get _licenseNumber => _driver?['license_number'] ?? 'No license';
  String get _vehicleNumber => _driver?['vehicle_number'] ?? 'No vehicle';

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadHospitalsFromApi();
    _startLocationTracking();
    _loadEmergencies();
    _startEmergencyPolling();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_currentPosition, 14.0);
    });
    print('DRIVER DASHBOARD: driver=${_driver?["id"]}');
  }

  void _startEmergencyPolling() {
    _emergencyTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isOnline && mounted) {
        _loadEmergencies();
      }
    });
  }

  Future<void> _loadEmergencies() async {
    if (!_isOnline) return;
    if (_driver == null) return;  // 🔴 ADDED: Check if driver data exists
    
    final driverId = _driver?['id'];
    if (driverId == null) return;

    setState(() => _isLoadingEmergencies = true);
    
    try {
      final response = await ApiService.get('get_driver_emergencies', 
        params: {'driver_id': driverId.toString()});
      
      if (response['success'] == true) {
        final newEmergencies = response['emergencies'] ?? [];
        final wasEmpty = _activeEmergencies.isEmpty;
        setState(() {
          _activeEmergencies = newEmergencies;
        });

        if (newEmergencies.isNotEmpty) {
          final emergency = newEmergencies[0];
          // Always recalculate nearest hospital when a new emergency arrives
          if (wasEmpty) {
            final lat = double.tryParse(emergency['latitude']?.toString() ?? '') ?? 0;
            final lng = double.tryParse(emergency['longitude']?.toString() ?? '') ?? 0;
            if (lat != 0 && lng != 0) {
              _findNearestHospital(lat, lng);
            }
          }
          if (emergency['status'] == 'accepted') {
            _showEmergencyNotification(emergency);
          }
        } else {
          // No emergencies — clear nearest hospital
          if (_nearestHospital != null) setState(() => _nearestHospital = null);
        }
      }
    } catch (e) {
      print('Error loading emergencies: $e');
    } finally {
      setState(() => _isLoadingEmergencies = false);
    }
  }

  void _showEmergencyNotification(dynamic emergency) {
    if (_isShowingDialog) return;
    _isShowingDialog = true;
    
    final isArabic = Provider.of<AppProvider>(context, listen: false).isArabic;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? 'طوارئ جديدة!' : 'New Emergency!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${isArabic ? 'المريض' : 'Patient'}: ${emergency['first_name']} ${emergency['last_name']}'),
            const SizedBox(height: 8),
            Text('${isArabic ? 'فصيلة الدم' : 'Blood Type'}: ${emergency['blood_type'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('${isArabic ? 'الهاتف' : 'Phone'}: ${emergency['phone'] ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _isShowingDialog = false;
              Navigator.pop(ctx);
            },
            child: Text(isArabic ? 'لاحقاً' : 'Later'),
          ),
          ElevatedButton(
            onPressed: () {
              _isShowingDialog = false;
              Navigator.pop(ctx);
              _navigateToPatient(emergency);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(isArabic ? 'الانتقال للمريض' : 'Go to Patient'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToPatient(dynamic emergency) async {
    final patientLat = double.tryParse(emergency['latitude'].toString()) ?? 0;
    final patientLng = double.tryParse(emergency['longitude'].toString()) ?? 0;
    
    if (patientLat != 0 && patientLng != 0) {
      final patientPos = LatLng(patientLat, patientLng);
      
      // Fetch route
      var route = await RoutingService.getRoute(_currentPosition, patientPos);
      
      // Fallback
      if (route.isEmpty) {
        route = [_currentPosition, patientPos];
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Route data: ${route.length} points')),
        );
      }

      setState(() {
        _routePoints = route;
        _isTransporting = false;
      });

      // Center the map to show both driver and patient
      _mapController.move(LatLng((_currentPosition.latitude + patientLat) / 2, (_currentPosition.longitude + patientLng) / 2), 14.0);
      
      // Update status to let server know driver is moving
      _updateEmergencyStatus(int.parse(emergency['id'].toString()), 'in_progress');
    }
  }

  Future<void> _startTransportToHospital(dynamic emergency) async {
    if (_nearestHospital == null) {
      // Re-find nearest hospital just in case
      final patientLat = double.tryParse(emergency['latitude'].toString()) ?? 0;
      final patientLng = double.tryParse(emergency['longitude'].toString()) ?? 0;
      _findNearestHospital(patientLat, patientLng);
      // Wait a bit for the async call to finish (simplified)
      await Future.delayed(const Duration(seconds: 1));
    }

    if (_nearestHospital != null) {
      final h = _nearestHospital!;
      final hLat = (h['latitude'] as num).toDouble();
      final hLng = (h['longitude'] as num).toDouble();
      final hospitalPos = LatLng(hLat, hLng);

      var route = await RoutingService.getRoute(_currentPosition, hospitalPos);
      
      // Fallback
      if (route.isEmpty) {
        route = [_currentPosition, hospitalPos];
      }

      setState(() {
        _routePoints = route;
        _isTransporting = true;
      });

      _mapController.move(LatLng((_currentPosition.latitude + hLat) / 2, (_currentPosition.longitude + hLng) / 2), 14.0);
    }
  }

  Future<void> _updateEmergencyStatus(int emergencyId, String status) async {
    try {
      await ApiService.post('update_emergency_status', {
        'emergency_id': emergencyId,
        'status': status,
      });
    } catch (e) {
      print('Error updating emergency status: $e');
    }
  }

  Future<void> _completeEmergency(int emergencyId) async {
    await _updateEmergencyStatus(emergencyId, 'completed');
    setState(() {
      _activeEmergencies.removeWhere((e) => e['id'] == emergencyId);
      _nearestHospital = null;
      _routePoints = []; // Clear route
      _isTransporting = false; // Reset phase
    });
    
    // Return map to normal
    _mapController.move(_currentPosition, 14.0);
    
    final isArabic = Provider.of<AppProvider>(context, listen: false).isArabic;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isArabic ? 'تم إكمال المهمة بنجاح' : 'Mission completed successfully'),
        backgroundColor: AppColors.neonGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _startLocationTracking() async {
    if (_driver == null) return;  // 🔴 ADDED: Check if driver data exists
    
    final driverId = _driver?['id'];
    if (driverId != null) {
      LocationService.startTracking(
        userId: driverId,
        userType: 'driver',
      );
    }
  }

  Future<void> _initLocation() async {
    try {
      PermissionStatus status = await Permission.location.request();
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentPosition, 14.0);
        
        // Cancel any existing subscription before starting a new one
        await _locationSubscription?.cancel();
        
        _locationSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
        ).listen((Position newPos) {
          if (mounted && _isAutoGPS) {
            setState(() {
              _currentPosition = LatLng(newPos.latitude, newPos.longitude);
            });
          }
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    if (_isAutoGPS) return; 
    setState(() {
      _currentPosition = point;
    });
  }

  Future<void> _saveManualLocation() async {
    if (_driver == null) return;
    final driverId = _driver!['id'];

    await ApiService.post('update_location', {
      'user_id': driverId,
      'user_type': 'driver',
      'latitude': _currentPosition.latitude,
      'longitude': _currentPosition.longitude,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manual station saved to database'), backgroundColor: Colors.green),
    );
  }

  void _toggleLocationMode() {
    setState(() {
      _isAutoGPS = !_isAutoGPS;
    });
    if (_isAutoGPS) {
      _initLocation(); 
    }
  }

  void _toggleOnlineStatus() async {
    setState(() {
      _isOnline = !_isOnline;
    });

    if (_driver == null) {  // 🔴 ADDED: Check if driver data exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No driver data available')),
      );
      return;
    }
    
    final driverId = _driver?['id'];
    
    if (driverId != null) {
      try {
        await ApiService.post('update_driver_status', {
          'id': driverId,
          'is_online': _isOnline ? 1 : 0,
        });
      } catch (e) {
        print('Error updating status: $e');
      }

      if (_isOnline) {
        LocationService.startTracking(userId: driverId, userType: 'driver');
        _loadEmergencies();
      } else {
        LocationService.stopTracking();
        setState(() => _activeEmergencies = []);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOnline ? 'You are now ONLINE' : 'You are now OFFLINE'),
        backgroundColor: _isOnline ? Colors.green : Colors.grey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Load hospitals from live API ───────────────────────────────────────────
  Future<void> _loadHospitalsFromApi() async {
    setState(() => _isLoadingHospitals = true);
    try {
      final response = await ApiService.get('get_hospitals');
      if (response['success'] == true) {
        final List<dynamic> raw = response['hospitals'] ?? [];
        setState(() {
          _hospitals = raw.cast<Map<String, dynamic>>();
          _isLoadingHospitals = false;
        });
      }
    } catch (e) {
      print('Hospital load error: $e');
      setState(() => _isLoadingHospitals = false);
    }
  }

  // ─── Find nearest hospital to a given point ──────────────────────────────────
  void _findNearestHospital(double emergencyLat, double emergencyLng) async {
    try {
      final response = await ApiService.get('get_nearest_hospital', params: {
        'lat': emergencyLat.toString(),
        'lng': emergencyLng.toString(),
      });
      if (response['success'] == true && response['hospital'] != null) {
        setState(() {
          _nearestHospital = response['hospital'] as Map<String, dynamic>;
        });
        // Briefly show the nearest hospital on map
        final h = _nearestHospital!;
        final hLat = (h['latitude'] as num).toDouble();
        final hLng = (h['longitude'] as num).toDouble();
        // Fit camera to show both emergency and hospital
        final midLat = (emergencyLat + hLat) / 2;
        final midLng = (emergencyLng + hLng) / 2;
        _mapController.move(LatLng(midLat, midLng), 12.0);
      }
    } catch (e) {
      print('Nearest hospital error: $e');
    }
  }

  // ─── Build hospital markers with nearest highlighted ────────────────────────
  List<Marker> _buildHospitalMarkers() {
    return _hospitals.map((h) {
      final lat = (h['latitude'] as num?)?.toDouble();
      final lng = (h['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;

      final isNearest = _nearestHospital != null &&
          _nearestHospital!['id'] == h['id'];

      final markerColor = isNearest ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
      final markerSize  = isNearest ? 48.0 : 36.0;

      return Marker(
        point: LatLng(lat, lng),
        width: markerSize,
        height: markerSize + (isNearest ? 16 : 0),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showHospitalDetails(h, isNearest),
          child: Column(
            children: [
              Container(
                width: markerSize,
                height: markerSize,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isNearest ? Colors.white : Colors.white70,
                    width: isNearest ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: markerColor.withOpacity(isNearest ? 0.6 : 0.3),
                      blurRadius: isNearest ? 14 : 6,
                      spreadRadius: isNearest ? 3 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  isNearest ? Icons.local_hospital : Icons.local_hospital_outlined,
                  color: Colors.white,
                  size: isNearest ? 24 : 18,
                ),
              ),
              if (isNearest)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEAREST',
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      );
    }).whereType<Marker>().toList();
  }

  void _showHospitalDetails(Map<String, dynamic> h, bool isNearest) {
    final isArabic = Provider.of<AppProvider>(context, listen: false).isArabic;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isNearest
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_hospital,
                    color: isNearest ? Colors.green : Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h['name'] ?? 'Hospital',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (isNearest)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isArabic ? '✅ أقرب مستشفى' : '✅ Nearest Hospital',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if ((h['city'] ?? '').toString().isNotEmpty)
              _detailRow(Icons.location_city, '${h['city']}, ${h['region'] ?? ''}'),
            if ((h['phone'] ?? '').toString().isNotEmpty)
              _detailRow(Icons.phone, h['phone']),
            if ((h['emergency_capacity'] ?? 0) > 0)
              _detailRow(Icons.bed, '${isArabic ? 'طاقة الطوارئ' : 'Emergency capacity'}: ${h['emergency_capacity']}'),
            if ((h['distance_km'] ?? 0) > 0)
              _detailRow(Icons.route, '${isArabic ? 'المسافة' : 'Distance'}: ${h['distance_km']} km'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _emergencyTimer?.cancel();
    LocationService.stopTracking();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isArabic = provider.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.midnightBlue,
        drawer: DriverProfileDrawer(
          isOnline: _isOnline,
          onToggleOnline: _toggleOnlineStatus,
          driverName: _driverName,  // 🔴 ADDED: Pass driver name
          driverEmail: _driverEmail,  // 🔴 ADDED: Pass driver email
        ),
        body: Stack(
          children: [
            // OpenStreetMap
            SizedBox.expand(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition,
                  initialZoom: 14.0,
                  maxZoom: 18.0,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                  onTap: _handleMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.ambulance_app',
                  ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: const Color(0xFFFF0000),
                          strokeWidth: 10.0,
                        ),
                      ],
                    ),
                  if (_routePoints.isNotEmpty)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _routePoints.first,
                          color: Colors.blue.withOpacity(0.5),
                          radius: 20,
                        ),
                        CircleMarker(
                          point: _routePoints.last,
                          color: Colors.red.withOpacity(0.5),
                          radius: 20,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      // Driver marker
                      Marker(
                        point: _currentPosition,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isAutoGPS ? Colors.blue : Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: (_isAutoGPS ? Colors.blue : Colors.orange).withOpacity(0.4),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Icon(
                            _isAutoGPS ? Icons.directions_car : Icons.location_on,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      ..._buildEmergencyMarkers(),
                      ..._buildHospitalMarkers(),
                    ],
                  ),
                  if (_isLoadingHospitals || _isLoadingEmergencies)
                    const Center(child: CircularProgressIndicator()),
                  
                  // Debug Route Indicator
                  Positioned(
                    top: 100,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      color: Colors.black54,
                      child: Text(
                        'Route: ${_routePoints.length} pts',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_isOnline && _activeEmergencies.isNotEmpty)
              Positioned(
                top: MediaQuery.of(context).padding.top + 80,
                left: 16,
                right: 16,
                child: _buildEmergencyPanel(isArabic),
              ),

            // Nearest hospital banner — shows when emergency is active
            if (_isOnline && _activeEmergencies.isNotEmpty && _nearestHospital != null)
              Positioned(
                bottom: 130,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_hospital, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isArabic ? '🏥 أقرب مستشفى' : '🏥 Nearest Hospital',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _nearestHospital!['name'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if ((_nearestHospital!['distance_km'] ?? 0) > 0)
                              Text(
                                '${_nearestHospital!['distance_km']} km ${isArabic ? 'بعيد' : 'away'}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final h = _nearestHospital!;
                          final lat = (h['latitude'] as num?)?.toDouble();
                          final lng = (h['longitude'] as num?)?.toDouble();
                          if (lat != null && lng != null) {
                            _mapController.move(LatLng(lat, lng), 15.0);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.navigation, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleOnlineStatus,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _isOnline
                            ? Colors.green
                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isOnline ? Colors.white : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isOnline
                                ? (isArabic ? 'متصل' : 'ONLINE')
                                : (isArabic ? 'غير متصل' : 'OFFLINE'),
                            style: TextStyle(
                              color: _isOnline ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        if (_activeEmergencies.isNotEmpty)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${_activeEmergencies.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Mode & Location Controls
            Positioned(
              right: 16,
              bottom: 100,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleLocationMode,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isAutoGPS ? Colors.blue : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_isAutoGPS ? Icons.gps_fixed : Icons.edit_location, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _isAutoGPS ? (isArabic ? 'تلقائي' : 'AUTO') : (isArabic ? 'يدوي' : 'MANUAL'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _mapController.move(_currentPosition, 14.0);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.my_location,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Manual Save Button
            if (!_isAutoGPS)
              Positioned(
                bottom: 30,
                left: 16,
                right: 16,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveManualLocation,
                    icon: const Icon(Icons.save),
                    label: Text(isArabic ? 'حفظ الموقع المختار' : 'Save Station Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildEmergencyMarkers() {
    return _activeEmergencies.map((emergency) {
      final lat = double.tryParse(emergency['latitude'].toString()) ?? 0;
      final lng = double.tryParse(emergency['longitude'].toString()) ?? 0;
      
      if (lat == 0 || lng == 0) return null;
      
      return Marker(
        point: LatLng(lat, lng),
        width: 60,
        height: 60,
        child: GestureDetector(
          onTap: () => _showEmergencyNotification(emergency),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(color: Colors.red.withOpacity(0.6), blurRadius: 10)
                  ],
                ),
                child: const Icon(Icons.person_pin_circle, color: Colors.white, size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  emergency['first_name'] ?? 'Patient',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }).whereType<Marker>().toList();
  }

  Widget _buildEmergencyPanel(bool isArabic) {
    final emergency = _activeEmergencies.first;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.midnightBlue.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.rosePrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.rosePrimary.withOpacity(0.2),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: const Icon(Icons.emergency_share, color: AppColors.rosePrimary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isTransporting 
                              ? (isArabic ? 'نقل إلى المستشفى' : 'HOSPITAL TRANSPORT')
                              : (isArabic ? 'استجابة نشطة' : 'ACTIVE RESPONSE'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppColors.rosePrimary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '${emergency['first_name']} ${emergency['last_name']}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _isTransporting ? _startTransportToHospital(emergency) : _navigateToPatient(emergency),
                      icon: const Icon(Icons.navigation_rounded),
                      label: Text(
                        _isTransporting 
                            ? (isArabic ? 'طريق المستشفى' : 'HOSPITAL ROUTE')
                            : (isArabic ? 'طريق المريض' : 'PATIENT ROUTE'),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceBlue,
                        foregroundColor: AppColors.medicalCyan,
                        side: const BorderSide(color: AppColors.medicalCyan, width: 1.5),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!_isTransporting) {
                          _startTransportToHospital(emergency);
                        } else {
                          _completeEmergency(emergency['id']);
                        }
                      },
                      icon: Icon(_isTransporting ? Icons.check_circle : Icons.local_hospital),
                      label: Text(
                        _isTransporting 
                            ? (isArabic ? 'إكمال المهمة' : 'COMPLETE MISSION')
                            : (isArabic ? 'بدء النقل' : 'START TRANSPORT'),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTransporting ? AppColors.neonGreen : AppColors.rosePrimary,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: (_isTransporting ? AppColors.neonGreen : AppColors.rosePrimary).withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== DRIVER PROFILE DRAWER ====================
class DriverProfileDrawer extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggleOnline;
  final String driverName;  // 🔴 ADDED
  final String driverEmail;  // 🔴 ADDED

  const DriverProfileDrawer({
    super.key,
    required this.isOnline,
    required this.onToggleOnline,
    required this.driverName,  // 🔴 ADDED
    required this.driverEmail,  // 🔴 ADDED
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isArabic = provider.isArabic;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.person, size: 32, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔴 UPDATED: Show actual driver name
                            Text(
                              driverName,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            // 🔴 ADDED: Show driver email
                            Text(
                              driverEmail,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isOnline ? (isArabic ? 'متصل' : 'ONLINE') : (isArabic ? 'غير متصل' : 'OFFLINE'),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    title: isArabic ? 'الملف الشخصي' : 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DriverProfileScreen()),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.history,
                    title: isArabic ? 'السجل' : 'History',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.notifications,
                    title: isArabic ? 'الإشعارات' : 'Notifications',
                    badge: '3',
                    onTap: () {},
                  ),
                  const Divider(height: 32),
                  _MenuItem(
                    icon: Icons.dark_mode,
                    title: isArabic ? 'المظهر' : 'Theme',
                    subtitle: Theme.of(context).brightness == Brightness.dark
                        ? (isArabic ? 'داكن' : 'Dark')
                        : (isArabic ? 'فاتح' : 'Light'),
                    onTap: () {
                      provider.setThemeMode(
                        provider.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.language,
                    title: isArabic ? 'اللغة' : 'Language',
                    subtitle: isArabic ? 'العربية' : 'English',
                    onTap: () => provider.toggleLanguage(),
                  ),
                  _MenuItem(
                    icon: Icons.settings,
                    title: isArabic ? 'الإعدادات' : 'Settings',
                    onTap: () {},
                  ),
                  const Divider(height: 32),
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: isArabic ? 'المساعدة' : 'Help',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.logout,
                    title: isArabic ? 'تسجيل الخروج' : 'Logout',
                    color: Colors.red,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(isArabic ? 'تسجيل الخروج' : 'Logout'),
                          content: Text(
                            isArabic 
                                ? 'هل أنت متأكد من تسجيل الخروج؟' 
                                : 'Are you sure you want to logout?'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RoleSelectionScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(isArabic ? 'تسجيل الخروج' : 'Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (color ?? const Color(0xFFDC2626)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? const Color(0xFFDC2626), size: 22),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 12)) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
              child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
        ],
      ),
      onTap: onTap,
    );
  }
}