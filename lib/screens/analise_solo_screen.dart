import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/analise_solo_service.dart';
import '../services/talhao_service.dart';
import '../services/pdf_generators/pdf_analise_solo.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'analise_solo_graficos_screen.dart';

class AnaliseSoloScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const AnaliseSoloScreen({super.key, required this.contexto});

  @override
  State<AnaliseSoloScreen> createState() => _AnaliseSoloScreenState();
}

class _AnaliseSoloScreenState extends State<AnaliseSoloScreen>
    with SingleTickerProviderStateMixin {
  final AnaliseSoloService _service = AnaliseSoloService();
  final TalhaoService _talhaoService = TalhaoService();
  late TabController _tabController;
  int _navIndex = 0;

  // ─── Estado ───
  String? _culturaSelecionada;
  String? _talhaoId;
  String? _editandoId;
  bool _calculado = false;
  bool _salvando = false;
  bool _carregandoHistorico = true;
  ResultadoInterpretacao? _resultado;
  List<AnaliseSolo> _historico = [];
  List<Talhao> _talhoes = [];
  DateTime? _dataColeta;
  DateTime? _dataResultado;

  // ─── Controllers ───
  final _labCtrl = TextEditingController();
  final _amostraCtrl = TextEditingController();
  final _profCtrl = TextEditingController(text: '20');
  final _argilaCtrl = TextEditingController();
  final _prntCtrl = TextEditingController(text: '100');
  final _prodCtrl = TextEditingController();
  final _phCtrl = TextEditingController();
  final _moCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  final _kCtrl = TextEditingController();
  final _caCtrl = TextEditingController();
  final _mgCtrl = TextEditingController();
  final _alCtrl = TextEditingController();
  final _halCtrl = TextEditingController();
  final _sCtrl = TextEditingController();
  final _cuCtrl = TextEditingController();
  final _feCtrl = TextEditingController();
  final _mnCtrl = TextEditingController();
  final _znCtrl = TextEditingController();
  final _bCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  List<TextEditingController> get _allControllers => [
        _labCtrl, _amostraCtrl, _profCtrl, _argilaCtrl, _prntCtrl, _prodCtrl,
        _phCtrl, _moCtrl, _pCtrl, _kCtrl, _caCtrl, _mgCtrl,
        _alCtrl, _halCtrl, _sCtrl,
        _cuCtrl, _feCtrl, _mnCtrl, _znCtrl, _bCtrl, _obsCtrl,
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final results = await Future.wait([
        _service.getAnalisesPorPropriedade(widget.contexto.propriedade.id),
        _talhaoService.getTalhoesPorPropriedade(widget.contexto.propriedade.id),
      ]);
      if (mounted) {
        setState(() {
          _historico = results[0] as List<AnaliseSolo>;
          _talhoes = results[1] as List<Talhao>;
          _carregandoHistorico = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregandoHistorico = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  double? _d(TextEditingController c) {
    final t = c.text.trim().replaceAll(',', '.');
    return t.isEmpty ? null : double.tryParse(t);
  }

  String _nomeTalhao(String? id) {
    if (id == null) return 'Geral';
    final t = _talhoes.where((t) => t.id == id).firstOrNull;
    return t?.nome ?? 'Talhão';
  }

  String _fmtData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ═══════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _navIndex,
      onNavigationSelect: (i) => setState(() => _navIndex = i),
      showBackButton: true,
      title: 'Análise de Solo',
      child: Column(
        children: [
          HeaderPropriedade(contexto: widget.contexto),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildDadosTab(), _buildResultadoTab(), _buildHistoricoTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surfaceDark,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.newPrimary,
        labelColor: AppColors.newPrimary,
        unselectedLabelColor: AppColors.newTextSecondary,
        tabs: const [
          Tab(icon: Icon(Icons.edit_note, size: 20), text: 'DADOS'),
          Tab(icon: Icon(Icons.science, size: 20), text: 'RESULTADO'),
          Tab(icon: Icon(Icons.history, size: 20), text: 'HISTÓRICO'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ABA 1 — DADOS
  // ═══════════════════════════════════════════════════

  Widget _buildDadosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBannerBoletim100(),
          const SizedBox(height: 16),
          _buildChipsCultura(),
          if (_culturaSelecionada != null) ...[
            const SizedBox(height: 12),
            _buildAutoParams(),
          ],
          const SizedBox(height: 16),
          _buildSecaoDadosGerais(),
          const SizedBox(height: 16),
          _buildSecaoMacronutrientes(),
          const SizedBox(height: 16),
          _buildSecaoMicronutrientes(),
          const SizedBox(height: 16),
          _buildSecaoFisicosCalcario(),
          const SizedBox(height: 16),
          _buildSecaoObservacoes(),
          const SizedBox(height: 24),
          _buildBotaoCalcular(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBannerBoletim100() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.newInfo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.newInfo.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book, color: AppColors.newInfo, size: 28),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Interpretação baseada no Boletim 100 — IAC',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                        color: AppColors.newTextPrimary)),
                SizedBox(height: 4),
                Text(
                  'Recomendações de Adubação e Calagem para o Estado de São Paulo '
                  '(5ª Aproximação). Selecione a cultura para carregar os parâmetros '
                  'automáticos do Quadro 3.',
                  style: TextStyle(fontSize: 11, color: AppColors.newTextSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsCultura() {
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.agriculture, color: AppColors.newPrimary, size: 20),
              SizedBox(width: 8),
              Text('Selecione a Cultura', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14,
                  color: AppColors.newTextPrimary)),
            ]),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 6,
              children: CulturaBoletim100.todas.map((c) {
                final sel = _culturaSelecionada == c.nome;
                return ChoiceChip(
                  label: Text(c.nome, style: TextStyle(
                    fontSize: 11,
                    color: sel ? AppColors.bgDark : AppColors.newTextPrimary,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  )),
                  selected: sel,
                  selectedColor: AppColors.newPrimary,
                  backgroundColor: AppColors.bgDark,
                  side: BorderSide(color: sel ? AppColors.newPrimary : AppColors.borderDark),
                  onSelected: (_) => setState(() => _culturaSelecionada = c.nome),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoParams() {
    final c = CulturaBoletim100.buscarPorNome(_culturaSelecionada);
    if (c == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.newPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.newPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _paramBox('mt máx.', '${c.mtMaxPercent.toStringAsFixed(0)}%'),
          _paramBox('X (Ca+Mg)', '${c.xCmolc.toStringAsFixed(1)} cmolc'),
          _paramBox('Ve', '${c.vePercent.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }

  Widget _paramBox(String label, String valor) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.newTextMuted)),
      const SizedBox(height: 2),
      Text(valor, style: const TextStyle(fontSize: 14,
          fontWeight: FontWeight.bold, color: AppColors.newPrimary)),
    ]);
  }

  Widget _buildSecaoDadosGerais() {
    return _cardSecao('Dados Gerais', Icons.info_outline, [
      DropdownButtonFormField<String?>(
        value: _talhaoId,
        decoration: const InputDecoration(labelText: 'Talhão', prefixIcon: Icon(Icons.agriculture)),
        dropdownColor: AppColors.surfaceDark,
        items: [
          const DropdownMenuItem(value: null, child: Text('Geral (sem talhão)')),
          ..._talhoes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))),
        ],
        onChanged: (v) => setState(() => _talhaoId = v),
      ),
      const SizedBox(height: 10),
      _row2(_input('Laboratório', _labCtrl), _input('Nº Amostra', _amostraCtrl)),
      const SizedBox(height: 10),
      _row2(
        _datePicker('Data Coleta', _dataColeta, (d) => setState(() => _dataColeta = d)),
        _datePicker('Data Resultado', _dataResultado, (d) => setState(() => _dataResultado = d)),
      ),
    ]);
  }

  Widget _buildSecaoMacronutrientes() {
    return _cardSecao('Macronutrientes', Icons.eco, [
      _row3(_num('pH (CaCl₂)', _phCtrl), _num('M.O. (g/dm³)', _moCtrl), _num('P resina (mg/dm³)', _pCtrl)),
      const SizedBox(height: 10),
      _row3(_num('K (mmolc/dm³)', _kCtrl), _num('Ca (mmolc/dm³)', _caCtrl), _num('Mg (mmolc/dm³)', _mgCtrl)),
      const SizedBox(height: 10),
      _row3(_num('Al (mmolc/dm³)', _alCtrl), _num('H+Al (mmolc/dm³)', _halCtrl), _num('S (mg/dm³)', _sCtrl)),
    ]);
  }

  Widget _buildSecaoMicronutrientes() {
    return _cardSecao('Micronutrientes', Icons.grain, [
      _row3(_num('Cu (mg/dm³)', _cuCtrl), _num('Fe (mg/dm³)', _feCtrl), _num('Mn (mg/dm³)', _mnCtrl)),
      const SizedBox(height: 10),
      _row2(_num('Zn (mg/dm³)', _znCtrl), _num('B (mg/dm³)', _bCtrl)),
    ]);
  }

  Widget _buildSecaoFisicosCalcario() {
    return _cardSecao('Dados Físicos e Calcário', Icons.terrain, [
      _row3(_num('Argila (%)', _argilaCtrl), _num('Profundidade (cm)', _profCtrl), _num('PRNT (%)', _prntCtrl)),
      const SizedBox(height: 10),
      _row2(_num('Produtividade esperada (t/ha)', _prodCtrl), const SizedBox()),
    ]);
  }

  Widget _buildSecaoObservacoes() {
    return _cardSecao('Observações', Icons.notes, [
      TextFormField(
        controller: _obsCtrl,
        maxLines: 2,
        decoration: const InputDecoration(
          hintText: 'Observações adicionais...',
          border: OutlineInputBorder(),
        ),
      ),
    ]);
  }

  Widget _buildBotaoCalcular() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _calcular,
        icon: const Icon(Icons.calculate),
        label: const Text('CALCULAR INTERPRETAÇÃO', style: TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.newPrimary,
          foregroundColor: AppColors.bgDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ABA 2 — RESULTADO
  // ═══════════════════════════════════════════════════

  Widget _buildResultadoTab() {
    if (!_calculado || _resultado == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 12),
            const Text('Preencha os dados na aba DADOS\ne clique em CALCULAR INTERPRETAÇÃO',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.newTextSecondary)),
          ],
        ),
      );
    }

    final r = _resultado!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildValoresCalculados(r),
          const SizedBox(height: 16),
          _buildSemaforoSection('Macronutrientes e Acidez', r.macronutrientes),
          const SizedBox(height: 16),
          if (r.micronutrientes.isNotEmpty) ...[
            _buildSemaforoSection('Micronutrientes', r.micronutrientes),
            const SizedBox(height: 16),
          ],
          _buildSecaoCalagem(r),
          const SizedBox(height: 16),
          _buildSecaoGessagem(r),
          const SizedBox(height: 16),
          _buildSecaoRelacoes(r),
          const SizedBox(height: 24),
          _buildBotoesResultado(r),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildValoresCalculados(ResultadoInterpretacao r) {
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.functions, color: AppColors.newPrimary, size: 20),
              SizedBox(width: 8),
              Text('Valores Calculados', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.newTextPrimary)),
            ]),
            const SizedBox(height: 10),
            Row(
              children: [
                _valorCalc('SB', '${r.somasBases.toStringAsFixed(1)} mmolc'),
                _valorCalc('CTC', '${r.ctc.toStringAsFixed(1)} mmolc'),
                _valorCalc('V%', '${r.saturacaoBases.toStringAsFixed(1)}%'),
                if (r.saturacaoAluminio != null)
                  _valorCalc('mt%', '${r.saturacaoAluminio!.toStringAsFixed(1)}%'),
                if (r.classeTextural != null)
                  _valorCalc('Textura', InterpretacaoBoletim100.textoClasseTextural(r.classeTextural!)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _valorCalc(String label, String valor) {
    return Expanded(
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.newTextMuted)),
        const SizedBox(height: 2),
        Text(valor, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.bold, color: AppColors.newTextPrimary)),
      ]),
    );
  }

  Widget _buildSemaforoSection(String titulo, List<ItemInterpretado> itens) {
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.newTextPrimary)),
            const SizedBox(height: 8),
            ...itens.map(_buildSemaforoItem),
          ],
        ),
      ),
    );
  }

  Widget _buildSemaforoItem(ItemInterpretado item) {
    final cor = _corSemaforo(item.semaforo);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(item.nome,
              style: const TextStyle(fontSize: 12, color: AppColors.newTextPrimary))),
          Expanded(flex: 2, child: Text(
              '${item.valor.toStringAsFixed(item.unidade.isEmpty ? 1 : 2)} ${item.unidade}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: AppColors.newTextPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: cor.withValues(alpha: 0.4)),
            ),
            child: Text(item.textoSemaforo,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cor)),
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoCalagem(ResultadoInterpretacao r) {
    final cor = _corSemaforo(r.semaforoCalagem);
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.landscape, color: cor, size: 20),
              const SizedBox(width: 8),
              const Text('Necessidade de Calagem', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.newTextPrimary)),
              const Spacer(),
              _semaforoBadge(r.semaforoCalagem, r.calagemFinal > 0
                  ? '${r.calagemFinal.toStringAsFixed(2)} t/ha' : 'Não necessária'),
            ]),
            const SizedBox(height: 10),
            _linhaCalc('Método 1 (Sat. Bases)', '${r.calagemMetodo1.toStringAsFixed(2)} t/ha'),
            _linhaCalc('Método 2 (Neutraliz. Al)', '${r.calagemMetodo2.toStringAsFixed(2)} t/ha'),
            _linhaCalc('Resultado Final (maior)', '${r.calagemFinal.toStringAsFixed(2)} t/ha',
                bold: true),
            if (r.doseMinimaCalagemAplicada)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('* Dose mínima 1,5 t/ha (PRNT=100%) aplicada — B-100 2022',
                    style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic,
                        color: AppColors.newWarning)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoGessagem(ResultadoInterpretacao r) {
    final cor = _corSemaforo(r.semaforoGessagem);
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.water_drop, color: cor, size: 20),
              const SizedBox(width: 8),
              const Text('Gessagem', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.newTextPrimary)),
              const Spacer(),
              _semaforoBadge(r.semaforoGessagem,
                  r.gessagemNecessaria ? '${r.gessagemDose.toStringAsFixed(2)} t/ha' : 'Não necessária'),
            ]),
            if (r.gessagemNecessaria) ...[
              const SizedBox(height: 8),
              const Text('Critérios B-100: V% < 40% ou m% > 30%',
                  style: TextStyle(fontSize: 11, color: AppColors.newTextSecondary)),
            ],
            if (r.fonteS) ...[
              const SizedBox(height: 8),
              Text('Fonte de S: aplicar ${r.doseFonteS.toStringAsFixed(1)} t/ha de gesso '
                  '(S-SO₄²⁻ < 15 mg/dm³)',
                  style: const TextStyle(fontSize: 11, color: AppColors.newWarning)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoRelacoes(ResultadoInterpretacao r) {
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.balance, color: AppColors.newInfo, size: 20),
              SizedBox(width: 8),
              Text('Relações Iônicas', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.newTextPrimary)),
            ]),
            const SizedBox(height: 10),
            if (r.relacaoCaMg != null)
              _linhaRelacao('Ca / Mg', r.relacaoCaMg!, '1,0 a 4,0', r.semaforoCaMg),
            if (r.relacaoCaK != null)
              _linhaRelacao('Ca / K', r.relacaoCaK!, '8,0 a 20,0', r.semaforoCaK),
            if (r.relacaoMgK != null)
              _linhaRelacao('Mg / K', r.relacaoMgK!, '1,5 a 6,0', r.semaforoMgK),
          ],
        ),
      ),
    );
  }

  Widget _linhaRelacao(String nome, double valor, String faixaIdeal, SemaforoSolo? sem) {
    final cor = sem != null ? _corSemaforo(sem) : AppColors.newTextSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(flex: 2, child: Text(nome,
            style: const TextStyle(fontSize: 12, color: AppColors.newTextPrimary))),
        Expanded(flex: 2, child: Text(valor.toStringAsFixed(1),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: AppColors.newTextPrimary))),
        Expanded(flex: 2, child: Text('Ideal: $faixaIdeal',
            style: const TextStyle(fontSize: 11, color: AppColors.newTextMuted))),
      ]),
    );
  }

  Widget _buildBotoesResultado(ResultadoInterpretacao r) {
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => AnaliseSoloGraficosScreen(resultado: r, contexto: widget.contexto),
          )),
          icon: const Icon(Icons.bar_chart),
          label: const Text('GRÁFICOS'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.newInfo,
            side: const BorderSide(color: AppColors.newInfo),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton.icon(
          onPressed: _salvando ? null : _salvar,
          icon: _salvando
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save),
          label: Text(_editandoId != null ? 'ATUALIZAR' : 'SALVAR'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.newPrimary,
            foregroundColor: AppColors.bgDark,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ]);
  }

  // ═══════════════════════════════════════════════════
  // ABA 3 — HISTÓRICO
  // ═══════════════════════════════════════════════════

  Widget _buildHistoricoTab() {
    if (_carregandoHistorico) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Text('${_historico.length} análise(s) salva(s)',
                style: const TextStyle(fontSize: 13, color: AppColors.newTextSecondary)),
            const Spacer(),
            if (_historico.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ElevatedButton.icon(
                  onPressed: _gerarPdfAnalises,
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('PDF Todas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.newPrimary,
                    foregroundColor: AppColors.bgDark,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _novaAnalise,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nova Análise'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.newPrimary,
                foregroundColor: AppColors.bgDark,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ]),
        ),
        Expanded(
          child: _historico.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey[600]),
                    const SizedBox(height: 8),
                    const Text('Nenhuma análise salva ainda',
                        style: TextStyle(color: AppColors.newTextSecondary)),
                  ],
                ))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _historico.length,
                  itemBuilder: (_, i) => _buildHistoricoCard(_historico[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildHistoricoCard(AnaliseSolo a) {
    // Determinar semáforo da calagem se possível
    SemaforoSolo? semCalagem;
    if (a.saturacaoBases != null && a.cultura != null) {
      final cult = CulturaBoletim100.buscarPorNome(a.cultura);
      if (cult != null && a.ctc != null && (a.prnt ?? 0) > 0) {
        final nc = InterpretacaoBoletim100.calagemMetodo1(
          ve: cult.vePercent, vAtual: a.saturacaoBases!, ctc: a.ctc!, prnt: a.prnt!,
        );
        semCalagem = InterpretacaoBoletim100.semaforoCalagem(nc);
      }
    }

    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: semCalagem != null
              ? _corSemaforo(semCalagem).withValues(alpha: 0.2)
              : AppColors.borderDark,
          child: Icon(
            semCalagem == SemaforoSolo.verde ? Icons.check_circle
                : semCalagem == SemaforoSolo.amarelo ? Icons.warning
                : semCalagem == SemaforoSolo.vermelho ? Icons.error
                : Icons.science,
            color: semCalagem != null ? _corSemaforo(semCalagem) : AppColors.newTextMuted,
            size: 22,
          ),
        ),
        title: Text(_nomeTalhao(a.talhaoId),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                color: AppColors.newTextPrimary)),
        subtitle: Text(
          '${a.cultura ?? "Sem cultura"} — '
          '${a.dataColeta != null ? _fmtData(a.dataColeta!) : "Sem data"} — '
          '${a.laboratorio ?? ""}',
          style: const TextStyle(fontSize: 11, color: AppColors.newTextSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, size: 20, color: AppColors.newPrimary),
              tooltip: 'Gerar PDF desta análise',
              onPressed: () => _gerarPdfAnaliseIndividual(a),
            ),
            IconButton(
              icon: const Icon(Icons.visibility, size: 20, color: AppColors.newInfo),
              tooltip: 'Carregar',
              onPressed: () => _carregarAnalise(a),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.newDanger),
              tooltip: 'Excluir',
              onPressed: () => _confirmarExclusao(a),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // HELPERS DE UI
  // ═══════════════════════════════════════════════════

  Widget _cardSecao(String titulo, IconData icone, List<Widget> children) {
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icone, color: AppColors.newPrimary, size: 20),
              const SizedBox(width: 8),
              Text(titulo, style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.newTextPrimary)),
            ]),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl) {
    return TextFormField(controller: ctrl, decoration: InputDecoration(
        labelText: label, isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)));
  }

  Widget _num(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label, isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
    );
  }

  Widget _row2(Widget a, Widget b) => Row(children: [
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: a)),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: b)),
      ]);

  Widget _row3(Widget a, Widget b, Widget c) => Row(children: [
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: a)),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: b)),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c)),
      ]);

  Widget _datePicker(String label, DateTime? data, ValueChanged<DateTime> onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: data ?? DateTime.now(),
          firstDate: DateTime(2000), lastDate: DateTime(2035),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.calendar_today)),
        child: Text(data != null ? _fmtData(data) : 'Selecionar',
            style: TextStyle(color: data != null ? AppColors.newTextPrimary : AppColors.newTextMuted)),
      ),
    );
  }

  Widget _linhaCalc(String label, String valor, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 12,
            color: AppColors.newTextSecondary,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal))),
        Text(valor, style: TextStyle(fontSize: 12, color: AppColors.newTextPrimary,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }

  Widget _semaforoBadge(SemaforoSolo sem, String texto) {
    final cor = _corSemaforo(sem);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cor.withValues(alpha: 0.4)),
      ),
      child: Text(texto, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cor)),
    );
  }

  Color _corSemaforo(SemaforoSolo s) {
    switch (s) {
      case SemaforoSolo.vermelho: return AppColors.newDanger;
      case SemaforoSolo.amarelo: return AppColors.newWarning;
      case SemaforoSolo.verde: return AppColors.newSuccess;
    }
  }

  // ═══════════════════════════════════════════════════
  // LÓGICA
  // ═══════════════════════════════════════════════════

  void _calcular() {
    final cultura = CulturaBoletim100.buscarPorNome(_culturaSelecionada);
    if (cultura == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma cultura antes de calcular')),
      );
      return;
    }

    final ph = _d(_phCtrl);
    final mo = _d(_moCtrl);
    final p = _d(_pCtrl);
    final k = _d(_kCtrl);
    final ca = _d(_caCtrl);
    final mg = _d(_mgCtrl);
    final al = _d(_alCtrl);
    final hAl = _d(_halCtrl);
    final prnt = _d(_prntCtrl);

    if (ph == null || mo == null || p == null || k == null ||
        ca == null || mg == null || al == null || hAl == null || prnt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os macronutrientes, Al, H+Al e PRNT')),
      );
      return;
    }

    final resultado = InterpretacaoBoletim100.calcularCompleto(
      ph: ph, mo: mo, p: p, k: k, ca: ca, mg: mg,
      al: al, hAl: hAl,
      s: _d(_sCtrl),
      cu: _d(_cuCtrl), fe: _d(_feCtrl), mn: _d(_mnCtrl),
      zn: _d(_znCtrl), b: _d(_bCtrl),
      argilaPercent: _d(_argilaCtrl),
      prnt: prnt,
      cultura: cultura,
    );

    setState(() {
      _resultado = resultado;
      _calculado = true;
    });

    _tabController.animateTo(1); // Ir para RESULTADO
  }

  Future<void> _salvar() async {
    if (_resultado == null) return;
    setState(() => _salvando = true);

    try {
      final analise = AnaliseSolo(
        id: _editandoId ?? '',
        propriedadeId: widget.contexto.propriedade.id,
        talhaoId: _talhaoId,
        cultura: _culturaSelecionada,
        laboratorio: _labCtrl.text.isNotEmpty ? _labCtrl.text : null,
        numeroAmostra: _amostraCtrl.text.isNotEmpty ? _amostraCtrl.text : null,
        dataColeta: _dataColeta,
        dataResultado: _dataResultado,
        profundidadeCm: int.tryParse(_profCtrl.text.trim()),
        ph: _d(_phCtrl),
        materiaOrganica: _d(_moCtrl),
        fosforo: _d(_pCtrl),
        potassio: _d(_kCtrl),
        calcio: _d(_caCtrl),
        magnesio: _d(_mgCtrl),
        enxofre: _d(_sCtrl),
        acidezPotencial: _d(_halCtrl),
        aluminio: _d(_alCtrl),
        somasBases: _resultado!.somasBases,
        ctc: _resultado!.ctc,
        saturacaoBases: _resultado!.saturacaoBases,
        boro: _d(_bCtrl),
        cobre: _d(_cuCtrl),
        ferro: _d(_feCtrl),
        manganes: _d(_mnCtrl),
        zinco: _d(_znCtrl),
        argila: _d(_argilaCtrl),
        prnt: _d(_prntCtrl),
        produtividadeEsperada: _d(_prodCtrl),
        observacoes: _obsCtrl.text.isNotEmpty ? _obsCtrl.text : null,
      );

      if (_editandoId != null) {
        await _service.atualizarAnalise(analise);
      } else {
        await _service.criarAnalise(analise);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editandoId != null
              ? 'Análise atualizada com sucesso' : 'Análise salva com sucesso')),
        );
        _editandoId = null;
        await _carregarDados();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _carregarAnalise(AnaliseSolo a) {
    _editandoId = a.id;
    _culturaSelecionada = a.cultura;
    _talhaoId = a.talhaoId;
    _labCtrl.text = a.laboratorio ?? '';
    _amostraCtrl.text = a.numeroAmostra ?? '';
    _dataColeta = a.dataColeta;
    _dataResultado = a.dataResultado;
    _profCtrl.text = a.profundidadeCm?.toString() ?? '20';
    _argilaCtrl.text = a.argila?.toString() ?? '';
    _prntCtrl.text = a.prnt?.toString() ?? '100';
    _prodCtrl.text = a.produtividadeEsperada?.toString() ?? '';
    _phCtrl.text = a.ph?.toString() ?? '';
    _moCtrl.text = a.materiaOrganica?.toString() ?? '';
    _pCtrl.text = a.fosforo?.toString() ?? '';
    _kCtrl.text = a.potassio?.toString() ?? '';
    _caCtrl.text = a.calcio?.toString() ?? '';
    _mgCtrl.text = a.magnesio?.toString() ?? '';
    _alCtrl.text = a.aluminio?.toString() ?? '';
    _halCtrl.text = a.acidezPotencial?.toString() ?? '';
    _sCtrl.text = a.enxofre?.toString() ?? '';
    _cuCtrl.text = a.cobre?.toString() ?? '';
    _feCtrl.text = a.ferro?.toString() ?? '';
    _mnCtrl.text = a.manganes?.toString() ?? '';
    _znCtrl.text = a.zinco?.toString() ?? '';
    _bCtrl.text = a.boro?.toString() ?? '';
    _obsCtrl.text = a.observacoes ?? '';

    setState(() {});
    _calcular();
  }

  void _novaAnalise() {
    _editandoId = null;
    _culturaSelecionada = null;
    _talhaoId = null;
    _dataColeta = null;
    _dataResultado = null;
    _calculado = false;
    _resultado = null;
    for (final c in _allControllers) {
      c.clear();
    }
    _profCtrl.text = '20';
    _prntCtrl.text = '100';
    setState(() {});
    _tabController.animateTo(0);
  }

  Future<void> _gerarPdfAnalises() async {
    try {
      final pdfBytes = await PdfAnaliseSolo.gerar(
        propriedade: widget.contexto.propriedade,
        analises: _historico,
        talhoes: _talhoes,
      );
      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'Analise_Solo_${widget.contexto.nomePropriedade}.pdf',
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e')),
      );
    }
  }

  Future<void> _gerarPdfAnaliseIndividual(AnaliseSolo analise) async {
    try {
      final pdfBytes = await PdfAnaliseSolo.gerar(
        propriedade: widget.contexto.propriedade,
        analises: [analise],
        talhoes: _talhoes,
      );
      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'Analise_Solo_${analise.numeroAmostra ?? "individual"}.pdf',
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e')),
      );
    }
  }

  Future<void> _confirmarExclusao(AnaliseSolo a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Excluir análise ${a.numeroAmostra ?? ""} '
            'do ${_nomeTalhao(a.talhaoId)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.newDanger),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.deletarAnalise(a.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Análise excluída')),
        );
        _carregarDados();
      }
    }
  }
}
