import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/api_service.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isLoadingData = true;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _licenseController;
  late TextEditingController _vehicleController;
  
  int? _driverId;
  double? _rating;
  int? _totalTrips;
  bool _isOnline = false;
  String? _joinDate;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _licenseController = TextEditingController();
    _vehicleController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _driverId = prefs.getInt('driver_id');
    
    if (_driverId != null) {
      try {
        final response = await ApiService.get('get_driver_profile', 
          params: {'id': _driverId.toString()});
        
        if (response['success'] == true) {
          final data = response['data'];
          setState(() {
            _firstNameController.text = data['first_name'] ?? '';
            _lastNameController.text = data['last_name'] ?? '';
            _emailController.text = data['email'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _licenseController.text = data['license_number'] ?? '';
            _vehicleController.text = data['vehicle_number'] ?? '';
            _isOnline = data['is_online'] == 1;
            _rating = double.tryParse(data['rating'].toString()) ?? 5.0;
            _totalTrips = data['total_trips'] ?? 0;
            _joinDate = data['created_at'];
            _isLoadingData = false;
          });
        }
      } catch (e) {
        print('Error loading driver profile: $e');
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_driverId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final response = await ApiService.post('update_driver_profile', {
        'id': _driverId,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone': _phoneController.text,
        'license_number': _licenseController.text,
        'vehicle_number': _vehicleController.text,
        'is_online': _isOnline ? 1 : 0,
      });
      
      if (response['success'] == true) {
        setState(() => _isEditing = false);
        _loadUserData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isArabic = provider.isArabic;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoadingData) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.directions_car,
                                size: 45,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _isOnline ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_firstNameController.text} ${_lastNameController.text}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isArabic ? 'سائق إسعاف' : 'Ambulance Driver',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < (_rating?.floor() ?? 5)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${_rating ?? 5.0}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.close : Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_isEditing) _loadUserData();
                      _isEditing = !_isEditing;
                    });
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCards(isArabic, colorScheme),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      isArabic ? 'المعلومات الشخصية' : 'Personal Information',
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildPersonalInfoCard(colorScheme, isDark),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      isArabic ? 'المعلومات المهنية' : 'Professional Information',
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildProfessionalInfoCard(colorScheme, isDark),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      isArabic ? 'معلومات الحساب' : 'Account Information',
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildAccountInfoCard(colorScheme, isDark),
                    const SizedBox(height: 32),
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveProfile,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            isArabic ? 'حفظ التغييرات' : 'Save Changes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isArabic, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_taxi,
            value: (_totalTrips ?? 0).toString(),
            label: isArabic ? 'رحلة' : 'Trips',
            color: const Color(0xFFDC2626),
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today,
            value: _calculateMemberSince(),
            label: isArabic ? 'عضو منذ' : 'Member Since',
            color: Colors.blue,
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.star,
            value: '${_rating ?? 5.0}',
            label: isArabic ? 'التقييم' : 'Rating',
            color: Colors.amber,
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ],
    );
  }

  String _calculateMemberSince() {
    if (_joinDate == null) return '0d';
    final joinDate = DateTime.parse(_joinDate!);
    final now = DateTime.now();
    final difference = now.difference(joinDate);
    
    if (difference.inDays < 30) return '${difference.inDays}d';
    if (difference.inDays < 365) return '${difference.inDays ~/ 30}m';
    return '${difference.inDays ~/ 365}y';
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPersonalInfoCard(ColorScheme colorScheme, bool isDark) {
    return _buildCard(
      isDark: isDark,
      children: [
        _buildInfoRow(
          icon: Icons.person_outline,
          label: 'First Name',
          value: _firstNameController.text,
          controller: _firstNameController,
          isEditing: _isEditing,
          colorScheme: colorScheme,
        ),
        const Divider(height: 24),
        _buildInfoRow(
          icon: Icons.person_outline,
          label: 'Last Name',
          value: _lastNameController.text,
          controller: _lastNameController,
          isEditing: _isEditing,
          colorScheme: colorScheme,
        ),
        const Divider(height: 24),
        _buildInfoRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: _phoneController.text,
          controller: _phoneController,
          isEditing: _isEditing,
          colorScheme: colorScheme,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoCard(ColorScheme colorScheme, bool isDark) {
    return _buildCard(
      isDark: isDark,
      children: [
        _buildInfoRow(
          icon: Icons.badge_outlined,
          label: 'License Number',
          value: _licenseController.text,
          controller: _licenseController,
          isEditing: _isEditing,
          colorScheme: colorScheme,
        ),
        const Divider(height: 24),
        _buildInfoRow(
          icon: Icons.local_shipping_outlined,
          label: 'Vehicle Number',
          value: _vehicleController.text,
          controller: _vehicleController,
          isEditing: _isEditing,
          colorScheme: colorScheme,
        ),
        const Divider(height: 24),
        _buildStatusRow(colorScheme),
      ],
    );
  }

  Widget _buildAccountInfoCard(ColorScheme colorScheme, bool isDark) {
    return _buildCard(
      isDark: isDark,
      children: [
        _buildInfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: _emailController.text,
          isEditing: false,
          colorScheme: colorScheme,
        ),
        const Divider(height: 24),
        _buildInfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'Member Since',
          value: _joinDate?.split(' ')[0] ?? '',
          isEditing: false,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildStatusRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (_isOnline ? Colors.green : Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _isOnline ? Icons.circle : Icons.circle_outlined,
            color: _isOnline ? Colors.green : Colors.grey,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              if (_isEditing)
                Switch(
                  value: _isOnline,
                  onChanged: (value) => setState(() => _isOnline = value),
                  activeThumbColor: Colors.green,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (_isOnline ? Colors.green : Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (_isOnline ? Colors.green : Colors.grey).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    TextEditingController? controller,
    required bool isEditing,
    required ColorScheme colorScheme,
    TextInputType? keyboardType,
  }) {
    if (isEditing && controller != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: colorScheme.onSurface.withOpacity(0.6)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFDC2626), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black54)),
        ],
      ),
    );
  }
}