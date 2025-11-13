import 'package:flutter/material.dart';

class AppColors {
  // Cor principal - Verde Musgo
  static const Color primary = Color(0xFF6B8E23);
  static const Color verdeMusgo = Color(0xFF6B8E23);

  // Cores secundárias
  static const Color secondary = Color(0xFF556B2F);
  static const Color accent = Color(0xFF8BC34A);

  // Cores de fundo e texto
  static const Color background = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Cores de status
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF0288D1); // 🔹 Adicionada cor azul para 'info'

  // Cores para indicadores de operação
  static const Color indicadorVerde = Color(0xFF4CAF50);
  static const Color indicadorAmarelo = Color(0xFFFFC107);
  static const Color indicadorVermelho = Color(0xFFF44336);

  // Cor divisória
  static const Color divider = Color(0xFFBDBDBD); // 🔹 Adicionada cor cinza para divisores

  // Método auxiliar (substitui o uso obsoleto de .withOpacity)
  static Color withAlpha(Color color, double opacity) {
    return color.withValues(alpha: opacity); // ✅ Usa o novo método
  }
}
