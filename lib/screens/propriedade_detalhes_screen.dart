import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import '../models/models.dart';
import '../services/proprietario_service.dart';

class PropriedadeDetalhesScreen extends StatefulWidget {
  final Propriedade propriedade;

  const PropriedadeDetalhesScreen({
    super.key,
    required this.propriedade,
  });

  @override
  State<PropriedadeDetalhesScreen> createState() =>
      _PropriedadeDetalhesScreenState();
}

class _PropriedadeDetalhesScreenState extends State<PropriedadeDetalhesScreen> {
  final ProprietarioService _proprietarioService = ProprietarioService();
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarContexto();
  }

  Future<void> _carregarContexto() async {
    try {
      // Carregar proprietário para exibir contexto
      await _proprietarioService
          .getProprietario(widget.propriedade.proprietarioId);
      if (mounted) {
        setState(() => _carregando = false);
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        appBar: AppBarAfcrc(title: widget.propriedade.nome),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // TODO: Redirecionar para PropriedadeHubScreen quando implementar /implementar-fluxo
    // if (_contexto != null) {
    //   return PropriedadeHubScreen(contexto: _contexto!);
    // }

    // Fallback: mostra apenas info + botão voltar
    return Scaffold(
      appBar: AppBarAfcrc(title: widget.propriedade.nome),
      body: const Center(
        child: Text('Não foi possível carregar os dados do proprietário.'),
      ),
    );
  }
}
