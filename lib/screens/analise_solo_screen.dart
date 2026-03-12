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
  TipoCana? _tipoCana;
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
  String _profundidadeSelecionada = '0-20';
  bool _profundidadeCustom = false;

  // ─── Controllers ───
  final _labCtrl = TextEditingController();
  final _amostraCtrl = TextEditingController();
  final _profCtrl = TextEditingController(text: '20');
  final _argilaCtrl = TextEditingController();
  final _silteCtrl = TextEditingController();
  final _areiaCtrl = TextEditingController();
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
        _labCtrl, _amostraCtrl, _profCtrl, _argilaCtrl, _silteCtrl, _areiaCtrl,
        _prntCtrl, _prodCtrl,
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
          if (_culturaSelecionada == 'CANA-DE-AÇÚCAR') ...[            const SizedBox(height: 12),
            _buildDropdownTipoCana(),
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
                final isCana = c.nome == 'CANA-DE-AÇÚCAR';
                return ChoiceChip(
                  avatar: isCana && !sel
                      ? const Icon(Icons.star, size: 14, color: AppColors.newPrimary)
                      : null,
                  label: Text(c.nome, style: TextStyle(
                    fontSize: 11,
                    color: sel
                        ? Colors.white
                        : isCana
                            ? AppColors.newPrimary
                            : AppColors.newTextPrimary,
                    fontWeight: sel || isCana ? FontWeight.bold : FontWeight.normal,
                  )),
                  selected: sel,
                  selectedColor: AppColors.newPrimary,
                  backgroundColor: isCana
                      ? AppColors.newPrimary.withValues(alpha: 0.08)
                      : AppColors.bgDark,
                  side: BorderSide(
                    color: sel
                        ? AppColors.newPrimary
                        : isCana
                            ? AppColors.newPrimary.withValues(alpha: 0.5)
                            : AppColors.borderDark,
                    width: isCana ? 1.5 : 1.0,
                  ),
                  onSelected: (_) => setState(() {
                    _culturaSelecionada = c.nome;
                    if (c.nome != 'CANA-DE-AÇÚCAR') _tipoCana = null;
                  }),
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

  Widget _buildDropdownTipoCana() {
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.eco, color: AppColors.newPrimary, size: 20),
              SizedBox(width: 8),
              Text('Tipo de Aplicação', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14,
                  color: AppColors.newTextPrimary)),
              Spacer(),
              Tooltip(
                message: 'Selecione o tipo de cana para obter\n'
                    'recomendações de adubação NPK específicas\n'
                    'conforme o Boletim 100 (IAC).\n\n'
                    '• Cana Planta: 1º plantio (adubação no sulco)\n'
                    '• Cana Soca: soqueiras (adubação de cobertura)',
                child: Icon(Icons.info_outline, size: 18, color: AppColors.newTextMuted),
              ),
            ]),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _tipoCanaChip('Cana Planta', TipoCana.planta,
                      Icons.nature, 'Adubação no sulco de plantio'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _tipoCanaChip('Cana Soca', TipoCana.soca,
                      Icons.replay, 'Adubação de cobertura em soqueira'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipoCanaChip(String label, TipoCana tipo, IconData icone, String subtitulo) {
    final sel = _tipoCana == tipo;
    return InkWell(
      onTap: () => setState(() => _tipoCana = tipo),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? AppColors.newPrimary.withValues(alpha: 0.12) : AppColors.bgDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? AppColors.newPrimary : AppColors.borderDark,
            width: sel ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icone, size: 24,
                color: sel ? AppColors.newPrimary : AppColors.newTextMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13,
                    color: sel ? AppColors.newPrimary : AppColors.newTextPrimary,
                  )),
                  Text(subtitulo, style: const TextStyle(
                    fontSize: 10, color: AppColors.newTextMuted,
                  )),
                ],
              ),
            ),
            if (sel)
              const Icon(Icons.check_circle, size: 20, color: AppColors.newPrimary),
          ],
        ),
      ),
    );
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
      _buildDropdownProfundidade(),
      const SizedBox(height: 10),
      _row3(_num('Argila (%)', _argilaCtrl), _num('Silte (%)', _silteCtrl), _num('Areia (%)', _areiaCtrl)),
      const SizedBox(height: 10),
      _row3(_buildPrntComInfo(), _num('Produtividade esperada (t/ha)', _prodCtrl), const SizedBox()),
    ]);
  }

  static const List<String> _profundidadesPreDefinidas = [
    '0-20', '20-40', '0-25', '25-50', '80-100',
  ];

  Widget _buildDropdownProfundidade() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.straighten, size: 18, color: AppColors.newPrimary),
            SizedBox(width: 6),
            Text('Profundidade da Amostra (cm)', style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.newTextPrimary)),
            Spacer(),
            Tooltip(
              message: 'Boletim 100 — Camadas de amostragem:\n\n'
                  '• 0-20 cm / 0-25 cm: Camada arável (calagem e adubação)\n'
                  '• 20-40 cm / 25-50 cm: Subsuperfície (gessagem)\n'
                  '• 80-100 cm: Profundidade (diagnóstico)\n\n'
                  'A calagem é calculada para a camada 0-20/0-25 cm.\n'
                  'A gessagem avalia a camada 20-40/25-50 cm.',
              child: Icon(Icons.info_outline, size: 18, color: AppColors.newTextMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 6,
          children: [
            ..._profundidadesPreDefinidas.map((p) {
              final sel = !_profundidadeCustom && _profundidadeSelecionada == p;
              return ChoiceChip(
                label: Text('$p cm', style: TextStyle(
                  fontSize: 12,
                  color: sel ? Colors.white : AppColors.newTextPrimary,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                )),
                selected: sel,
                selectedColor: AppColors.newPrimary,
                backgroundColor: AppColors.bgDark,
                side: BorderSide(color: sel ? AppColors.newPrimary : AppColors.borderDark),
                onSelected: (_) => setState(() {
                  _profundidadeSelecionada = p;
                  _profundidadeCustom = false;
                  final partes = p.split('-');
                  _profCtrl.text = partes.length == 2 ? partes[1] : p;
                }),
              );
            }),
            ChoiceChip(
              avatar: _profundidadeCustom
                  ? null
                  : const Icon(Icons.add, size: 16, color: AppColors.newTextMuted),
              label: Text(_profundidadeCustom ? 'Personalizada' : 'Outra', style: TextStyle(
                fontSize: 12,
                color: _profundidadeCustom ? Colors.white : AppColors.newTextMuted,
                fontWeight: _profundidadeCustom ? FontWeight.bold : FontWeight.normal,
              )),
              selected: _profundidadeCustom,
              selectedColor: AppColors.newPrimary,
              backgroundColor: AppColors.bgDark,
              side: BorderSide(color: _profundidadeCustom ? AppColors.newPrimary : AppColors.borderDark),
              onSelected: (_) => setState(() {
                _profundidadeCustom = true;
                _profCtrl.clear();
              }),
            ),
          ],
        ),
        if (_profundidadeCustom) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _profCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Profundidade (cm)',
                    hintText: 'Ex: 30',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],
        // Nota informativa sobre a camada selecionada
        if (!_profundidadeCustom) ...[
          const SizedBox(height: 6),
          _notaCamadaProfundidade(_profundidadeSelecionada),
        ],
      ],
    );
  }

  Widget _notaCamadaProfundidade(String faixa) {
    String texto;
    IconData icone;
    Color cor;

    switch (faixa) {
      case '0-20':
      case '0-25':
        texto = 'Camada arável — Usada para cálculo de calagem e adubação (B-100)';
        icone = Icons.check_circle_outline;
        cor = AppColors.newSuccess;
      case '20-40':
      case '25-50':
        texto = 'Camada de subsuperfície — Usada para avaliação de gessagem (B-100)';
        icone = Icons.water_drop_outlined;
        cor = AppColors.newInfo;
      case '80-100':
        texto = 'Camada profunda — Diagnóstico de restrições em profundidade';
        icone = Icons.layers_outlined;
        cor = AppColors.newWarning;
      default:
        texto = 'Profundidade personalizada';
        icone = Icons.info_outline;
        cor = AppColors.newTextMuted;
    }

    return Row(
      children: [
        Icon(icone, size: 14, color: cor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(texto, style: TextStyle(fontSize: 10, color: cor)),
        ),
      ],
    );
  }

  Widget _buildPrntComInfo() {
    return TextFormField(
      controller: _prntCtrl,
      decoration: InputDecoration(
        labelText: 'PRNT (%)',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: IconButton(
          icon: const Icon(Icons.info_outline, size: 20, color: AppColors.newPrimary),
          tooltip: 'Adapte o PRNT (%) de acordo com o calcário\n'
              'que será utilizado na sua propriedade.\n\n'
              'Exemplo:\n'
              '• Calcário dolomítico: PRNT entre 75% e 90%\n'
              '• Calcário calcítico: PRNT entre 80% e 95%\n'
              '• Cal virgem: PRNT acima de 125%\n\n'
              'O valor padrão é 100%. Consulte a\n'
              'embalagem do produto para o PRNT correto.',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.newPrimary),
                    SizedBox(width: 8),
                    Text('PRNT — Poder Relativo de\nNeutralização Total',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text(
                  'Adapte o PRNT (%) de acordo com o calcário '
                  'que será utilizado na sua propriedade.\n\n'
                  'O PRNT indica a eficiência do calcário em corrigir '
                  'a acidez do solo. Quanto maior o PRNT, menor a '
                  'quantidade necessária.\n\n'
                  'Exemplos de PRNT por tipo de calcário:\n\n'
                  '• Calcário dolomítico: 75% a 90%\n'
                  '• Calcário calcítico: 80% a 95%\n'
                  '• Calcário filler (moído fino): 90% a 100%\n'
                  '• Cal virgem: acima de 125%\n\n'
                  'O valor padrão é 100%. Consulte a embalagem '
                  'do produto adquirido para informar o PRNT correto.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ENTENDI'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
    );
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
          if (r.recomendacaoAdubacao != null) ...[
            _buildSecaoAdubacao(r.recomendacaoAdubacao!),
            const SizedBox(height: 16),
          ],
          _buildSecaoRelacoes(r),
          const SizedBox(height: 16),
          _buildSecaoConversaoUnidades(),
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
            if (r.notaCamada != null && (r.profundidadeFaixa == '20-40' ||
                r.profundidadeFaixa == '25-50' || r.profundidadeFaixa == '80-100'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Expanded(child: Text(
                      'Calagem não se aplica nesta camada (${r.profundidadeFaixa} cm)',
                      style: const TextStyle(fontSize: 11, color: Colors.orange),
                    )),
                  ]),
                ),
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
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.newWarning.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.newWarning.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.newWarning),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ATENÇÃO — Aplicar Gesso como Fonte de Enxofre',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.newWarning,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      'Gessagem não necessária pelos critérios de V% e m%, '
                      'porém o teor de S-SO₄²⁻ está abaixo de 15 mg/dm³.\n'
                      'Recomendação B-100: aplicar ${r.doseFonteS.toStringAsFixed(1)} t/ha '
                      'de gesso agrícola como fonte de enxofre.',
                      style: const TextStyle(fontSize: 12, color: AppColors.newTextPrimary, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
            if (r.profundidadeFaixa == '80-100')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    SizedBox(width: 6),
                    Expanded(child: Text(
                      'Camada profunda (80-100 cm) — diagnóstico, gessagem não se aplica',
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                    )),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoAdubacao(RecomendacaoAdubacao rec) {
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.compost, color: AppColors.newPrimary, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Recomendação de Adubação NPK', style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.newTextPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.newPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.newPrimary.withValues(alpha: 0.3)),
                ),
                child: Text(rec.tipoLabel, style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.newPrimary)),
              ),
            ]),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _adubacaoCard('N', rec.nKgHa, rec.obsN, const Color(0xFF2563EB))),
                const SizedBox(width: 8),
                Expanded(child: _adubacaoCard('P₂O₅', rec.p2o5KgHa, rec.obsP, const Color(0xFFD97706))),
                const SizedBox(width: 8),
                Expanded(child: _adubacaoCard('K₂O', rec.k2oKgHa, rec.obsK, const Color(0xFF7C3AED))),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.newInfo.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.menu_book, size: 14, color: AppColors.newInfo),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Doses baseadas no Boletim 100 — IAC (5ª Aproximação). '
                      'Consulte um agrônomo para ajustes conforme condições locais.',
                      style: TextStyle(fontSize: 10, color: AppColors.newTextSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adubacaoCard(String nutriente, double dose, String obs, Color cor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(nutriente, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: cor)),
          const SizedBox(height: 4),
          Text(dose.toStringAsFixed(0), style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: cor)),
          const Text('kg/ha', style: TextStyle(
              fontSize: 10, color: AppColors.newTextMuted)),
          const SizedBox(height: 4),
          Text(obs, textAlign: TextAlign.center, style: const TextStyle(
              fontSize: 9, color: AppColors.newTextSecondary)),
        ],
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

  /// Conversão de Unidades — mg/dm³ e mmolc/dm³ → kg/ha
  /// Fator: camada 0-20cm, densidade 1,0 g/cm³ → 2.000.000 kg solo/ha → ×2
  Widget _buildSecaoConversaoUnidades() {
    final p = _d(_pCtrl);
    final s = _d(_sCtrl);
    final k = _d(_kCtrl);
    final ca = _d(_caCtrl);
    final mg = _d(_mgCtrl);
    final al = _d(_alCtrl);

    // Se nenhum valor preenchido, não mostrar
    if (p == null && s == null && k == null && ca == null && mg == null && al == null) {
      return const SizedBox.shrink();
    }

    // Pesos atômicos/equivalentes para conversão mmolc → mg
    // K⁺ (39,1), Ca²⁺ (20,04), Mg²⁺ (12,15), Al³⁺ (8,99)
    final itens = <_ConversaoItem>[
      if (p != null)
        _ConversaoItem('P', 'Fósforo Resina', p, 'mg/dm³', p * 2, 'kg/ha'),
      if (s != null)
        _ConversaoItem('S', 'Enxofre', s, 'mg/dm³', s * 2, 'kg/ha'),
      if (k != null)
        _ConversaoItem('K⁺', 'Potássio', k, 'mmolc/dm³', k * 39.1 * 2 / 1000, 'kg/ha'),
      if (ca != null)
        _ConversaoItem('Ca²⁺', 'Cálcio', ca, 'mmolc/dm³', ca * 20.04 * 2 / 1000, 'kg/ha'),
      if (mg != null)
        _ConversaoItem('Mg²⁺', 'Magnésio', mg, 'mmolc/dm³', mg * 12.15 * 2 / 1000, 'kg/ha'),
      if (al != null)
        _ConversaoItem('Al³⁺', 'Alumínio', al, 'mmolc/dm³', al * 8.99 * 2 / 1000, 'kg/ha'),
    ];

    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.swap_horiz, color: Color(0xFF0891B2), size: 20),
              SizedBox(width: 8),
              Text('Conversão de Unidades', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.newTextPrimary)),
              Spacer(),
              Tooltip(
                message: 'Conversão para kg/ha considerando:\n'
                    '• Camada 0-20 cm\n'
                    '• Densidade do solo: 1,0 g/cm³\n'
                    '• 2.000.000 kg de solo/ha (fator ×2)',
                child: Icon(Icons.info_outline, size: 16, color: AppColors.newTextMuted),
              ),
            ]),
            const SizedBox(height: 12),
            // Cabeçalho da tabela
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Expanded(flex: 2, child: Text('Nutriente',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                        color: AppColors.newTextMuted))),
                Expanded(flex: 2, child: Text('Resultado Análise',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                        color: AppColors.newTextMuted))),
                Expanded(flex: 2, child: Text('Conversão kg/ha',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                        color: AppColors.newTextMuted))),
              ]),
            ),
            const Divider(height: 1),
            ...itens.map(_buildLinhaConversao),
          ],
        ),
      ),
    );
  }

  Widget _buildLinhaConversao(_ConversaoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(flex: 2, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.simbolo, style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.bold, color: AppColors.newTextPrimary)),
            Text(item.nome, style: const TextStyle(fontSize: 10,
                color: AppColors.newTextMuted)),
          ],
        )),
        Expanded(flex: 2, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0891B2).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${item.valorOriginal.toStringAsFixed(2)} ${item.unidadeOriginal}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: AppColors.newTextPrimary),
          ),
        )),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.arrow_forward, size: 14, color: AppColors.newTextMuted),
        ),
        Expanded(flex: 2, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.newPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.newPrimary.withValues(alpha: 0.3)),
          ),
          child: Text(
            '${item.valorConvertido.toStringAsFixed(1)} ${item.unidadeConvertida}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                color: AppColors.newPrimary),
          ),
        )),
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

    if (_culturaSelecionada == 'CANA-DE-AÇÚCAR' && _tipoCana == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo de aplicação: Cana Planta ou Cana Soca')),
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

    // Validação de faixas críticas
    if (ph < 0 || ph > 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('pH inválido. Deve estar entre 0 e 14.')),
      );
      return;
    }
    if (prnt <= 0 || prnt > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PRNT inválido. Deve estar entre 1 e 100%.')),
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
      tipoCana: _tipoCana,
      produtividadeEsperada: _d(_prodCtrl),
      profundidadeFaixa: _profundidadeCustom ? null : _profundidadeSelecionada,
    );

    setState(() {
      _resultado = resultado;
      _calculado = true;
    });

    _tabController.animateTo(1); // Ir para RESULTADO
  }

  Future<void> _salvar() async {
    if (_resultado == null) return;

    // Validar dados obrigatórios antes de salvar
    if (widget.contexto.propriedade.id.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: propriedade inválida. Volte e selecione novamente.')),
        );
      }
      return;
    }

    setState(() => _salvando = true);

    try {
      final profCm = _profundidadeCustom
          ? int.tryParse(_profCtrl.text.trim())
          : _parseProfundidadeFaixa(_profundidadeSelecionada);

      final analise = AnaliseSolo(
        id: _editandoId ?? '',
        propriedadeId: widget.contexto.propriedade.id,
        talhaoId: _talhaoId,
        cultura: _culturaSelecionada,
        laboratorio: _labCtrl.text.isNotEmpty ? _labCtrl.text : null,
        numeroAmostra: _amostraCtrl.text.isNotEmpty ? _amostraCtrl.text : null,
        dataColeta: _dataColeta,
        dataResultado: _dataResultado,
        profundidadeCm: profCm,
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
        silte: _d(_silteCtrl),
        areia: _d(_areiaCtrl),
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
          SnackBar(
            content: Text(_editandoId != null
                ? 'Análise atualizada com sucesso' : 'Análise salva com sucesso'),
            backgroundColor: AppColors.newSuccess,
          ),
        );
        _editandoId = null;
        await _carregarDados();
      }
    } catch (e) {
      debugPrint('Erro ao salvar análise de solo: $e');
      if (mounted) {
        final msg = e.toString();
        String erroAmigavel;
        if (msg.contains('violates') || msg.contains('constraint')) {
          erroAmigavel = 'Erro de validação no banco de dados. Verifique os dados.\n$msg';
        } else if (msg.contains('network') || msg.contains('connection') || msg.contains('timeout')) {
          erroAmigavel = 'Erro de conexão. Verifique sua internet e tente novamente.';
        } else if (msg.contains('permission') || msg.contains('denied') || msg.contains('policy')) {
          erroAmigavel = 'Sem permissão para salvar. Verifique seu login.';
        } else if (msg.contains('does not exist') || msg.contains('column')) {
          erroAmigavel = 'Erro de estrutura do banco. Coluna pode não existir.\n$msg';
        } else {
          erroAmigavel = 'Erro ao salvar: $msg';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(erroAmigavel),
            backgroundColor: AppColors.newDanger,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  /// Extrai a profundidade final (cm) de uma faixa predefinida.
  /// Ex: '0-20' → 20, '25-50' → 50, '80-100' → 100
  int? _parseProfundidadeFaixa(String faixa) {
    final partes = faixa.split('-');
    if (partes.length == 2) {
      return int.tryParse(partes[1]);
    }
    return int.tryParse(faixa);
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
    // Restaurar faixa de profundidade
    final profVal = a.profundidadeCm;
    if (profVal != null) {
      final match = _profundidadesPreDefinidas
          .where((p) => p.endsWith('-$profVal') || p.endsWith('-${profVal.toString()}'))
          .toList();
      if (match.isNotEmpty) {
        _profundidadeSelecionada = match.first;
        _profundidadeCustom = false;
      } else {
        _profundidadeCustom = true;
      }
    }
    _argilaCtrl.text = a.argila?.toString() ?? '';
    _silteCtrl.text = a.silte?.toString() ?? '';
    _areiaCtrl.text = a.areia?.toString() ?? '';
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
    _tipoCana = null;
    _talhaoId = null;
    _dataColeta = null;
    _dataResultado = null;
    _calculado = false;
    _resultado = null;
    for (final c in _allControllers) {
      c.clear();
    }
    _profCtrl.text = '20';
    _profundidadeSelecionada = '0-20';
    _profundidadeCustom = false;
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

/// Modelo auxiliar para a tabela de conversão de unidades
class _ConversaoItem {
  final String simbolo;
  final String nome;
  final double valorOriginal;
  final String unidadeOriginal;
  final double valorConvertido;
  final String unidadeConvertida;

  const _ConversaoItem(
    this.simbolo,
    this.nome,
    this.valorOriginal,
    this.unidadeOriginal,
    this.valorConvertido,
    this.unidadeConvertida,
  );
}
