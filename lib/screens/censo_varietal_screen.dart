import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../constants/app_colors.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../models/models.dart';
import '../services/talhao_service.dart';
import '../services/variedade_service.dart';
import '../services/pdf_generators/pdf_censo_varietal.dart';

/// Dados agregados de uma variedade no censo
class _ResumoVariedade {
  final String variedadeId;
  final String nomeVariedade;
  final String destaque;
  final double areaHa;
  final int anoPlantioMaisAntigo;
  final int qtdTalhoes;
  final double percentual;
  final int idade;

  const _ResumoVariedade({
    required this.variedadeId,
    required this.nomeVariedade,
    required this.destaque,
    required this.areaHa,
    required this.anoPlantioMaisAntigo,
    required this.qtdTalhoes,
    required this.percentual,
    required this.idade,
  });
}

class CensoVarietalScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const CensoVarietalScreen({
    super.key,
    required this.contexto,
  });

  @override
  State<CensoVarietalScreen> createState() => _CensoVarietalScreenState();
}

class _CensoVarietalScreenState extends State<CensoVarietalScreen> {
  final TalhaoService _talhaoService = TalhaoService();
  final VariedadeService _variedadeService = VariedadeService();
  int _selectedNavigationIndex = 0;

  bool _carregando = true;
  List<Talhao> _talhoes = [];
  Map<String, Variedade> _variedadeMap = {};
  List<_ResumoVariedade> _resumos = [];

  // Totais
  double _areaPlantadaTotal = 0;
  double _areaTotalPropriedade = 0;
  double _ocupacaoPercent = 0;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      final resultados = await Future.wait([
        _talhaoService.getTalhoesPorPropriedade(widget.contexto.propriedade.id),
        _variedadeService.getVariedadeMap(),
      ]);

      final talhoes = resultados[0] as List<Talhao>;
      final variedadeMap = resultados[1] as Map<String, Variedade>;

      _talhoes = talhoes;
      _variedadeMap = variedadeMap;
      _areaTotalPropriedade = widget.contexto.propriedade.areaHa ?? 0;

      _calcularResumos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _calcularResumos() {
    final anoAtual = DateTime.now().year;
    final agrupado = <String, List<Talhao>>{};

    // Agrupar talhões por variedade (ignorar sem variedade)
    for (final t in _talhoes) {
      if (t.variedade != null && t.variedade!.isNotEmpty) {
        agrupado.putIfAbsent(t.variedade!, () => []).add(t);
      }
    }

    _areaPlantadaTotal = 0;
    final resumos = <_ResumoVariedade>[];

    for (final entry in agrupado.entries) {
      final variedadeId = entry.key;
      final talhoesVar = entry.value;

      final area = talhoesVar.fold<double>(0, (s, t) => s + (t.areaHa ?? 0));
      _areaPlantadaTotal += area;

      final anosPlantio = talhoesVar
          .where((t) => t.anoPlantio != null)
          .map((t) => t.anoPlantio!)
          .toList();
      final anoMaisAntigo = anosPlantio.isNotEmpty
          ? anosPlantio.reduce((a, b) => a < b ? a : b)
          : anoAtual;

      // Resolver nome da variedade
      final variedade = _variedadeMap[variedadeId];
      final nomeVariedade = variedade?.codigo ?? variedadeId;
      final destaque = variedade?.destaque ?? '';

      resumos.add(_ResumoVariedade(
        variedadeId: variedadeId,
        nomeVariedade: nomeVariedade,
        destaque: destaque,
        areaHa: area,
        anoPlantioMaisAntigo: anoMaisAntigo,
        qtdTalhoes: talhoesVar.length,
        percentual: _areaTotalPropriedade > 0
            ? (area / _areaTotalPropriedade) * 100
            : 0,
        idade: anoAtual - anoMaisAntigo,
      ));
    }

    // Ordenar por área decrescente
    resumos.sort((a, b) => b.areaHa.compareTo(a.areaHa));

    _resumos = resumos;
    _ocupacaoPercent = _areaTotalPropriedade > 0
        ? (_areaPlantadaTotal / _areaTotalPropriedade) * 100
        : 0;
  }

  Future<void> _gerarPdf() async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) => PdfCensoVarietal.gerar(
          contexto: widget.contexto,
          talhoes: _talhoes,
          variedadeMap: _variedadeMap,
        ),
        name: 'Censo_Varietal_${widget.contexto.nomePropriedade}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: 'Censo Varietal',
      child: Stack(
        children: [
          _buildConteudo(),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: _resumos.isEmpty ? null : _gerarPdf,
              backgroundColor: const Color(0xFFFFA726),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text(
                'Exportar PDF',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    return Scaffold(
      body: Column(
        children: [
          HeaderPropriedade(contexto: widget.contexto),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _resumos.isEmpty
                    ? _buildEstadoVazio()
                    : _buildListaCenso(),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grass, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma variedade cadastrada nos talhões',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Cadastre variedades nos talhões para gerar o censo varietal',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildListaCenso() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards de resumo executivo
          _buildCardsResumo(),
          const SizedBox(height: 24),

          // Tabela de variedades
          const Text(
            'Distribuição por Variedade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTabela(),
          const SizedBox(height: 80), // Espaço para o FAB
        ],
      ),
    );
  }

  Widget _buildCardsResumo() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildCardKpi(
          icon: Icons.grass,
          label: 'Total de Variedades',
          valor: '${_resumos.length}',
          cor: AppColors.primary,
        ),
        _buildCardKpi(
          icon: Icons.square_foot,
          label: 'Área Plantada',
          valor: '${_areaPlantadaTotal.toStringAsFixed(1)} ha',
          cor: Colors.blue,
        ),
        _buildCardKpi(
          icon: Icons.pie_chart,
          label: 'Ocupação',
          valor: '${_ocupacaoPercent.toStringAsFixed(1)}%',
          cor: Colors.orange,
        ),
        _buildCardKpi(
          icon: Icons.agriculture,
          label: 'Talhões com Variedade',
          valor: '${_talhoes.where((t) => t.variedade != null && t.variedade!.isNotEmpty).length}',
          cor: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildCardKpi({
    required IconData icon,
    required String label,
    required String valor,
    required Color cor,
  }) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cor.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: cor, size: 28),
              const SizedBox(height: 8),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabela() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppColors.primary.withOpacity(0.1),
          ),
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('Variedade', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Destaque', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Ano Plantio', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Área (ha)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('% Propriedade', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Idade (anos)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Talhões', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          ],
          rows: [
            ..._resumos.map((r) => DataRow(
                  cells: [
                    DataCell(Text(
                      r.nomeVariedade,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )),
                    DataCell(Text(r.destaque)),
                    DataCell(Text('${r.anoPlantioMaisAntigo}')),
                    DataCell(Text(r.areaHa.toStringAsFixed(1))),
                    DataCell(Text('${r.percentual.toStringAsFixed(1)}%')),
                    DataCell(Text('${r.idade}')),
                    DataCell(Text('${r.qtdTalhoes}')),
                  ],
                )),
            // Linha de totais
            DataRow(
              color: WidgetStateProperty.all(Colors.grey[100]),
              cells: [
                const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataCell(Text('')),
                const DataCell(Text('')),
                DataCell(Text(
                  _areaPlantadaTotal.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
                DataCell(Text(
                  '${_ocupacaoPercent.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
                const DataCell(Text('')),
                DataCell(Text(
                  '${_talhoes.where((t) => t.variedade != null && t.variedade!.isNotEmpty).length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
