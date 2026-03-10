import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/app_bar_afcrc.dart';
import '../models/models.dart';
import '../services/talhao_service.dart';
import '../services/variedade_service.dart';
import '../services/anexo_service.dart';

class GestaoAgricolaDashboardScreen extends StatefulWidget {
  const GestaoAgricolaDashboardScreen({super.key});

  @override
  State<GestaoAgricolaDashboardScreen> createState() => _GestaoAgricolaDashboardScreenState();
}

class _GestaoAgricolaDashboardScreenState extends State<GestaoAgricolaDashboardScreen> {
  late TalhaoService _talhaoService;
  late VariedadeService _variedadeService;
  late AnexoService _anexoService;

  List<Talhao> _talhoes = [];
  List<Variedade> _variedades = [];
  List<Anexo> _anexos = [];
  
  bool _loadingTalhoes = true;
  bool _loadingVariedades = true;
  bool _loadingAnexos = true;

  @override
  void initState() {
    super.initState();
    _talhaoService = TalhaoService();
    _variedadeService = VariedadeService();
    _anexoService = AnexoService();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadTalhoes(),
      _loadVariedades(),
      _loadAnexos(),
    ]);
  }

  Future<void> _loadTalhoes() async {
    try {
      // Buscar todos os talhões disponíveis
      final talhoes = await _talhaoService.getTalhoesPorPropriedade('dummy');
      if (mounted) {
        setState(() {
          _talhoes = talhoes.where((t) => t.areaHa != null && t.areaHa! > 0).toList();
          _loadingTalhoes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Se houver erro, trata como "sem dados" em vez de falhar
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

  Future<void> _loadAnexos() async {
    try {
      // Buscar anexos de todas as propriedades
      final anexos = await _anexoService.getAnexosByPropriedade('dummy');
      if (mounted) {
        setState(() {
          _anexos = anexos;
          _loadingAnexos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _anexos = [];
          _loadingAnexos = false;
        });
      }
    }
  }

  double _getTotalArea() {
    if (_talhoes.isEmpty) return 0;
    return _talhoes.fold<double>(0, (sum, t) => sum + (t.areaHa ?? 0));
  }

  int _getTotalTalhoes() => _talhoes.length;

  int _getRelatoriosPragas() {
    return _anexos.where((a) => a.tipoAnexo.contains('praga')).length;
  }

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para definir se o layout fica em colunas (Desktop) ou empilhado (Mobile)
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBarAfcrc(
        actions: [
          IconButton(
            icon: const Icon(Icons.nightlight_round, color: Colors.grey),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text('JD', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs e Título
            _buildHeader(context),
            const SizedBox(height: 32),
            
            // Layout Principal (Responsivo)
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  // Desktop/Tablet Paisagem: Duas Colunas
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Coluna Esquerda (Menor)
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildTalhoesCard(),
                            const SizedBox(height: 24),
                            _buildCensoVarietalCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Coluna Direita (Maior)
                      Expanded(
                        flex: 7,
                        child: _buildAnexosArea(),
                      ),
                    ],
                  );
                } else {
                  // Mobile/Tablet Retrato: Empilhado
                  return Column(
                    children: [
                      _buildTalhoesCard(),
                      const SizedBox(height: 24),
                      _buildCensoVarietalCard(),
                      const SizedBox(height: 24),
                      _buildAnexosArea(),
                    ],
                  );
                }
              },
            ),
            
            const SizedBox(height: 48),
            // Footer
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2023 AFCRC - Catanduva/SP. Todos os direitos reservados.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Row(
                    children: [
                      TextButton(onPressed: () {}, child: Text('Documentação', style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                      TextButton(onPressed: () {}, child: Text('Suporte Técnico', style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                      TextButton(onPressed: () {}, child: Text('Status do Sistema', style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.home, size: 16, color: Colors.grey),
            SizedBox(width: 8),
            Text('Início', style: TextStyle(color: Colors.grey, fontSize: 13)),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            Text('Dashboard', style: TextStyle(color: Colors.grey, fontSize: 13)),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            Text('Gestão Agrícola', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Dashboard de Gestão Agrícola',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Visão geral da propriedade e monitoramento técnico.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTalhoesCard() {
    if (_loadingTalhoes) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
        ),
      );
    }

    if (_talhoes.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.map, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Talhões', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Icon(Icons.arrow_forward, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
                ),
                child: const Center(
                  child: Text('Nenhum talhão cadastrado', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.map, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Talhões', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dashboard, size: 32, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('VISUALIZAÇÃO DE MAPA / LISTA', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL DE ÁREA', style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${_getTotalArea().toStringAsFixed(1)} ha', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL TALHÕES', style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${_getTotalTalhoes()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCensoVarietalCard() {
    if (_loadingVariedades) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
        ),
      );
    }

    if (_variedades.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.eco, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Censo Varietal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Icon(Icons.arrow_forward, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
                ),
                child: const Center(
                  child: Text('Nenhuma variedade cadastrada', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.eco, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Censo Varietal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 32, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('DISTRIBUIÇÃO DE VARIEDADES', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ..._buildVariedadesProgressBars(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildVariedadesProgressBars() {
    final total = _variedades.length;
    if (total == 0) return [const SizedBox.shrink()];

    final colors = [AppColors.primary, Colors.grey, Colors.orange, Colors.blue, Colors.red];
    final widgets = <Widget>[];

    for (int i = 0; i < _variedades.length && i < 5; i++) {
      final variedade = _variedades[i];
      final percentage = ((1 / total) * 100).toStringAsFixed(0);
      final progress = 1 / total;

      if (i > 0) widgets.add(const SizedBox(height: 16));

      widgets.add(_buildProgressBar(
        variedade.nome,
        progress,
        '$percentage%',
        colors[i % colors.length],
      ));
    }

    return widgets;
  }

  Widget _buildProgressBar(String label, double progress, String percentageText, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
            Text(percentageText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildAnexosArea() {
    if (_loadingAnexos) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
        ),
      );
    }

    final pragas = _getRelatoriosPragas();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.folder, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Anexos e Documentação Técnica', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.filter_list, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 24),
            if (pragas > 0)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.bug_report, color: Colors.red),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Relatórios de Pragas', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('$pragas documento${pragas != 1 ? 's' : ''} arquivado${pragas != 1 ? 's' : ''}', 
                                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.bug_report, color: Colors.grey[400]),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Relatórios de Pragas', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Nenhum documento arquivado', 
                              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
