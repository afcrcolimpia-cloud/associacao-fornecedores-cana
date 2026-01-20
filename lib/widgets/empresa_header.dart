// lib/widgets/empresa_header.dart
import 'package:flutter/material.dart';

class EmpresaHeader extends StatelessWidget {
  final bool mostrarLogo;
  final double fontSize;

  const EmpresaHeader({
    super.key,
    this.mostrarLogo = true,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mostrarLogo) ...[
          Image.asset(
            'assets/logo/logo.png',
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.business,
                  size: 40,
                  color: Colors.grey[600],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
        Text(
          'Associação dos Fornecedores de Cana',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'da Região de Catanduva',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'AFCRC - Catanduva/SP',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize - 2,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}