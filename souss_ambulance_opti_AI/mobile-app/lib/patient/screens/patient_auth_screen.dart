import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/providers/app_provider.dart';
import '../../patient/screens/patient_dashboard_screen.dart';

class PatientAuthScreen extends StatefulWidget {
  const PatientAuthScreen({super.key});

  @override
  State<PatientAuthScreen> createState() => _PatientAuthScreenState();
}

class _PatientAuthScreenState extends State<PatientAuthScreen> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();
    final isArabic = provider.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Back Button
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300,
                          ),
                        ),
                        child: Icon(
                          isArabic ? Icons.arrow_forward : Icons.arrow_back,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Logo
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.health_and_safety,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ATLAS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: 2,
                          ),
                        ),
                        const Text(
                          'PATIENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFDC2626),
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Title
                Text(
                  isLogin ? l10n.welcomeBack : l10n.createAccount,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  isLogin 
                    ? 'Sign in to request emergency services'
                    : 'Create an account to get help quickly',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                
                const SizedBox(height: 32),
                
                // Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isLogin = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isLogin 
                                ? const Color(0xFFDC2626)
                                : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.signIn,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isLogin ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: !isLogin 
                                ? const Color(0xFFDC2626)
                                : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.signUp,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !isLogin ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
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
                
                // Form - Pass isArabic to both forms
                AnimatedCrossFade(
                  firstChild: _buildLoginForm(l10n, isArabic),  // <-- Pass isArabic
                  secondChild: _buildRegisterForm(l10n, isArabic),  // <-- Pass isArabic
                  crossFadeState: isLogin 
                    ? CrossFadeState.showFirst 
                    : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 300),
                ),
                
                const SizedBox(height: 24),
                
                // Social Auth
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.orContinueWith,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        icon: Icons.g_mobiledata,
                        color: Colors.red,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SocialButton(
                        icon: Icons.apple,
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FIX: Add isArabic parameter
  Widget _buildLoginForm(AppLocalizations l10n, bool isArabic) {
    return Column(
      children: [
        _buildTextField(
          label: l10n.email,
          hint: 'Enter your email or phone',
          icon: Icons.email_outlined,
          controller: _emailController,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: l10n.password,
          hint: 'Enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,  // FIX: RTL alignment
          child: TextButton(
            onPressed: () {},
            child: Text(
              l10n.forgotPassword,
              style: const TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PatientDashboardScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.signIn),
        ),
      ],
    );
  }

  // FIX: Add isArabic parameter
  Widget _buildRegisterForm(AppLocalizations l10n, bool isArabic) {
    return Column(
      children: [
        _buildTextField(
          label: l10n.fullName,
          hint: 'Enter your full name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: l10n.email,
          hint: 'Enter your email',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: l10n.phone,
          hint: 'Enter your phone number',
          icon: Icons.phone_outlined,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: l10n.password,
          hint: 'Create a password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PatientDashboardScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.signUp),  // FIX: Use l10n.signUp instead of isArabic check
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300,
          ),
        ),
        child: Icon(icon, size: 28, color: color),
      ),
    );
  }
}