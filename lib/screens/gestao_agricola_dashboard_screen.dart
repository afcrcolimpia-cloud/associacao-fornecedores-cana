import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/talhao_service.dart';
import '../services/variedade_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/kpi_card.dart';

class GestaoAgricolaDashboardScreen extends StatefulWidget {
  const GestaoAgricolaDashboardScreen({super.key});

  @override
  State<GestaoAgricolaDashboardScreen> createState() =>
      _GestaoAgricolaDashboardScreenState();
}

class _GestaoAgricolaDashboardScreenState
    extends State<GestaoAgricolaDashboardScreen> {
  late TalhaoService _talhaoService;
  late VariedadeService _variedadeService;

  List<Talhao> _talhoes = [];
  List<Variedade> _variedades = [];

  bool _loadingTalhoes = true;
  bool _loadingVariedades = true;

  @override
  void initState() {
    super.initState();
    _talhaoService = TalhaoService();
    _variedadeService = VariedadeService();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadTalhoes(),
      _loadVariedades(),
    ]);
  }

  Future<void> _loadTalhoes() async {
    try {
      final talhoes = await _talhaoService.getTalhoesPorPropriedade('dummy');
      if (mounted) {
        setState(() {
          _talhoes = talhoes.where((t) => t.areaHa != null && t.areaHa! > 0).toList();
          _loadingTalhoes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _talhoes = [];
          _loadingTalhoes = false;
        });
      }
    }
  }

  Future<void> _loadVariedades() async {
    try {
      final variedades = await _variedadeService.getAllVariedades();
      if (mounted) {
        setState(() {
          _variedades = variedades;
          _loadingVariedades = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _variedades = [];
          _loadingVariedades = false;
        });
      }
    }
  }

  double _getTotalArea() {
    if (_talhoes.isEmpty) return 0;
    return _talhoes.fold<double>(0, (sum, t) => sum + (t.areaHa ?? 0));
  }

  int _getTotalTalhoes() => _talhoes.length;

  String _getVariedadeMaisCultivada() {
    if (_variedades.isEmpty) return 'N/A';
    return _variedades.first.nome;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: 0,
      title: 'Gestão Agrícola',
      onNavigationSelect: (_) {},
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Dashboard de Gestão Agrícola',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.newTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Visão geral da propriedade e monitoramento técnico',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.newTextSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Grid de KPI Cards
            _buildKPIGrid(),
            const SizedBox(height: 32),

            // Grid duas colunas: Talhões + Variedades
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildTalhoesCard(),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: _buildVariedadesCard(),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildTalhoesCard(),
                      const SizedBox(height: 24),
                      _buildVariedadesCard(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIGrid() {
    return Column(
      children: [
        KpiCard(
          label: 'Talhões Ativos',
          value: '${_getTotalTalhoes()}',
          icon: Icons.grid_view_outlined,
          iconColor: AppColors.newPrimary,
        ),
        const SizedBox(height: 8),
        KpiCard(
          label: 'Área Total',
          value: '${_getTotalArea().toStringAsFixed(1)} ha',
          icon: Icons.agriculture_outlined,
          iconColor: AppColors.newSuccess,
        ),
        const SizedBox(height: 8),
        const KpiCard(
          label: 'Produtividade',
          value: 'N/A',
          icon: Icons.trending_up_outlined,
          iconColor: AppColors.newInfo,
        ),
        const SizedBox(height: 8),
        KpiCard(
          label: 'Variedade',
          value: _getVariedadeMaisCultivada(),
          icon: Icons.eco_outlined,
          iconColor: AppColors.newWarning,
        ),
      ],
    );
  }

  Widget _buildTalhoesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(color: AppColors.borderDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.grid_view,
                  color: AppColors.newPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Talhões',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.newTextPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo
          if (_loadingTalhoes)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_talhoes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Nenhum talhão cadastrado',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.newTextMuted,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _talhoes.length,
                separatorBuilder: (_, __) => const Divider(
                  color: AppColors.borderDark,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final talhao = _talhoes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          talhao.nome,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.newTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${talhao.areaHa?.toStringAsFixed(1) ?? "N/A"} ha',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.newTextSecondary,
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
    );
  }

  Widget _buildVariedadesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(color: AppColors.borderDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.eco,
                  color: AppColors.newWarning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Variedades',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.newTextPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo
          if (_loadingVariedades)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_variedades.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Nenhuma variedade cadastrada',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.newTextMuted,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _variedades.length,
                separatorBuilder: (_, __) => const Divider(
                  color: AppColors.borderDark,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final variedade = _variedades[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variedade.nome,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.newTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          variedade.destaque,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.newTextSecondary,
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
    );
  }
}
