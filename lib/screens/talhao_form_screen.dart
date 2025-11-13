import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../utils/formatters.dart';

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
  final _service = PropriedadeService();

  late TextEditingController _numeroTalhaoController;
  late TextEditingController _areaHectaresController;
  late TextEditingController _areaAlqueiresController;
  late TextEditingController _variedadeController;
  late TextEditingController _anoPlantioController;
  late TextEditingController _corteController;
  late TextEditingController _observacoesController;

  bool _isLoading = false;
  bool _calculandoArea = false;

  @override
  void initState() {
    super.initState();
    final t = widget.talhao;

    _numeroTalhaoController = TextEditingController(text: t?.numeroTalhao);
    _areaHectaresController = TextEditingController(
      text: t?.areaHectares.toString(),
    );
    _areaAlqueiresController = TextEditingController(
      text: t?.areaAlqueires.toString(),
    );
    _variedadeController = TextEditingController(text: t?.variedade);
    _anoPlantioController = TextEditingController(
      text: t?.anoPlantio.toString() ?? DateTime.now().year.toString(),
    );
    _corteController = TextEditingController(
      text: t?.corte.toString() ?? '1',
    );
    _observacoesController = TextEditingController(text: t?.observacoes);

    // Listeners para cálculo automático
    _areaHectaresController.addListener(_onHectaresChanged);
    _areaAlqueiresController.addListener(_onAlqueiresChanged);
  }

  void _onHectaresChanged() {
    if (_calculandoArea) return;
    if (_areaHectaresController.text.isEmpty) return;

    final hectares = double.tryParse(_areaHectaresController.text);
    if (hectares != null) {
      _calculandoArea = true;
      final alqueires = Formatters.hectaresToAlqueires(hectares);
      _areaAlqueiresController.text = alqueires.toStringAsFixed(2);
      _calculandoArea = false;
    }
  }

  void _onAlqueiresChanged() {
    if (_calculandoArea) return;
    if (_areaAlqueiresController.text.isEmpty) return;

    final alqueires = double.tryParse(_areaAlqueiresController.text);
    if (alqueires != null) {
      _calculandoArea = true;
      final hectares = Formatters.alqueiresToHectares(alqueires);
      _areaHectaresController.text = hectares.toStringAsFixed(2);
      _calculandoArea = false;
    }
  }

  @override
  void dispose() {
    _numeroTalhaoController.dispose();
    _areaHectaresController.dispose();
    _areaAlqueiresController.dispose();
    _variedadeController.dispose();
    _anoPlantioController.dispose();
    _corteController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final talhao = Talhao(
        id: widget.talhao?.id ?? '',
        propriedadeId: widget.propriedade.id,
        numeroTalhao: _numeroTalhaoController.text.trim(),
        areaHectares: double.parse(_areaHectaresController.text),
        areaAlqueires: double.parse(_areaAlqueiresController.text),
        variedade: _variedadeController.text.trim(),
        anoPlantio: int.parse(_anoPlantioController.text),
        corte: int.parse(_corteController.text),
        observacoes: _observacoesController.text.trim(),
        criadoEm: widget.talhao?.criadoEm ?? DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      if (widget.talhao == null) {
        await _service.addTalhao(talhao);
      } else {
        await _service.updateTalhao(talhao);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.talhao == null
                  ? 'Talhão cadastrado com sucesso!'
                  : 'Talhão atualizado com sucesso!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.talhao != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Talhão' : 'Novo Talhão'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Card Propriedade
            Card(
              color: AppColors.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.home_work, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.propriedade.nomePropriedade,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FA: ${widget.propriedade.numeroFA}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card Identificação
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identificação',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numeroTalhaoController,
                      decoration: const InputDecoration(
                        labelText: 'Número do Talhão *',
                        hintText: 'Ex: 1, 2, A, B',
                        prefixIcon: Icon(Icons.tag),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _variedadeController,
                      decoration: const InputDecoration(
                        labelText: 'Variedade *',
                        hintText: 'Ex: RB867515',
                        prefixIcon: Icon(Icons.grass),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card Área
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Área',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Digite a área em hectares ou alqueires. O cálculo será automático.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _areaHectaresController,
                            decoration: const InputDecoration(
                              labelText: 'Hectares *',
                              suffixText: 'ha',
                              prefixIcon: Icon(Icons.square_foot),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Número inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _areaAlqueiresController,
                            decoration: const InputDecoration(
                              labelText: 'Alqueires *',
                              suffixText: 'alq',
                              prefixIcon: Icon(Icons.square_foot),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card Cultivo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações de Cultivo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _anoPlantioController,
                            decoration: const InputDecoration(
                              labelText: 'Ano Plantio *',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório';
                              }
                              final ano = int.tryParse(value);
                              if (ano == null || ano < 1900 || ano > DateTime.now().year + 1) {
                                return 'Ano inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _corteController,
                            decoration: const InputDecoration(
                              labelText: 'Corte *',
                              suffixText: 'º',
                              prefixIcon: Icon(Icons.agriculture),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório';
                              }
                              final corte = int.tryParse(value);
                              if (corte == null || corte < 1) {
                                return 'Inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _observacoesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('CANCELAR'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _salvar,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEdicao ? 'ATUALIZAR' : 'SALVAR'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}