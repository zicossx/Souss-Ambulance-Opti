import 'package:flutter/material.dart';
import '../../core/widgets/auth_scaffold.dart';
import '../../core/widgets/auth_text_field.dart';

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
      title: 'Hospital Staff',
      subtitle: 'Secure medical dashboard access',
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            // Segmented Control
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFBFDBFE)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    _buildSegment('Sign In', isLogin, () => setState(() => isLogin = true)),
                    _buildSegment('Register', !isLogin, () => setState(() => isLogin = false)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            AnimatedCrossFade(
              firstChild: _buildLoginForm(),
              secondChild: _buildRegisterForm(),
              crossFadeState: isLogin 
                ? CrossFadeState.showFirst 
                : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        const AuthTextField(
          label: 'Hospital ID',
          hint: 'Enter hospital ID',
          prefixIcon: Icons.local_hospital_outlined,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Staff ID / Email',
          hint: 'Enter your staff ID',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Password',
          hint: 'Enter password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
          child: const Text('Access Dashboard'),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        const AuthTextField(
          label: 'Hospital Name',
          hint: 'Enter hospital name',
          prefixIcon: Icons.local_hospital_outlined,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Registration Number',
          hint: 'Hospital registration ID',
          prefixIcon: Icons.numbers_outlined,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Admin Email',
          hint: 'Enter admin email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Create Password',
          hint: 'Create secure password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
          child: const Text('Register Hospital'),
        ),
      ],
    );
  }
}