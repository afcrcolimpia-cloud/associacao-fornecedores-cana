import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/custo_operacional_analise.dart';
import '../services/custo_operacional_service.dart';
import '../constants/app_colors.dart';

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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue * 1.1,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${dados[groupIndex].toStringAsFixed(2)} $unidade',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < nomes.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            nomes[index].length > 15
                                ? '${nomes[index].substring(0, 12)}...'
                                : nomes[index],
                            style: const TextStyle(fontSize: 9),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 40,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 9),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              barGroups: [
                for (int i = 0; i < dados.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: dados[i].toDouble(),
                        color: _obterCorBarra(dados[i], maxValue),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
              ],
              gridData: const FlGridData(show: true),
            ),
          ),
        ),
      ],
    );
  }

  Color _obterCorBarra(double valor, double maxValue) {
    if (_tipoGrafico == 0) {
      // Margem: verde se positivo, vermelho se negativo
      return valor >= 0 ? AppColors.success : AppColors.error;
    } else {
      // Produtividade e Custo: gradiente
      final opacity = (valor / maxValue).clamp(0.4, 1.0);
      return AppColors.primary.withOpacity(opacity);
    }
  }

  Widget _buildTabelaComparativa() {
    final nomes = dadosComparacao['nomes'] as List<String>;
    final margens = dadosComparacao['margens'] as List<double>;
    final producoes = dadosComparacao['producoes'] as List<double>;
    final custos = dadosComparacao['custos'] as List<double>;

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.bgDark,
            padding: const EdgeInsets.all(12),
            child: const Row(
              children: [
                Expanded(
                  flex: 25,
                  child: Text(
                    'Cenário',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  flex: 25,
                  child: Text(
                    'Margem/t',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  flex: 25,
                  child: Text(
                    'Prod.',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  flex: 25,
                  child: Text(
                    'Custo',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
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
                      style: const TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Text(
                      'R\$ ${margens[index].toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: margens[index] >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Text(
                      '${producoes[index].toStringAsFixed(1)} t',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Text(
                      'R\$ ${custos[index].toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 10),
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
