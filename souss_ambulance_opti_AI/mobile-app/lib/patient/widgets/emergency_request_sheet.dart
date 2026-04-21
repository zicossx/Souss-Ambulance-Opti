import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';

class EmergencyRequestSheet extends StatefulWidget {
  const EmergencyRequestSheet({super.key});

  @override
  State<EmergencyRequestSheet> createState() => _EmergencyRequestSheetState();
}

class _EmergencyRequestSheetState extends State<EmergencyRequestSheet> {
  String? _selectedCondition;
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  final List<Map<String, dynamic>> conditions = [
    {'name': 'Heart Attack', 'nameAr': 'أزمة قلبية', 'icon': Icons.favorite, 'color': Colors.red},
    {'name': 'Severe Bleeding', 'nameAr': 'نزيف حاد', 'icon': Icons.water_drop, 'color': Colors.red.shade700},
    {'name': 'Difficulty Breathing', 'nameAr': 'صعوبة في التنفس', 'icon': Icons.air, 'color': Colors.blue},
    {'name': 'Chest Pain', 'nameAr': 'ألم صدر', 'icon': Icons.heart_broken, 'color': Colors.orange},
    {'name': 'Accident', 'nameAr': 'حادث', 'icon': Icons.car_crash, 'color': Colors.purple},
    {'name': 'Unconscious', 'nameAr': 'فقدان الوعي', 'icon': Icons.bed, 'color': Colors.grey},
    {'name': 'Other', 'nameAr': 'أخرى', 'icon': Icons.help, 'color': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.midnightBlue.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                    color: AppColors.textMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
    
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.rosePrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.rosePrimary.withOpacity(0.2),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: const Icon(Icons.emergency, color: AppColors.rosePrimary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'طلب إسعاف عاجل' : 'Emergency Dispatch',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                        ),
                        Text(
                          isArabic ? 'اختر الحالة لبدء الاستجابة' : 'Select condition to start response',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    
              const SizedBox(height: 24),
    
              // Condition Selector
              Text(
                isArabic ? 'نوع الحالة:' : 'Condition Type:',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
    
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: conditions.map((condition) {
                  final isSelected = _selectedCondition == condition['name'];
                  return ChoiceChip(
                    avatar: Icon(
                      condition['icon'],
                      size: 18,
                      color: isSelected ? Colors.white : condition['color'],
                    ),
                    label: Text(isArabic ? condition['nameAr'] : condition['name']),
                    selected: isSelected,
                    selectedColor: condition['color'],
                    backgroundColor: AppColors.surfaceBlue.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCondition = selected ? condition['name'] : null;
                      });
                    },
                  );
                }).toList(),
              ),
    
              const SizedBox(height: 20),
    
              // Location
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'الموقع الحالي' : 'Current Location',
                  prefixIcon: const Icon(Icons.location_on, color: AppColors.medicalCyan),
                  hintText: isArabic ? 'مثال: شارع محمد الخامس' : 'e.g., Boulevard Mohammed V',
                ),
              ),
    
              const SizedBox(height: 16),
    
              // Notes
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: isArabic ? 'ملاحظات إضافية' : 'Additional Notes',
                  hintText: isArabic ? 'صف الحالة باختصار...' : 'Briefly describe the condition...',
                ),
              ),
    
              const SizedBox(height: 24),
    
              // Submit Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    if (_selectedCondition != null)
                      BoxShadow(
                        color: AppColors.rosePrimary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _selectedCondition == null
                      ? null
                      : () {
                          Navigator.pop(context);
                          _showConfirmation(context, isArabic);
                        },
                  icon: const Icon(Icons.flash_on),
                  label: Text(
                    isArabic ? 'إرسال طلب الاستجابة' : 'SEND RESPONSE REQUEST',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCondition != null ? null : Colors.grey.shade800,
                    shadowColor: Colors.transparent,
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.disabled)) return Colors.grey.shade800;
                      return null; // Let the gradient take over if we used one, but here we'll use theme colors
                    }),
                  ),
                ),
              ),
    
              const SizedBox(height: 12),
    
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                label: Text(
                  isArabic ? 'إلغاء الطلب' : 'Cancel Request',
                  style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmation(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(isArabic ? 'تم إرسال الطلب!' : 'Request Sent!'),
          ],
        ),
        content: Text(
          isArabic
              ? 'سيارة الإسعاف في طريقها إليك. سيتم إعلامك عند وصولها.'
              : 'Ambulance is on its way. You will be notified when it arrives.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }
}