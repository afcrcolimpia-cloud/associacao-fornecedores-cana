// lib/widgets/variedade_dropdown_widget.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/variedade_service.dart';
import '../screens/variedade_form_screen.dart';

class VariedadeDropdownWidget extends StatefulWidget {
  final String? variedadeSelecionada;
  final Function(String?) onChanged;

  const VariedadeDropdownWidget({
    super.key,
    required this.variedadeSelecionada,
    required this.onChanged,
  });

  @override
  State<VariedadeDropdownWidget> createState() => _VariedadeDropdownWidgetState();
}

class _VariedadeDropdownWidgetState extends State<VariedadeDropdownWidget> {
  final VariedadeService _service = VariedadeService();
  List<Variedade> _variedades = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarVariedades();
  }

  Future<void> _carregarVariedades() async {
    try {
      final variedades = await _service.getVariedadesAtivas();
      if (mounted) {
        setState(() {
          _variedades = variedades;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
      debugPrint('Erro ao carregar variedades: $e');
    }
  }

  Future<void> _abrirNovaVariedade() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const VariedadeFormScreen()),
    );
    if (resultado == true) {
      await _carregarVariedades();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Verificar se o valor selecionado existe na lista
    final valorValido = _variedades.any((v) => v.id == widget.variedadeSelecionada)
        ? widget.variedadeSelecionada
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: valorValido,
          decoration: InputDecoration(
            labelText: 'Variedade',
            prefixIcon: const Icon(Icons.grass),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          isExpanded: true,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Selecione uma variedade...'),
            ),
            ..._variedades.map((variedade) {
              return DropdownMenuItem<String>(
                value: variedade.id,
                child: Text(
                  '${variedade.codigo} — ${variedade.destaque}',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: widget.onChanged,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _abrirNovaVariedade,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nova Variedade'),
          ),
        ),
      ],
    );
  }
}