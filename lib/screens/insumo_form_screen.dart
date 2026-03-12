import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../widgets/app_shell.dart';
import '../models/insumo_com_dose.dart';
import '../services/insumo_com_dose_service.dart';

class InsumoFormScreen extends StatefulWidget {
  final InsumoComDose? insumo;
  final List<String> categoriasExistentes;

  const InsumoFormScreen({
    super.key,
    this.insumo,
    required this.categoriasExistentes,
  });

  bool get isEdicao => insumo != null;

  @override
  State<InsumoFormScreen> createState() => _InsumoFormScreenState();
}

class _InsumoFormScreenState extends State<InsumoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final InsumoComDoseService _service = InsumoComDoseService();
  int _selectedNavigationIndex = 0;
  bool _salvando = false;

  late final TextEditingController _categoriaController;
  late final TextEditingController _tipoController;
  late final TextEditingController _produtoController;
  late final TextEditingController _doseMinimaController;
  late final TextEditingController _doseMaximaController;
  late final TextEditingController _unidadeController;
  late final TextEditingController _precoController;
  late final TextEditingController _observacoesController;
  String? _situacao;

  final List<String> _unidadesComuns = [
    'kg/ha',
    'L/ha',
    'g/ha',
    'mL/ha',
    't/ha',
    'un/ha',
  ];

  final List<String> _situacoes = ['Ativo', 'Inativo', 'Suspenso'];

  @override
  void initState() {
    super.initState();
    final i = widget.insumo;
    _categoriaController = TextEditingController(text: i?.categoria ?? '');
    _tipoController = TextEditingController(text: i?.tipo ?? '');
    _produtoController = TextEditingController(text: i?.produto ?? '');
    _doseMinimaController = TextEditingController(
        text: i != null ? i.doseMinima.toString() : '');
    _doseMaximaController = TextEditingController(
        text: i != null ? i.doseMaxima.toString() : '');
    _unidadeController = TextEditingController(text: i?.unidade ?? '');
    _precoController = TextEditingController(
        text: i != null ? i.precoUnitario.toString() : '');
    _observacoesController = TextEditingController(text: i?.observacoes ?? '');
    _situacao = i?.situacao;
  }

  @override
  void dispose() {
    _categoriaController.dispose();
    _tipoController.dispose();
    _produtoController.dispose();
    _doseMinimaController.dispose();
    _doseMaximaController.dispose();
    _unidadeController.dispose();
    _precoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: widget.isEdicao ? 'Editar Insumo' : 'Novo Insumo',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Seção: Classificação ──
              _buildSecao('Classificação'),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Autocomplete<String>(
                      initialValue: TextEditingValue(text: _categoriaController.text),
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return widget.categoriasExistentes;
                        }
                        return widget.categoriasExistentes.where((c) => c
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                        // Sync with our controller
                        controller.text = _categoriaController.text;
                        controller.addListener(() {
                          _categoriaController.text = controller.text;
                        });
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Categoria *',
                            hintText: 'Ex: Herbicida, Inseticida...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Informe a categoria' : null,
                        );
                      },
                      onSelected: (value) {
                        _categoriaController.text = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _tipoController,
                      decoration: const InputDecoration(
                        labelText: 'Tipo *',
                        hintText: 'Ex: Pré-emergente, Sistêmico...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Informe o tipo' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _produtoController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto *',
                  hintText: 'Ex: Glifosato 480 SL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o nome do produto' : null,
              ),

              const SizedBox(height: 24),

              // ── Seção: Dosagem ──
              _buildSecao('Dosagem'),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _doseMinimaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Dose Mínima *',
                        hintText: '0.0',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.arrow_downward),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Informe a dose mínima';
                        final valor = double.tryParse(v.replaceAll(',', '.'));
                        if (valor == null || valor < 0) return 'Valor inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _doseMaximaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Dose Máxima *',
                        hintText: '0.0',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.arrow_upward),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Informe a dose máxima';
                        final valor = double.tryParse(v.replaceAll(',', '.'));
                        if (valor == null || valor < 0) return 'Valor inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Autocomplete<String>(
                      initialValue: TextEditingValue(text: _unidadeController.text),
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) return _unidadesComuns;
                        return _unidadesComuns.where((u) => u
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                        controller.text = _unidadeController.text;
                        controller.addListener(() {
                          _unidadeController.text = controller.text;
                        });
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Unidade *',
                            hintText: 'Ex: kg/ha',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.straighten),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Informe a unidade' : null,
                        );
                      },
                      onSelected: (value) {
                        _unidadeController.text = value;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Seção: Preço e Situação ──
              _buildSecao('Preço e Situação'),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precoController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Preço Unitário (R\$) *',
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Informe o preço';
                        final valor = double.tryParse(v.replaceAll(',', '.'));
                        if (valor == null || valor < 0) return 'Valor inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _situacao,
                      decoration: const InputDecoration(
                        labelText: 'Situação',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.toggle_on),
                      ),
                      items: _situacoes
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _situacao = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Seção: Observações ──
              _buildSecao('Observações'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacoesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  hintText: 'Informações adicionais sobre o insumo...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              // ── Botão Salvar ──
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _salvando
                        ? 'Salvando...'
                        : widget.isEdicao
                            ? 'Atualizar Insumo'
                            : 'Cadastrar Insumo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.newPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecao(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final insumo = InsumoComDose(
        id: widget.insumo?.id ?? '',
        categoria: _categoriaController.text.trim(),
        tipo: _tipoController.text.trim(),
        produto: _produtoController.text.trim(),
        situacao: _situacao,
        doseMinima:
            double.tryParse(_doseMinimaController.text.replaceAll(',', '.')) ?? 0,
        doseMaxima:
            double.tryParse(_doseMaximaController.text.replaceAll(',', '.')) ?? 0,
        unidade: _unidadeController.text.trim(),
        precoUnitario:
            double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0,
        observacoes: _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
        dataCriacao: widget.insumo?.dataCriacao ?? DateTime.now(),
      );

      if (widget.isEdicao) {
        await _service.atualizarInsumo(insumo);
      } else {
        await _service.salvarInsumo(insumo);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEdicao
                ? 'Insumo atualizado com sucesso!'
                : 'Insumo cadastrado com sucesso!'),
            backgroundColor: AppColors.newPrimary,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _salvando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.newDanger,
          ),
        );
      }
    }
  }
}
