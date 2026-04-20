import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final List<Widget>? actions;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, size: 24),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Header
              Text(
                title,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              
              const SizedBox(height: 40),
              
              // Form
              form,
              
              const SizedBox(height: 24),
              
              // Actions
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}