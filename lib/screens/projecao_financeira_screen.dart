import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../widgets/chart_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/custo_operacional_analise.dart';
import '../services/custo_operacional_service.dart';
import '../constants/app_colors.dart';
import '../constants/chart_styles.dart';

class ProjecaoFinanceiraScreen extends StatefulWidget {
  final CustoOperacionalCenario cenario;

  const ProjecaoFinanceiraScreen({
    required this.cenario,
    super.key,
  });

  @override
  State<ProjecaoFinanceiraScreen> createState() =>
      _ProjecaoFinanceiraScreenState();
}

class _ProjecaoFinanceiraScreenState extends State<ProjecaoFinanceiraScreen> {
  late List<ProjecaoFinanceira> projacoes;
  int _periodos = 12;
  int _selectedNavigationIndex = 0;

  @override
  void initState() {
    super.initState();
    projacoes =
        CustoOperacionalAnalise.gerarProjecaoFinanceira(widget.cenario, _periodos);
  }

  double _custoAnualizado() {
    // Usa o service centralizado para calcular — nunca duplicar lógica
    final resumo = CustoOperacionalService().calcularResumoComTotais(
      cenario: widget.cenario,
    );
    return resumo.totalOperacional.rHa;
  }

  void _atualizarProjecao(int novosPeriodos) {
    setState(() {
      _periodos = novosPeriodos;
      projacoes = CustoOperacionalAnalise.gerarProjecaoFinanceira(
        widget.cenario,
        _periodos,
      );
    });
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
                'Projeção Financeira',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              // Card com informações do cenário
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cenario.nomeCenario,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoCircle(
                            'Receita Anual',
                            'R\$ ${(widget.cenario.produtividade * widget.cenario.atr.toDouble() * (widget.cenario.precoAtr ?? 0)).toStringAsFixed(0)}',
                            AppColors.success,
                          ),
                          _buildInfoCircle(
                            'Custo Anual',
                            'R\$ ${_custoAnualizado().toStringAsFixed(0)}',
                            AppColors.error,
                          ),
                          _buildInfoCircle(
                            'Margem',
                            'R\$ ${(widget.cenario.margemLucroPorTonelada ?? 0).toStringAsFixed(0)}/t',
                            AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Seletor de períodos
              const Text(
                'Período de Análise:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [3, 6, 12, 18, 24].map((periodo) {
                  return FilterChip(
                    label: Text('$periodo meses'),
                    selected: _periodos == periodo,
                    onSelected: (selected) {
                      if (selected) {
                        _atualizarProjecao(periodo);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Gráfico de linha
              _buildGraficoProjecao(),
              const SizedBox(height: 20),

              // Tabela de detalhes
              _buildTabelaProjecao(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCircle(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                value.split(' ')[0],
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoProjecao() {
    return ChartCard(
      titulo: 'Evolução Financeira',
      subtitulo: 'Projeção de receita, custo e margem',
      legendWidget: Wrap(
        spacing: 16,
        children: [
          ChartStyles.legendItem('Receita', ChartStyles.positive),
          ChartStyles.legendItem('Custo', ChartStyles.negative),
          ChartStyles.legendItem('Margem', ChartStyles.barBlue),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: ChartStyles.gridPadrao,
          titlesData: ChartStyles.titlesData(
            left: ChartStyles.leftAxis(
              reservedSize: 50,
              getTitlesWidget: (value, meta) =>
                  ChartStyles.axisLabel('R\$ ${(value / 1000).toStringAsFixed(0)}k'),
            ),
            bottom: ChartStyles.bottomAxis(
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index > 0 && index <= projacoes.length) {
                  return ChartStyles.axisLabel('${projacoes[index - 1].periodo}m');
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          borderData: ChartStyles.borderNenhum,
          lineBarsData: [
            ChartStyles.lineBar(
              spots: [
                for (int i = 0; i < projacoes.length; i++)
                  FlSpot(i + 1.0, projacoes[i].receita)
              ],
              color: ChartStyles.positive,
              showArea: true,
            ),
            ChartStyles.lineBar(
              spots: [
                for (int i = 0; i < projacoes.length; i++)
                  FlSpot(i + 1.0, projacoes[i].custo)
              ],
              color: ChartStyles.negative,
              showArea: true,
            ),
            ChartStyles.lineBar(
              spots: [
                for (int i = 0; i < projacoes.length; i++)
                  FlSpot(i + 1.0, projacoes[i].margem)
              ],
              color: ChartStyles.barBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabelaProjecao() {
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
                  flex: 15,
                  child: Text('Período',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold,
                          fontSize: 11, color: AppColors.newTextPrimary)),
                ),
                Expanded(
                  flex: 28,
                  child: Text('Receita', textAlign: TextAlign.right,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold,
                          fontSize: 11, color: AppColors.newTextPrimary)),
                ),
                Expanded(
                  flex: 28,
                  child: Text('Custo', textAlign: TextAlign.right,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold,
                          fontSize: 11, color: AppColors.newTextPrimary)),
                ),
                Expanded(
                  flex: 29,
                  child: Text('Margem', textAlign: TextAlign.right,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold,
                          fontSize: 11, color: AppColors.newTextPrimary)),
                ),
              ],
            ),
          ),
          ...projacoes.map((proj) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: Text(
                      '${proj.periodo}m',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.newTextPrimary),
                    ),
                  ),
                  Expanded(
                    flex: 28,
                    child: Text(
                      'R\$ ${(proj.receita / 1000).toStringAsFixed(1)}k',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.newTextSecondary),
                    ),
                  ),
                  Expanded(
                    flex: 28,
                    child: Text(
                      'R\$ ${(proj.custo / 1000).toStringAsFixed(1)}k',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.newTextSecondary),
                    ),
                  ),
                  Expanded(
                    flex: 29,
                    child: Text(
                      'R\$ ${(proj.margem / 1000).toStringAsFixed(1)}k',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: proj.margem >= 0
                            ? ChartStyles.positive
                            : ChartStyles.negative,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
