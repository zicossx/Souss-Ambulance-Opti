import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/auth_scaffold.dart';
import '../../core/widgets/auth_text_field.dart';
import '../../core/theme/app_colors.dart';
import 'patient_dashboard_screen.dart';

class PatientAuthScreen extends StatefulWidget {
  const PatientAuthScreen({super.key});

  @override
  State<PatientAuthScreen> createState() => _PatientAuthScreenState();
}

class _PatientAuthScreenState extends State<PatientAuthScreen> {
  bool isLogin = true;
  bool _isLoading = false;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedBloodType;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown'];

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.post('patient_register', {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'blood_type': _selectedBloodType ?? 'Unknown',
      });
      
      if (response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('patient_id', response['user_id']);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PatientDashboardScreen()));
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
      final response = await ApiService.post('patient_login', {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });
      
      if (response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('patient_id', response['user']['id']);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PatientDashboardScreen()));
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
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: isLogin ? 'Welcome Back' : 'Get Help Fast',
      subtitle: isLogin ? 'Sign in to access emergency services' : 'Create an account for instant support',
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
            color: active ? AppColors.rosePrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active ? [BoxShadow(color: AppColors.rosePrimary.withOpacity(0.3), blurRadius: 10)] : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
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
          label: 'Password',
          hint: 'Enter your password',
          prefixIcon: Icons.lock_rounded,
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _signIn,
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
              : const Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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
          label: 'Age',
          hint: 'Enter your age',
          prefixIcon: Icons.calendar_today_rounded,
          controller: _ageController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildBloodTypeDropdown(),
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

  Widget _buildBloodTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BLOOD TYPE',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.medicalCyan, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedBloodType,
              dropdownColor: AppColors.midnightBlue,
              hint: Text('Select blood type', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.medicalCyan),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              items: _bloodTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (val) => setState(() => _selectedBloodType = val),
            ),
          ),
        ),
      ],
    );
  }
}