import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ADDED
import '../../core/providers/app_provider.dart';
import '../../core/services/location_service.dart'; // ADDED
import 'patient_profile_screen.dart';
import 'patient_auth_screen.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import 'dart:async'; // Added

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(30.4720, -8.8770); // Taroudant default

  bool _isAutoGPS = true; // Added
  StreamSubscription<Position>? _locationSubscription; // Added

  @override
  void initState() {
    super.initState();
    _initLocation();
    _startLocationTracking(); // ADDED THIS LINE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_currentPosition, 14.0);
    });
  }

  // ADDED THIS METHOD
  Future<void> _startLocationTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final patientId = prefs.getInt('patient_id');
    if (patientId != null) {
      LocationService.startTracking(
        userId: patientId,
        userType: 'patient',
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

  void _showEmergencyRequest() async {
  final prefs = await SharedPreferences.getInstance();
  final patientId = prefs.getInt('patient_id');
  
  if (patientId == null) return;

  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final response = await ApiService.post('create_emergency', {
      'patient_id': patientId,
      'latitude': _currentPosition.latitude,
      'longitude': _currentPosition.longitude,
    });

    Navigator.pop(context); // Close loading

    if (response['success'] == true) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ambulance Dispatched'),
          content: Text('Driver assigned! Distance: ${response['distance']} km'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      _showError(response['message'] ?? 'No drivers available');
    }
  } catch (e) {
    Navigator.pop(context);
    _showError('Connection error');
  }
}

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.roseSecondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    if (_isAutoGPS) return; // Ignore taps in Auto mode
    setState(() {
      _currentPosition = point;
    });
  }

  Future<void> _saveManualLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final patientId = prefs.getInt('patient_id');
    
    if (patientId == null) return;

    await ApiService.post('update_location', {
      'user_id': patientId,
      'user_type': 'patient',
      'latitude': _currentPosition.latitude,
      'longitude': _currentPosition.longitude,
    });

    final isArabic = Provider.of<AppProvider>(context, listen: false).isArabic;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isArabic ? 'تم حفظ الموقع يدوياً' : 'Manual location saved to database'),
        backgroundColor: AppColors.neonGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleLocationMode() {
    setState(() {
      _isAutoGPS = !_isAutoGPS;
    });
    if (_isAutoGPS) {
      _initLocation(); // Force refresh GPS when switching back
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
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
        drawer: _PatientDrawer(isArabic: isArabic, provider: provider),
        body: Stack(
          children: [
            // Map Background
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
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isAutoGPS ? Colors.red : Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: (_isAutoGPS ? Colors.red : Colors.orange).withOpacity(0.4), 
                                blurRadius: 10
                              )
                            ],
                          ),
                          child: Icon(
                            _isAutoGPS ? Icons.person : Icons.location_on, 
                            color: Colors.white, 
                            size: 24
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Profile Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: GestureDetector(
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
            ),
            // Mode Toggle Button
            Positioned(
              right: 16,
              bottom: 160,
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
            // Manual Confirm Button
            if (!_isAutoGPS)
              Positioned(
                bottom: 100,
                left: 16,
                right: 16,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveManualLocation,
                    icon: const Icon(Icons.save),
                    label: Text(isArabic ? 'حفظ الموقع المختار' : 'Save Selected Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ),
            // Emergency Button
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _EmergencyButton(
                onTap: _showEmergencyRequest,
                isArabic: isArabic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Emergency Button ====================
class _EmergencyButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isArabic;

  const _EmergencyButton({required this.onTap, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDC2626).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emergency, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'طلب إسعاف' : 'REQUEST AMBULANCE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    isArabic ? 'اضغط للحصول على المساعدة' : 'Tap for immediate help',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
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

// ==================== Patient Drawer ====================
class _PatientDrawer extends StatelessWidget {
  final bool isArabic;
  final AppProvider provider;

  const _PatientDrawer({required this.isArabic, required this.provider});

  @override
  Widget build(BuildContext context) {
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
              child: Row(
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
                        Text(
                          isArabic ? 'مريض' : 'Patient',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            isArabic ? 'متصل' : 'Online',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _DrawerMenuItem(
                    icon: Icons.person_outline,
                    title: isArabic ? 'الملف الشخصي' : 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PatientProfileScreen()),
                      );
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.history,
                    title: isArabic ? 'السجل' : 'History',
                    onTap: () {},
                  ),
                  const Divider(height: 32),
                  _DrawerMenuItem(
                    icon: Icons.dark_mode,
                    title: isArabic ? 'المظهر' : 'Theme',
                    subtitle: Theme.of(context).brightness == Brightness.dark
                        ? (isArabic ? 'داكن' : 'Dark')
                        : (isArabic ? 'فاتح' : 'Light'),
                    onTap: () {
                      provider.setThemeMode(
                        provider.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.language,
                    title: isArabic ? 'اللغة' : 'Language',
                    subtitle: isArabic ? 'العربية' : 'English',
                    onTap: () {
                      provider.toggleLanguage();
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(height: 32),
                  _DrawerMenuItem(
                    icon: Icons.logout,
                    title: isArabic ? 'تسجيل الخروج' : 'Logout',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(isArabic ? 'تسجيل الخروج' : 'Logout'),
                          content: Text(isArabic ? 'هل أنت متأكد من تسجيل الخروج؟' : 'Are you sure you want to logout?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isArabic ? 'إلغاء' : 'Cancel')),
                            ElevatedButton(
                              onPressed: () async {
                                // Clear session data
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.remove('patient_id');
                                
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const PatientAuthScreen()),
                                    (route) => false,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
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
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
      onTap: onTap,
    );
  }
}