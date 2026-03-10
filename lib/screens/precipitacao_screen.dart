import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:gestao_cana_app/constants/app_colors.dart';
import 'package:gestao_cana_app/widgets/app_shell.dart';
import 'package:gestao_cana_app/widgets/header_propriedade.dart';
import 'package:gestao_cana_app/models/models.dart';
import 'package:gestao_cana_app/services/precipitacao_service.dart';
import 'package:gestao_cana_app/services/pdf_generators/pdf_precipitacao.dart';

class PrecipitacaoScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const PrecipitacaoScreen({
    super.key,
    required this.contexto,
  });

  @override
  State<PrecipitacaoScreen> createState() => _PrecipitacaoScreenState();
}

class _PrecipitacaoScreenState extends State<PrecipitacaoScreen> {
  final PrecipitacaoService _precipitacaoService = PrecipitacaoService();
  List<Precipitacao> _precipitacoes = [];
  List<String> _safras = [];
  List<String> _municipios = [];
  String? _selectedSafra;
  String? _selectedMunicipio;
  bool _isLoading = true;
  int _selectedNavigationIndex = 0;

  List<double> _monthlyData = List.filled(12, 0.0);
  final List<String> _months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final precipitacoes = await _precipitacaoService.getPrecipitacoesByPropriedade(
        widget.contexto.propriedade.id,
      );

      final anosSet = <int>{};
      final municipiosSet = <String>{};
      for (final p in precipitacoes) {
        anosSet.add(p.ano);
        if (p.municipio.isNotEmpty) municipiosSet.add(p.municipio);
      }

      final anos = anosSet.toList()..sort((a, b) => b.compareTo(a));
      final municipios = municipiosSet.toList()..sort();

      final propMunicipio = widget.contexto.municipio;
      if (propMunicipio.isNotEmpty && !municipios.contains(propMunicipio)) {
        municipios.insert(0, propMunicipio);
      }

      setState(() {
        _precipitacoes = precipitacoes;
        _safras = anos.map((a) => a.toString()).toList();
        _municipios = municipios;
        _selectedSafra = _safras.isNotEmpty ? _safras.first : null;
        _selectedMunicipio = municipios.isNotEmpty
            ? (municipios.contains(propMunicipio) ? propMunicipio : municipios.first)
            : null;
        _computeMonthlyData();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados de precipitação: $e');
      setState(() => _isLoading = false);
    }
  }

  void _computeMonthlyData() {
    final data = List<double>.filled(12, 0.0);
    final anoFiltro = int.tryParse(_selectedSafra ?? '');

    for (final p in _precipitacoes) {
      if (anoFiltro != null && p.ano != anoFiltro) continue;
      if (_selectedMunicipio != null && p.municipio != _selectedMunicipio) continue;
      if (p.mes >= 1 && p.mes <= 12) {
        data[p.mes - 1] += p.milimetros;
      }
    }

    _monthlyData = data;
  }

  double _getMonthlyTotal() => _monthlyData.fold(0.0, (sum, val) => sum + val);
  double _getMonthlyAverage() {
    final nonZero = _monthlyData.where((v) => v > 0).length;
    return nonZero > 0 ? _getMonthlyTotal() / nonZero : 0;
  }
  String _getWettestMonth() {
    if (_monthlyData.every((v) => v == 0)) return '-';
    final maxIndex = _monthlyData.indexWhere((val) => val == _monthlyData.reduce((a, b) => a > b ? a : b));
    return _months[maxIndex];
  }
  String _getDriestMonth() {
    final nonZero = <int>[];
    for (int i = 0; i < _monthlyData.length; i++) {
      if (_monthlyData[i] > 0) nonZero.add(i);
    }
    if (nonZero.isEmpty) return '-';
    final minIdx = nonZero.reduce((a, b) => _monthlyData[a] < _monthlyData[b] ? a : b);
    return _months[minIdx];
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      title: 'Monitoramento Pluviométrico',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderPropriedade(contexto: widget.contexto),
            if (_precipitacoes.isEmpty) ...[
              const SizedBox(height: 48),
              const Center(
                child: Text(
                  'Nenhum dado de precipitação disponível',
                  style: TextStyle(color: AppColors.newTextSecondary, fontSize: 16),
                ),
              ),
            ] else ...[
            const SizedBox(height: 16),

            // 4 KPI Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: [
                  _buildKpiCard(
                    'Total Anual',
                    '${_getMonthlyTotal().toStringAsFixed(0)} mm',
                    AppColors.newSuccess,
                  ),
                  _buildKpiCard(
                    'Média Mensal',
                    '${_getMonthlyAverage().toStringAsFixed(0)} mm',
                    AppColors.newInfo,
                  ),
                  _buildKpiCard(
                    'Mês Chuvoso',
                    _getWettestMonth(),
                    AppColors.newWarning,
                  ),
                  _buildKpiCard(
                    'Mês Seco',
                    _getDriestMonth(),
                    AppColors.newDanger,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Dropdowns: Safra + Município
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        border: Border.all(color: AppColors.borderDark),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Selecionar Safra', style: TextStyle(color: AppColors.newTextSecondary)),
                        value: _selectedSafra,
                        items: _safras
                            .map((safra) => DropdownMenuItem(
                                  value: safra,
                                  child: Text(safra, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSafra = value;
                            _computeMonthlyData();
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: AppColors.surfaceDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        border: Border.all(color: AppColors.borderDark),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Município', style: TextStyle(color: AppColors.newTextSecondary)),
                        value: _selectedMunicipio,
                        items: _municipios
                            .map((municipio) => DropdownMenuItem(
                                  value: municipio,
                                  child: Text(municipio, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMunicipio = value;
                            _computeMonthlyData();
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: AppColors.surfaceDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BarChart - Precipitação Mensal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  border: Border.all(color: AppColors.borderDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: BarChart(
                  BarChartData(
                    barGroups: List.generate(
                      12,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: _monthlyData[index],
                            color: AppColors.newSuccess,
                            width: 14,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 50,
                      getDrawingHorizontalLine: (value) => const FlLine(
                        color: AppColors.borderDark,
                        strokeWidth: 0.5,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(color: AppColors.newTextSecondary, fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            _months[value.toInt()],
                            style: const TextStyle(color: AppColors.newTextSecondary, fontSize: 10),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DataTable - Dados por Município
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  border: Border.all(color: AppColors.borderDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 12,
                    headingRowColor: MaterialStateProperty.all(AppColors.bgDark),
                    columns: [
                      const DataColumn(
                        label: Text('Município', style: TextStyle(color: AppColors.newTextPrimary, fontWeight: FontWeight.bold)),
                      ),
                      ...List.generate(
                        12,
                        (index) => DataColumn(
                          label: Text(_months[index],
                              style: const TextStyle(color: AppColors.newTextPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ),
                      const DataColumn(
                        label: Text('Total', style: TextStyle(color: AppColors.newSuccess, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text(_selectedMunicipio ?? '-', style: const TextStyle(color: AppColors.newTextPrimary))),
                        ...List.generate(
                          12,
                          (index) => DataCell(Text(_monthlyData[index].toStringAsFixed(0),
                              style: const TextStyle(color: AppColors.newTextSecondary, fontSize: 12))),
                        ),
                        DataCell(Text(_getMonthlyTotal().toStringAsFixed(0),
                            style: const TextStyle(color: AppColors.newSuccess, fontWeight: FontWeight.bold))),
                      ]),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botão Exportar PDF
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ElevatedButton.icon(
                onPressed: () => _gerarPdfPrecipitacao(),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Exportar PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.newSuccess,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        border: Border(left: BorderSide(color: color, width: 3)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.newTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _gerarPdfPrecipitacao() async {
    try {
      final service = PrecipitacaoService();
      final precipitacoes = await service.getPrecipitacoesByPropriedade(
        widget.contexto.propriedade.id,
      );
      final ano = int.tryParse(_selectedSafra ?? '') ?? DateTime.now().year;
      
      final pdfBytes = await PdfPrecipitacao.gerar(
        propriedade: widget.contexto.propriedade,
        dadosPrecipitacao: precipitacoes,
        ano: ano,
      );
      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'Precipitacao_${widget.contexto.nomePropriedade}.pdf',
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e')),
      );
    }
  }
}
