import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/talhao_service.dart';
import '../services/variedade_service.dart';
import '../services/proprietario_service.dart';
import '../services/propriedade_service.dart';
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
  final _talhaoService = TalhaoService();
  final _variedadeService = VariedadeService();
  final _proprietarioService = ProprietarioService();
  final _propriedadeService = PropriedadeService();

  List<Talhao> _talhoes = [];
  List<Variedade> _variedades = [];
  List<Proprietario> _proprietarios = [];
  List<Propriedade> _propriedades = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _talhaoService.getAllTalhoes(),
        _variedadeService.getVariedadesAtivas(),
        _proprietarioService.getProprietarios(),
        _propriedadeService.getPropriedades(),
      ]);
      if (mounted) {
        setState(() {
          _talhoes = results[0] as List<Talhao>;
          _variedades = results[1] as List<Variedade>;
          _proprietarios = results[2] as List<Proprietario>;
          _propriedades = results[3] as List<Propriedade>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  double _getTotalArea() {
    return _talhoes.fold<double>(0, (sum, t) => sum + (t.areaHa ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: 0,
      title: 'Gestão Agrícola',
      onNavigationSelect: (_) {},
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    'Visão geral consolidada — dados reais do sistema',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.newTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildKPIGrid(),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTalhoesCard()),
                            const SizedBox(width: 24),
                            Expanded(child: _buildVariedadesCard()),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _buildTalhoesCard(),
                          const SizedBox(height: 24),
                          _buildVariedadesCard(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKPIGrid() {
    final totalArea = _getTotalArea();

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: 220,
          child: KpiCard(
            label: 'Proprietários',
            value: '${_proprietarios.length}',
            icon: Icons.people_outlined,
            iconColor: AppColors.newPrimary,
          ),
        ),
        SizedBox(
          width: 220,
          child: KpiCard(
            label: 'Propriedades',
            value: '${_propriedades.length}',
            icon: Icons.home_work_outlined,
            iconColor: AppColors.newInfo,
          ),
        ),
        SizedBox(
          width: 220,
          child: KpiCard(
            label: 'Talhões',
            value: '${_talhoes.length}',
            icon: Icons.grid_view_outlined,
            iconColor: AppColors.newSuccess,
          ),
        ),
        SizedBox(
          width: 220,
          child: KpiCard(
            label: 'Área Total',
            value: totalArea > 0
                ? '${totalArea.toStringAsFixed(1)} ha'
                : 'Nenhum dado',
            icon: Icons.agriculture_outlined,
            iconColor: AppColors.newWarning,
          ),
        ),
        SizedBox(
          width: 220,
          child: KpiCard(
            label: 'Variedades',
            value: '${_variedades.length}',
            icon: Icons.eco_outlined,
            iconColor: Colors.teal,
          ),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.grid_view, color: AppColors.newPrimary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Talhões (${_talhoes.length})',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.newTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (_talhoes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Nenhum talhão cadastrado',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.newTextMuted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _talhoes.length > 10 ? 10 : _talhoes.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppColors.borderDark, height: 1),
              itemBuilder: (context, index) {
                final talhao = _talhoes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        talhao.nome,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.newTextPrimary,
                        ),
                      ),
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
          if (_talhoes.length > 10)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                '+ ${_talhoes.length - 10} talhões não exibidos',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.newTextMuted),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.eco, color: AppColors.newWarning, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Variedades (${_variedades.length})',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.newTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (_variedades.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Nenhuma variedade cadastrada',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.newTextMuted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _variedades.length > 10 ? 10 : _variedades.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppColors.borderDark, height: 1),
              itemBuilder: (context, index) {
                final variedade = _variedades[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          variedade.nome,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.newTextPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          variedade.destaque,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.newTextSecondary,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (_variedades.length > 10)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                '+ ${_variedades.length - 10} variedades não exibidas',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.newTextMuted),
              ),
            ),
        ],
      ),
    );
  }
}
