// lib/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ═══════════════════════════════════════════════════════════════
  // NOVO DESIGN SYSTEM — Light Theme (Redesign 2026)
  // ═══════════════════════════════════════════════════════════════
  
  // Light Theme - Backgrounds
  static const Color bgDark = Color(0xFFF8FAFC);        // Background claro (slate-50)
  static const Color surfaceDark = Color(0xFFFFFFFF);   // Surface branco
  static const Color borderDark = Color(0xFFE2E8F0);    // Border claro (slate-200)
  
  // Primary & Accents - Novo Design System
  static const Color newPrimary = Color(0xFF16A34A);    // Verde escuro (#16A34A — green-600)
  static const Color primaryMutedValue = Color(0x3316A34A); // 20% opacity (const-compatible)
  
  // Status Colors - New System
  static const Color newSuccess = Color(0xFF16A34A);    // Verde sucesso (igual primary)
  static const Color newWarning = Color(0xFFD97706);    // Amarelo/Laranja aviso (amber-600)
  static const Color newDanger = Color(0xFFDC2626);     // Vermelho perigo (red-600)
  static const Color newInfo = Color(0xFF2563EB);       // Azul informação (blue-600)
  
  // Text Colors - Light Theme
  static const Color newTextPrimary = Color(0xFF1E293B);   // Texto principal (slate-800)
  static const Color newTextSecondary = Color(0xFF64748B); // Texto secundário (slate-500)
  static const Color newTextMuted = Color(0xFF94A3B8);     // Texto desativado/leve (slate-400)
  
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