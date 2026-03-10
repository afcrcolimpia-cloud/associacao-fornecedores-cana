import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/talhao_service.dart';

class TalhaoFormScreen extends StatefulWidget {
  final Propriedade propriedade;
  final Talhao? talhao;

  const TalhaoFormScreen({
    super.key,
    required this.propriedade,
    this.talhao,
  });

  @override
  State<TalhaoFormScreen> createState() => _TalhaoFormScreenState();
}

class _TalhaoFormScreenState extends State<TalhaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _talhaoService = TalhaoService();

  final _numeroController = TextEditingController();
  final _areaHaController = TextEditingController();
  final _areaAlqueiresController = TextEditingController();
  final _variedadeController = TextEditingController();
  final _observacoesController = TextEditingController();

  String? _culturaSelecionada;
  bool _ativo = true;
  bool _isLoading = false;

  final List<String> _culturas = [
    'Cana-de-açúcar',
    'Milho',
    'Soja',
    'Sorgo',
    'Outra',
  ];

  // Normalizar cultura para compatibilidade
  String _normalizarCultura(String cultura) {
    return cultura.toLowerCase().trim();
  }

  // Encontrar a cultura correta na lista ou retornar a original
  String? _encontrarCultura(String? culturaBuscada) {
    if (culturaBuscada == null) return null;
    
    final normalizada = _normalizarCultura(culturaBuscada);
    
    // Procurar na lista normalizada
    for (var cultura in _culturas) {
      if (_normalizarCultura(cultura) == normalizada) {
        return cultura;
      }
    }
    
    // Se não encontrou, retornar a original
    return culturaBuscada;
  }

  @override
  void initState() {
    super.initState();
    if (widget.talhao != null) {
      _carregarDados();
    }
  }

  void _carregarDados() {
    final talhao = widget.talhao!;
    _numeroController.text = talhao.numeroTalhao;
    _areaHaController.text = talhao.areaHa?.toString() ?? '';
    _areaAlqueiresController.text = talhao.areaAlqueires?.toString() ?? '';
    
    // Procurar a cultura correta na lista
    if (talhao.cultura != null) {
      final culturaNormalizada = _encontrarCultura(talhao.cultura);
      _culturaSelecionada = culturaNormalizada;
    } else {
      _culturaSelecionada = null;
    }
    
    _variedadeController.text = talhao.variedade ?? '';
    _ativo = talhao.ativo;
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _areaHaController.dispose();
    _areaAlqueiresController.dispose();
    _variedadeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarAfcrc(
        title: widget.talhao == null ? 'Novo Talhão' : 'Editar Talhão',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Informações Básicas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildNumeroField(),
                  const SizedBox(height: 16),
                  _buildCulturaField(),
                  const SizedBox(height: 16),
                  _buildVariedadeField(),
                  const SizedBox(height: 24),
                  const Text(
                    'Área',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAreaHaField(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildAreaAlqueiresField(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Talhão Ativo'),
                    subtitle: const Text('O talhão está em operação?'),
                    value: _ativo,
                    onChanged: (value) {
                      setState(() => _ativo = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildBotoes(),
                ],
              ),
            ),
    );
  }

  Widget _buildNumeroField() {
    return TextFormField(
      controller: _numeroController,
      decoration: const InputDecoration(
        labelText: 'Número do Talhão',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.tag),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Número do talhão é obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildCulturaField() {
    // Criar uma lista de culturas que inclui o valor atualmente selecionado se não estiver na lista
    final culturasList = List<String>.from(_culturas);
    
    if (_culturaSelecionada != null) {
      // Se o valor selecionado não está na lista, adicionar
      if (!culturasList.any((c) => _normalizarCultura(c) == _normalizarCultura(_culturaSelecionada!))) {
        culturasList.add(_culturaSelecionada!);
      }
    }

    return DropdownButtonFormField<String>(
      value: _culturaSelecionada,
      decoration: const InputDecoration(
        labelText: 'Cultura',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.eco),
      ),
      items: culturasList.map((cultura) {
        return DropdownMenuItem(
          value: cultura,
          child: Text(cultura),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _culturaSelecionada = value);
      },
    );
  }

  Widget _buildVariedadeField() {
    return TextFormField(
      controller: _variedadeController,
      decoration: const InputDecoration(
        labelText: 'Variedade Principal',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.nature),
      ),
    );
  }

  Widget _buildAreaHaField() {
    return TextFormField(
      controller: _areaHaController,
      decoration: const InputDecoration(
        labelText: 'Área (Hectares)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.agriculture),
        suffixText: 'ha',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Área em hectares é obrigatória';
        }
        if (double.tryParse(value) == null) {
          return 'Digite um número válido';
        }
        return null;
      },
    );
  }

  Widget _buildAreaAlqueiresField() {
    return TextFormField(
      controller: _areaAlqueiresController,
      decoration: const InputDecoration(
        labelText: 'Área (Alqueires)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.agriculture),
        suffixText: 'alq',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (double.tryParse(value) == null) {
            return 'Digite um número válido';
          }
        }
        return null;
      },
    );
  }

  Widget _buildBotoes() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _salvar,
            child: const Text('Salvar'),
          ),
        ),
      ],
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Normalizar a cultura para a versão padrão na lista
      String? culturaNormalizada;
      if (_culturaSelecionada != null) {
        culturaNormalizada = _encontrarCultura(_culturaSelecionada);
      }

      final talhao = Talhao(
        id: widget.talhao?.id ?? '',
        propriedadeId: widget.propriedade.id,
        numeroTalhao: _numeroController.text,
        areaHa: _areaHaController.text.isEmpty
            ? null
            : double.parse(_areaHaController.text),
        areaAlqueires: _areaAlqueiresController.text.isEmpty
            ? null
            : double.parse(_areaAlqueiresController.text),
        cultura: culturaNormalizada,
        variedade: _variedadeController.text.isEmpty
            ? null
            : _variedadeController.text,
        anoPlantio: widget.talhao?.anoPlantio,
        corte: widget.talhao?.corte,
        dataPlantio: widget.talhao?.dataPlantio,
        tipoTalhao: widget.talhao?.tipoTalhao ?? 'producao',
        ativo: _ativo,
        observacoes: widget.talhao?.observacoes,
        criadoEm: widget.talhao?.criadoEm ?? DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      if (widget.talhao == null) {
        await _talhaoService.createTalhao(talhao);
      } else {
        await _talhaoService.updateTalhao(talhao);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.talhao == null
                ? 'Talhão criado com sucesso'
                : 'Talhão atualizado com sucesso'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}