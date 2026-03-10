import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_shell.dart';
import '../widgets/kpi_card.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/proprietario_service.dart';
import '../services/propriedade_service.dart';
import '../services/talhao_service.dart';
import 'proprietarios_screen.dart';
import 'propriedades_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _proprietarioService = ProprietarioService();
  final _propriedadeService = PropriedadeService();
  final _talhaoService = TalhaoService();

  int _selectedNavigationIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      title: 'Dashboard Principal',
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI CARDS — 4 COLUNAS
              StreamBuilder<List<Proprietario>>(
                stream: _proprietarioService.getProprietariosStream(),
                builder: (context, proprietariosSnapshot) {
                  if (proprietariosSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: SizedBox(
                      height: 200,
                      child: CircularProgressIndicator(),
                    ));
                  }

                  final proprietarios = proprietariosSnapshot.data ?? [];

                  return Column(
                    children: [
                      _buildKPIGrid(proprietarios),
                      const SizedBox(height: 32),
                      
                      // TITLE "MENU PRINCIPAL"
                      Text(
                        'Menu Principal',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.newTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // MENU GRID (2 colunas)
                      _buildMenuGrid(proprietarios),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIGrid(List<Proprietario> proprietarios) {
    return StreamBuilder<List<Propriedade>>(
      stream: _propriedadeService.getPropriedadesStream(),
      builder: (context, snapshotPropriedades) {
        final propriedades = snapshotPropriedades.data ?? [];

        return FutureBuilder<double>(
          future: _computeTotalArea(propriedades),
          builder: (context, snapshotAreaTotal) {
            final areaTotal = snapshotAreaTotal.data ?? 0.0;

            return FutureBuilder<int>(
              future: _computeTotalTalhoes(propriedades),
              builder: (context, snapshotTalhoes) {
                final totalTalhoes = snapshotTalhoes.data ?? 0;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 1200;
                    final crossAxisCount = isWide ? 4 : 2;
                    final childAspectRatio = isWide ? 1.5 : 1.3;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        KpiCard(
                          label: 'Total de Proprietários',
                          value: proprietarios.length.toString(),
                          icon: Icons.people,
                          iconColor: AppColors.newPrimary,
                          variation: 0,
                          isPositive: true,
                        ),
                        KpiCard(
                          label: 'Total de Propriedades',
                          value: propriedades.length.toString(),
                          icon: Icons.home_work,
                          iconColor: AppColors.newSuccess,
                          variation: 0,
                          isPositive: true,
                        ),
                        KpiCard(
                          label: 'Total de Talhões',
                          value: totalTalhoes.toString(),
                          icon: Icons.landscape,
                          iconColor: AppColors.newWarning,
                          variation: 0,
                          isPositive: true,
                        ),
                        KpiCard(
                          label: 'Área Total (ha)',
                          value: areaTotal.toStringAsFixed(1),
                          icon: Icons.terrain,
                          iconColor: AppColors.newInfo,
                          variation: 0,
                          isPositive: true,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<double> _computeTotalArea(List<Propriedade> propriedades) async {
    double total = 0.0;
    for (var p in propriedades) {
      if (p.areaHa != null && p.areaHa! > 0) {
        total += p.areaHa!;
      } else {
        try {
          final area = await _talhaoService.getAreaTotalPropriedade(p.id);
          total += area;
        } catch (_) {}
      }
    }
    return total;
  }

  Future<int> _computeTotalTalhoes(List<Propriedade> propriedades) async {
    int total = 0;
    for (var p in propriedades) {
      try {
        final talhoes = await _talhaoService.getTalhoesPorPropriedade(p.id);
        total += talhoes.length;
      } catch (_) {}
    }
    return total;
  }

  Widget _buildMenuGrid(List<Proprietario> proprietarios) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1000;
        final crossAxisCount = isWide ? 2 : 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isWide ? 2 : 3,
          children: [
            _buildMenuCard(
              icon: Icons.person,
              title: 'Proprietários',
              subtitle: 'Gerenciar proprietários',
              count: proprietarios.length.toString(),
              color: AppColors.newPrimary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProprietariosScreen()),
                );
              },
            ),
            
            _buildMenuCardWithStream(
              icon: Icons.location_city,
              title: 'Propriedades',
              subtitle: 'Visualizar propriedades',
              color: AppColors.newSuccess,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PropriedadesScreen()),
                );
              },
            ),
            
            _buildMenuCard(
              icon: Icons.landscape,
              title: 'Talhões',
              subtitle: 'Gerenciar talhões',
              count: '',
              color: AppColors.newWarning,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Acesse a GESTÃO para gerenciar talhões')),
                );
              },
            ),
            
            _buildMenuCard(
              icon: Icons.attach_file,
              title: 'Anexos',
              subtitle: 'Documentos e arquivos',
              count: '',
              color: AppColors.newInfo,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Acesse a GESTÃO para gerenciar anexos')),
                );
              },
            ),
            
            _buildMenuCard(
              icon: Icons.agriculture,
              title: 'Operações',
              subtitle: 'Operações de cultivo',
              count: '',
              color: AppColors.newPrimary,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Acesse a GESTÃO para gerenciar operações')),
                );
              },
            ),
            
            _buildMenuCard(
              icon: Icons.attach_money,
              title: 'Custo Operacional',
              subtitle: 'Análise de custos',
              count: '',
              color: AppColors.newSuccess,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Acesse a GESTÃO para analisar custos operacionais')),
                );
              },
            ),
            
            _buildMenuCard(
              icon: Icons.trending_up,
              title: 'Produtividade',
              subtitle: 'Análise de produção',
              count: '',
              color: AppColors.newWarning,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Acesse a GESTÃO para análise de produtividade')),
                );
              },
            ),
            
            _buildMenuCard(
              icon: Icons.water_drop,
              title: 'Precipitação',
              subtitle: 'Dados de chuvas',
              count: '',
              color: AppColors.newInfo,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Acesse a GESTÃO para visualizar precipitação')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String count,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppColors.borderDark.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const Spacer(),
                    if (count.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          count,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.newTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.newTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCardWithStream({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return StreamBuilder<List<Propriedade>>(
      stream: _propriedadeService.getPropriedadesStream(),
      builder: (context, snapshot) {
        final count = (snapshot.data ?? []).length.toString();
        
        return _buildMenuCard(
          icon: icon,
          title: title,
          subtitle: subtitle,
          color: color,
          count: count,
          onTap: onTap,
        );
      },
    );
  }
}