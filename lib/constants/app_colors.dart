// lib/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Cores Principais
  static const Color primary = Color(0xFF2E7D32);      // Verde escuro
  static const Color secondary = Color(0xFF558B2F);    // Verde médio
  static const Color accent = Color(0xFF8BC34A);       // Verde claro
  
  // Cores de Status
  static const Color success = Color(0xFF4CAF50);      // Verde sucesso
  static const Color error = Color(0xFFD32F2F);        // Vermelho erro
  static const Color warning = Color(0xFFFFA726);      // Laranja aviso
  static const Color info = Color(0xFF2196F3);         // Azul informação
  
  // Cores de Texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Cores de Fundo
  static const Color background = Color(0xFFF5F5F5);
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Construtor privado para evitar instanciação
  AppColors._();
}