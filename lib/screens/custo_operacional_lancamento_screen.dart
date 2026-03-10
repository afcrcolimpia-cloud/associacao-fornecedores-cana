import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import 'package:flutter/services.dart';
import '../services/custo_operacional_repository.dart';
import '../services/custo_operacional_service.dart';
import '../constants/app_colors.dart';

// ---------------------------------------------
// WIDGET: CAMPO COM BUSCA E AUTOCOMPLETE
// ---------------------------------------------

class SearchField<T> extends StatefulWidget {
  final String label;
  final IconData icon;
  final T? valorSelecionado;
  final String Function(T) labelBuilder;
  final Future<List<T>> Function(String query) onSearch;
  final void Function(T item) onSelected;
  final VoidCallback? onClear;
  final String? suffixText;

  const SearchField({
    super.key,
    required this.label,
    required this.icon,
    required this.labelBuilder,
    required this.onSearch,
    required this.onSelected,
    this.valorSelecionado,
    this.onClear,
    this.suffixText,
  });

  @override
  State<SearchField<T>> createState() => _SearchFieldState<T>();
}

class _SearchFieldState<T> extends State<SearchField<T>> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  List<T> _sugestoes = [];
  bool _showSugestoes = false;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    if (widget.valorSelecionado != null) {
      _ctrl.text = widget.labelBuilder(widget.valorSelecionado as T);
    }
    _focus.addListener(() {
      if (!_focus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showSugestoes = false);
        });
      }
    });
  }

  void _onChanged(String v) async {
    if (v.isEmpty) {
      setState(() {
        _sugestoes = [];
        _showSugestoes = false;
      });
      widget.onClear?.call();
      return;
    }

    setState(() => _carregando = true);
    final result = await widget.onSearch(v);
    if (mounted) {
      setState(() {
        _sugestoes = result;
        _showSugestoes = true;
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ctrl,
          focusNode: _focus,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: Icon(widget.icon, size: 18),
            suffixText: widget.suffixText,
            suffixIcon: _carregando
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  )
                : (widget.valorSelecionado != null
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          _ctrl.clear();
                          setState(() => _sugestoes = []);
                          widget.onClear?.call();
                        })
                    : null),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: _onChanged,
        ),
        if (_showSugestoes && _sugestoes.isNotEmpty)
          Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _sugestoes.length,
                itemBuilder: (_, i) {
                  final item = _sugestoes[i];
                  return ListTile(
                    dense: true,
                    title: Text(
                      widget.labelBuilder(item),
                      style: const TextStyle(fontSize: 13),
                    ),
                    onTap: () {
                      _ctrl.text = widget.labelBuilder(item);
                      setState(() => _showSugestoes = false);
                      _focus.unfocus();
                      widget.onSelected(item);
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }
}

// ---------------------------------------------
// TELA: NOVO/EDITAR LANÇAMENTO
// ---------------------------------------------

class CustoOperacionalLancamentoScreen extends StatefulWidget {
  final String propriedadeId;
  final String? talhaoId;
  final int safra;
  final LancamentoModel? edicao;

  const CustoOperacionalLancamentoScreen({
    super.key,
    required this.propriedadeId,
    this.talhaoId,
    required this.safra,
    this.edicao,
  });

  @override
  State<CustoOperacionalLancamentoScreen> createState() =>
      _CustoOperacionalLancamentoScreenState();
}

class _CustoOperacionalLancamentoScreenState
    extends State<CustoOperacionalLancamentoScreen> {
  final _repo = CustoOperacionalRepository();
  final _service = CustoOperacionalService();
  final _formKey = GlobalKey<FormState>();

  // Seleções
  CategoriaModel? _categoria;
  OperacaoCatalogo? _operacao;
  MaquinaCatalogo? _maquina;
  ImplementoCatalogo? _implemento;
  InsumoCatalogo? _insumo;

  // Controllers
  final _operacaoCustomCtrl = TextEditingController();
  final _maquinaValorCtrl = TextEditingController();
  final _implementoValorCtrl = TextEditingController();
  final _rendimentoCtrl = TextEditingController();
  final _maquinaCustomCtrl = TextEditingController();
  final _implementoCustomCtrl = TextEditingController();
  final _insumoCustomCtrl = TextEditingController();
  final _insumoPrecoeCtrl = TextEditingController();
  final _insumoDoseCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  List<CategoriaModel> _categorias = [];
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
    if (widget.edicao != null) _preencherEdicao();
  }

  Future<void> _carregarCategorias() async {
    final cats = await _repo.getCategorias();
    setState(() => _categorias = cats);
  }

  void _preencherEdicao() {
    final e = widget.edicao!;
    _maquinaValorCtrl.text = e.maquinaValor?.toString() ?? '';
    _implementoValorCtrl.text = e.implementoValor?.toString() ?? '';
    _rendimentoCtrl.text = e.rendimento?.toString() ?? '';
    _insumoPrecoeCtrl.text = e.insumoPreco?.toString() ?? '';
    _insumoDoseCtrl.text = e.insumoDose?.toString() ?? '';
    _obsCtrl.text = e.observacao ?? '';
    _operacaoCustomCtrl.text = e.operacaoCustom ?? '';
    _maquinaCustomCtrl.text = e.maquinaCustom ?? '';
    _implementoCustomCtrl.text = e.implementoCustom ?? '';
    _insumoCustomCtrl.text = e.insumoCustom ?? '';
  }

  void _recalcular() => setState(() {});

  /// Getters para cálculos automáticos
  double get _operacaoValorTotal =>
      (double.tryParse(_maquinaValorCtrl.text) ?? 0) +
      (double.tryParse(_implementoValorCtrl.text) ?? 0);

  double get _operacaoRha =>
      _operacaoValorTotal * (double.tryParse(_rendimentoCtrl.text) ?? 0);

  double get _insumoRha =>
      (double.tryParse(_insumoPrecoeCtrl.text) ?? 0) *
      (double.tryParse(_insumoDoseCtrl.text) ?? 0);

  double get _custoTotal => _operacaoRha + _insumoRha;

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoria == null) {
      _snack('Selecione uma categoria');
      return;
    }

    setState(() => _salvando = true);

    try {
      final lancamento = LancamentoModel(
        id: widget.edicao?.id,
        propriedadeId: widget.propriedadeId,
        talhaoId: widget.talhaoId,
        categoriaId: _categoria!.id,
        safra: widget.safra,
        operacaoId: _operacao?.id,
        operacaoCustom:
            _operacaoCustomCtrl.text.isEmpty ? null : _operacaoCustomCtrl.text,
        maquinaId: _maquina?.id,
        maquinaCustom:
            _maquinaCustomCtrl.text.isEmpty ? null : _maquinaCustomCtrl.text,
        maquinaValor: double.tryParse(_maquinaValorCtrl.text),
        implementoId: _implemento?.id,
        implementoCustom: _implementoCustomCtrl.text.isEmpty
            ? null
            : _implementoCustomCtrl.text,
        implementoValor: double.tryParse(_implementoValorCtrl.text),
        rendimento: double.tryParse(_rendimentoCtrl.text),
        operacaoRha: _operacaoRha,
        insumoId: _insumo?.id,
        insumoCustom:
            _insumoCustomCtrl.text.isEmpty ? null : _insumoCustomCtrl.text,
        insumoPreco: double.tryParse(_insumoPrecoeCtrl.text),
        insumoDose: double.tryParse(_insumoDoseCtrl.text),
        insumoRha: _insumoRha,
        custoTotalRha: _custoTotal,
        observacao:
            _obsCtrl.text.isEmpty ? null : _obsCtrl.text,
      );

      await _repo.salvarLancamento(lancamento);
      await _service.recalcularTotaisPorPropriedadeSafra(widget.propriedadeId, widget.safra);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.edicao == null
                ? 'Lançamento criado!'
                : 'Lançamento atualizado!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _snack('Erro: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarAfcrc(
        title: widget.edicao == null ? 'Novo Lançamento' : 'Editar Lançamento',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // -- CATEGORIA --
            _secao('1ª Etapa de Produção'),
            DropdownButtonFormField<CategoriaModel>(
              value: _categoria,
              decoration: const InputDecoration(
                labelText: 'Categoria *',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _categorias
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text(c.nome)))
                  .toList(),
              validator: (v) =>
                  v == null ? 'Selecione uma categoria' : null,
              onChanged: (v) => setState(() {
                _categoria = v;
                _operacao = null;
              }),
            ),
            const SizedBox(height: 16),

            // -- OPERAÇÃO --
            if (_categoria != null) ...[
              _secao('2ª Operação'),
              SearchField<OperacaoCatalogo>(
                label: 'Buscar operação',
                icon: Icons.agriculture,
                valorSelecionado: _operacao,
                labelBuilder: (o) => o.nome,
                onSearch: (q) => _repo.searchOperacoes(q),
                onSelected: (o) => setState(() => _operacao = o),
                onClear: () => setState(() => _operacao = null),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _operacaoCustomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ou digite a operação',
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                  isDense: true,
                  helperText: 'Se não encontrar na lista',
                ),
              ),
              const SizedBox(height: 16),
            ],

            // -- MÁQUINA --
            _secao('3ª Máquina ou Diária'),
            SearchField<MaquinaCatalogo>(
              label: 'Buscar máquina',
              icon: Icons.precision_manufacturing,
              valorSelecionado: _maquina,
              labelBuilder: (m) => m.nome,
              onSearch: (q) => _repo.getMaquinas(query: q),
              onSelected: (m) {
                setState(() {
                  _maquina = m;
                  if (m.valorUnd != null) {
                    _maquinaValorCtrl.text = m.valorUnd!.toStringAsFixed(2);
                  }
                });
                _recalcular();
              },
              onClear: () => setState(() => _maquina = null),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _maquinaCustomCtrl,
              decoration: const InputDecoration(
                labelText: 'Ou digite a máquina',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            _campoNumerico(
              controller: _maquinaValorCtrl,
              label: 'Valor Máquina (R\$/und)',
              icon: Icons.attach_money,
              onChanged: (_) => _recalcular(),
            ),
            const SizedBox(height: 16),

            // -- IMPLEMENTO --
            _secao('4º Implemento'),
            SearchField<ImplementoCatalogo>(
              label: 'Buscar implemento',
              icon: Icons.build,
              valorSelecionado: _implemento,
              labelBuilder: (i) => i.nome,
              onSearch: (q) => _repo.getImplementos(query: q),
              onSelected: (i) {
                setState(() {
                  _implemento = i;
                  if (i.valorUnd != null) {
                    _implementoValorCtrl.text = i.valorUnd!.toStringAsFixed(2);
                  }
                });
                _recalcular();
              },
              onClear: () => setState(() => _implemento = null),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _implementoCustomCtrl,
              decoration: const InputDecoration(
                labelText: 'Ou digite o implemento',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            _campoNumerico(
              controller: _implementoValorCtrl,
              label: 'Valor Implemento (R\$/und)',
              icon: Icons.attach_money,
              onChanged: (_) => _recalcular(),
            ),
            const SizedBox(height: 8),
            _campoNumerico(
              controller: _rendimentoCtrl,
              label: 'Rendimento (und/ha)',
              icon: Icons.speed,
              onChanged: (_) => _recalcular(),
            ),
            const SizedBox(height: 16),

            // -- INSUMO --
            _secao('5º Insumo'),
            SearchField<InsumoCatalogo>(
              label: 'Buscar insumo',
              icon: Icons.science,
              valorSelecionado: _insumo,
              labelBuilder: (i) => '${i.nome} (${i.unidade})',
              onSearch: (q) => _repo.getInsumos(query: q),
              onSelected: (i) {
                setState(() {
                  _insumo = i;
                  if (i.valorUnd != null) {
                    _insumoPrecoeCtrl.text = i.valorUnd!.toStringAsFixed(2);
                  }
                });
                _recalcular();
              },
              onClear: () => setState(() => _insumo = null),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _insumoCustomCtrl,
              decoration: const InputDecoration(
                labelText: 'Ou digite o insumo',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _campoNumerico(
                    controller: _insumoPrecoeCtrl,
                    label: 'Preço (R\$/und)',
                    icon: Icons.attach_money,
                    onChanged: (_) => _recalcular(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _campoNumerico(
                    controller: _insumoDoseCtrl,
                    label: 'Dose (und/ha)',
                    icon: Icons.water_drop,
                    onChanged: (_) => _recalcular(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // -- RESUMO CALCULADO --
            _cardResumo(),
            const SizedBox(height: 16),

            // -- OBSERVAÇÃO --
            TextField(
              controller: _obsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Observação',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 24),

            // -- BOTÃO SALVAR --
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                label: Text(_salvando ? 'Salvando...' : 'Salvar Lançamento'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _secao(String titulo) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.primary,
          ),
        ),
      );

  Widget _campoNumerico({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    void Function(String)? onChanged,
  }) =>
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
        ],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: onChanged,
      );

  Widget _cardResumo() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo Calculado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _linhaResumo(
              'Operação (máq + impl)',
              'R\$ ${_operacaoValorTotal.toStringAsFixed(2)}/und',
            ),
            _linhaResumo(
              'Operação',
              'R\$ ${_operacaoRha.toStringAsFixed(4)}/ha',
            ),
            _linhaResumo(
              'Insumo',
              'R\$ ${_insumoRha.toStringAsFixed(4)}/ha',
            ),
            const Divider(thickness: 2),
            _linhaResumo(
              'CUSTO TOTAL',
              'R\$ ${_custoTotal.toStringAsFixed(2)}/ha',
              destaque: true,
            ),
          ],
        ),
      );

  Widget _linhaResumo(String label, String valor, {bool destaque = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    destaque ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              valor,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    destaque ? FontWeight.bold : FontWeight.normal,
                color: destaque ? AppColors.primary : null,
              ),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    _operacaoCustomCtrl.dispose();
    _maquinaValorCtrl.dispose();
    _implementoValorCtrl.dispose();
    _rendimentoCtrl.dispose();
    _maquinaCustomCtrl.dispose();
    _implementoCustomCtrl.dispose();
    _insumoCustomCtrl.dispose();
    _insumoPrecoeCtrl.dispose();
    _insumoDoseCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }
}


