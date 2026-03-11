import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../widgets/chart_card.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/chart_styles.dart';
import '../models/models.dart';
import '../services/produtividade_service.dart';
import '../services/variedade_service.dart';
import '../services/pdf_generators/pdf_produtividade.dart';
import 'produtividade_form_screen.dart';

class ProdutividadeScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const ProdutividadeScreen({
    super.key,
    required this.contexto,
  });

  @override
  State<ProdutividadeScreen> createState() => _ProdutividadeScreenState();
}

class _ProdutividadeScreenState extends State<ProdutividadeScreen> {
  final ProdutividadeService _service = ProdutividadeService();
  final VariedadeService _variedadeService = VariedadeService();
  int _selectedNavigationIndex = 0;
  
  String? _anoSafraSelecionado;
  String? _anoComparacao;
  
  bool _modoComparacao = false;
  List<Produtividade> _produtividadesAtuais = [];
  Map<String, Variedade> _variedadeMap = {};

  @override
  void initState() {
    super.initState();
    _anoSafraSelecionado = DateTime.now().year.toString();
    _carregarVariedades();
  }

  Future<void> _carregarVariedades() async {
    final mapa = await _variedadeService.getVariedadeMap();
    if (mounted) setState(() => _variedadeMap = mapa);
  }

  String _nomeVariedade(String? id) =>
      _variedadeService.resolverNomeSync(id, _variedadeMap);
  
  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: 'Produtividade',
      child: Stack(
        children: [
          Column(
            children: [
              HeaderPropriedade(contexto: widget.contexto),
              _buildFiltros(),
              Expanded(
                child: _buildConteudo(),
              ),
            ],
          ),
          Positioned(
            bottom: 88,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: _produtividadesAtuais.isEmpty ? null : () => _gerarPdf(),
              backgroundColor: const Color(0xFFFFA726),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text(
                'Gerar PDF',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: () => _mostrarFormulario(),
              backgroundColor: const Color(0xFF0DF28F),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text(
                'Nova Produtividade',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _anoSafraSelecionado,
              decoration: const InputDecoration(
                labelText: 'Ano Safra',
                border: OutlineInputBorder(),
              ),
              items: List.generate(5, (index) {
                final ano = (DateTime.now().year - index).toString();
                return DropdownMenuItem(value: ano, child: Text(ano));
              }),
              onChanged: (value) {
                setState(() => _anoSafraSelecionado = value);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Modo Comparação'),
              subtitle: const Text('Compare com ano anterior'),
              value: _modoComparacao,
              onChanged: (value) {
                setState(() => _modoComparacao = value);
              },
            ),
            if (_modoComparacao) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _anoComparacao,
                decoration: const InputDecoration(
                  labelText: 'Comparar com',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(5, (index) {
                  final ano = (DateTime.now().year - index - 1).toString();
                  return DropdownMenuItem(value: ano, child: Text(ano));
                }),
                onChanged: (value) {
                  setState(() => _anoComparacao = value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo() {
    if (_anoSafraSelecionado == null) {
      return const Center(
        child: Text('Selecione o ano safra'),
      );
    }

    return StreamBuilder<List<Produtividade>>(
      stream: _service.getProdutividadePorPropriedadeEAno(
        widget.contexto.propriedade.id,
        _anoSafraSelecionado!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        final produtividades = snapshot.data ?? [];
        _produtividadesAtuais = produtividades;

        if (produtividades.isEmpty) {
          return const Center(
            child: Text('Nenhum registro encontrado'),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildResumo(produtividades),
              const SizedBox(height: 16),
              if (_modoComparacao && _anoComparacao != null)
                _buildComparacao(),
              const SizedBox(height: 16),
              _buildGrafico(produtividades),
              const SizedBox(height: 16),
              _buildTabela(produtividades),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResumo(List<Produtividade> produtividades) {
    final totalPeso = produtividades.fold<double>(
      0,
      (sum, p) => sum + (p.pesoLiquidoToneladas ?? 0),
    );
    
    final mediaATR = produtividades.isEmpty
        ? 0.0
        : produtividades.fold<double>(
            0,
            (sum, p) => sum + (p.mediaATR ?? 0),
          ) / produtividades.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResumoItem(
                  'Total',
                  '${totalPeso.toStringAsFixed(2)} T',
                  Icons.agriculture,
                ),
                _buildResumoItem(
                  'Média ATR',
                  mediaATR.toStringAsFixed(2),
                  Icons.analytics,
                ),
                _buildResumoItem(
                  'Talhões',
                  produtividades.length.toString(),
                  Icons.grass,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoItem(String label, String valor, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.green),
        const SizedBox(height: 8),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildComparacao() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _service.compararAnos(
        widget.contexto.propriedade.id,
        _anoSafraSelecionado!,
        _anoComparacao!,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final dados = snapshot.data!;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comparação com Ano Anterior',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildComparacaoRow(
                  'Peso Total',
                  dados['totalPesoAtual'] ?? 0,
                  dados['totalPesoAnterior'] ?? 0,
                  dados['variacaoPeso'] ?? 0,
                  'T',
                ),
                _buildComparacaoRow(
                  'Média ATR',
                  dados['mediaATRAtual'] ?? 0,
                  dados['mediaATRAnterior'] ?? 0,
                  dados['variacaoATR'] ?? 0,
                  '',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComparacaoRow(
    String label,
    double valorAtual,
    double valorAnterior,
    double variacao,
    String unidade,
  ) {
    final color = variacao > 0 ? Colors.green : Colors.red;
    final icon = variacao > 0 ? Icons.arrow_upward : Icons.arrow_downward;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${valorAtual.toStringAsFixed(2)} $unidade',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Anterior: ${valorAnterior.toStringAsFixed(2)} $unidade',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  '${variacao.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrafico(List<Produtividade> produtividades) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _service.getDadosGraficoPorMes(
        widget.contexto.propriedade.id,
        _anoSafraSelecionado!,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final dados = snapshot.data!;
        final maxY = dados
                .map((e) => e['peso'] as double)
                .reduce((a, b) => a > b ? a : b) *
            1.2;

        return ChartCard(
          titulo: 'Produção por Mês',
          subtitulo: 'Safra $_anoSafraSelecionado',
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: ChartStyles.barTooltip(
                  getLabel: (i) =>
                      '${(dados[i]['peso'] as double).toStringAsFixed(1)} t',
                ),
              ),
              barGroups: dados.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    ChartStyles.barRod(
                      toY: entry.value['peso'] as double,
                      color: ChartStyles.barPrimary,
                    ),
                  ],
                );
              }).toList(),
              titlesData: ChartStyles.titlesData(
                left: ChartStyles.leftAxis(
                  getTitlesWidget: (value, meta) =>
                      ChartStyles.axisLabel('${value.toInt()}'),
                ),
                bottom: ChartStyles.bottomAxis(
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= dados.length) {
                      return const SizedBox.shrink();
                    }
                    return ChartStyles.axisLabel(
                        dados[value.toInt()]['mes'] as String);
                  },
                ),
              ),
              borderData: ChartStyles.borderNenhum,
              gridData: ChartStyles.gridPadrao,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabela(List<Produtividade> produtividades) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Talhão')),
            DataColumn(label: Text('Variedade')),
            DataColumn(label: Text('Estágio')),
            DataColumn(label: Text('Mês')),
            DataColumn(label: Text('Peso (T)')),
            DataColumn(label: Text('ATR')),
            DataColumn(label: Text('Ações')),
          ],
          rows: produtividades.map((prod) {
            return DataRow(
              cells: [
                DataCell(Text(prod.talhaoId ?? '-')),
                DataCell(Text(prod.variedade != null ? _nomeVariedade(prod.variedade) : '-')),
                DataCell(Text(prod.estagio ?? '-')),
                DataCell(Text(_getMesNome(prod.mesColheita))),
                DataCell(Text(
                  prod.pesoLiquidoToneladas?.toStringAsFixed(2) ?? '-',
                )),
                DataCell(Text(prod.mediaATR?.toStringAsFixed(2) ?? '-')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _mostrarFormulario(produtividade: prod),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => _confirmarExclusao(prod.id),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getMesNome(int? mes) {
    if (mes == null) return '-';
    const meses = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return meses[mes - 1];
  }

  Future<void> _mostrarFormulario({Produtividade? produtividade}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProdutividadeFormScreen(
          propriedade: widget.contexto.propriedade,
          produtividade: produtividade,
        ),
      ),
    );

    if (resultado == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmarExclusao(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _service.deleteProdutividade(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro excluído com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  Future<void> _gerarPdf() async {
    try {
      final pdfBytes = await PdfProdutividade.gerar(
        propriedade: widget.contexto.propriedade,
        dadosProdutividade: _produtividadesAtuais,
        anoSafra: _anoSafraSelecionado ?? DateTime.now().year.toString(),
      );
      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'Produtividade_${widget.contexto.nomePropriedade}.pdf',
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
