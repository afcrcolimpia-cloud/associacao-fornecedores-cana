// lib/widgets/variedade_dropdown_widget.dart

import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
  State<VariedadeDropdownWidget> createState() =>
      _VariedadeDropdownWidgetState();
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

  String _labelVariedade(Variedade v) => '${v.codigo} — ${v.destaque}';

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Encontrar a variedade selecionada pelo ID
    final variedadeSelecionada = _variedades
        .where((v) => v.id == widget.variedadeSelecionada)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownSearch<Variedade>(
          selectedItem: variedadeSelecionada,
          // Na v6 do dropdown_search, items é uma função que retorna a lista
          items: (filtro, _) {
            final f = filtro.toLowerCase();
            if (f.isEmpty) return _variedades;
            return _variedades.where((v) =>
                v.codigo.toLowerCase().contains(f) ||
                v.destaque.toLowerCase().contains(f)).toList();
          },
          // Na v6 não há filterFn separado — o filtro é feito dentro da função items
          itemAsString: _labelVariedade,
          compareFn: (a, b) => a.id == b.id,
          decoratorProps: const DropDownDecoratorProps(
            decoration: InputDecoration(
              labelText: 'Variedade',
              prefixIcon: Icon(Icons.grass),
              border: OutlineInputBorder(),
              hintText: 'Selecione uma variedade...',
            ),
          ),
          popupProps: const PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Digite o código ou nome (ex: 75, RB867515)...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          onChanged: (variedade) {
            widget.onChanged(variedade?.id);
          },
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