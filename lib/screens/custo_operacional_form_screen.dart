import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
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
  int _selectedNavigationIndex = 0;

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
      _custoAdministrativoController = TextEditingController(
          text: DadosCustoOperacional.parametros.custoAdmin.toString());
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

  void _abrirCalculadoraAdministrativa() {
    final contadorCtrl = TextEditingController();
    final escritorioCtrl = TextEditingController();
    final gerenteCtrl = TextEditingController();
    final internetCtrl = TextEditingController();
    final licencasCtrl = TextEditingController();
    final outrosCtrl = TextEditingController();
    final areaCtrl = TextEditingController(
      text: widget.propriedade.areaHa?.toString() ?? '',
    );
    final baseCtrl = TextEditingController(text: '18536.17');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calcular Despesas Administrativas'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Insira os gastos anuais (R\$):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildInputAdm('Contador', contadorCtrl),
              _buildInputAdm('Escritório', escritorioCtrl),
              _buildInputAdm('Gerente', gerenteCtrl),
              _buildInputAdm('Internet', internetCtrl),
              _buildInputAdm('Licenças', licencasCtrl),
              _buildInputAdm('Outros', outrosCtrl),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildInputAdm('Área Cultivada (ha)', areaCtrl),
              _buildInputAdm('Base Operacional (R\$/ha)', baseCtrl,
                  hint: 'Padrão: 18.536,17 (AFCRC)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _calcularAdministrativo(
                contador: double.tryParse(contadorCtrl.text) ?? 0,
                escritorio: double.tryParse(escritorioCtrl.text) ?? 0,
                gerente: double.tryParse(gerenteCtrl.text) ?? 0,
                internet: double.tryParse(internetCtrl.text) ?? 0,
                licencas: double.tryParse(licencasCtrl.text) ?? 0,
                outros: double.tryParse(outrosCtrl.text) ?? 0,
                area: double.tryParse(areaCtrl.text) ?? 1,
                baseOperacional: double.tryParse(baseCtrl.text) ?? 18536.17,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              'Calcular e Aplicar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputAdm(String label, TextEditingController controller,
      {String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }

  void _calcularAdministrativo({
    required double contador,
    required double escritorio,
    required double gerente,
    required double internet,
    required double licencas,
    required double outros,
    required double area,
    required double baseOperacional,
  }) {
    if (area <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Informe uma área válida maior que 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Soma todos os gastos anuais
    final totalAnual = contador + escritorio + gerente + internet + licencas + outros;

    // Custo administrativo por hectare
    final admPorHa = totalAnual / area;

    // Percentual = (Adm R$/ha ÷ Base) × 100
    final percentualAdm = (admPorHa / baseOperacional) * 100;

    // Aplicar ao campo
    setState(() {
      _custoAdministrativoController.text = percentualAdm.toStringAsFixed(4);
    });

    // Mostrar resumo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✅ Cálculo Realizado:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Total Anual: R\$ ${totalAnual.toStringAsFixed(2)}'),
            Text('Por Hectare: R\$ ${admPorHa.toStringAsFixed(2)}'),
            Text(
                'Percentual: ${percentualAdm.toStringAsFixed(4)}% (aplicado)'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
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
      return AppShell(
        selectedIndex: _selectedNavigationIndex,
        title: isEditando ? 'Editar Cenário' : 'Novo Cenário',
        showBackButton: true,
        onNavigationSelect: (index) {
          setState(() => _selectedNavigationIndex = index);
        },
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Se não há categorias após carregar, mostrar erro
    if (_categorias.isEmpty) {
      return AppShell(
        selectedIndex: _selectedNavigationIndex,
        title: isEditando ? 'Editar Cenário' : 'Novo Cenário',
        showBackButton: true,
        onNavigationSelect: (index) {
          setState(() => _selectedNavigationIndex = index);
        },
        child: const Center(
          child: Text('Nenhuma categoria disponível'),
        ),
      );
    }

    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      title: isEditando ? 'Editar Cenário' : 'Novo Cenário',
      showBackButton: true,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              const Tab(text: 'Parâmetros'),
              ..._categorias.map((cat) => Tab(text: cat.nome)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ABA 1: PARÂMETROS TÉCNICOS
                _buildAbaParametros(),
                // ABAS 2+: CATEGORIAS
                ..._categorias.map((categoria) => _buildAbaCategoria(categoria)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbaParametros() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // INFORMAÇÕES BÁSICAS
                _buildSectionCard(
                  titulo: 'Informações Básicas',
                  icone: Icons.info_outline,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _campo(
                            controller: _nomeCenarioController,
                            label: 'Nome do Cenário',
                            hint: 'Ex: Cenário Base, Pessimista',
                            icone: Icons.label,
                            obrigatorio: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _campo(
                            controller: _periodoRefController,
                            label: 'Período de Referência',
                            hint: 'Ex: Jan-Fev/2026',
                            icone: Icons.calendar_month,
                            obrigatorio: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _campo(
                            controller: _longevidadeController,
                            label: 'Longevidade',
                            sufixo: 'safras',
                            numerico: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _campo(
                            controller: _doseMudaController,
                            label: 'Dose de Muda',
                            sufixo: 't/ha',
                            numerico: true,
                            decimal: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _campo(
                            controller: _produtividadeController,
                            label: 'Produtividade',
                            sufixo: 't/ha',
                            numerico: true,
                            decimal: true,
                            obrigatorio: true,
                            validadorExtra: (v) =>
                                double.tryParse(v) == null ? 'Inválido' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _campo(
                            controller: _atrController,
                            label: 'ATR',
                            sufixo: 'kg/t',
                            numerico: true,
                            obrigatorio: true,
                            validadorExtra: (v) =>
                                int.tryParse(v) == null ? 'Inválido' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // PREÇOS E CUSTOS numa única seção lado a lado
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PREÇOS DE MERCADO
                    Expanded(
                      child: _buildSectionCard(
                        titulo: 'Preços de Mercado',
                        icone: Icons.attach_money,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _campo(
                                  controller: _precoDieselController,
                                  label: 'Diesel',
                                  sufixo: 'R\$/L',
                                  numerico: true,
                                  decimal: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _campo(
                                  controller: _precoAtrController,
                                  label: 'Preço ATR',
                                  sufixo: 'R\$/kg',
                                  numerico: true,
                                  decimal: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // CUSTOS DE OPERAÇÃO
                    Expanded(
                      child: _buildSectionCard(
                        titulo: 'Custos de Operação',
                        icone: Icons.account_balance_wallet,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _campo(
                                  controller: _arrendamentoController,
                                  label: 'Arrendamento',
                                  sufixo: 't/ha',
                                  numerico: true,
                                  decimal: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _campo(
                                  controller: _atrArrendController,
                                  label: 'ATR Arrend.',
                                  sufixo: 'kg/t',
                                  numerico: true,
                                  decimal: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _campo(
                                  controller: _custoAdministrativoController,
                                  label: 'Administrativo',
                                  sufixo: '%',
                                  numerico: true,
                                  decimal: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Tooltip(
                                message: 'Calcular automaticamente',
                                child: SizedBox(
                                  height: 44,
                                  child: ElevatedButton.icon(
                                    onPressed: _abrirCalculadoraAdministrativa,
                                    icon: const Icon(Icons.calculate, size: 18),
                                    label: const Text('Calc'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.newPrimary,
                                      foregroundColor: AppColors.bgDark,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // BOTÃO SALVAR
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _salvar,
                    icon: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _isSaving ? 'SALVANDO...' : 'SALVAR CENÁRIO',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.newPrimary,
                      foregroundColor: AppColors.bgDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Card visual para agrupar campos de uma seção
  Widget _buildSectionCard({
    required String titulo,
    required IconData icone,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 18, color: AppColors.newPrimary),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.newTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  /// Campo de texto compacto e reutilizável
  Widget _campo({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? sufixo,
    IconData? icone,
    bool numerico = false,
    bool decimal = false,
    bool obrigatorio = false,
    String? Function(String)? validadorExtra,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: numerico
          ? TextInputType.numberWithOptions(decimal: decimal)
          : TextInputType.text,
      style: const TextStyle(
          fontSize: 13, color: AppColors.newTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: sufixo,
        prefixIcon: icone != null ? Icon(icone, size: 18) : null,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.borderDark),
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.newPrimary),
          borderRadius: BorderRadius.circular(6),
        ),
        filled: true,
        fillColor: AppColors.bgDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
        labelStyle:
            const TextStyle(fontSize: 12, color: AppColors.newTextSecondary),
        hintStyle:
            const TextStyle(fontSize: 12, color: AppColors.newTextMuted),
        suffixStyle:
            const TextStyle(fontSize: 11, color: AppColors.newTextMuted),
      ),
      validator: obrigatorio
          ? (value) {
              if (value == null || value.isEmpty) return 'Obrigatório';
              return validadorExtra?.call(value);
            }
          : null,
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

  int get _safraAtual => _inferirSafra(_periodoRefController.text);

  int _inferirSafra(String periodoRef) {
    final matches = RegExp(r'(20\d{2})').allMatches(periodoRef);
    if (matches.isNotEmpty) {
      return int.parse(matches.last.group(1)!);
    }
    return DateTime.now().year;
  }
}
