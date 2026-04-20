import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../providers/app_provider.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();
    final isArabic = provider.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settings,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 24),
                  
                  // Language Section
                  _buildSectionTitle(context, l10n.language),
                  const SizedBox(height: 12),
                  _buildOptionTile(
                    context,
                    title: l10n.english,
                    isSelected: provider.languageCode == 'en',
                    onTap: () => provider.setLanguage('en'),
                  ),
                  _buildOptionTile(
                    context,
                    title: l10n.arabic,
                    isSelected: provider.languageCode == 'ar',
                    onTap: () => provider.setLanguage('ar'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Theme Section
                  _buildSectionTitle(context, l10n.theme),
                  const SizedBox(height: 12),
                  _buildOptionTile(
                    context,
                    title: l10n.light,
                    icon: Icons.light_mode_outlined,
                    isSelected: provider.themeMode == ThemeMode.light,
                    onTap: () => provider.setThemeMode(ThemeMode.light),
                  ),
                  _buildOptionTile(
                    context,
                    title: l10n.dark,
                    icon: Icons.dark_mode_outlined,
                    isSelected: provider.themeMode == ThemeMode.dark,
                    onTap: () => provider.setThemeMode(ThemeMode.dark),
                  ),
                  _buildOptionTile(
                    context,
                    title: l10n.system,
                    icon: Icons.settings_suggest_outlined,
                    isSelected: provider.themeMode == ThemeMode.system,
                    onTap: () => provider.setThemeMode(ThemeMode.system),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String title,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodyLarge?.color,
              ),
              const SizedBox(width: 12),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}