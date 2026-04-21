import 'package:flutter/material.dart';

class AppColors {
  // Midnight Theme (Base Layers)
  static const Color midnightBlue = Color(0xFF0F172A);
  static const Color surfaceBlue = Color(0xFF1E293B);
  static const Color surfaceElevated = Color(0xFF334155);
  static const Color borderBlue = Color(0xFF334155);
  
  // Cyber Medical Accents (Core Branding)
  static const Color rosePrimary = Color(0xFFF43F5E);
  static const Color roseSecondary = Color(0xFFE11D48);
  static const Color medicalCyan = Color(0xFF22D3EE);
  static const Color neonGreen = Color(0xFF10B981);
  static const Color neonAmber = Color(0xFFF59E0B);
  
  // Text & Communication
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  
  // Premium Gradients
  static const LinearGradient cyberGradient = LinearGradient(
    colors: [rosePrimary, roseSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Colors.white10, Colors.white24], // Changed white05 to white24 or similar since white05 doesn't exist
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [medicalCyan, Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
