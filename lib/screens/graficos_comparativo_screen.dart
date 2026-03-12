import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../widgets/chart_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/custo_operacional_analise.dart';
import '../services/custo_operacional_service.dart';
import '../constants/app_colors.dart';
import '../constants/chart_styles.dart';

class GraficosComparativoScreen extends StatefulWidget {
  final List<CustoOperacionalCenario> cenarios;

  const GraficosComparativoScreen({
    required this.cenarios,
    super.key,
  });

  @override
  State<GraficosComparativoScreen> createState() =>
      _GraficosComparativoScreenState();
}

class _GraficosComparativoScreenState extends State<GraficosComparativoScreen> {
  late Map<String, dynamic> dadosComparacao;
  int _tipoGrafico = 0; // 0: Margem, 1: Produção, 2: Custo
  int _selectedNavigationIndex = 0;

  @override
  void initState() {
    super.initState();
    dadosComparacao =
        CustoOperacionalAnalise.gerarDadosComparacao(widget.cenarios);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) => setState(() => _selectedNavigationIndex = index),
      showBackButton: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Comparação de Cenários',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.newTextPrimary),
              ),
              const SizedBox(height: 16),
              // Segmented buttons para seleção de gráfico
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Margem/t'),
                    selected: _tipoGrafico == 0,
                    onSelected: (selected) {
                      setState(() => _tipoGrafico = 0);
                    },
                  ),
                  FilterChip(
                    label: const Text('Produtividade'),
                    selected: _tipoGrafico == 1,
                    onSelected: (selected) {
                      setState(() => _tipoGrafico = 1);
                    },
                  ),
                  FilterChip(
                    label: const Text('Custos'),
                    selected: _tipoGrafico == 2,
                    onSelected: (selected) {
                      setState(() => _tipoGrafico = 2);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Gráfico de barras
              _buildGrafico(),
              const SizedBox(height: 24),

              // Tabela comparativa
              _buildTabelaComparativa(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrafico() {
    final nomes = dadosComparacao['nomes'] as List<String>;
    List<double> dados;
    String titulo;
    String unidade;

    switch (_tipoGrafico) {
      case 0:
        dados = dadosComparacao['margens'] as List<double>;
        titulo = 'Margem por Tonelada';
        unidade = 'R\$/t';
        break;
      case 1:
        dados = dadosComparacao['producoes'] as List<double>;
        titulo = 'Produtividade';
        unidade = 't/ha';
        break;
      case 2:
        dados = dadosComparacao['custos'] as List<double>;
        titulo = 'Custo Total';
        unidade = 'R\$/ha';
        break;
      default:
        dados = [];
        titulo = '';
        unidade = '';
    }

    final maxValue =
        dados.isNotEmpty ? dados.reduce((a, b) => a > b ? a : b) : 1.0;

    return ChartCard(
      titulo: titulo,
      subtitulo: '${dados.length} cenários comparados',
      margin: EdgeInsets.zero,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.1,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: ChartStyles.barTooltip(
              getLabel: (i) =>
                  '${dados[i].toStringAsFixed(2)} $unidade',
            ),
          ),
          titlesData: ChartStyles.titlesData(
            left: ChartStyles.leftAxis(
              getTitlesWidget: (value, meta) =>
                  ChartStyles.axisLabel(value.toStringAsFixed(0)),
            ),
            bottom: ChartStyles.bottomAxis(
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < nomes.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      nomes[index].length > 15
                          ? '${nomes[index].substring(0, 12)}...'
                          : nomes[index],
                      style: ChartStyles.axisLabelStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          barGroups: [
            for (int i = 0; i < dados.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  ChartStyles.barRod(
                    toY: dados[i].toDouble(),
                    color: _obterCorBarra(dados[i], maxValue),
                    width: 20,
                  ),
                ],
              ),
          ],
          borderData: ChartStyles.borderNenhum,
          gridData: ChartStyles.gridPadrao,
        ),
      ),
    );
  }

  Color _obterCorBarra(double valor, double maxValue) {
    if (_tipoGrafico == 0) {
      // 3 níveis: lucrativo > 15, atenção 0-15, prejuízo < 0
      if (valor > 15) return const Color(0xFF66BB6A);
      if (valor >= 0) return const Color(0xFFFDD835);
      return const Color(0xFFEF5350);
    } else {
      final opacity = (valor / maxValue).clamp(0.4, 1.0);
      return ChartStyles.barPrimary.withValues(alpha: opacity);
    }
  }

  Widget _buildTabelaComparativa() {
    final nomes = dadosComparacao['nomes'] as List<String>;
    final margens = dadosComparacao['margens'] as List<double>;
    final producoes = dadosComparacao['producoes'] as List<double>;
    final custos = dadosComparacao['custos'] as List<double>;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(color: AppColors.borderDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  flex: 25,
                  child: Text('Cenário',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold,
                          fontSize: 11, color: AppColors.newTextPrimary)),
                ),
                Expanded(
                  flex: 25,
                  child: Text('Margem/t', textAlign: TextAlign.right,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold,
                          fontSize: 11, color: AppColors.newTextPrimary)),
                ),
                Expanded(
                  flex: 25,
                  child: Text('Prod.', textAlign: TextAlign.right,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold,
                          fontSize: 11, color: AppColors.newTextPrimary)),
                ),
                Expanded(
                  flex: 25,
                  child: Text('Custo', textAlign: TextAlign.right,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold,
                          fontSize: 11, color: AppColors.newTextPrimary)),
                ),
              ],
            ),
          ),
          ...List.generate(
            nomes.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 25,
                    child: Text(
                      nomes[index],
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.newTextPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Text(
                      'R\$ ${margens[index].toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: margens[index] > 15
                            ? const Color(0xFF66BB6A)
                            : margens[index] >= 0
                                ? const Color(0xFFFDD835)
                                : const Color(0xFFEF5350),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Text(
                      '${producoes[index].toStringAsFixed(1)} t',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.newTextSecondary),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Text(
                      'R\$ ${custos[index].toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.newTextSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
