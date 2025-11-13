import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

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
        Text(
          'ASSOCIAÇÃO DOS FORNECEDORES',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.verdeMusgo,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          'DE CANA DA REGIÃO DE CATANDUVA',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.verdeMusgo,
            letterSpacing: 0.5,
          ),
        ),
        
        if (mostrarLogo) ...[
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.verdeMusgo,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'AFCRC',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}