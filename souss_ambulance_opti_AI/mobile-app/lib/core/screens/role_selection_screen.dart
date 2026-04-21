import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../../core/providers/app_provider.dart';
import '../../patient/screens/patient_auth_screen.dart';
import '../../driver/screens/driver_auth_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isArabic = provider.isArabic;

    final roles = [
      RoleItem(
        title: isArabic ? 'المريض' : 'Patient',
        subtitle: isArabic ? 'طلب إسعاف فوري' : 'Instant Emergency Request',
        icon: Icons.personal_injury_rounded,
        accentColor: AppColors.rosePrimary,
        gradient: [AppColors.rosePrimary, AppColors.roseSecondary],
      ),
      RoleItem(
        title: isArabic ? 'السائق' : 'Driver',
        subtitle: isArabic ? 'نظام تتبع المهام' : 'Mission Tracking System',
        icon: Icons.emergency_rounded,
        accentColor: AppColors.medicalCyan,
        gradient: [AppColors.medicalCyan, const Color(0xFF0891B2)],
      ),
      RoleItem(
        title: isArabic ? 'المستشفى' : 'Hospital',
        subtitle: isArabic ? 'إدارة الأسرة والطوارئ' : 'Bed & ER Management',
        icon: Icons.local_hospital_rounded,
        accentColor: AppColors.neonGreen,
        gradient: [AppColors.neonGreen, const Color(0xFF059669)],
      ),
    ];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.midnightBlue,
        body: Stack(
          children: [
            const ModernBackground(),
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(isArabic, provider),
                          const SizedBox(height: 40),
                          _buildTitle(isArabic),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: RoleCard(
                            role: roles[index],
                            isArabic: isArabic,
                            onTap: () => _navigateToRole(context, index),
                          ),
                        ),
                        childCount: roles.length,
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildEmergencyAction(isArabic),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isArabic, AppProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'أطلس للطوارئ' : 'ATLAS EMERGENCY',
              style: const TextStyle(
                color: AppColors.medicalCyan,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Container(height: 2, width: 40, color: AppColors.rosePrimary),
          ],
        ),
        _GlassIconButton(
          icon: Icons.language_rounded,
          onTap: () => provider.toggleLanguage(),
        ),
      ],
    );
  }

  Widget _buildTitle(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'اختر هويتك' : 'Select Identity',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isArabic 
              ? 'يرجى تحديد دورك للوصول إلى الخدمات المناسبة' 
              : 'Please select your role to access specialized services',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildEmergencyAction(bool isArabic) {
    return GestureDetector(
      onTap: () => _showEmergencyDialog(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.rosePrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.rosePrimary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: AppColors.rosePrimary, shape: BoxShape.circle),
                  child: const Icon(Icons.phone_in_talk_rounded, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'مساعدة فورية؟' : 'Need Help Now?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        isArabic ? 'اضغط للاتصال المباشر بالطوارئ' : 'Tap for immediate emergency call',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.rosePrimary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToRole(BuildContext context, int index) async {
    if (index == 2) {
      final Uri url = Uri.parse('http://127.0.0.1:8000/login/?next=/'); 
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else {
      final screens = [const PatientAuthScreen(), const DriverAuthScreen()];
      Navigator.push(context, MaterialPageRoute(builder: (_) => screens[index]));
    }
  }

  void _showEmergencyDialog(BuildContext context) {
    final isArabic = context.read<AppProvider>().isArabic;
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppColors.midnightBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: AppColors.rosePrimary.withOpacity(0.3))),
          title: Text(isArabic ? 'اتصال طوارئ' : 'Emergency Call', style: const TextStyle(color: Colors.white)),
          content: Text(
            isArabic ? 'هل تريد الاتصال بخدمة الإسعاف الآن؟' : 'Do you want to call the ambulance service now?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(isArabic ? 'إلغاء' : 'Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosePrimary),
              child: Text(isArabic ? 'اتصل الآن' : 'Call Now'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final RoleItem role;
  final bool isArabic;
  final VoidCallback onTap;

  const RoleCard({super.key, required this.role, required this.isArabic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: isArabic ? null : -20,
                  left: isArabic ? -20 : null,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(color: role.accentColor.withOpacity(0.1), shape: BoxShape.circle),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: role.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: role.accentColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Icon(role.icon, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(role.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(role.subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class ModernBackground extends StatelessWidget {
  const ModernBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(width: 300, height: 300, decoration: BoxDecoration(color: AppColors.rosePrimary.withOpacity(0.05), shape: BoxShape.circle)),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(width: 200, height: 200, decoration: BoxDecoration(color: AppColors.medicalCyan.withOpacity(0.05), shape: BoxShape.circle)),
        ),
      ],
    );
  }
}

class RoleItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradient;

  RoleItem({required this.title, required this.subtitle, required this.icon, required this.accentColor, required this.gradient});
}