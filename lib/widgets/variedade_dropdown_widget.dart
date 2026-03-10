// lib/widgets/variedade_dropdown_widget.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/variedade_service.dart';

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
      setState(() {
        _variedades = variedades;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _carregando = false;
      });
      debugPrint('Erro ao carregar variedades: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: CircularProgressIndicator(),
      );
    }

    return DropdownButtonFormField<String>(
      value: widget.variedadeSelecionada,
      decoration: InputDecoration(
        labelText: 'Variedade',
        prefixIcon: const Icon(Icons.grass),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Selecione uma variedade...'),
        ),
        ..._variedades.map((variedade) {
          return DropdownMenuItem<String>(
            value: variedade.id,
            child: Text('${variedade.codigo} - ${variedade.nome}'),
          );
        }),
      ],
      onChanged: widget.onChanged,
    );
  }
}