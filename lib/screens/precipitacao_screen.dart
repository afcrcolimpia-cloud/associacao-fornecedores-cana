import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/precipitacao_agregada_service.dart';
import '../services/pdf_generators/pdf_precipitacao.dart';
import '../widgets/app_shell.dart';

class PrecipitacaoScreen extends StatefulWidget {
  const PrecipitacaoScreen({super.key});

  @override
  State<PrecipitacaoScreen> createState() => _PrecipitacaoScreenState();
}

class _PrecipitacaoScreenState extends State<PrecipitacaoScreen> {
  final PrecipitacaoAgregadaService _service = PrecipitacaoAgregadaService();
  
  String? _municipioSelecionado;
  List<String> _municipios = [];
  Map<String, double> _dadosMenais = {};
  Map<String, dynamic> _estatisticas = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final municipios = await _service.obterMunicipios();
      setState(() {
        _municipios = municipios;
        _municipioSelecionado = municipios.isNotEmpty ? municipios.first : null;
      });

      if (_municipioSelecionado != null) {
        await _carregarDadosMunicipio(_municipioSelecionado!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar municípios: $e')),
        );
      }
    }
  }

  Future<void> _carregarDadosMunicipio(String municipio) async {
    try {
      setState(() => _carregando = true);

      final dados = await _service.totalPorMes(municipio: municipio);
      final stats = await _service.estatisticasPorMunicipio(municipio);

      setState(() {
        _dadosMenais = dados;
        _estatisticas = stats;
        _carregando = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
      setState(() => _carregando = false);
    }
  }

  Future<void> _exportarPDF() async {
    try {
      if (_municipioSelecionado == null) return;

      final todos = await _service.getTodas();
      final filtrados = todos.where((p) => p.municipio == _municipioSelecionado).toList();

      // Criar propriedade dummy para cabeçalho
      final propriedadeDummy = Propriedade(
        id: 'pdf',
        proprietarioId: 'pdf',
        nomePropriedade: 'Precipitação — $_municipioSelecionado',
        numeroFA: '',
        areaHa: 0,
        cidade: _municipioSelecionado ?? '',
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      final pdfBytes = await PdfPrecipitacao.gerar(
        propriedade: propriedadeDummy,
        dadosPrecipitacao: filtrados,
        ano: DateTime.now().year,
      );

      if (mounted) {
        Printing.layoutPdf(
          name: 'precipitacao_$_municipioSelecionado',
          format: PdfPageFormat.a4,
          onLayout: (_) => pdfBytes,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e')),
        );
      }
    }
  }

  String _obterMesMaisChuvoso() {
    if (_dadosMenais.isEmpty) return 'N/A';
    final maior = _dadosMenais.entries.reduce((a, b) => a.value > b.value ? a : b);
    return '${_formatarMes(maior.key)} (${maior.value.toStringAsFixed(1)} mm)';
  }

  String _obterMesMaisSeco() {
    if (_dadosMenais.isEmpty) return 'N/A';
    final menor = _dadosMenais.entries.reduce((a, b) => a.value < b.value ? a : b);
    return '${_formatarMes(menor.key)} (${menor.value.toStringAsFixed(1)} mm)';
  }

  String _formatarMes(String mesAno) {
    final partes = mesAno.split('-');
    if (partes.length != 2) return mesAno;
    final mes = int.tryParse(partes[1]) ?? 0;
    final nomesMeses = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${nomesMeses[mes - 1]} ${partes[0]}';
  }

  List<BarChartGroupData> _gerarDadosBarChart() {
    final meses = _dadosMenais.keys.toList()..sort();

    return meses.asMap().entries.map((e) {
      final index = e.key;
      final mes = e.value;
      final valor = _dadosMenais[mes] ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: valor,
            color: AppColors.newPrimary,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
        showingTooltipIndicators: [],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: 3,
      onNavigationSelect: (_) {},
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: AppColors.newPrimary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitoramento Pluviométrico',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Catanduva/SP',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Filtro de município
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecione o Município',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _municipioSelecionado,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.borderDark),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.borderDark),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    items: _municipios.map((m) {
                      return DropdownMenuItem(value: m, child: Text(m));
                    }).toList(),
                    onChanged: (novoMunicipio) {
                      if (novoMunicipio != null) {
                        setState(() => _municipioSelecionado = novoMunicipio);
                        _carregarDadosMunicipio(novoMunicipio);
                      }
                    },
                  ),
                ],
              ),
            ),

            if (_carregando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            'Total Anual',
                            '${(_estatisticas['totalVolume'] ?? 0.0).toStringAsFixed(1)} mm',
                            Icons.water_drop,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildKpiCard(
                            'Média Mensal',
                            '${(_estatisticas['mediaVolume'] ?? 0.0).toStringAsFixed(1)} mm',
                            Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            'Mês Mais Chuvoso',
                            _obterMesMaisChuvoso(),
                            Icons.cloud_queue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildKpiCard(
                            'Mês Mais Seco',
                            _obterMesMaisSeco(),
                            Icons.sunny,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Gráfico mensal
                    Text(
                      'Precipitação Mensal',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: _dadosMenais.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Text('Sem dados para exibir gráfico'),
                              ),
                            )
                          : SizedBox(
                              height: 300,
                              child: BarChart(
                                BarChartData(
                                  barGroups: _gerarDadosBarChart(),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          final meses = _dadosMenais.keys.toList()..sort();
                                          if (index >= 0 && index < meses.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                _formatarMes(meses[index]).substring(0, 3),
                                                style: GoogleFonts.inter(fontSize: 10),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            '${value.toInt()}',
                                            style: GoogleFonts.inter(fontSize: 10),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  gridData: const FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 100,
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                        final meses = _dadosMenais.keys.toList()..sort();
                                        if (groupIndex >= 0 && groupIndex < meses.length) {
                                          return BarTooltipItem(
                                            '${_formatarMes(meses[groupIndex])}\n${rod.toY.toStringAsFixed(1)} mm',
                                            const TextStyle(color: Colors.white),
                                          );
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 32),

                    // Botão Exportar PDF
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _exportarPDF,
                        icon: const Icon(Icons.download),
                        label: const Text('Exportar PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.newWarning,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String titulo, String valor, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: AppColors.newPrimary, size: 28),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
