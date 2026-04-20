import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../widgets/patient_profile_card.dart';
import '../widgets/emergency_request_sheet.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> medicalConditions = [
    {
      'title': 'Heart Attack',
      'titleAr': 'أزمة قلبية',
      'icon': Icons.favorite,
      'color': Colors.red,
      'advice': [
        'Call emergency immediately',
        'Keep patient calm and seated',
        'Loosen tight clothing',
        'Give aspirin if conscious',
      ],
      'adviceAr': [
        'اتصل بالطوارئ فوراً',
        'حافظ على هدوء المريض وجلوسه',
        'فك الملابس الضيقة',
        'أعطِ أسبرين إذا كان واعياً',
      ],
      'image': 'https://images.unsplash.com/photo-1628348070889-cb656235b4eb?w=400',
    },
    {
      'title': 'Severe Bleeding',
      'titleAr': 'نزيف حاد',
      'icon': Icons.water_drop,
      'color': Colors.red.shade700,
      'advice': [
        'Apply direct pressure to wound',
        'Elevate the injured area',
        'Use clean cloth or bandage',
        'Do not remove embedded objects',
      ],
      'adviceAr': [
        'ضغط مباشر على الجرح',
        'ارفع المنطقة المصابة',
        'استخدم قماشاً نظيفاً',
        'لا تزعج الأجسام الغائرة',
      ],
      'image': 'https://images.unsplash.com/photo-1615461066842-32561977e3d8?w=400',
    },
    {
      'title': 'Choking',
      'titleAr': 'اختناق',
      'icon': Icons.air,
      'color': Colors.orange,
      'advice': [
        'Encourage coughing if possible',
        'Perform Heimlich maneuver if unable to breathe',
        'Call emergency if severe',
        'Do not give water or food',
      ],
      'adviceAr': [
        'شجع على السعال إن أمكن',
        'أجرِ مناورة هيمليخ إذا تعذر التنفس',
        'اتصل بالطوارئ إذا كان حاداً',
        'لا تعطِ ماء أو طعام',
      ],
      'image': 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400',
    },
    {
      'title': 'Burns',
      'titleAr': 'حروق',
      'icon': Icons.local_fire_department,
      'color': Colors.orange.shade700,
      'advice': [
        'Cool burn with running water',
        'Do not apply ice directly',
        'Cover with clean cloth',
        'Do not pop blisters',
      ],
      'adviceAr': [
        'برد الحرق بماء جارٍ',
        'لا تضع الثلج مباشرة',
        'غطِ بقماش نظيف',
        'لا تفقأ الفقاعات',
      ],
      'image': 'https://images.unsplash.com/photo-1584515933487-779824d29309?w=400',
    },
    {
      'title': 'Fractures',
      'titleAr': 'كسور',
      'icon': Icons.broken_image,
      'color': Colors.blue,
      'advice': [
        'Do not move the injured area',
        'Immobilize with splint if possible',
        'Apply ice to reduce swelling',
        'Elevate above heart level',
      ],
      'adviceAr': [
        'لا تحرك المنطقة المصابة',
        'ثبتها بالجبيرة إن أمكن',
        'ضع ثلجاً لتقليل التورم',
        'ارفعها فوق مستوى القلب',
      ],
      'image': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400',
    },
    {
      'title': 'Poisoning',
      'titleAr': 'تسمم',
      'icon': Icons.warning,
      'color': Colors.purple,
      'advice': [
        'Call poison control immediately',
        'Do not induce vomiting',
        'Keep container for identification',
        'Monitor breathing and consciousness',
      ],
      'adviceAr': [
        'اتصل بمركز التسمم فوراً',
        'لا تُحدث القيء',
        'احتفظ بالعبوة للتعرف',
        'راقب التنفس والوعي',
      ],
      'image': 'https://images.unsplash.com/photo-1584308666744-24b5c5f54644?w=400',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isArabic = provider.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header with Profile
              const PatientProfileCard(),
              
              // Emergency Button (Always Visible)
              _EmergencyButton(
                onTap: () => _showEmergencyRequest(context),
                isArabic: isArabic,
              ),

              // Tab Bar
              _TabBar(
                selectedTab: _selectedTab,
                onTabChange: (index) => setState(() => _selectedTab = index),
                isArabic: isArabic,
              ),

              // Content
              Expanded(
                child: _selectedTab == 0
                    ? _MedicalAdviceGrid(
                        conditions: medicalConditions,
                        isArabic: isArabic,
                        onConditionTap: (condition) => _showConditionDetails(context, condition),
                      )
                    : _selectedTab == 1
                        ? _HistoryView(isArabic: isArabic)
                        : _SettingsView(isArabic: isArabic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmergencyRequest(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EmergencyRequestSheet(),
    );
  }

  void _showConditionDetails(BuildContext context, Map<String, dynamic> condition) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConditionDetailsSheet(
        condition: condition,
        isArabic: isArabic,
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isArabic;

  const _EmergencyButton({
    required this.onTap,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
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
                  child: const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 28,
                  ),
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
                        letterSpacing: 1,
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
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChange;
  final bool isArabic;

  const _TabBar({
    required this.selectedTab,
    required this.onTabChange,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _TabButton(
            icon: Icons.medical_services,
            label: isArabic ? 'الإسعافات' : 'First Aid',
            isSelected: selectedTab == 0,
            onTap: () => onTabChange(0),
          ),
          _TabButton(
            icon: Icons.history,
            label: isArabic ? 'السجل' : 'History',
            isSelected: selectedTab == 1,
            onTap: () => onTabChange(1),
          ),
          _TabButton(
            icon: Icons.settings,
            label: isArabic ? 'الإعدادات' : 'Settings',
            isSelected: selectedTab == 2,
            onTap: () => onTabChange(2),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicalAdviceGrid extends StatelessWidget {
  final List<Map<String, dynamic>> conditions;
  final bool isArabic;
  final Function(Map<String, dynamic>) onConditionTap;

  const _MedicalAdviceGrid({
    required this.conditions,
    required this.isArabic,
    required this.onConditionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: conditions.length,
      itemBuilder: (context, index) {
        final condition = conditions[index];
        return GestureDetector(
          onTap: () => onConditionTap(condition),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: condition['color'].withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    color: condition['color'].withOpacity(0.1),
                    child: Icon(
                      condition['icon'],
                      size: 48,
                      color: condition['color'],
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: condition['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            condition['icon'],
                            size: 16,
                            color: condition['color'],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isArabic ? condition['titleAr'] : condition['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic ? 'اضغط للتفاصيل' : 'Tap for details',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryView extends StatelessWidget {
  final bool isArabic;

  const _HistoryView({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _HistoryCard(
          date: 'Today, 14:30',
          dateAr: 'اليوم، 14:30',
          condition: 'Severe Chest Pain',
          conditionAr: 'ألم صدر حاد',
          status: 'Completed',
          statusAr: 'مكتمل',
          isArabic: isArabic,
        ),
        _HistoryCard(
          date: 'Yesterday, 11:15',
          dateAr: 'أمس، 11:15',
          condition: 'Accident Injury',
          conditionAr: 'إصابة حادث',
          status: 'Completed',
          statusAr: 'مكتمل',
          isArabic: isArabic,
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String date;
  final String dateAr;
  final String condition;
  final String conditionAr;
  final String status;
  final String statusAr;
  final bool isArabic;

  const _HistoryCard({
    required this.date,
    required this.dateAr,
    required this.condition,
    required this.conditionAr,
    required this.status,
    required this.statusAr,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.emergency, color: Colors.red),
        ),
        title: Text(isArabic ? conditionAr : condition),
        subtitle: Text(isArabic ? dateAr : date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isArabic ? statusAr : status,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsView extends StatelessWidget {
  final bool isArabic;

  const _SettingsView({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _SettingTile(
          icon: Icons.language,
          title: isArabic ? 'اللغة' : 'Language',
          subtitle: isArabic ? 'تغيير اللغة' : 'Change language',
          trailing: TextButton(
            onPressed: provider.toggleLanguage,
            child: Text(isArabic ? 'English' : 'العربية'),
          ),
        ),
        _SettingTile(
          icon: Icons.dark_mode,
          title: isArabic ? 'السمة' : 'Theme',
          subtitle: isArabic ? 'فاتح / داكن' : 'Light / Dark',
          trailing: DropdownButton<ThemeMode>(
            value: provider.themeMode,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text(isArabic ? 'فاتح' : 'Light'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text(isArabic ? 'داكن' : 'Dark'),
              ),
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text(isArabic ? 'النظام' : 'System'),
              ),
            ],
            onChanged: (mode) {
              if (mode != null) provider.setThemeMode(mode);
            },
          ),
        ),
        _SettingTile(
          icon: Icons.person,
          title: isArabic ? 'الملف الشخصي' : 'Profile',
          subtitle: isArabic ? 'تعديل المعلومات' : 'Edit information',
          onTap: () {},
        ),
        _SettingTile(
          icon: Icons.contact_phone,
          title: isArabic ? 'جهات الاتصال' : 'Emergency Contacts',
          subtitle: isArabic ? 'أضف أرقام الطوارئ' : 'Add emergency numbers',
          onTap: () {},
        ),
        _SettingTile(
  icon: Icons.logout,
  title: isArabic ? 'تسجيل الخروج' : 'Logout',
  subtitle: '',  // Add empty subtitle or proper text
  color: Colors.red,
  trailing: null,  // Explicitly null
  onTap: () {},
),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class ConditionDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> condition;
  final bool isArabic;

  const ConditionDetailsSheet({
    super.key,
    required this.condition,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final advice = isArabic ? condition['adviceAr'] : condition['advice'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: condition['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  condition['icon'],
                  color: condition['color'],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? condition['titleAr'] : condition['title'],
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: condition['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isArabic ? 'إسعافات أولية' : 'First Aid',
                        style: TextStyle(
                          color: condition['color'],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Advice List
          Text(
            isArabic ? 'خطوات الإسعاف:' : 'First Aid Steps:',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          ...List.generate(advice.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: condition['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: condition['color'],
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      advice[index],
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Emergency Button
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Show emergency request
            },
            icon: const Icon(Icons.emergency),
            label: Text(isArabic ? 'طلب إسعاف لهذه الحالة' : 'Request Ambulance for this'),
            style: FilledButton.styleFrom(
              backgroundColor: condition['color'],
              minimumSize: const Size(double.infinity, 56),
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: Text(isArabic ? 'إغلاق' : 'Close'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}