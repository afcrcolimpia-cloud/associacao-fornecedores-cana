import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../models/models.dart';
import '../services/proprietario_service.dart';
import 'propriedade_hub_screen.dart';

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
  Proprietario? _proprietario;
  bool _carregando = true;
  int _selectedNavigationIndex = 0;

  @override
  void initState() {
    super.initState();
    _carregarContexto();
  }

  Future<void> _carregarContexto() async {
    try {
      final proprietario = await _proprietarioService
          .getProprietario(widget.propriedade.proprietarioId);
      if (mounted) {
        setState(() {
          _proprietario = proprietario;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return AppShell(
        selectedIndex: _selectedNavigationIndex,
        onNavigationSelect: (index) {
          setState(() => _selectedNavigationIndex = index);
        },
        title: widget.propriedade.nome,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Redirecionar para PropriedadeHubScreen quando proprietário foi carregado
    if (_proprietario != null) {
      return PropriedadeHubScreen(
        contexto: ContextoPropriedade(
          proprietario: _proprietario!,
          propriedade: widget.propriedade,
        ),
      );
    }

    // Fallback: mostra apenas info + botão voltar
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      title: widget.propriedade.nome,
      child: const Center(
        child: Text('Não foi possível carregar os dados do proprietário.'),
      ),
    );
  }
}
