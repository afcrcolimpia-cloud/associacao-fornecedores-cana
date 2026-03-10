// lib/widgets/empresa_header.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class EmpresaHeader extends StatelessWidget {
  final bool mostrarLogo;
  final double fontSize;
  final bool horizontal;

  const EmpresaHeader({
    super.key,
    this.mostrarLogo = true,
    this.fontSize = 16,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = mostrarLogo
        ? Image.asset(
            'assets/logo/logo.png',
            width: horizontal ? 48 : 80,
            height: horizontal ? 48 : 80,
            errorBuilder: (context, error, stackTrace) => Container(
              width: horizontal ? 48 : 80,
              height: horizontal ? 48 : 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco, size: 32, color: AppColors.primary),
            ),
          )
        : const SizedBox.shrink();

    final textContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'Associação dos Fornecedores de Cana da Região de Catanduva',
          textAlign: horizontal ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'AFCRC — Catanduva/SP',
          textAlign: horizontal ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            fontSize: fontSize - 2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );

    if (horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mostrarLogo) ...[logoWidget, const SizedBox(width: 16)],
          Flexible(child: textContent),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mostrarLogo) ...[logoWidget, const SizedBox(height: 16)],
        textContent,
      ],
    );
  }
}