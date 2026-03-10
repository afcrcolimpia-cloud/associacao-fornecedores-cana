import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../constants/app_colors.dart';
import 'talhoes_screen.dart';
import 'tratos_culturais_screen.dart';
import 'operacoes_cultivo_screen.dart';
import 'produtividade_screen.dart';
import 'precipitacao_screen.dart';
import 'custo_operacional_screen.dart';
import 'anexos_screen.dart';
import 'formularios_pdf_screen.dart';

/// Tela central (Hub) de uma propriedade
/// Agrupa todos os módulos operacionais e dados da propriedade
class PropriedadeHubScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const PropriedadeHubScreen({
    super.key,
    required this.contexto,
  });

  @override
  State<PropriedadeHubScreen> createState() => _PropriedadeHubScreenState();
}

class _PropriedadeHubScreenState extends State<PropriedadeHubScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedIndex = index);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.contexto.nomePropriedade} - Hub'),
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: Column(
          children: [
            HeaderPropriedade(contexto: widget.contexto),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Módulos da Propriedade',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _buildModuleCard(
                          icon: Icons.agriculture,
                          title: 'Talhões',
                          onTap: () => _navegarParaTalhoes(),
                        ),
                        _buildModuleCard(
                          icon: Icons.spa,
                          title: 'Tratos Culturais',
                          onTap: () => _navegarParaTratos(),
                        ),
                        _buildModuleCard(
                          icon: Icons.build,
                          title: 'Operações de Cultivo',
                          onTap: () => _navegarParaOperacoes(),
                        ),
                        _buildModuleCard(
                          icon: Icons.trending_up,
                          title: 'Produtividade',
                          onTap: () => _navegarParaProdutividade(),
                        ),
                        _buildModuleCard(
                          icon: Icons.cloud,
                          title: 'Precipitação',
                          onTap: () => _navegarParaPrecipitacao(),
                        ),
                        _buildModuleCard(
                          icon: Icons.money,
                          title: 'Custo Operacional',
                          onTap: () => _navegarParaCusto(),
                        ),
                        _buildModuleCard(
                          icon: Icons.attach_file,
                          title: 'Anexos',
                          onTap: () => _navegarParaAnexos(),
                        ),
                        _buildModuleCard(
                          icon: Icons.bug_report,
                          title: 'Relatórios de Pragas',
                          onTap: () => _navegarParaPragas(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navegarParaTalhoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TalhoesScreen(
          contexto: widget.contexto,
        ),
      ),
    );
  }

  void _navegarParaTratos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TratosCulturaisScreen(
          contexto: widget.contexto,
        ),
      ),
    );
  }

  void _navegarParaOperacoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OperacoesCultivoScreen(
          contexto: widget.contexto,
        ),
      ),
    );
  }

  void _navegarParaProdutividade() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProdutividadeScreen(
          contexto: widget.contexto,
        ),
      ),
    );
  }

  void _navegarParaPrecipitacao() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrecipitacaoScreen(
          contexto: widget.contexto,
        ),
      ),
    );
  }

  void _navegarParaCusto() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustoOperacionalScreen(
          contexto: widget.contexto,
        ),
      ),
    );
  }

  void _navegarParaAnexos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnexosScreen(
          contexto: widget.contexto,
        ),
      ),
    );
  }

  void _navegarParaPragas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormulariosPdfScreen(
          contexto: widget.contexto,
        ),
      ),
    );
  }
}
