import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/custo_operacional_analise.dart';
import '../services/custo_operacional_service.dart';
import '../constants/app_colors.dart';

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
                            'R\$ ${(widget.cenario.totalOperacional ?? 0).toStringAsFixed(0)}',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evolucao Financeira',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        'R\$ ${(value / 1000).toStringAsFixed(0)}k',
                        style: const TextStyle(fontSize: 9),
                      );
                    },
                    reservedSize: 50,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index > 0 && index <= projacoes.length) {
                        return Text(
                          '${projacoes[index - 1].periodo}m',
                          style: const TextStyle(fontSize: 9),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                // Linha de Receita
                LineChartBarData(
                  spots: [
                    for (int i = 0; i < projacoes.length; i++)
                      FlSpot(i + 1.0, projacoes[i].receita)
                  ],
                  isCurved: true,
                  color: AppColors.success,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.success.withOpacity(0.1),
                  ),
                ),
                // Linha de Custo
                LineChartBarData(
                  spots: [
                    for (int i = 0; i < projacoes.length; i++)
                      FlSpot(i + 1.0, projacoes[i].custo)
                  ],
                  isCurved: true,
                  color: AppColors.error,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.error.withOpacity(0.1),
                  ),
                ),
                // Linha de Margem
                LineChartBarData(
                  spots: [
                    for (int i = 0; i < projacoes.length; i++)
                      FlSpot(i + 1.0, projacoes[i].margem)
                  ],
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legenda
        Wrap(
          spacing: 16,
          children: [
            _buildLegendaItem('Receita', AppColors.success),
            _buildLegendaItem('Custo', AppColors.error),
            _buildLegendaItem('Margem', AppColors.primary),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendaItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildTabelaProjecao() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.lightBackground,
            padding: const EdgeInsets.all(12),
            child: const Row(
              children: [
                Expanded(
                  flex: 15,
                  child: Text(
                    'Período',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                Expanded(
                  flex: 28,
                  child: Text(
                    'Receita',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                Expanded(
                  flex: 28,
                  child: Text(
                    'Custo',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                Expanded(
                  flex: 29,
                  child: Text(
                    'Margem',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
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
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 28,
                    child: Text(
                      'R\$ ${(proj.receita / 1000).toStringAsFixed(1)}k',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  Expanded(
                    flex: 28,
                    child: Text(
                      'R\$ ${(proj.custo / 1000).toStringAsFixed(1)}k',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  Expanded(
                    flex: 29,
                    child: Text(
                      'R\$ ${(proj.margem / 1000).toStringAsFixed(1)}k',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: proj.margem >= 0
                            ? AppColors.success
                            : AppColors.error,
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
