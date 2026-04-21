import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/auth_scaffold.dart';
import '../../core/widgets/auth_text_field.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'driver_dashboard_screen.dart';

class DriverAuthScreen extends StatefulWidget {
  const DriverAuthScreen({super.key});

  @override
  State<DriverAuthScreen> createState() => _DriverAuthScreenState();
}

class _DriverAuthScreenState extends State<DriverAuthScreen> {
  bool isLogin = true;
  bool _isLoading = false;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.post('driver_register', {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'license_number': _licenseController.text.trim(),
        'vehicle_number': _vehicleController.text.trim(),
      });
      
      if (response['success'] == true) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DriverDashboardScreen(driverData: response['driver'])),
          );
        }
      } else {
        _showError(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _showError('Connection error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.post('driver_login', {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });
      
      if (response['success'] == true) {
        final driverData = response['driver'] ?? response['user'];
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DriverDashboardScreen(driverData: driverData)),
          );
        }
      } else {
        _showError(response['message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      _showError('Connection error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.rosePrimary),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _vehicleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: isLogin ? 'Driver Login' : 'Driver Registration',
      subtitle: 'Ambulance driver portal access',
      form: Column(
        children: [
          // Modern Toggle
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                _buildToggleButton('Sign In', isLogin, () => setState(() => isLogin = true)),
                _buildToggleButton('Register', !isLogin, () => setState(() => isLogin = false)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLogin ? _buildLoginForm() : _buildRegisterForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String title, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.medicalCyan : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active ? [BoxShadow(color: AppColors.medicalCyan.withOpacity(0.3), blurRadius: 10)] : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.black : AppColors.textSecondary,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      children: [
        AuthTextField(
          label: 'Email Address',
          hint: 'Enter your email',
          prefixIcon: Icons.email_rounded,
          controller: _emailController,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: 'Security Password',
          hint: 'Enter your password',
          prefixIcon: Icons.lock_rounded,
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _signIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.medicalCyan,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: AppColors.medicalCyan.withOpacity(0.4),
          ),
          child: _isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Text('ACCESS PORTAL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      children: [
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                label: 'First Name',
                hint: 'Name',
                prefixIcon: Icons.person_rounded,
                controller: _firstNameController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuthTextField(
                label: 'Last Name',
                hint: 'Surname',
                prefixIcon: Icons.person_rounded,
                controller: _lastNameController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: 'Email',
          hint: 'Enter your email',
          prefixIcon: Icons.email_rounded,
          controller: _emailController,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: 'Phone',
          hint: 'Enter phone number',
          prefixIcon: Icons.phone_rounded,
          controller: _phoneController,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: 'License Number',
          hint: 'Enter ID/License',
          prefixIcon: Icons.badge_rounded,
          controller: _licenseController,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: 'Vehicle Plate',
          hint: 'Enter plate number',
          prefixIcon: Icons.local_shipping_rounded,
          controller: _vehicleController,
        ),
        const SizedBox(height: 20),
        AuthTextField(
          label: 'Password',
          hint: 'Create password',
          prefixIcon: Icons.lock_rounded,
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _signUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.rosePrimary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: AppColors.rosePrimary.withOpacity(0.4),
          ),
          child: _isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
      ],
    );
  }
}