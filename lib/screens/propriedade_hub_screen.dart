import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../constants/app_colors.dart';
import '../services/talhao_service.dart';
import 'talhoes_screen.dart';
import 'tratos_culturais_screen.dart';
import 'operacoes_cultivo_screen.dart';
import 'produtividade_screen.dart';
import 'precipitacao_screen.dart';
import 'custo_operacional_screen.dart';
import 'anexos_screen.dart';
import 'formularios_pdf_screen.dart';
import 'analise_solo_screen.dart';
import 'censo_varietal_screen.dart';
import 'central_relatorios_screen.dart';
import 'dashboard_analitico_screen.dart';
import 'safras_screen.dart';
import 'insumos_screen.dart';
import 'monitoramento_pragas_screen.dart';

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
  final TalhaoService _talhaoService = TalhaoService();
  double _areaTotalHa = 0;
  double _areaReformaHa = 0;
  int _qtdTalhoes = 0;
  bool _carregandoEstatisticas = true;

  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  Future<void> _carregarEstatisticas() async {
    final talhoes = await _talhaoService.getTalhoesPorPropriedade(
      widget.contexto.propriedade.id,
    );
    if (mounted) {
      setState(() {
        _qtdTalhoes = talhoes.length;
        _areaTotalHa = talhoes.fold<double>(0, (s, t) => s + (t.areaHa ?? 0));
        _areaReformaHa = talhoes
            .where((t) => t.isReforma)
            .fold<double>(0, (s, t) => s + (t.areaHa ?? 0));
        _carregandoEstatisticas = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedIndex = index);
      },
      showBackButton: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.contexto.nomePropriedade} - Hub'),
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: Column(
          children: [
            HeaderPropriedade(
              contexto: widget.contexto,
              infoExtra: _carregandoEstatisticas
                  ? []
                  : [
                      MapEntry('Área Total', '${_areaTotalHa.toStringAsFixed(1)} ha'),
                      MapEntry('Reforma', '${_areaReformaHa.toStringAsFixed(1)} ha'),
                      MapEntry('Área Líquida', '${(_areaTotalHa - _areaReformaHa).toStringAsFixed(1)} ha'),
                      MapEntry('Talhões', '$_qtdTalhoes'),
                    ],
            ),
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
                    _buildModuleItem(
                      icon: Icons.date_range,
                      title: 'Safras',
                      subtitle: 'Gerenciar safras por ciclo (ex: 2025/26)',
                      onTap: () => _navegarParaSafras(),
                    ),
                    _buildModuleItem(
                      icon: Icons.agriculture,
                      title: 'Talhões',
                      subtitle: 'Gerenciar talhões da propriedade',
                      onTap: () => _navegarParaTalhoes(),
                    ),
                    _buildModuleItem(
                      icon: Icons.inventory_2,
                      title: 'Catálogo de Insumos',
                      subtitle: 'Herbicidas, inseticidas, fertilizantes e mais',
                      onTap: () => _navegarParaInsumos(),
                    ),
                    _buildModuleItem(
                      icon: Icons.spa,
                      title: 'Tratos Culturais',
                      subtitle: 'Registros de tratos culturais',
                      onTap: () => _navegarParaTratos(),
                    ),
                    _buildModuleItem(
                      icon: Icons.build,
                      title: 'Operações de Cultivo',
                      subtitle: 'Operações realizadas nos talhões',
                      onTap: () => _navegarParaOperacoes(),
                    ),
                    _buildModuleItem(
                      icon: Icons.trending_up,
                      title: 'Produtividade',
                      subtitle: 'Dados de produtividade por safra',
                      onTap: () => _navegarParaProdutividade(),
                    ),
                    _buildModuleItem(
                      icon: Icons.cloud,
                      title: 'Precipitação',
                      subtitle: 'Registros pluviométricos',
                      onTap: () => _navegarParaPrecipitacao(),
                    ),
                    _buildModuleItem(
                      icon: Icons.money,
                      title: 'Custo Operacional',
                      subtitle: 'Análise de custos e cenários',
                      onTap: () => _navegarParaCusto(),
                    ),
                    _buildModuleItem(
                      icon: Icons.grass,
                      title: 'Censo Varietal',
                      subtitle: 'Variedades plantadas e áreas por talhão',
                      onTap: () => _navegarParaCensoVarietal(),
                    ),
                    _buildModuleItem(
                      icon: Icons.bar_chart,
                      title: 'Dashboard Analítico',
                      subtitle: 'Gráficos de produtividade, precipitação, custos e variedades',
                      onTap: () => _navegarParaDashboardAnalitico(),
                    ),
                    _buildModuleItem(
                      icon: Icons.picture_as_pdf,
                      title: 'Central de Relatórios',
                      subtitle: 'Gerar relatórios PDF de todas as categorias',
                      onTap: () => _navegarParaCentralRelatorios(),
                    ),
                    _buildModuleItem(
                      icon: Icons.attach_file,
                      title: 'Anexos',
                      subtitle: 'Documentos e arquivos anexados',
                      onTap: () => _navegarParaAnexos(),
                    ),
                    _buildModuleItem(
                      icon: Icons.science,
                      title: 'Interpretação de Análises de Solo',
                      subtitle: 'Análises de fertilidade — Boletim 100 IAC',
                      onTap: () => _navegarParaAnalisesSolo(),
                    ),
                    _buildModuleItem(
                      icon: Icons.pest_control,
                      title: 'Monitoramento de Pragas',
                      subtitle: 'Registrar e acompanhar pragas nos talhões',
                      onTap: () => _navegarParaMonitoramentoPragas(),
                    ),
                    _buildModuleItem(
                      icon: Icons.bug_report,
                      title: 'Relatórios de Pragas',
                      subtitle: 'Formulários de levantamento de pragas',
                      onTap: () => _navegarParaPragas(),
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

  Widget _buildModuleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _navegarParaSafras() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafrasScreen(
          contexto: widget.contexto,
        ),
      ),
    );
  }

  void _navegarParaTalhoes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TalhoesScreen(
          contexto: widget.contexto,
        ),
      ),
    );
    _carregarEstatisticas();
  }

  void _navegarParaInsumos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InsumosScreen(),
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

  void _navegarParaCensoVarietal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CensoVarietalScreen(
          contexto: widget.contexto,
        ),
      ),
    );
  }

  void _navegarParaDashboardAnalitico() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardAnaliticoScreen(
          contexto: widget.contexto,
        ),
      ),
    );
  }

  void _navegarParaCentralRelatorios() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CentralRelatoriosScreen(
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

  void _navegarParaAnalisesSolo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnaliseSoloScreen(
          contexto: widget.contexto,
        ),
      ),
    );
  }

  void _navegarParaMonitoramentoPragas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonitoramentoPragasScreen(
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
