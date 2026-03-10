import 'package:flutter/material.dart';
import '../models/contexto_propriedade.dart';
import '../constants/app_colors.dart';

/// Widget que exibe o cabeçalho com informações base da propriedade selecionada
/// Deve ser colocado no topo de TODAS as telas operacionais
class HeaderPropriedade extends StatelessWidget {
  final ContextoPropriedade contexto;

  const HeaderPropriedade({
    super.key,
    required this.contexto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.primary, // Verde #2E7D32
      child: Wrap(
        spacing: 24,
        runSpacing: 4,
        children: [
          _info('Proprietário', contexto.nomeProprietario),
          _info('Propriedade', contexto.nomePropriedade),
          _info('FA', contexto.numeroFA),
          _info('Município', contexto.municipio),
          _info('Área', contexto.areaHa),
        ],
      ),
    );
  }

  /// Cria um widget de informação com label e valor
  Widget _info(String label, String valor) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
