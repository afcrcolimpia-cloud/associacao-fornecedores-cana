import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import '../models/models.dart';
import '../services/custo_operacional_service.dart';
import '../services/custo_operacional_repository.dart';
import '../services/dados_custo_operacional.dart';
import '../constants/app_colors.dart';
import 'custo_operacional_lancamento_screen.dart';

class CustoOperacionalFormScreen extends StatefulWidget {
  final Propriedade propriedade;
  final CustoOperacionalCenario? cenarioEditando;

  const CustoOperacionalFormScreen({
    super.key,
    required this.propriedade,
    this.cenarioEditando,
  });

  @override
  State<CustoOperacionalFormScreen> createState() =>
      _CustoOperacionalFormScreenState();
}

class _CustoOperacionalFormScreenState extends State<CustoOperacionalFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _service = CustoOperacionalService();
  final _repo = CustoOperacionalRepository();

  late TextEditingController _nomeCenarioController;
  late TextEditingController _periodoRefController;
  late TextEditingController _produtividadeController;
  late TextEditingController _atrController;
  late TextEditingController _longevidadeController;
  late TextEditingController _doseMudaController;
  late TextEditingController _precoDieselController;
  late TextEditingController _arrendamentoController;
  late TextEditingController _atrArrendController;
  late TextEditingController _precoAtrController;
  late TextEditingController _custoAdministrativoController;

  late TabController _tabController;
  List<CategoriaModel> _categorias = [];
  final Map<String, List<LancamentoModel>> _lancamentosPorCategoria = {};

  bool _isSaving = false;
  bool _carregandoCategorias = true;
  bool _usandoFallbackAfcrc = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    // Inicializar TabController com comprimento padrão
    _tabController = TabController(length: 1, vsync: this);
    _carregarCategorias();
  }

  void _initializeControllers() {
    if (widget.cenarioEditando != null) {
      _nomeCenarioController =
          TextEditingController(text: widget.cenarioEditando!.nomeCenario);
      _periodoRefController =
          TextEditingController(text: widget.cenarioEditando!.periodoRef);
      _produtividadeController = TextEditingController(
          text: widget.cenarioEditando!.produtividade.toString());
      _atrController =
          TextEditingController(text: widget.cenarioEditando!.atr.toString());
      _longevidadeController = TextEditingController(
          text: (widget.cenarioEditando!.longevidade ??
                  DadosCustoOperacional.parametros.longevidade)
              .toString());
      _doseMudaController = TextEditingController(
          text: (widget.cenarioEditando!.doseMuda ??
                  DadosCustoOperacional.parametros.doseMuda)
              .toString());
      _precoDieselController = TextEditingController(
          text: widget.cenarioEditando!.precoDiesel?.toString() ?? '');
      _arrendamentoController = TextEditingController(
          text: widget.cenarioEditando!.arrendamento?.toString() ?? '');
      _atrArrendController = TextEditingController(
          text: (widget.cenarioEditando!.atrArrend ??
                  DadosCustoOperacional.parametros.atrArrend)
              .toString());
      _precoAtrController = TextEditingController(
          text: widget.cenarioEditando!.precoAtr?.toString() ?? '');
      _custoAdministrativoController = TextEditingController(
          text: widget.cenarioEditando!.custoAdministrativo?.toString() ?? '');
    } else {
      _nomeCenarioController = TextEditingController(text: 'Cenário Padrão');
      _periodoRefController = TextEditingController(
          text: DadosCustoOperacional.parametros.periodoRef);
      _produtividadeController = TextEditingController(
          text: DadosCustoOperacional.parametros.produtividade.toString());
      _atrController = TextEditingController(
          text: DadosCustoOperacional.parametros.atr.toString());
      _longevidadeController = TextEditingController(
          text: DadosCustoOperacional.parametros.longevidade.toString());
      _doseMudaController = TextEditingController(
          text: DadosCustoOperacional.parametros.doseMuda.toString());
      _precoDieselController = TextEditingController(
          text: DadosCustoOperacional.parametros.precoDiesel.toString());
      _arrendamentoController = TextEditingController(
          text: DadosCustoOperacional.parametros.arrendamento.toString());
      _atrArrendController = TextEditingController(
          text: DadosCustoOperacional.parametros.atrArrend.toString());
      _precoAtrController = TextEditingController(
          text: DadosCustoOperacional.parametros.precoATR.toString());
      _custoAdministrativoController = TextEditingController(text: '10');
    }
  }

  Future<void> _carregarCategorias() async {
    final safra = _safraAtual;
    try {
      var categorias = await _repo.buscarCategorias();
      final lancamentosPorCategoria = <String, List<LancamentoModel>>{};
      var usandoFallback = false;

      if (categorias.isEmpty) {
        usandoFallback = true;
        categorias = _categoriasFallbackAfcrc();
        for (final categoria in categorias) {
          lancamentosPorCategoria[categoria.id] =
              _lancamentosFallbackPorCategoria(categoria.id, safra);
        }
      } else {
        for (final categoria in categorias) {
          final lancamentos = await _repo.buscarLancamentosPorCategoria(
            widget.propriedade.id,
            categoria.id,
            safra,
          );
          lancamentosPorCategoria[categoria.id] = lancamentos;
        }
      }

      if (!mounted) return;

      _tabController.dispose();
      _tabController =
          TabController(length: categorias.length + 1, vsync: this);

      setState(() {
        _categorias = categorias;
        _usandoFallbackAfcrc = usandoFallback;
        _lancamentosPorCategoria
          ..clear()
          ..addAll(lancamentosPorCategoria);
        _carregandoCategorias = false;
      });
    } catch (e) {
      if (mounted) {
        final categorias = _categoriasFallbackAfcrc();
        final lancamentosPorCategoria = <String, List<LancamentoModel>>{};
        for (final categoria in categorias) {
          lancamentosPorCategoria[categoria.id] =
              _lancamentosFallbackPorCategoria(categoria.id, safra);
        }
        _tabController.dispose();
        _tabController =
            TabController(length: categorias.length + 1, vsync: this);

        setState(() {
          _categorias = categorias;
          _usandoFallbackAfcrc = true;
          _lancamentosPorCategoria
            ..clear()
            ..addAll(lancamentosPorCategoria);
          _carregandoCategorias = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Catálogo indisponível, usando referência AFCRC local. Detalhe: $e',
            ),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeCenarioController.dispose();
    _periodoRefController.dispose();
    _produtividadeController.dispose();
    _atrController.dispose();
    _longevidadeController.dispose();
    _doseMudaController.dispose();
    _precoDieselController.dispose();
    _arrendamentoController.dispose();
    _atrArrendController.dispose();
    _precoAtrController.dispose();
    _custoAdministrativoController.dispose();
    try {
      _tabController.dispose();
    } catch (_) {
      // TabController já foi descartado
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final produtividade = double.parse(_produtividadeController.text);
      final atr = int.parse(_atrController.text);
      final longevidade = int.tryParse(_longevidadeController.text);
      final doseMuda = double.tryParse(_doseMudaController.text);
      final precoDiesel = double.tryParse(_precoDieselController.text);
      final arrendamento = double.tryParse(_arrendamentoController.text);
      final atrArrend = double.tryParse(_atrArrendController.text);
      final precoAtr = double.tryParse(_precoAtrController.text);
      final custoAdmin = double.tryParse(_custoAdministrativoController.text);
      final cenarioBase = CustoOperacionalCenario(
        id: widget.cenarioEditando?.id,
        propriedadeId: widget.propriedade.id,
        periodoRef: _periodoRefController.text,
        nomeCenario: _nomeCenarioController.text,
        produtividade: produtividade,
        atr: atr,
        longevidade: longevidade,
        doseMuda: doseMuda,
        precoDiesel: precoDiesel,
        arrendamento: arrendamento,
        atrArrend: atrArrend,
        precoAtr: precoAtr,
        custoAdministrativo: custoAdmin,
      );
      final resumoFallback = _usandoFallbackAfcrc
          ? _service.calcularResumoComTotais(
              cenario: cenarioBase,
              totaisCategorias: _obterTotaisCategoriasLocais(),
            )
          : null;

      final cenario = CustoOperacionalCenario(
        id: cenarioBase.id,
        propriedadeId: cenarioBase.propriedadeId,
        periodoRef: cenarioBase.periodoRef,
        nomeCenario: cenarioBase.nomeCenario,
        produtividade: cenarioBase.produtividade,
        atr: cenarioBase.atr,
        longevidade: cenarioBase.longevidade,
        doseMuda: cenarioBase.doseMuda,
        precoDiesel: cenarioBase.precoDiesel,
        custoAdministrativo: cenarioBase.custoAdministrativo,
        arrendamento: cenarioBase.arrendamento,
        atrArrend: cenarioBase.atrArrend,
        precoAtr: cenarioBase.precoAtr,
        totalOperacional: resumoFallback?.totalOperacional.rHa,
        margemLucro: resumoFallback?.margemPercentual,
        margemLucroPorTonelada: resumoFallback?.margemLucro.rT,
      );

      if (widget.cenarioEditando != null) {
        await _service.atualizarCenario(
          widget.cenarioEditando!.id!,
          cenario,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cenário atualizado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        await _service.criarCenario(cenario);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cenário criado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditando = widget.cenarioEditando != null;

    // Mostrar tela de carregamento enquanto categorias são carregadas
    if (_carregandoCategorias) {
      return Scaffold(
        appBar: AppBarAfcrc(title: isEditando ? 'Editar Cenário' : 'Novo Cenário'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Se não há categorias após carregar, mostrar erro
    if (_categorias.isEmpty) {
      return Scaffold(
        appBar: AppBarAfcrc(title: isEditando ? 'Editar Cenário' : 'Novo Cenário'),
        body: const Center(
          child: Text('Nenhuma categoria disponível'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBarAfcrc(
        title: isEditando ? 'Editar Cenário' : 'Novo Cenário',
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Parâmetros'),
            ..._categorias.map((cat) => Tab(text: cat.nome)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ABA 1: PARÂMETROS TÉCNICOS
          _buildAbaParametros(),
          // ABAS 2+: CATEGORIAS
          ..._categorias.map((categoria) => _buildAbaCategoria(categoria)),
        ],
      ),
    );
  }

  Widget _buildAbaParametros() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFORMAÇÕES BÁSICAS
            _buildSectionTitle('Informações Básicas'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nomeCenarioController,
              decoration: const InputDecoration(
                labelText: 'Nome do Cenário',
                hintText: 'Ex: Cenário Base, Pessimista, Otimista',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite um nome para o cenário';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _periodoRefController,
              decoration: const InputDecoration(
                labelText: 'Período de Referência',
                hintText: 'Ex: Jan-Fev/2026',
                prefixIcon: Icon(Icons.calendar_month),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o período';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _longevidadeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Longevidade',
                      suffixText: 'safras',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _doseMudaController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Dose de Muda',
                      suffixText: 't/ha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // PARÂMETROS TÉCNICOS
            _buildSectionTitle('Parâmetros Técnicos'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _produtividadeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Produtividade',
                      suffixText: 't/ha',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatorio';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _atrController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ATR',
                      suffixText: 'kg/t',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatorio';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // PREÇOS
            _buildSectionTitle('Preços de Mercado'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precoDieselController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Diesel',
                      suffixText: 'R\$/L',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _precoAtrController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Preço ATR',
                      suffixText: 'R\$/kg',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // CUSTOS
            _buildSectionTitle('Custos de Operação'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _arrendamentoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Arrendamento',
                      suffixText: 't/ha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _atrArrendController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'ATR Arrendamento',
                      suffixText: 'kg/t',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _custoAdministrativoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Administrativo',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),

            // BOTÕES
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _salvar,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'SALVAR CENÁRIO',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbaCategoria(CategoriaModel categoria) {
    final lancamentos = _lancamentosPorCategoria[categoria.id] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_usandoFallbackAfcrc) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Text(
                'Referência AFCRC carregada localmente. Você pode editar os dados na lista abaixo.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
          // Botão para adicionar novo lançamento
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _usandoFallbackAfcrc
                  ? _editarLancamentoFallback(categoria: categoria)
                  : _abrirNovoLancamento(categoria),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Operação'),
            ),
          ),
          const SizedBox(height: 16),

          // Lista de lançamentos
          if (lancamentos.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.list_alt_outlined,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma operação cadastrada',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lancamentos.length,
              itemBuilder: (context, index) {
                final lancamento = lancamentos[index];
                return _buildLancamentoCard(lancamento, categoria);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLancamentoCard(
      LancamentoModel lancamento, CategoriaModel categoria) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operação
            Text(
              lancamento.operacaoCustom ?? 'Operação',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            // Detalhes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Máquina: ${lancamento.maquinaCustom ?? 'N/A'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${lancamento.maquinaValor?.toStringAsFixed(2) ?? '0.00'}/un',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total R\$/ha',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${lancamento.custoTotalRha?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Botões de ação
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _usandoFallbackAfcrc
                      ? _editarLancamentoFallback(
                          categoria: categoria,
                          lancamentoOriginal: lancamento,
                        )
                      : _editarLancamento(lancamento, categoria),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                ),
                TextButton.icon(
                  onPressed: () => _deletarLancamento(lancamento, categoria),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text('Deletar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirNovoLancamento(CategoriaModel categoria) async {
    final safra = _safraAtual;
    final resultado = await Navigator.push<LancamentoModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CustoOperacionalLancamentoScreen(
          propriedadeId: widget.propriedade.id,
          safra: safra,
        ),
      ),
    );

    if (resultado != null && mounted) {
      // Recarregar lançamentos da categoria
      final lancamentos = await _repo.buscarLancamentosPorCategoria(
        widget.propriedade.id,
        categoria.id,
        safra,
      );
      setState(() {
        _lancamentosPorCategoria[categoria.id] = lancamentos;
      });
      await _service.recalcularTotaisPorPropriedadeSafra(
        widget.propriedade.id,
        safra,
      );
    }
  }

  Future<void> _editarLancamento(
      LancamentoModel lancamento, CategoriaModel categoria) async {
    final safra = _safraAtual;
    final resultado = await Navigator.push<LancamentoModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CustoOperacionalLancamentoScreen(
          propriedadeId: widget.propriedade.id,
          safra: safra,
          edicao: lancamento,
        ),
      ),
    );

    if (resultado != null && mounted) {
      // Recarregar lançamentos da categoria
      final lancamentos = await _repo.buscarLancamentosPorCategoria(
        widget.propriedade.id,
        categoria.id,
        safra,
      );
      setState(() {
        _lancamentosPorCategoria[categoria.id] = lancamentos;
      });
      await _service.recalcularTotaisPorPropriedadeSafra(
        widget.propriedade.id,
        safra,
      );
    }
  }

  Future<void> _deletarLancamento(
    LancamentoModel lancamento,
    CategoriaModel categoria,
  ) async {
    final safra = _safraAtual;
    if (_usandoFallbackAfcrc) {
      final confirmou = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remover Operação'),
          content: const Text('Deseja remover esta operação da lista?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remover', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmou == true && mounted) {
        final atuais = List<LancamentoModel>.from(
          _lancamentosPorCategoria[categoria.id] ?? <LancamentoModel>[],
        )..remove(lancamento);
        setState(() => _lancamentosPorCategoria[categoria.id] = atuais);
      }
      return;
    }

    if (lancamento.id == null) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deletar Operação'),
        content: const Text('Tem certeza que deseja deletar esta operação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      try {
        await _repo.deletarLancamento(lancamento.id!);
        await _service.recalcularTotaisPorPropriedadeSafra(
          widget.propriedade.id,
          safra,
        );
        if (mounted) {
          // Recarregar lançamentos para todas as categorias
          for (var categoria in _categorias) {
            final lancamentos = await _repo.buscarLancamentosPorCategoria(
              widget.propriedade.id,
              categoria.id,
              safra,
            );
            if (!mounted) return;
            setState(() {
              _lancamentosPorCategoria[categoria.id] = lancamentos;
            });
          }
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Operação deletada com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao deletar: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  List<CategoriaModel> _categoriasFallbackAfcrc() {
    return const [
      CategoriaModel(
          id: 'afcrc-conservacao', nome: 'Conservação de Solo', ordem: 1),
      CategoriaModel(id: 'afcrc-preparo', nome: 'Preparo de Solo', ordem: 2),
      CategoriaModel(id: 'afcrc-plantio', nome: 'Plantio', ordem: 3),
      CategoriaModel(
        id: 'afcrc-manutencao',
        nome: 'Manutenção de Soqueira',
        ordem: 4,
      ),
      CategoriaModel(
          id: 'afcrc-colheita', nome: 'Sistema de Colheita', ordem: 5),
    ];
  }

  List<LancamentoModel> _lancamentosFallbackPorCategoria(
    String categoriaId,
    int safra,
  ) {
    final estagios = DadosCustoOperacional.obterEstagios();
    final estagioPorCategoria = <String, int>{
      'afcrc-conservacao': 0,
      'afcrc-preparo': 1,
      'afcrc-plantio': 2,
      'afcrc-manutencao': 3,
      'afcrc-colheita': 4,
    };

    final indice = estagioPorCategoria[categoriaId];
    if (indice == null || indice >= estagios.length) return [];

    return estagios[indice]
        .operacoes
        .map(
          (operacao) => LancamentoModel(
            propriedadeId: widget.propriedade.id,
            categoriaId: categoriaId,
            safra: safra,
            operacaoCustom: operacao.operacao,
            maquinaCustom: operacao.maquina == '-' ? null : operacao.maquina,
            maquinaValor: operacao.maquinaVal,
            implementoCustom:
                operacao.implemento == '-' ? null : operacao.implemento,
            implementoValor: operacao.implVal,
            rendimento: operacao.rend,
            operacaoRha: operacao.operRHa,
            insumoCustom: (operacao.insumo == null || operacao.insumo == '-')
                ? null
                : operacao.insumo,
            insumoPreco:
                _calcularPrecoInsumo(operacao.insumoRHa, operacao.dose),
            insumoDose: operacao.dose,
            insumoRha: operacao.insumoRHa,
            custoTotalRha: operacao.total,
          ),
        )
        .toList();
  }

  double? _calcularPrecoInsumo(double? insumoRha, double? dose) {
    if (insumoRha == null || dose == null || dose == 0) return null;
    return insumoRha / dose;
  }

  String? _normalizarCategoriaLocal(String categoriaId, String categoriaNome) {
    final bruto = '$categoriaId $categoriaNome'.toLowerCase();
    if (bruto.contains('conserv')) return 'conservacao';
    if (bruto.contains('preparo')) return 'preparo';
    if (bruto.contains('plantio')) return 'plantio';
    if (bruto.contains('manut')) return 'manutencao';
    if (bruto.contains('colheita')) return 'colheita';
    return null;
  }

  Map<String, double> _obterTotaisCategoriasLocais() {
    final totais = <String, double>{};

    for (final categoria in _categorias) {
      final chave = _normalizarCategoriaLocal(categoria.id, categoria.nome);
      if (chave == null) continue;

      final totalCategoria =
          (_lancamentosPorCategoria[categoria.id] ?? const <LancamentoModel>[])
              .fold<double>(
        0.0,
        (soma, lancamento) => soma + (lancamento.custoTotalRha ?? 0.0),
      );

      totais[chave] = totalCategoria;
    }

    return totais;
  }

  Future<void> _editarLancamentoFallback({
    required CategoriaModel categoria,
    LancamentoModel? lancamentoOriginal,
  }) async {
    final safra = _safraAtual;
    final opCtrl =
        TextEditingController(text: lancamentoOriginal?.operacaoCustom ?? '');
    final maqCtrl =
        TextEditingController(text: lancamentoOriginal?.maquinaCustom ?? '');
    final maqValCtrl = TextEditingController(
      text: lancamentoOriginal?.maquinaValor?.toString() ?? '',
    );
    final implCtrl = TextEditingController(
      text: lancamentoOriginal?.implementoCustom ?? '',
    );
    final implValCtrl = TextEditingController(
      text: lancamentoOriginal?.implementoValor?.toString() ?? '',
    );
    final rendCtrl = TextEditingController(
      text: lancamentoOriginal?.rendimento?.toString() ?? '',
    );
    final insumoCtrl =
        TextEditingController(text: lancamentoOriginal?.insumoCustom ?? '');
    final insumoPrecoCtrl = TextEditingController(
      text: lancamentoOriginal?.insumoPreco?.toString() ?? '',
    );
    final doseCtrl = TextEditingController(
      text: lancamentoOriginal?.insumoDose?.toString() ?? '',
    );

    final salvou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            lancamentoOriginal == null ? 'Nova Operação' : 'Editar Operação'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campoDialogo(opCtrl, 'Operação'),
                _campoDialogo(maqCtrl, 'Máquina'),
                _campoDialogo(maqValCtrl, 'Valor máquina (R\$/und)',
                    numerico: true),
                _campoDialogo(implCtrl, 'Implemento'),
                _campoDialogo(implValCtrl, 'Valor implemento (R\$/und)',
                    numerico: true),
                _campoDialogo(rendCtrl, 'Rendimento', numerico: true),
                _campoDialogo(insumoCtrl, 'Insumo'),
                _campoDialogo(insumoPrecoCtrl, 'Preço insumo (R\$/und)',
                    numerico: true),
                _campoDialogo(doseCtrl, 'Dose', numerico: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (salvou != true || !mounted) return;

    final maquinaValor = _toDouble(maqValCtrl.text);
    final implementoValor = _toDouble(implValCtrl.text);
    final rendimento = _toDouble(rendCtrl.text);
    final insumoPreco = _toDouble(insumoPrecoCtrl.text);
    final insumoDose = _toDouble(doseCtrl.text);
    final operacaoRha = (maquinaValor + implementoValor) * rendimento;
    final insumoRha = insumoPreco * insumoDose;
    final total = operacaoRha + insumoRha;

    final atualizado = LancamentoModel(
      propriedadeId: widget.propriedade.id,
      categoriaId: categoria.id,
      safra: safra,
      operacaoCustom: opCtrl.text.trim().isEmpty ? null : opCtrl.text.trim(),
      maquinaCustom: maqCtrl.text.trim().isEmpty ? null : maqCtrl.text.trim(),
      maquinaValor: maquinaValor,
      implementoCustom:
          implCtrl.text.trim().isEmpty ? null : implCtrl.text.trim(),
      implementoValor: implementoValor,
      rendimento: rendimento,
      operacaoRha: operacaoRha,
      insumoCustom:
          insumoCtrl.text.trim().isEmpty ? null : insumoCtrl.text.trim(),
      insumoPreco: insumoPreco,
      insumoDose: insumoDose,
      insumoRha: insumoRha,
      custoTotalRha: total,
    );

    final listaAtual = List<LancamentoModel>.from(
      _lancamentosPorCategoria[categoria.id] ?? <LancamentoModel>[],
    );
    final indice = lancamentoOriginal == null
        ? -1
        : listaAtual.indexOf(lancamentoOriginal);

    setState(() {
      if (indice >= 0) {
        listaAtual[indice] = atualizado;
      } else {
        listaAtual.add(atualizado);
      }
      _lancamentosPorCategoria[categoria.id] = listaAtual;
    });
  }

  Widget _campoDialogo(
    TextEditingController controller,
    String label, {
    bool numerico = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: numerico
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  double _toDouble(String valor) => double.tryParse(valor.trim()) ?? 0.0;

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  int get _safraAtual => _inferirSafra(_periodoRefController.text);

  int _inferirSafra(String periodoRef) {
    final matches = RegExp(r'(20\d{2})').allMatches(periodoRef);
    if (matches.isNotEmpty) {
      return int.parse(matches.last.group(1)!);
    }
    return DateTime.now().year;
  }
}
