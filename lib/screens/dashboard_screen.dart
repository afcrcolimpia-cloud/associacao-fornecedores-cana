import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/proprietario_service.dart';
import '../services/propriedade_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _proprietarioService = ProprietarioService();
  final _propriedadeService = PropriedadeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StreamBuilder<List<Proprietario>>(
              stream: _proprietarioService.getProprietariosStream(),
              builder: (context, proprietariosSnapshot) {
                if (!proprietariosSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final proprietarios = proprietariosSnapshot.data!;

                return StreamBuilder<List<Propriedade>>(
                  stream: _getAllPropriedades(proprietarios),
                  builder: (context, propriedadesSnapshot) {
                    if (!propriedadesSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final propriedades = propriedadesSnapshot.data!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResumoCards(proprietarios, propriedades),
                        const SizedBox(height: 24),
                        _buildPropriedadesPorProprietario(
                          proprietarios,
                          propriedades,
                        ),
                        const SizedBox(height: 24),
                        StreamBuilder<List<Talhao>>(
                          stream: _getAllTalhoes(propriedades),
                          builder: (context, talhoesSnapshot) {
                            if (!talhoesSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            final talhoes = talhoesSnapshot.data!;

                            return Column(
                              children: [
                                _buildAreaTotal(talhoes),
                                const SizedBox(height: 24),
                                _buildVariedades(talhoes),
                                const SizedBox(height: 24),
                                _buildCortes(talhoes),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoCards(
    List<Proprietario> proprietarios,
    List<Propriedade> propriedades,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Proprietários',
          value: proprietarios.length.toString(),
          icon: Icons.people,
          color: AppColors.primary,
          subtitle: '${proprietarios.where((p) => p.ativo).length} ativos',
        ),
        _buildStatCard(
          title: 'Propriedades',
          value: propriedades.length.toString(),
          icon: Icons.home_work,
          color: AppColors.secondary,
          subtitle: '${propriedades.where((p) => p.ativa).length} ativas',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPropriedadesPorProprietario(
    List<Proprietario> proprietarios,
    List<Propriedade> propriedades,
  ) {
    if (proprietarios.isEmpty) return const SizedBox.shrink();

    final dados = proprietarios.map((prop) {
      final count = propriedades
          .where((propriedade) => propriedade.proprietarioId == prop.id)
          .length;
      return {
        'nome': prop.nome,
        'count': count,
      };
    }).where((d) => (d['count'] as int) > 0).toList();

    if (dados.isEmpty) return const SizedBox.shrink();

    final maxY = dados.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b).toDouble() + 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Propriedades por Proprietário',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${dados[groupIndex]['nome']}\n${rod.toY.toInt()} propriedades',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
                          if (value.toInt() >= dados.length) return const Text('');
                          final nome = dados[value.toInt()]['nome'] as String;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              nome.split(' ').first,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    dados.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (dados[index]['count'] as int).toDouble(),
                          color: AppColors.primary,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaTotal(List<Talhao> talhoes) {
    if (talhoes.isEmpty) return const SizedBox.shrink();

    final totalHectares = talhoes.fold<double>(0, (sum, t) => sum + t.areaHectares);
    final totalAlqueires = talhoes.fold<double>(0, (sum, t) => sum + t.areaAlqueires);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Área Total Cultivada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircleStat('${talhoes.length}', 'Talhões', AppColors.accent),
                _buildCircleStat(totalHectares.toStringAsFixed(0), 'Hectares', AppColors.success),
                _buildCircleStat(totalAlqueires.toStringAsFixed(0), 'Alqueires', AppColors.info),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleStat(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildVariedades(List<Talhao> talhoes) {
    if (talhoes.isEmpty) return const SizedBox.shrink();

    final variedadeCount = <String, int>{};
    for (final talhao in talhoes) {
      variedadeCount[talhao.variedade] = (variedadeCount[talhao.variedade] ?? 0) + 1;
    }

    final cores = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.info,
      AppColors.warning,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Variedades Cultivadas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: variedadeCount.entries.toList().asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final percentage = (item.value / talhoes.length * 100);

                          return PieChartSectionData(
                            value: item.value.toDouble(),
                            title: '${percentage.toStringAsFixed(0)}%',
                            color: cores[index % cores.length],
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: variedadeCount.entries.toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: cores[index % cores.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${item.key} (${item.value})',
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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

  Widget _buildCortes(List<Talhao> talhoes) {
    if (talhoes.isEmpty) return const SizedBox.shrink();

    final corteCount = <int, int>{};
    for (final talhao in talhoes) {
      corteCount[talhao.corte] = (corteCount[talhao.corte] ?? 0) + 1;
    }

    final sortedCortes = corteCount.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribuição por Corte',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 24),
            ...sortedCortes.map((entry) {
              final percentage = entry.value / talhoes.length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${entry.key}º Corte',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          '${entry.value} talhões (${(percentage * 100).toStringAsFixed(0)}%)',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.key == 1
                            ? AppColors.success
                            : entry.key <= 3
                                ? AppColors.primary
                                : AppColors.warning,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Stream<List<Propriedade>> _getAllPropriedades(
    List<Proprietario> proprietarios,
  ) async* {
    final allPropriedades = <Propriedade>[];

    for (final proprietario in proprietarios) {
      await for (final propriedades
          in _propriedadeService.getPropriedadesByProprietarioStream(proprietario.id)) {
        for (final prop in propriedades) {
          if (!allPropriedades.any((p) => p.id == prop.id)) {
            allPropriedades.add(prop);
          }
        }
        yield List.from(allPropriedades);
      }
    }
  }

  Stream<List<Talhao>> _getAllTalhoes(List<Propriedade> propriedades) async* {
    final allTalhoes = <Talhao>[];

    for (final propriedade in propriedades) {
      await for (final talhoes
          in _propriedadeService.getTalhoesByPropriedadeStream(propriedade.id)) {
        for (final talhao in talhoes) {
          if (!allTalhoes.any((t) => t.id == talhao.id)) {
            allTalhoes.add(talhao);
          }
        }
        yield List.from(allTalhoes);
      }
    }
  }
}
