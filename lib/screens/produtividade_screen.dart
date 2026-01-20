import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../services/produtividade_service.dart';
import '../services/proprietario_service.dart';
import '../services/propriedade_service.dart';

class ProdutividadeScreen extends StatefulWidget {
  const ProdutividadeScreen({super.key});

  @override
  State<ProdutividadeScreen> createState() => _ProdutividadeScreenState();
}

class _ProdutividadeScreenState extends State<ProdutividadeScreen> {
  final ProdutividadeService _service = ProdutividadeService();
  final ProprietarioService _proprietarioService = ProprietarioService();
  final PropriedadeService _propriedadeService = PropriedadeService();
  
  String? _proprietarioSelecionado;
  String? _propriedadeSelecionada;
  String? _anoSafraSelecionado;
  String? _anoComparacao;
  
  List<Proprietario> _proprietarios = [];
  List<Propriedade> _propriedades = [];
  List<String> _anosSafra = [];
  
  bool _modoComparacao = false;
  
  @override
  void initState() {
    super.initState();
    _carregarProprietarios();
    _carregarAnosSafra();
  }
  
  Future<void> _carregarProprietarios() async {
    try {
      final proprietarios = await _proprietarioService.getProprietarios();
      setState(() => _proprietarios = proprietarios);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar proprietários: $e')),
        );
      }
    }
  }
  
  Future<void> _carregarPropriedades(String proprietarioId) async {
    try {
      _propriedadeService
          .getPropriedadesByProprietarioStream(proprietarioId)
          .listen((propriedades) {
        setState(() => _propriedades = propriedades);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar propriedades: $e')),
        );
      }
    }
  }
  
  Future<void> _carregarAnosSafra() async {
    try {
      final anos = await _service.getAnosSafra();
      setState(() => _anosSafra = anos);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar anos: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtividade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarFormulario(),
          ),
        ],
      ),
      body: Column(
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
            // Dropdown de Proprietário
            DropdownButtonFormField<String>(
              value: _proprietarioSelecionado,
              decoration: const InputDecoration(
                labelText: 'Proprietário',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: _proprietarios.map((prop) {
                return DropdownMenuItem(
                  value: prop.id,
                  child: Text(prop.nome),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _proprietarioSelecionado = value;
                  _propriedadeSelecionada = null;
                  _propriedades.clear();
                });
                if (value != null) {
                  _carregarPropriedades(value);
                }
              },
            ),
            const SizedBox(height: 12),
            
            // Dropdown de Propriedade (F.A)
            DropdownButtonFormField<String>(
              value: _propriedadeSelecionada,
              decoration: const InputDecoration(
                labelText: 'Propriedade (F.A)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home_work),
              ),
              items: _propriedades.map((prop) {
                return DropdownMenuItem(
                  value: prop.id,
                  child: Text('${prop.numeroFA} - ${prop.nomePropriedade}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _propriedadeSelecionada = value);
              },
            ),
            const SizedBox(height: 12),
            
            // Dropdown de Ano Safra
            DropdownButtonFormField<String>(
              value: _anoSafraSelecionado,
              decoration: const InputDecoration(
                labelText: 'Ano Safra',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: _anosSafra.map((ano) {
                return DropdownMenuItem(
                  value: ano,
                  child: Text(ano),
                );
              }).toList(),
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
              // Dropdown de Ano Comparação
              DropdownButtonFormField<String>(
                value: _anoComparacao,
                decoration: const InputDecoration(
                  labelText: 'Ano para Comparação',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.compare),
                ),
                items: _anosSafra
                    .where((ano) => ano != _anoSafraSelecionado)
                    .map((ano) {
                  return DropdownMenuItem(
                    value: ano,
                    child: Text(ano),
                  );
                }).toList(),
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

  Future<void> _mostrarFormulario({Produtividade? produtividade}) async {
    await showDialog(
      context: context,
      builder: (context) => ProdutividadeFormDialog(
        produtividade: produtividade,
        propriedadeId: _propriedadeSelecionada,
        anoSafra: _anoSafraSelecionado,
        onSalvo: () {
          Navigator.pop(context);
          setState(() {});
        },
      ),
    );
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
          // Forçar rebuild do StreamBuilder
          setState(() {});
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

class ProdutividadeFormDialog extends StatefulWidget {
  final Produtividade? produtividade;
  final String? propriedadeId;
  final String? anoSafra;
  final VoidCallback onSalvo;

  const ProdutividadeFormDialog({
    super.key,
    this.produtividade,
    this.propriedadeId,
    this.anoSafra,
    required this.onSalvo,
  });

  @override
  State<ProdutividadeFormDialog> createState() =>
      _ProdutividadeFormDialogState();
}

class _ProdutividadeFormDialogState extends State<ProdutividadeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final ProdutividadeService _service = ProdutividadeService();
  
  late TextEditingController _talhaoController;
  late TextEditingController _variedadeController;
  late TextEditingController _pesoController;
  late TextEditingController _atrController;
  
  int? _mesSelecionado;
  String? _estagio;

  @override
  void initState() {
    super.initState();
    _talhaoController = TextEditingController(
      text: widget.produtividade?.talhaoId ?? '',
    );
    _variedadeController = TextEditingController(
      text: widget.produtividade?.variedade ?? '',
    );
    _pesoController = TextEditingController(
      text: widget.produtividade?.pesoLiquidoToneladas?.toString() ?? '',
    );
    _atrController = TextEditingController(
      text: widget.produtividade?.mediaATR?.toString() ?? '',
    );
    _mesSelecionado = widget.produtividade?.mesColheita;
    _estagio = widget.produtividade?.estagio;
  }

  @override
  void dispose() {
    _talhaoController.dispose();
    _variedadeController.dispose();
    _pesoController.dispose();
    _atrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.produtividade == null
          ? 'Adicionar Produtividade'
          : 'Editar Produtividade'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _talhaoController,
                decoration: const InputDecoration(
                  labelText: 'Talhão',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _variedadeController,
                decoration: const InputDecoration(
                  labelText: 'Variedade',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _mesSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Mês de Colheita',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(12, (i) {
                  final meses = [
                    'Janeiro', 'Fevereiro', 'Março', 'Abril',
                    'Maio', 'Junho', 'Julho', 'Agosto',
                    'Setembro', 'Outubro', 'Novembro', 'Dezembro'
                  ];
                  return DropdownMenuItem(
                    value: i + 1,
                    child: Text(meses[i]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _mesSelecionado = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pesoController,
                decoration: const InputDecoration(
                  labelText: 'Peso (Toneladas)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _atrController,
                decoration: const InputDecoration(
                  labelText: 'Média ATR',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _estagio,
                decoration: const InputDecoration(
                  labelText: 'Estágio',
                  border: OutlineInputBorder(),
                ),
                items: ['Colheita', 'Processamento', 'Armazenamento']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _estagio = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final produtividade = Produtividade(
        id: widget.produtividade?.id ?? '',
        propriedadeId: widget.propriedadeId ?? '',
        talhaoId: _talhaoController.text,
        variedade: _variedadeController.text.isNotEmpty
            ? _variedadeController.text
            : null,
        mesColheita: _mesSelecionado,
        pesoLiquidoToneladas: _pesoController.text.isNotEmpty
            ? double.parse(_pesoController.text)
            : null,
        mediaATR: _atrController.text.isNotEmpty
            ? double.parse(_atrController.text)
            : null,
        estagio: _estagio,
        anoSafra: widget.anoSafra ?? '',
      );

      if (widget.produtividade == null) {
        await _service.addProdutividade(produtividade);
      } else {
        await _service.updateProdutividade(produtividade);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produtividade salva com sucesso!')),
        );
        widget.onSalvo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }
}