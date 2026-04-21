import 'package:flutter/material.dart';
import '../../core/widgets/auth_scaffold.dart';
import '../../core/widgets/auth_text_field.dart';
import '../../core/theme/app_colors.dart';

class HospitalAuthScreen extends StatefulWidget {
  const HospitalAuthScreen({super.key});

  @override
  State<HospitalAuthScreen> createState() => _HospitalAuthScreenState();
}

class _HospitalAuthScreenState extends State<HospitalAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Hospital Portal',
      subtitle: 'Secure medical dashboard access',
      form: Form(
        key: _formKey,
        child: Column(
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
            color: active ? AppColors.neonGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active ? [BoxShadow(color: AppColors.neonGreen.withOpacity(0.3), blurRadius: 10)] : null,
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
        const AuthTextField(
          label: 'Hospital ID',
          hint: 'Enter hospital ID',
          prefixIcon: Icons.local_hospital_rounded,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Staff credentials',
          hint: 'Enter your staff ID',
          prefixIcon: Icons.badge_rounded,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Password',
          hint: 'Enter password',
          prefixIcon: Icons.lock_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonGreen,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: AppColors.neonGreen.withOpacity(0.4),
          ),
          child: const Text('ACCESS DASHBOARD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      children: [
        const AuthTextField(
          label: 'Hospital Name',
          hint: 'Enter hospital name',
          prefixIcon: Icons.local_hospital_rounded,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Registration ID',
          hint: 'Hospital registration ID',
          prefixIcon: Icons.app_registration_rounded,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Admin Email',
          hint: 'Enter admin email',
          prefixIcon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Create Password',
          hint: 'Create secure password',
          prefixIcon: Icons.lock_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonGreen,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: AppColors.neonGreen.withOpacity(0.4),
          ),
          child: const Text('REGISTER INSTITUTION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
      ],
    );
  }
}