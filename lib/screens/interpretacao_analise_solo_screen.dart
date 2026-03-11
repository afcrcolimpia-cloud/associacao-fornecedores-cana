import 'package:flutter/material.dart';
import '../models/models.dart';
import 'analise_solo_screen.dart';

/// @deprecated Use [AnaliseSoloScreen] em vez desta tela.
/// Mantido apenas para compatibilidade â€” redireciona automaticamente.
class InterpretacaoAnaliseSoloScreen extends StatelessWidget {
  final ContextoPropriedade contexto;

  const InterpretacaoAnaliseSoloScreen({
    super.key,
    required this.contexto,
  });

  @override
  Widget build(BuildContext context) {
    return AnaliseSoloScreen(contexto: contexto);
  }
}

