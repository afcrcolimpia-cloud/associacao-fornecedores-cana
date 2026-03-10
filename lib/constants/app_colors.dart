// lib/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ═══════════════════════════════════════════════════════════════
  // NOVO DESIGN SYSTEM — Dark Theme (Redesign 2026)
  // ═══════════════════════════════════════════════════════════════
  
  // Dark Theme - Backgrounds
  static const Color bgDark = Color(0xFF0F1117);        // Background escuro
  static const Color surfaceDark = Color(0xFF1C2333);   // Surface escuro
  static const Color borderDark = Color(0xFF2A3347);    // Border escuro
  
  // Primary & Accents - Novo Design System
  static const Color newPrimary = Color(0xFF0DF28F);    // Verde vibrante (#0DF28F)
  static const Color primaryMutedValue = Color(0x330DF28F); // 20% opacity (const-compatible)
  
  // Status Colors - New System
  static const Color newSuccess = Color(0xFF0DF28F);    // Verde sucesso (igual primary)
  static const Color newWarning = Color(0xFFF59E0B);    // Amarelo/Laranja aviso
  static const Color newDanger = Color(0xFFEF4444);     // Vermelho perigo
  static const Color newInfo = Color(0xFF3B82F6);       // Azul informação
  
  // Text Colors - Dark Theme
  static const Color newTextPrimary = Color(0xFFE2E8F0);   // Texto principal (claro)
  static const Color newTextSecondary = Color(0xFF94A3B8); // Texto secundário
  static const Color newTextMuted = Color(0xFF64748B);     // Texto desativado/leve
  
  // ═══════════════════════════════════════════════════════════════
  // PALETA LEGADA (Compatibilidade com código existente)
  // ═══════════════════════════════════════════════════════════════
  
  // Cores Principais (paleta ant iga — verde)
  static const Color primary = Color(0xFF2E7D32);      // Verde escuro
  static const Color secondary = Color(0xFF558B2F);    // Verde médio
  static const Color accent = Color(0xFF8BC34A);       // Verde claro
  
  // Cores de Status (paleta antiga)
  static const Color success = Color(0xFF4CAF50);      // Verde sucesso
  static const Color error = Color(0xFFD32F2F);        // Vermelho erro
  static const Color warning = Color(0xFFFFA726);      // Laranja aviso
  static const Color info = Color(0xFF2196F3);         // Azul informação
  
  // Cores de Texto (paleta antiga — light)
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Cores de Fundo (paleta antiga — light)
  static const Color background = Color(0xFFF5F5F5);
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Construtor privado para evitar instanciação
  AppColors._();
}