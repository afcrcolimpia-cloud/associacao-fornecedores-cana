import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/talhao_service.dart';
import '../services/propriedade_service.dart';
import 'talhao_form_screen.dart';

class TalhoesScreen extends StatefulWidget {
  final String propriedadeId;
  final String propriedadeNome;

  const TalhoesScreen({
    super.key,
    required this.propriedadeId,
    required this.propriedadeNome,
  });

  @override
  State<TalhoesScreen> createState() => _TalhoesScreenState();
}

class _TalhoesScreenState extends State<TalhoesScreen> {
  final TalhaoService _service = TalhaoService();
  final PropriedadeService _propriedadeService = PropriedadeService();
  Propriedade? _propriedade;
  String? _filtroTipo; // null = todos, 'producao' ou 'reforma'

  @override
  void initState() {
    super.initState();
    _carregarPropriedade();
  }

  Future<void> _carregarPropriedade() async {
    try {
      final prop = await _propriedadeService.getPropriedade(widget.propriedadeId);
      if (prop != null && mounted) {
        setState(() {
          _propriedade = prop;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar propriedade: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Talhões'),
            Text(
              widget.propriedadeNome,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _abrirFormulario(),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'lote',
                child: Row(
                  children: [
                    Icon(Icons.library_add),
                    SizedBox(width: 8),
                    Text('Criar em lote'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'estatisticas',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('Estatísticas'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'lote') {
                _criarEmLote();
              } else if (value == 'estatisticas') {
                _mostrarEstatisticas();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Talhao>>(
        stream: _service.getTalhoesStream(widget.propriedadeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          var talhoes = snapshot.data ?? [];
          
          // Aplicar filtro
          if (_filtroTipo != null) {
            talhoes = talhoes.where((t) => t.tipoTalhao == _filtroTipo).toList();
          }

          if (talhoes.isEmpty) {
            return _buildEmpty();
          }

          return Column(
            children: [
              _buildFiltroButtons(),
              _buildResumo(talhoes),
              Expanded(
                child: _buildTabela(talhoes),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltroButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: FilterChip(
              selected: _filtroTipo == null,
              label: const Text('Todos'),
              onSelected: (selected) {
                setState(() {
                  _filtroTipo = null;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilterChip(
              selected: _filtroTipo == 'producao',
              label: const Text('Produção'),
              backgroundColor: Colors.green[50],
              selectedColor: Colors.green[100],
              onSelected: (selected) {
                setState(() {
                  _filtroTipo = selected ? 'producao' : null;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilterChip(
              selected: _filtroTipo == 'reforma',
              label: const Text('Reforma'),
              backgroundColor: Colors.orange[50],
              selectedColor: Colors.orange[100],
              onSelected: (selected) {
                setState(() {
                  _filtroTipo = selected ? 'reforma' : null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grass, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum talhão cadastrado',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em + para adicionar',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildResumo(List<Talhao> talhoes) {
    final ativos = talhoes.where((t) => t.ativo).toList();
    final producao = ativos.where((t) => t.tipoTalhao == 'producao').toList();
    final reforma = ativos.where((t) => t.tipoTalhao == 'reforma').toList();

    final areaProducaoHa = producao.fold<double>(0, (sum, t) => sum + (t.areaHa ?? 0));
    final areaReformaHa = reforma.fold<double>(0, (sum, t) => sum + (t.areaHa ?? 0));
    final areaTotalHa = areaProducaoHa + areaReformaHa;

    final areaProducaoAlq = producao.fold<double>(0, (sum, t) => sum + (t.areaAlqueires ?? 0));
    final areaReformaAlq = reforma.fold<double>(0, (sum, t) => sum + (t.areaAlqueires ?? 0));
    final areaTotalAlq = areaProducaoAlq + areaReformaAlq;

    return Card(
      margin: const EdgeInsets.all(16),
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
              children: [
                Expanded(
                  child: _buildResumoCard(
                    'Total',
                    ativos.length.toString(),
                    'talhões',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildResumoCard(
                    'Produção',
                    producao.length.toString(),
                    'talhões',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildResumoCard(
                    'Reforma',
                    reforma.length.toString(),
                    'talhões',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Áreas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Hectares', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Alqueires', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                  ],
                ),
                _buildTabelaRow('Produção', areaProducaoHa, areaProducaoAlq, Colors.green[50]),
                _buildTabelaRow('Reforma', areaReformaHa, areaReformaAlq, Colors.orange[50]),
                _buildTabelaRow('Total', areaTotalHa, areaTotalAlq, Colors.blue[50], bold: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTabelaRow(String label, double ha, double alq, Color? color, {bool bold = false}) {
    return TableRow(
      decoration: BoxDecoration(color: color),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            ha.toStringAsFixed(2),
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            alq.toStringAsFixed(2),
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildResumoCard(String label, String valor, String subtitulo, Color color) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          subtitulo,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTabela(List<Talhao> talhoes) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
            columns: const [
              DataColumn(label: Text('Nº', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Área (ha)', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Área (Alqs)', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Variedade', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Ano Plantio', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: talhoes.map((talhao) {
              return DataRow(
                color: MaterialStateProperty.all(
                  talhao.ativo ? null : Colors.grey[100],
                ),
                cells: [
                  DataCell(
                    Text(
                      talhao.numeroTalhao,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: talhao.ativo ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  DataCell(Text(talhao.areaHa?.toStringAsFixed(2) ?? '-')),
                  DataCell(Text(talhao.areaAlqueires?.toStringAsFixed(2) ?? '-')),
                  DataCell(Text(talhao.variedade ?? '-')),
                  DataCell(Text(talhao.anoPlantio?.toString() ?? '-')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: talhao.tipoTalhao == 'producao' 
                            ? Colors.green[100] 
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        talhao.tipoTalhao == 'producao' ? 'Produção' : 'Reforma',
                        style: TextStyle(
                          fontSize: 12,
                          color: talhao.tipoTalhao == 'producao' 
                              ? Colors.green[900] 
                              : Colors.orange[900],
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Icon(
                      talhao.ativo ? Icons.check_circle : Icons.cancel,
                      color: talhao.ativo ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _abrirFormulario(talhao: talhao),
                        ),
                        IconButton(
                          icon: Icon(
                            talhao.ativo ? Icons.toggle_on : Icons.toggle_off,
                            size: 20,
                            color: talhao.ativo ? Colors.green : Colors.grey,
                          ),
                          onPressed: () => _toggleAtivo(talhao),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _confirmarExclusao(talhao),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _abrirFormulario({Talhao? talhao}) async {
    if (_propriedade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carregando propriedade...')),
      );
      return;
    }

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TalhaoFormScreen(
          propriedade: _propriedade!,
          talhao: talhao,
        ),
      ),
    );

    if (resultado == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleAtivo(Talhao talhao) async {
    try {
      await _service.toggleAtivo(talhao.id, !talhao.ativo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              talhao.ativo ? 'Talhão inativado' : 'Talhão ativado',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status: $e')),
        );
      }
    }
  }

  Future<void> _confirmarExclusao(Talhao talhao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir o talhão ${talhao.numeroTalhao}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _service.deleteTalhao(talhao.id);
        if (mounted) {
          // Forçar rebuild do StreamBuilder
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Talhão excluído com sucesso')),
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

  void _criarEmLote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar talhões em lote'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarEstatisticas() async {
    try {
      final stats = await _service.getEstatisticas(widget.propriedadeId);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Estatísticas'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatRow('Total de talhões', stats['totalTalhoes'].toString()),
                  _buildStatRow('Produção', stats['talhoesProducao'].toString()),
                  _buildStatRow('Reforma', stats['talhoesReforma'].toString()),
                  const Divider(),
                  _buildStatRow('Área Produção (ha)', (stats['areaProducaoHa'] as num?)?.toStringAsFixed(2) ?? '-'),
                  _buildStatRow('Área Reforma (ha)', (stats['areaReformaHa'] as num?)?.toStringAsFixed(2) ?? '-'),
                  _buildStatRow('Área Total (ha)', (stats['areaTotalHa'] as num?)?.toStringAsFixed(2) ?? '-'),
                  const Divider(),
                  _buildStatRow('Área Produção (alq)', (stats['areaProducaoAlq'] as num?)?.toStringAsFixed(2) ?? '-'),
                  _buildStatRow('Área Reforma (alq)', (stats['areaReformaAlq'] as num?)?.toStringAsFixed(2) ?? '-'),
                  _buildStatRow('Área Total (alq)', (stats['areaTotalAlq'] as num?)?.toStringAsFixed(2) ?? '-'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar estatísticas: $e')),
        );
      }
    }
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
