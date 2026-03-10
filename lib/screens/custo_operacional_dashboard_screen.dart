import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_shell.dart';
import '../widgets/kpi_card.dart';
import '../constants/app_colors.dart';
import '../services/custo_operacional_service.dart';

class CustoOperacionalDashboardScreen extends StatefulWidget {
  const CustoOperacionalDashboardScreen({super.key});

  @override
  State<CustoOperacionalDashboardScreen> createState() =>
      _CustoOperacionalDashboardScreenState();
}

class _CustoOperacionalDashboardScreenState
    extends State<CustoOperacionalDashboardScreen> {
  List<CustoOperacionalCenario> _cenarios = [];
  bool _loadingCenarios = true;
  String? _filtroSafra;
  String? _filtroCategoria;

  final CustoOperacionalService _serviceCustos =
      CustoOperacionalService();

  @override
  void initState() {
    super.initState();
    _loadCenarios();
  }

  Future<void> _loadCenarios() async {
    try {
      if (!mounted) return;
      setState(() => _loadingCenarios = true);

      // Carregar cenários para propriedade dummy
      final cenarios =
          await _serviceCustos.getCenariosByPropriedade('dummy');

      if (mounted) {
        setState(() {
          _cenarios = cenarios;
          _loadingCenarios = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cenarios = [];
          _loadingCenarios = false;
        });
      }
    }
  }

  double _getCustoTotal() {
    return _cenarios.fold<double>(
        0, (sum, item) => sum + (item.totalOperacional ?? 0));
  }

  Map<String, double> _getCustosPorSafra() {
    final safras = <String, double>{};
    for (var item in _cenarios) {
      safras[item.periodoRef] = (safras[item.periodoRef] ?? 0) + 
          (item.totalOperacional ?? 0);
    }
    return safras;
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final dados = _getCustosPorSafra();
    final total = _getCustoTotal();

    if (dados.isEmpty || total == 0) {
      return [];
    }

    final cores = [
      AppColors.newSuccess,
      AppColors.newWarning,
      AppColors.newInfo,
      AppColors.newPrimary,
    ];

    int colorIndex = 0;
    return dados.entries.map((entry) {
      final cor = cores[colorIndex % cores.length];
      colorIndex++;
      final percentual = (entry.value / total) * 100;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentual.toStringAsFixed(1)}%',
        color: cor,
        radius: 80,
        titleStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: 0,
      title: 'Custo Operacional',
      onNavigationSelect: (_) {},
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título e Subtítulo
            Text(
              'Gestão de Custos',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.newTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acompanhe e analise todos os custos operacionais',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.newTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),

            // KPI Cards Grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: const [
                KpiCard(
                  label: 'Custo Total',
                  value: 'R\$ 0,00',
                  icon: Icons.payments_outlined,
                  iconColor: AppColors.newSuccess,
                ),
                KpiCard(
                  label: 'Custo Médio',
                  value: 'R\$ 0,00',
                  icon: Icons.trending_down_outlined,
                  iconColor: AppColors.newWarning,
                ),
                KpiCard(
                  label: 'Cenários',
                  value: 'N/A',
                  icon: Icons.category_outlined,
                  iconColor: AppColors.newInfo,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Seção de Filtros e Botões
            Row(
              children: [
                // Filtro Safra
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      border: Border.all(
                        color: AppColors.borderDark,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _filtroSafra,
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (value) {
                        setState(() => _filtroSafra = value);
                      },
                      dropdownColor: AppColors.surfaceDark,
                      style: GoogleFonts.inter(
                        color: AppColors.newTextPrimary,
                        fontSize: 14,
                      ),
                      hint: Text(
                        'Filtrar por Safra',
                        style: GoogleFonts.inter(
                          color: AppColors.newTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                      items: ['2023', '2024', '2025']
                          .map((safra) => DropdownMenuItem(
                                value: safra,
                                child: Text(safra),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Filtro Categoria
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      border: Border.all(
                        color: AppColors.borderDark,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _filtroCategoria,
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (value) {
                        setState(() => _filtroCategoria = value);
                      },
                      dropdownColor: AppColors.surfaceDark,
                      style: GoogleFonts.inter(
                        color: AppColors.newTextPrimary,
                        fontSize: 14,
                      ),
                      hint: Text(
                        'Filtrar por Categoria',
                        style: GoogleFonts.inter(
                          color: AppColors.newTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                      items: ['Mecanização', 'Insumos', 'Mão de Obra', 'Outros']
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Botão Novo Lançamento
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Novo'),
                  onPressed: () {
                    // TODO: Navegar para formulário de novo lançamento
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.newPrimary,
                    foregroundColor: AppColors.bgDark,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Botão Gerar PDF
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('PDF'),
                  onPressed: () {
                    // TODO: Implementar geração de PDF
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.newWarning,
                    foregroundColor: AppColors.bgDark,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Conteúdo Principal: Gráfico + Tabela
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gráfico Pizza (Custos por Safra)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      border: Border.all(
                        color: AppColors.borderDark,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _loadingCenarios
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _cenarios.isEmpty
                            ? Center(
                                child: Text(
                                  'Nenhum dado disponível',
                                  style: GoogleFonts.inter(
                                    color: AppColors.newTextMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  Text(
                                    'Custos por Safra',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.newTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 250,
                                    child: PieChart(
                                      PieChartData(
                                        sections: _buildPieChartSections(),
                                        centerSpaceRadius: 40,
                                        sectionsSpace: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
                const SizedBox(width: 24),

                // Tabela de Cenários
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      border: Border.all(
                        color: AppColors.borderDark,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _loadingCenarios
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _cenarios.isEmpty
                            ? Center(
                                child: Text(
                                  'Nenhum cenário cadastrado',
                                  style: GoogleFonts.inter(
                                    color: AppColors.newTextMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  Text(
                                    'Cenários Ativos',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.newTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount:
                                          _cenarios.length.clamp(0, 8),
                                      separatorBuilder: (_, __) =>
                                          const Divider(
                                        color: AppColors.borderDark,
                                        height: 1,
                                      ),
                                      itemBuilder: (context, index) {
                                        final item = _cenarios[index];
                                        return Padding(
                                          padding: const EdgeInsets
                                              .symmetric(vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                      item.nomeCenario,
                                                      style: GoogleFonts
                                                          .inter(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight
                                                                .w600,
                                                        color: AppColors
                                                            .newTextPrimary,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height: 4),
                                                    Text(
                                                      item.periodoRef,
                                                      style: GoogleFonts
                                                          .inter(
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .newTextSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'R\$ ${(item.totalOperacional ?? 0).toStringAsFixed(2)}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: AppColors
                                                      .newSuccess,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tabela Completa de Cenários
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border.all(
                  color: AppColors.borderDark,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _loadingCenarios
                  ? const Center(child: CircularProgressIndicator())
                  : _cenarios.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhum cenário cadastrado',
                            style: GoogleFonts.inter(
                              color: AppColors.newTextMuted,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Todos os Cenários',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.newTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 20,
                                dataRowColor:
                                    MaterialStateProperty.all(
                                  AppColors.bgDark,
                                ),
                                headingRowColor:
                                    MaterialStateProperty.all(
                                  AppColors.borderDark,
                                ),
                                columns: [
                                  DataColumn(
                                    label: Text(
                                      'Cenário',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newTextPrimary,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Período',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newTextPrimary,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Produtividade',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newTextPrimary,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'ATR',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newTextPrimary,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Total (R\$)',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newTextPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: _cenarios
                                    .map(
                                      (item) => DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              item.nomeCenario,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: AppColors
                                                    .newTextSecondary,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              item.periodoRef,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: AppColors
                                                    .newTextPrimary,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              '${item.produtividade.toStringAsFixed(1)} t/ha',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: AppColors
                                                    .newTextSecondary,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              '${item.atr}',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: AppColors
                                                    .newTextSecondary,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              'R\$ ${(item.totalOperacional ?? 0).toStringAsFixed(2)}',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: AppColors
                                                    .newSuccess,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
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
}
