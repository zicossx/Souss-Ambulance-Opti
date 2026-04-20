import 'package:flutter/material.dart';
import '../../core/widgets/auth_scaffold.dart';
import '../../core/widgets/auth_text_field.dart';
import '../../driver/screens/driver_dashboard_screen.dart';
import '../../l10n/generated/app_localizations.dart';

class DriverAuthScreen extends StatefulWidget {
  const DriverAuthScreen({super.key});

  @override
  State<DriverAuthScreen> createState() => _DriverAuthScreenState();
}

class _DriverAuthScreenState extends State<DriverAuthScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: isLogin ? 'Driver Login' : 'Driver Registration',
      subtitle: 'Ambulance driver portal access',
      form: Column(
        children: [
          // Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isLogin = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isLogin
                            ? const Color(0xFF059669)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Sign In',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              isLogin ? Colors.white : const Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isLogin = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isLogin
                            ? const Color(0xFF059669)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Register',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              !isLogin ? Colors.white : const Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Form
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLogin ? _buildLoginForm() : _buildRegisterForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      children: [
        const AuthTextField(
          label: 'Driver ID / License',
          hint: 'Enter your driver ID',
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Password',
          hint: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(value: false, onChanged: (v) {}),
            const Text('Remember me'),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot?',
                style: TextStyle(color: Color(0xFF059669)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF059669),
            foregroundColor: Colors.white,
          ),
          child: const Text('Access Portal'),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      children: [
        const AuthTextField(
          label: 'Full Name',
          hint: 'Enter your full name',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Driver License Number',
          hint: 'Enter license number',
          prefixIcon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Phone',
          hint: 'Enter phone number',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        const AuthTextField(
          label: 'Password',
          hint: 'Create password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        // Find the login button and change onPressed:
       ElevatedButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DriverDashboardScreen(),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF059669),
    foregroundColor: Colors.white,
  ),
  child: Text(AppLocalizations.of(context)!.signIn),  // Direct use
),
      ],
    );
  }
}
