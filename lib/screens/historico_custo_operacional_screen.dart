import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_shell.dart';
import '../constants/app_colors.dart';
import '../services/custo_operacional_service.dart';

class HistoricoCustoOperacionalScreen extends StatefulWidget {
  const HistoricoCustoOperacionalScreen({super.key});

  @override
  State<HistoricoCustoOperacionalScreen> createState() =>
      _HistoricoCustoOperacionalScreenState();
}

class _HistoricoCustoOperacionalScreenState
    extends State<HistoricoCustoOperacionalScreen> {
  List<CustoOperacionalCenario> _cenarios = [];
  bool _loadingCenarios = true;
  String? _filtroSafra;

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

  List<BarChartGroupData> _buildBarChartGroups() {
    final dados = _getCustosPorSafra();
    final entries = dados.entries.toList();
    
    return List.generate(
      entries.length,
      (index) {
        final maxValue = dados.values.isNotEmpty
            ? dados.values.reduce((a, b) => a > b ? a : b)
            : 1.0;
        final normedValue =
            (entries[index].value / maxValue) * 100;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: normedValue,
              color: [
                AppColors.newSuccess,
                AppColors.newWarning,
                AppColors.newInfo,
                AppColors.newPrimary,
              ][index % 4],
              width: 40,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: 0,
      title: 'Relatório de Custos',
      onNavigationSelect: (_) {},
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do Relatório
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo AFCRC (simulado com texto)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Associação dos Fornecedores de Cana',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.newTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AFCRC — Catanduva/SP',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.newTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Data: ${DateTime.now().toString().substring(0, 10)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.newTextMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    color: AppColors.borderDark,
                    height: 1,
                  ),
                  const SizedBox(height: 16),

                  // Título do Relatório
                  Text(
                    'Relatório Executivo — Custos Operacionais',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.newTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sumário Executivo
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Custo Total',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.newTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${_getCustoTotal().toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.newSuccess,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Número de Cenários',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.newTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_cenarios.length}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.newInfo,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Períodos Analisados',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.newTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_getCustosPorSafra().length}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.newWarning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Filtro de Safra
            SizedBox(
              width: 250,
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

            const SizedBox(height: 24),

            // Gráfico de Evolução
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
                            'Nenhum dado disponível',
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
                              'Evolução de Custos por Safra',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.newTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: BarChart(
                                BarChartData(
                                  barGroups: _buildBarChartGroups(),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (double value,
                                            TitleMeta meta) {
                                          final safras =
                                              _getCustosPorSafra().keys.toList();
                                          if (value.toInt() < safras.length) {
                                            return Text(
                                              safras[value.toInt()],
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: AppColors
                                                    .newTextSecondary,
                                              ),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (double value,
                                            TitleMeta meta) {
                                          return Text(
                                            '${value.toInt()}%',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: AppColors
                                                  .newTextSecondary,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: const FlGridData(show: false),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),

            const SizedBox(height: 32),

            // Tabela Detalhada de Cenários
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
                              'Detalhamento de Custos',
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
                                      'Produtividade (t/ha)',
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
                                      'Custo Administrativo (R\$)',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newTextPrimary,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Total Operacional (R\$)',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newTextPrimary,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Margem Lucro (R\$)',
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
                                              item.produtividade
                                                  .toStringAsFixed(1),
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
                                              'R\$ ${(item.custoAdministrativo ?? 0).toStringAsFixed(2)}',
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
                                          DataCell(
                                            Text(
                                              'R\$ ${(item.margemLucro ?? 0).toStringAsFixed(2)}',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: AppColors
                                                    .newTextSecondary,
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

            const SizedBox(height: 24),

            // Botão Exportar PDF
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Exportar PDF'),
                onPressed: () {
                  // TODO: Implementar exportação de PDF usando ExportacaoPdfService
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.newPrimary,
                  foregroundColor: AppColors.bgDark,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
