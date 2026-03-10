import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../services/produtividade_service.dart';
import '../services/pdf_generators/pdf_produtividade.dart';
import 'produtividade_form_screen.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class ProdutividadeScreen extends StatefulWidget {
  final Propriedade? propriedade;

  const ProdutividadeScreen({
    super.key,
    this.propriedade,
  });

  @override
  State<ProdutividadeScreen> createState() => _ProdutividadeScreenState();
}

class _ProdutividadeScreenState extends State<ProdutividadeScreen> {
  final ProdutividadeService _service = ProdutividadeService();
  
  String? _propriedadeSelecionada;
  String? _anoSafraSelecionado;
  String? _anoComparacao;
  
  bool _modoComparacao = false;

  @override
  void initState() {
    super.initState();
    if (widget.propriedade != null) {
      _propriedadeSelecionada = widget.propriedade!.id;
      _anoSafraSelecionado = DateTime.now().year.toString();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarAfcrc(
        title: 'Produtividade',
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: widget.propriedade != null && _anoSafraSelecionado != null
                ? _gerarPdf
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: widget.propriedade != null ? _mostrarFormulario : null,
          ),
        ],
      ),
      body: widget.propriedade == null
          ? const Center(
              child: Text('Selecione uma propriedade para visualizar produtividade'),
            )
          : Column(
              children: [
                _buildFiltros(),
                Expanded(
                  child: _buildConteudo(),
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
    if (_propriedadeSelecionada == null || _anoSafraSelecionado == null) {
      return const Center(
        child: Text('Selecione uma propriedade e ano safra'),
      );
    }

    return StreamBuilder<List<Produtividade>>(
      stream: _service.getProdutividadePorPropriedadeEAno(
        _propriedadeSelecionada!,
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
        _propriedadeSelecionada!,
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
        _propriedadeSelecionada!,
        _anoSafraSelecionado!,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
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
                  'Produção por Mês',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: dados.map((e) => e['peso'] as double).reduce(
                            (a, b) => a > b ? a : b,
                          ) * 1.2,
                      barGroups: dados.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value['peso'] as double,
                              color: Colors.green,
                              width: 20,
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= dados.length) {
                                return const Text('');
                              }
                              return Text(dados[value.toInt()]['mes']);
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: true),
                    ),
                  ),
                ),
              ],
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
                DataCell(Text(prod.variedade ?? '-')),
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

  Future<void> _gerarPdf() async {
    if (widget.propriedade == null || _anoSafraSelecionado == null) return;

    try {
      final produtividades = await _service.getProdutividadePorPropriedadeEAno(
        widget.propriedade!.id,
        _anoSafraSelecionado!,
      ).first;

      if (!mounted) return;

      final pdf = await PdfProdutividade.gerar(
        propriedade: widget.propriedade!,
        dadosProdutividade: produtividades,
        anoSafra: _anoSafraSelecionado!,
      );

      await Printing.layoutPdf(
        name: 'Relatorio_Produtividade_${widget.propriedade!.nomePropriedade}_${_anoSafraSelecionado!}.pdf',
        format: PdfPageFormat.a4,
        onLayout: (_) async => pdf,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e')),
        );
      }
    }
  }

  Future<void> _mostrarFormulario({Produtividade? produtividade}) async {
    if (widget.propriedade == null) return;

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProdutividadeFormScreen(
          propriedade: widget.propriedade!,
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
}