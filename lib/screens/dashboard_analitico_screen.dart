import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../constants/chart_styles.dart';
import '../models/models.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../services/produtividade_service.dart';
import '../services/precipitacao_service.dart';
import '../services/custo_operacional_service.dart';
import '../services/talhao_service.dart';
import '../services/variedade_service.dart';

class DashboardAnaliticoScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const DashboardAnaliticoScreen({
    super.key,
    required this.contexto,
  });

  @override
  State<DashboardAnaliticoScreen> createState() =>
      _DashboardAnaliticoScreenState();
}

class _DashboardAnaliticoScreenState extends State<DashboardAnaliticoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedNavigationIndex = 0;

  // Services
  final ProdutividadeService _produtividadeService = ProdutividadeService();
  final PrecipitacaoService _precipitacaoService = PrecipitacaoService();
  final CustoOperacionalService _custoService = CustoOperacionalService();
  final TalhaoService _talhaoService = TalhaoService();
  final VariedadeService _variedadeService = VariedadeService();

  // Estado — Produtividade
  bool _carregandoProd = true;
  List<Produtividade> _produtividades = [];

  // Estado — Precipitação
  bool _carregandoPrecip = true;
  List<Precipitacao> _precipitacoes = [];

  // Estado — Custos
  bool _carregandoCustos = true;
  List<CustoOperacionalCenario> _cenarios = [];

  // Estado — Variedades (censo)
  bool _carregandoVariedades = true;
  List<Talhao> _talhoes = [];
  Map<String, Variedade> _variedadeMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _carregarTodosDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarTodosDados() async {
    final propId = widget.contexto.propriedade.id;

    // Carregar tudo em paralelo
    await Future.wait([
      _carregarProdutividade(propId),
      _carregarPrecipitacao(propId),
      _carregarCustos(propId),
      _carregarVariedades(propId),
    ]);
  }

  Future<void> _carregarProdutividade(String propId) async {
    try {
      final anos = await _produtividadeService.getAnosSafraDisponiveis(propId);
      final List<Produtividade> todas = [];
      if (anos.isNotEmpty) {
        final dados = await _produtividadeService
            .getProdutividadePorPropriedade(propId)
            .first;
        todas.addAll(dados);
      }
      // Se não tem por stream, pegar direto
      if (todas.isEmpty) {
        final stream =
            _produtividadeService.getProdutividadePorPropriedade(propId);
        final dados = await stream.first;
        todas.addAll(dados);
      }
      if (mounted) {
        setState(() {
          _produtividades = todas;
          _carregandoProd = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregandoProd = false);
    }
  }

  Future<void> _carregarPrecipitacao(String propId) async {
    try {
      final dados =
          await _precipitacaoService.getPrecipitacoesByPropriedade(propId);
      if (mounted) {
        setState(() {
          _precipitacoes = dados;
          _carregandoPrecip = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregandoPrecip = false);
    }
  }

  Future<void> _carregarCustos(String propId) async {
    try {
      final dados = await _custoService.getCenariosByPropriedade(propId);
      if (mounted) {
        setState(() {
          _cenarios = dados;
          _carregandoCustos = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregandoCustos = false);
    }
  }

  Future<void> _carregarVariedades(String propId) async {
    try {
      final resultados = await Future.wait([
        _talhaoService.getTalhoesPorPropriedade(propId),
        _variedadeService.getVariedadeMap(),
      ]);
      if (mounted) {
        setState(() {
          _talhoes = resultados[0] as List<Talhao>;
          _variedadeMap = resultados[1] as Map<String, Variedade>;
          _carregandoVariedades = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregandoVariedades = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: 'Dashboard Analítico',
      child: Scaffold(
        body: Column(
          children: [
            HeaderPropriedade(contexto: widget.contexto),
            Material(
              color: Colors.white,
              elevation: 1,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.trending_up), text: 'Produtividade'),
                  Tab(icon: Icon(Icons.cloud), text: 'Precipitação'),
                  Tab(icon: Icon(Icons.money), text: 'Custos'),
                  Tab(icon: Icon(Icons.grass), text: 'Variedades'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAbaProdutividade(),
                  _buildAbaPrecipitacao(),
                  _buildAbaCustos(),
                  _buildAbaVariedades(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ABA 1: PRODUTIVIDADE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAbaProdutividade() {
    if (_carregandoProd) return _loading();
    if (_produtividades.isEmpty) return _vazio('Nenhum dado de produtividade');

    // Agrupar por ano safra
    final porAno = <String, List<Produtividade>>{};
    for (final p in _produtividades) {
      porAno.putIfAbsent(p.anoSafra, () => []).add(p);
    }
    final anosOrdenados = porAno.keys.toList()..sort();

    // Dados para BarChart — total toneladas por ano
    final barGroups = <BarChartGroupData>[];
    final barLabels = <int, String>{};
    double maxY = 0;

    for (var i = 0; i < anosOrdenados.length; i++) {
      final ano = anosOrdenados[i];
      final prods = porAno[ano]!;
      final totalTon = prods.fold<double>(
          0, (s, p) => s + (p.pesoLiquidoToneladas ?? 0));
      if (totalTon > maxY) maxY = totalTon;
      barLabels[i] = ano;
      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [ChartStyles.barRod(toY: totalTon)],
      ));
    }

    // Dados para LineChart — ATR médio por ano
    final atrSpots = <FlSpot>[];
    double maxATR = 0;
    for (var i = 0; i < anosOrdenados.length; i++) {
      final prods = porAno[anosOrdenados[i]]!;
      final atrs = prods.where((p) => p.mediaATR != null).toList();
      if (atrs.isNotEmpty) {
        final media =
            atrs.fold<double>(0, (s, p) => s + p.mediaATR!) / atrs.length;
        if (media > maxATR) maxATR = media;
        atrSpots.add(FlSpot(i.toDouble(), media));
      }
    }

    // KPIs
    final totalGeral = _produtividades.fold<double>(
        0, (s, p) => s + (p.pesoLiquidoToneladas ?? 0));
    final atrsValidos =
        _produtividades.where((p) => p.mediaATR != null).toList();
    final mediaATRGeral = atrsValidos.isNotEmpty
        ? atrsValidos.fold<double>(0, (s, p) => s + p.mediaATR!) /
            atrsValidos.length
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _kpiCard('Total Produzido',
                  '${totalGeral.toStringAsFixed(1)} t', Icons.scale, Colors.green),
              _kpiCard('ATR Médio', '${mediaATRGeral.toStringAsFixed(1)} kg/t',
                  Icons.science, Colors.blue),
              _kpiCard('Safras', '${anosOrdenados.length}',
                  Icons.calendar_month, Colors.orange),
              _kpiCard('Registros', '${_produtividades.length}',
                  Icons.list_alt, Colors.teal),
            ],
          ),
          const SizedBox(height: 24),

          // Gráfico barras — Produção por Safra
          if (barGroups.isNotEmpty) ...[
            _chartCard(
              titulo: 'Produção por Safra (toneladas)',
              child: SizedBox(
                height: 280,
                child: BarChart(
                  BarChartData(
                    maxY: maxY * 1.15,
                    barGroups: barGroups,
                    gridData: ChartStyles.gridPadrao,
                    borderData: ChartStyles.borderNenhum,
                    titlesData: ChartStyles.titlesData(
                      left: ChartStyles.leftAxis(
                        getTitlesWidget: (v, meta) =>
                            ChartStyles.axisLabel(v.toInt().toString()),
                      ),
                      bottom: ChartStyles.bottomAxis(
                        getTitlesWidget: (v, meta) {
                          final idx = v.toInt();
                          return ChartStyles.axisLabel(
                              barLabels[idx] ?? '');
                        },
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: ChartStyles.barTooltip(
                        getLabel: (i) {
                          final ano = barLabels[i] ?? '';
                          final total = barGroups[i].barRods.first.toY;
                          return '$ano\n${total.toStringAsFixed(1)} t';
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Gráfico linha — ATR médio por safra
          if (atrSpots.length >= 2) ...[
            _chartCard(
              titulo: 'ATR Médio por Safra (kg/t)',
              child: SizedBox(
                height: 240,
                child: LineChart(
                  LineChartData(
                    maxY: maxATR * 1.15,
                    minY: 0,
                    lineBarsData: [
                      ChartStyles.lineBar(
                        spots: atrSpots,
                        color: ChartStyles.barBlue,
                        showDots: true,
                        showArea: true,
                      ),
                    ],
                    gridData: ChartStyles.gridPadrao,
                    borderData: ChartStyles.borderNenhum,
                    titlesData: ChartStyles.titlesData(
                      left: ChartStyles.leftAxis(
                        getTitlesWidget: (v, meta) =>
                            ChartStyles.axisLabel(v.toInt().toString()),
                      ),
                      bottom: ChartStyles.bottomAxis(
                        getTitlesWidget: (v, meta) {
                          final idx = v.toInt();
                          if (idx >= 0 && idx < anosOrdenados.length) {
                            return ChartStyles.axisLabel(anosOrdenados[idx]);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) => spots
                            .map((s) => LineTooltipItem(
                                  '${s.y.toStringAsFixed(1)} kg/t',
                                  ChartStyles.tooltipStyle,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ABA 2: PRECIPITAÇÃO
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAbaPrecipitacao() {
    if (_carregandoPrecip) return _loading();
    if (_precipitacoes.isEmpty) return _vazio('Nenhum dado de precipitação');

    // Agrupar por mês/ano
    final porMes = <int, double>{};
    final porAno = <int, double>{};
    for (final p in _precipitacoes) {
      porMes[p.mes] = (porMes[p.mes] ?? 0) + p.milimetros;
      porAno[p.ano] = (porAno[p.ano] ?? 0) + p.milimetros;
    }

    // Barras por mês
    const meses = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    final barGroupsMes = <BarChartGroupData>[];
    double maxMes = 0;
    for (var m = 1; m <= 12; m++) {
      final val = porMes[m] ?? 0;
      if (val > maxMes) maxMes = val;
      barGroupsMes.add(BarChartGroupData(
        x: m - 1,
        barRods: [ChartStyles.barRod(toY: val, color: ChartStyles.barBlue)],
      ));
    }

    // Linha acumulada por ano
    final anosOrdenados = porAno.keys.toList()..sort();
    final spotsAno = <FlSpot>[];
    double maxAno = 0;
    for (var i = 0; i < anosOrdenados.length; i++) {
      final val = porAno[anosOrdenados[i]]!;
      if (val > maxAno) maxAno = val;
      spotsAno.add(FlSpot(i.toDouble(), val));
    }

    // KPIs
    final totalMm = _precipitacoes.fold<double>(0, (s, p) => s + p.milimetros);
    final mediaPorRegistro =
        _precipitacoes.isNotEmpty ? totalMm / _precipitacoes.length : 0.0;
    final maiorRegistro = _precipitacoes.isNotEmpty
        ? _precipitacoes
            .map((p) => p.milimetros)
            .reduce((a, b) => a > b ? a : b)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _kpiCard('Total Acumulado', '${totalMm.toStringAsFixed(1)} mm',
                  Icons.water_drop, Colors.blue),
              _kpiCard('Média/Registro',
                  '${mediaPorRegistro.toStringAsFixed(1)} mm',
                  Icons.equalizer, Colors.cyan),
              _kpiCard('Maior Registro', '${maiorRegistro.toStringAsFixed(1)} mm',
                  Icons.arrow_upward, Colors.indigo),
              _kpiCard('Registros', '${_precipitacoes.length}',
                  Icons.list_alt, Colors.teal),
            ],
          ),
          const SizedBox(height: 24),

          // Barras — Precipitação por Mês
          _chartCard(
            titulo: 'Precipitação por Mês (mm)',
            child: SizedBox(
              height: 280,
              child: BarChart(
                BarChartData(
                  maxY: maxMes * 1.15,
                  barGroups: barGroupsMes,
                  gridData: ChartStyles.gridPadrao,
                  borderData: ChartStyles.borderNenhum,
                  titlesData: ChartStyles.titlesData(
                    left: ChartStyles.leftAxis(
                      getTitlesWidget: (v, meta) =>
                          ChartStyles.axisLabel(v.toInt().toString()),
                    ),
                    bottom: ChartStyles.bottomAxis(
                      getTitlesWidget: (v, meta) {
                        final idx = v.toInt();
                        if (idx >= 0 && idx < 12) {
                          return ChartStyles.axisLabel(meses[idx]);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: ChartStyles.barTooltip(
                      getLabel: (i) {
                        final m = meses[i];
                        final v = porMes[i + 1] ?? 0;
                        return '$m\n${v.toStringAsFixed(1)} mm';
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Linha — Acumulado Anual
          if (spotsAno.length >= 2)
            _chartCard(
              titulo: 'Acumulado Anual (mm)',
              child: SizedBox(
                height: 240,
                child: LineChart(
                  LineChartData(
                    maxY: maxAno * 1.15,
                    minY: 0,
                    lineBarsData: [
                      ChartStyles.lineBar(
                        spots: spotsAno,
                        color: ChartStyles.barBlue,
                        showDots: true,
                        showArea: true,
                      ),
                    ],
                    gridData: ChartStyles.gridPadrao,
                    borderData: ChartStyles.borderNenhum,
                    titlesData: ChartStyles.titlesData(
                      left: ChartStyles.leftAxis(
                        getTitlesWidget: (v, meta) =>
                            ChartStyles.axisLabel(v.toInt().toString()),
                      ),
                      bottom: ChartStyles.bottomAxis(
                        getTitlesWidget: (v, meta) {
                          final idx = v.toInt();
                          if (idx >= 0 && idx < anosOrdenados.length) {
                            return ChartStyles.axisLabel(
                                '${anosOrdenados[idx]}');
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) => spots
                            .map((s) => LineTooltipItem(
                                  '${s.y.toStringAsFixed(1)} mm',
                                  ChartStyles.tooltipStyle,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ABA 3: CUSTOS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAbaCustos() {
    if (_carregandoCustos) return _loading();
    if (_cenarios.isEmpty) return _vazio('Nenhum cenário de custo');

    // PieChart — composição por cenário (produtividade vs custo)
    final pieSections = <PieChartSectionData>[];
    for (var i = 0; i < _cenarios.length && i < ChartStyles.seriesColors.length; i++) {
      final c = _cenarios[i];
      final valor = c.totalOperacional ?? 0;
      pieSections.add(ChartStyles.pieSection(
        value: valor,
        title: '${c.nomeCenario}\nR\$ ${valor.toStringAsFixed(0)}',
        color: ChartStyles.seriesColors[i],
        radius: 70,
      ));
    }

    // BarChart — margem por cenário
    final barGroups = <BarChartGroupData>[];
    final barLabels = <int, String>{};
    double maxMargem = 0;
    double minMargem = 0;
    for (var i = 0; i < _cenarios.length; i++) {
      final c = _cenarios[i];
      final margem = c.margemLucroPorTonelada ?? 0;
      if (margem > maxMargem) maxMargem = margem;
      if (margem < minMargem) minMargem = margem;
      barLabels[i] = c.nomeCenario.length > 10
          ? '${c.nomeCenario.substring(0, 10)}…'
          : c.nomeCenario;
      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          ChartStyles.barRod(
            toY: margem,
            color: margem >= 0 ? ChartStyles.positive : ChartStyles.negative,
          ),
        ],
      ));
    }

    // KPIs
    final custoMedio = _cenarios.isNotEmpty
        ? _cenarios.fold<double>(
                0, (s, c) => s + (c.totalOperacional ?? 0)) /
            _cenarios.length
        : 0.0;
    final margemMedia = _cenarios.isNotEmpty
        ? _cenarios.fold<double>(
                0, (s, c) => s + (c.margemLucroPorTonelada ?? 0)) /
            _cenarios.length
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _kpiCard('Cenários', '${_cenarios.length}',
                  Icons.compare_arrows, Colors.purple),
              _kpiCard('Custo Médio',
                  'R\$ ${custoMedio.toStringAsFixed(0)}/ha',
                  Icons.money, Colors.orange),
              _kpiCard(
                  'Margem Média',
                  'R\$ ${margemMedia.toStringAsFixed(2)}/t',
                  Icons.trending_up,
                  margemMedia >= 0 ? Colors.green : Colors.red),
            ],
          ),
          const SizedBox(height: 24),

          // PieChart — Distribuição de Custos
          if (pieSections.isNotEmpty)
            _chartCard(
              titulo: 'Custo Operacional por Cenário (R\$/ha)',
              child: SizedBox(
                height: 280,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sections: pieSections,
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          _cenarios.length > ChartStyles.seriesColors.length
                              ? ChartStyles.seriesColors.length
                              : _cenarios.length,
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ChartStyles.legendItem(
                              _cenarios[i].nomeCenario,
                              ChartStyles.seriesColors[i],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),

          // BarChart — Margem por cenário
          if (barGroups.isNotEmpty)
            _chartCard(
              titulo: 'Margem por Cenário (R\$/t)',
              child: SizedBox(
                height: 280,
                child: BarChart(
                  BarChartData(
                    maxY: maxMargem > 0 ? maxMargem * 1.2 : 10,
                    minY: minMargem < 0 ? minMargem * 1.2 : 0,
                    barGroups: barGroups,
                    gridData: ChartStyles.gridPadrao,
                    borderData: ChartStyles.borderNenhum,
                    titlesData: ChartStyles.titlesData(
                      left: ChartStyles.leftAxis(
                        getTitlesWidget: (v, meta) =>
                            ChartStyles.axisLabel(v.toStringAsFixed(0)),
                      ),
                      bottom: ChartStyles.bottomAxis(
                        getTitlesWidget: (v, meta) {
                          final idx = v.toInt();
                          return ChartStyles.axisLabel(barLabels[idx] ?? '');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: ChartStyles.barTooltip(
                        getLabel: (i) {
                          final c = _cenarios[i];
                          return '${c.nomeCenario}\nR\$ ${(c.margemLucroPorTonelada ?? 0).toStringAsFixed(2)}/t';
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ABA 4: VARIEDADES
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAbaVariedades() {
    if (_carregandoVariedades) return _loading();

    // Agrupar talhões por variedade
    final agrupado = <String, List<Talhao>>{};
    for (final t in _talhoes) {
      if (t.variedade != null && t.variedade!.isNotEmpty) {
        agrupado.putIfAbsent(t.variedade!, () => []).add(t);
      }
    }

    if (agrupado.isEmpty) return _vazio('Nenhuma variedade nos talhões');

    final areaTotalProp = widget.contexto.propriedade.areaHa ?? 0;

    // Montar resumos
    final resumos = <_ResumoVar>[];
    double areaPlantadaTotal = 0;
    for (final entry in agrupado.entries) {
      final varId = entry.key;
      final talhoesVar = entry.value;
      final area =
          talhoesVar.fold<double>(0, (s, t) => s + (t.areaHa ?? 0));
      areaPlantadaTotal += area;

      final variedade = _variedadeMap[varId];
      final nome = variedade?.codigo ?? varId;

      resumos.add(_ResumoVar(
        nome: nome,
        areaHa: area,
        qtdTalhoes: talhoesVar.length,
        percentual: areaTotalProp > 0 ? (area / areaTotalProp) * 100 : 0,
      ));
    }
    resumos.sort((a, b) => b.areaHa.compareTo(a.areaHa));

    final ocupacao =
        areaTotalProp > 0 ? (areaPlantadaTotal / areaTotalProp) * 100 : 0.0;

    // PieChart — distribuição por variedade
    final pieSections = <PieChartSectionData>[];
    for (var i = 0;
        i < resumos.length && i < ChartStyles.seriesColors.length;
        i++) {
      pieSections.add(ChartStyles.pieSection(
        value: resumos[i].areaHa,
        title: '${resumos[i].percentual.toStringAsFixed(1)}%',
        color: ChartStyles.seriesColors[i],
      ));
    }

    // BarChart — área por variedade
    final barGroups = <BarChartGroupData>[];
    final barLabels = <int, String>{};
    double maxArea = 0;
    for (var i = 0; i < resumos.length; i++) {
      final r = resumos[i];
      if (r.areaHa > maxArea) maxArea = r.areaHa;
      barLabels[i] = r.nome.length > 8 ? '${r.nome.substring(0, 8)}…' : r.nome;
      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          ChartStyles.barRod(
            toY: r.areaHa,
            color: ChartStyles.seriesColors[i % ChartStyles.seriesColors.length],
          ),
        ],
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _kpiCard('Variedades', '${resumos.length}', Icons.grass,
                  Colors.green),
              _kpiCard('Área Plantada',
                  '${areaPlantadaTotal.toStringAsFixed(1)} ha',
                  Icons.square_foot, Colors.blue),
              _kpiCard('Ocupação', '${ocupacao.toStringAsFixed(1)}%',
                  Icons.pie_chart, Colors.orange),
              _kpiCard(
                  'Talhões',
                  '${_talhoes.where((t) => t.variedade != null && t.variedade!.isNotEmpty).length}',
                  Icons.agriculture,
                  Colors.teal),
            ],
          ),
          const SizedBox(height: 24),

          // PieChart — Distribuição
          if (pieSections.isNotEmpty)
            _chartCard(
              titulo: 'Distribuição por Variedade (% área)',
              child: SizedBox(
                height: 280,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sections: pieSections,
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            resumos.length > ChartStyles.seriesColors.length
                                ? ChartStyles.seriesColors.length
                                : resumos.length,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: ChartStyles.legendItem(
                                '${resumos[i].nome} (${resumos[i].areaHa.toStringAsFixed(1)} ha)',
                                ChartStyles.seriesColors[i],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),

          // BarChart — Área por Variedade
          if (barGroups.isNotEmpty)
            _chartCard(
              titulo: 'Área por Variedade (ha)',
              child: SizedBox(
                height: 280,
                child: BarChart(
                  BarChartData(
                    maxY: maxArea * 1.15,
                    barGroups: barGroups,
                    gridData: ChartStyles.gridPadrao,
                    borderData: ChartStyles.borderNenhum,
                    titlesData: ChartStyles.titlesData(
                      left: ChartStyles.leftAxis(
                        getTitlesWidget: (v, meta) =>
                            ChartStyles.axisLabel(v.toStringAsFixed(0)),
                      ),
                      bottom: ChartStyles.bottomAxis(
                        getTitlesWidget: (v, meta) {
                          final idx = v.toInt();
                          return ChartStyles.axisLabel(barLabels[idx] ?? '');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: ChartStyles.barTooltip(
                        getLabel: (i) {
                          final r = resumos[i];
                          return '${r.nome}\n${r.areaHa.toStringAsFixed(1)} ha';
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDGETS COMUNS
  // ═══════════════════════════════════════════════════════════════

  Widget _loading() => const Center(child: CircularProgressIndicator());

  Widget _vazio(String mensagem) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(mensagem,
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Cadastre dados para visualizar os gráficos',
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ],
        ),
      );

  Widget _kpiCard(String label, String valor, IconData icon, Color cor) {
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cor.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: cor, size: 24),
              const SizedBox(height: 8),
              Text(valor,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: cor)),
              const SizedBox(height: 2),
              Text(label,
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartCard({required String titulo, required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: ChartStyles.titleStyle),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ResumoVar {
  final String nome;
  final double areaHa;
  final int qtdTalhoes;
  final double percentual;

  const _ResumoVar({
    required this.nome,
    required this.areaHa,
    required this.qtdTalhoes,
    required this.percentual,
  });
}
