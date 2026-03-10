import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestao_cana_app/constants/app_colors.dart';
import 'package:gestao_cana_app/widgets/app_shell.dart';
import 'package:gestao_cana_app/utils/municipios_sp.dart' as sp;

class PrecipitacaoScreen extends StatefulWidget {
  const PrecipitacaoScreen({super.key});

  @override
  State<PrecipitacaoScreen> createState() => _PrecipitacaoScreenState();
}

class _PrecipitacaoScreenState extends State<PrecipitacaoScreen> {
  List<String> _safras = [];
  String? _selectedSafra;
  String? _selectedMunicipio;
  // ignore: unused_field
  bool _isLoading = true;
  
  // Dados mock para demonstração (serão substituídos por dados reais)
  final List<double> _monthlyData = [120, 95, 110, 140, 160, 185, 180, 175, 160, 145, 132, 115];
  final List<String> _months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // TODO: Carregar dados reais via services
      // final safras = await _agregadaService.getSafras().first;
      // final dados = await _precipitacaoService.getPrecipitacao().first;
      
      setState(() {
        _safras = ['2024', '2023', '2022'];
        _selectedSafra = _safras.isNotEmpty ? _safras.first : null;
        _selectedMunicipio = sp.MunicipiosSP.municipiosList.isNotEmpty ? sp.MunicipiosSP.municipiosList.first : null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados de precipitação: $e');
      setState(() => _isLoading = false);
    }
  }

  double _getMonthlyTotal() => _monthlyData.fold(0, (sum, val) => sum + val);
  double _getMonthlyAverage() => _getMonthlyTotal() / 12;
  String _getWettestMonth() {
    final maxIndex = _monthlyData.indexWhere((val) => val == _monthlyData.reduce((a, b) => a > b ? a : b));
    return _months[maxIndex];
  }
  String _getDriestMonth() {
    final minIndex = _monthlyData.indexWhere((val) => val == _monthlyData.reduce((a, b) => a < b ? a : b));
    return _months[minIndex];
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      onNavigationSelect: (index) {},
      selectedIndex: 5,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
              child: Text(
                'Monitoramento Pluviométrico',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.newTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                'Catanduva/SP',
                style: TextStyle(color: AppColors.newTextSecondary, fontSize: 14),
              ),
            ),

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
                        hint: Text('Selecionar Safra', style: TextStyle(color: AppColors.newTextSecondary)),
                        value: _selectedSafra,
                        items: _safras
                            .map((safra) => DropdownMenuItem(
                                  value: safra,
                                  child: Text(safra, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedSafra = value),
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
                        hint: Text('Município', style: TextStyle(color: AppColors.newTextSecondary)),
                        value: _selectedMunicipio,
                        items: sp.MunicipiosSP.municipiosList
                            .map((municipio) => DropdownMenuItem(
                                  value: municipio,
                                  child: Text(municipio, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedMunicipio = value),
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
                      getDrawingHorizontalLine: (value) => FlLine(
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
                            style: TextStyle(color: AppColors.newTextSecondary, fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            _months[value.toInt()],
                            style: TextStyle(color: AppColors.newTextSecondary, fontSize: 10),
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
                      DataColumn(
                        label: Text('Município', style: TextStyle(color: AppColors.newTextPrimary, fontWeight: FontWeight.bold)),
                      ),
                      ...List.generate(
                        12,
                        (index) => DataColumn(
                          label: Text(_months[index],
                              style: TextStyle(color: AppColors.newTextPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ),
                      DataColumn(
                        label: Text('Total', style: TextStyle(color: AppColors.newSuccess, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text('Catanduva', style: TextStyle(color: AppColors.newTextPrimary))),
                        ...List.generate(
                          12,
                          (index) => DataCell(Text('${_monthlyData[index].toStringAsFixed(0)}',
                              style: TextStyle(color: AppColors.newTextSecondary, fontSize: 12))),
                        ),
                        DataCell(Text('${_getMonthlyTotal().toStringAsFixed(0)}',
                            style: TextStyle(color: AppColors.newSuccess, fontWeight: FontWeight.bold))),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF exportado com sucesso!')),
                  );
                },
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
            style: TextStyle(
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
}
