import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../patient/screens/patient_auth_screen.dart';
import '../../driver/screens/driver_auth_screen.dart';
import '../../hospital/screens/hospital_auth_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = provider.isArabic;

    final AppColors colors = isDark ? DarkColors() : LightColors();

    final roles = [
      RoleItem(
        title: isArabic ? 'المريض' : 'Patient',
        subtitle: isArabic ? 'اطلب إسعاف طوارئ' : 'Request emergency ambulance',
        icon: Icons.emergency_outlined,
        gradient: colors.patientGradient,
        accentColor: colors.patientAccent,
      ),
      RoleItem(
        title: isArabic ? 'السائق' : 'Driver',
        subtitle: isArabic ? 'بوابة سائق الإسعاف' : 'Ambulance driver portal',
        icon: Icons.local_shipping_outlined,
        gradient: colors.driverGradient,
        accentColor: colors.driverAccent,
      ),
      RoleItem(
        title: isArabic ? 'المستشفى' : 'Hospital',
        subtitle:
            isArabic ? 'لوحة تحكم الطاقم الطبي' : 'Medical staff dashboard',
        icon: Icons.local_hospital_outlined,
        gradient: colors.hospitalGradient,
        accentColor: colors.hospitalAccent,
      ),
    ];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [
            BackgroundShapes(colors: colors),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ModernHeader(
                      isArabic: isArabic,
                      provider: provider,
                      colors: colors,
                      onSettingsTap: () => _showSettings(context),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: roles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final role = roles[index];
                          final isHovered = hoveredIndex == index;

                          return ModernRoleCard(
                            role: role,
                            isHovered: isHovered,
                            isArabic: isArabic,
                            colors: colors,
                            onTapDown: () =>
                                setState(() => hoveredIndex = index),
                            onTapUp: () => setState(() => hoveredIndex = null),
                            onTapCancel: () =>
                                setState(() => hoveredIndex = null),
                            onTap: () => _navigateToRole(context, index),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    ModernEmergencyButton(
                      isArabic: isArabic,
                      colors: colors,
                      onTap: () => _showEmergencyDialog(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRole(BuildContext context, int index) {
    final screens = [
      const PatientAuthScreen(),
      const DriverAuthScreen(),
      const HospitalAuthScreen(),
    ];

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screens[index]),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    final isArabic = context.read<AppProvider>().isArabic;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emergency, color: Color(0xFFDC2626)),
            ),
            const SizedBox(width: 12),
            Text(isArabic ? 'اتصال طوارئ' : 'Emergency Call',
                style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          isArabic
              ? 'سيتم الاتصال فوراً بخدمات الطوارئ. هل تريد المتابعة؟'
              : 'This will immediately connect you to emergency services. Continue?',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel',
                style: const TextStyle(color: Color(0xFF94A3B8))),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626)),
            child: Text(isArabic ? 'اتصل الآن' : 'Call Now'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModernSettingsSheet(),
    );
  }
}

// Abstract base class for colors
abstract class AppColors {
  Color get background;
  Color get surface;
  Color get cardBackground;
  Color get primaryText;
  Color get secondaryText;
  Color get accent;
  Color get patientAccent;
  Color get driverAccent;
  Color get hospitalAccent;
  List<Color> get patientGradient;
  List<Color> get driverGradient;
  List<Color> get hospitalGradient;
}

// Light theme colors
class LightColors implements AppColors {
  @override
  Color get background => const Color(0xFFF8FAFC);

  @override
  Color get surface => Colors.white;

  @override
  Color get cardBackground => Colors.white;

  @override
  Color get primaryText => const Color(0xFF0F172A);

  @override
  Color get secondaryText => const Color(0xFF64748B);

  @override
  Color get accent => const Color(0xFFDC2626);

  @override
  Color get patientAccent => const Color(0xFFDC2626);

  @override
  Color get driverAccent => const Color(0xFF0F172A);

  @override
  Color get hospitalAccent => const Color(0xFF64748B);

  @override
  List<Color> get patientGradient => [
        const Color(0xFFFEE2E2),
        const Color(0xFFFEF2F2),
      ];

  @override
  List<Color> get driverGradient => [
        const Color(0xFFF1F5F9),
        Colors.white,
      ];

  @override
  List<Color> get hospitalGradient => [
        const Color(0xFFF1F5F9),
        Colors.white,
      ];
}

// Dark theme colors - DARK BLUE theme
class DarkColors implements AppColors {
  @override
  Color get background => const Color(0xFF0B1120); // Dark blue background

  @override
  Color get surface => const Color(0xFF1E293B); // Slate 800 - cards surface

  @override
  Color get cardBackground => const Color(0xFF334155); // Slate 700 - elevated

  @override
  Color get primaryText => const Color(0xFFF8FAFC); // White

  @override
  Color get secondaryText => const Color(0xFF94A3B8); // Slate 400

  @override
  Color get accent => const Color(0xFFDC2626); // Red accent

  @override
  Color get patientAccent => const Color(0xFFDC2626); // Red

  @override
  Color get driverAccent => const Color(0xFFF8FAFC); // White

  @override
  Color get hospitalAccent => const Color(0xFF94A3B8); // Slate 400

  @override
  List<Color> get patientGradient => [
        const Color(0xFF7F1D1D), // Dark red
        const Color(0xFF991B1B),
      ];

  @override
  List<Color> get driverGradient => [
        const Color(0xFF1E293B), // Slate 800
        const Color(0xFF334155), // Slate 700
      ];

  @override
  List<Color> get hospitalGradient => [
        const Color(0xFF1E293B), // Slate 800
        const Color(0xFF334155), // Slate 700
      ];
}

// Background Shapes
class BackgroundShapes extends StatelessWidget {
  final AppColors colors;

  const BackgroundShapes({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colors.accent.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Modern Header
class ModernHeader extends StatelessWidget {
  final bool isArabic;
  final AppProvider provider;
  final AppColors colors;
  final VoidCallback onSettingsTap;

  const ModernHeader({
    super.key,
    required this.isArabic,
    required this.provider,
    required this.colors,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Professional logo – using a simple widget instead of CustomPainter
        Container(
  width: 48,                     // increased from 48 to 60
  height: 48,                    // increased from 48 to 60
  decoration: BoxDecoration(
    color: const Color(0xFF1E1E1E), // carbon black (very dark gray)
    borderRadius: BorderRadius.circular(20),
  ),
  child: const Center(
    child: SizedBox(
      width: 34,                  // scaled up proportionally (was 28)
      height: 34,                 // scaled up proportionally
      child: ProfessionalLogo(),  // plus sign remains white
    ),
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
                letterSpacing: 2,
                color: colors.primaryText,
              ),
            ),
            Text(
              'EMERGENCY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: colors.secondaryText,
              ),
            ),
          ],
        ),
        const Spacer(),
        GlassButton(
          icon: Icons.settings_outlined,
          onTap: onSettingsTap,
          colors: colors,
        ),
        const SizedBox(width: 8),
        GlassButton(
          icon: Icons.language,
          label: provider.languageCode.toUpperCase(),
          onTap: () => provider.toggleLanguage(),
          colors: colors,
        ),
      ],
    );
  }
}

// Glass Button
class GlassButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final AppColors colors;

  const GlassButton({
    super.key,
    required this.icon,
    this.label,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.primaryText.withOpacity(0.1),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: colors.secondaryText),
                    if (label != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        label!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Modern Role Card
class ModernRoleCard extends StatelessWidget {
  final RoleItem role;
  final bool isHovered;
  final bool isArabic;
  final AppColors colors;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;
  final VoidCallback onTap;

  const ModernRoleCard({
    super.key,
    required this.role,
    required this.isHovered,
    required this.isArabic,
    required this.colors,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(isHovered ? 0.98 : 1.0),
      child: GestureDetector(
        onTapDown: (_) => onTapDown(),
        onTapUp: (_) => onTapUp(),
        onTapCancel: () => onTapCancel(),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: role.gradient,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isHovered
                  ? role.accentColor
                  : colors.primaryText.withOpacity(0.1),
              width: isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isHovered ? 0.4 : 0.2),
                blurRadius: isHovered ? 24 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: role.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    role.icon,
                    color: role.accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: role.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                    color: role.accentColor,
                    size: 16,
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

// Modern Emergency Button
class ModernEmergencyButton extends StatelessWidget {
  final bool isArabic;
  final AppColors colors;
  final VoidCallback onTap;

  const ModernEmergencyButton({
    super.key,
    required this.isArabic,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isArabic ? 'اتصال طوارئ' : 'EMERGENCY CALL',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
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

// Modern Settings Sheet
class ModernSettingsSheet extends StatelessWidget {
  const ModernSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = provider.isArabic;
    final AppColors colors = isDark ? DarkColors() : LightColors();

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.secondaryText.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'الإعدادات' : 'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 24),
                SettingOption(
                  icon: Icons.dark_mode,
                  title: isArabic ? 'السمة' : 'Theme',
                  value: provider.themeMode == ThemeMode.light
                      ? (isArabic ? 'فاتح' : 'Light')
                      : provider.themeMode == ThemeMode.dark
                          ? (isArabic ? 'داكن' : 'Dark')
                          : (isArabic ? 'النظام' : 'System'),
                  onTap: () {
                    final modes = [
                      ThemeMode.light,
                      ThemeMode.dark,
                      ThemeMode.system
                    ];
                    final currentIndex = modes.indexOf(provider.themeMode);
                    provider.setThemeMode(modes[(currentIndex + 1) % 3]);
                  },
                  colors: colors,
                ),
                const SizedBox(height: 12),
                SettingOption(
                  icon: Icons.language,
                  title: isArabic ? 'اللغة' : 'Language',
                  value: isArabic ? 'العربية' : 'English',
                  onTap: provider.toggleLanguage,
                  colors: colors,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final AppColors colors;

  const SettingOption({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.primaryText.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colors.accent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.primaryText,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

// Role Item Model
class RoleItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accentColor;

  RoleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accentColor,
  });
}

// NEW: Simple professional logo widget
class ProfessionalLogo extends StatelessWidget {
  const ProfessionalLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Horizontal bar
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        // Vertical bar
        Align(
          alignment: Alignment.center,
          child: Container(
            height: double.infinity,
            width: 6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ],
    );
  }
}