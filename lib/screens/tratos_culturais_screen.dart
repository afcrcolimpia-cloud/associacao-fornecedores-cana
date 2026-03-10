import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/talhao_service.dart';
import '../services/tratos_culturais_service.dart';
import 'tratos_culturais_form_screen.dart';

class TratosCulturaisScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const TratosCulturaisScreen({
    super.key,
    required this.contexto,
  });

  @override
  State<TratosCulturaisScreen> createState() => _TratosCulturaisScreenState();
}

class _TratosCulturaisScreenState extends State<TratosCulturaisScreen> {
  final TratosCulturaisService _service = TratosCulturaisService();
  int _selectedNavigationIndex = 0;
  final TalhaoService _talhaoService = TalhaoService();

  int _filtroAnoSafra = DateTime.now().year;
  List<Talhao> _talhoes = [];

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 TratosCulturaisScreen - Propriedade ID: ${widget.contexto.propriedade.id}');
    debugPrint('🔵 TratosCulturaisScreen - Propriedade Nome: ${widget.contexto.propriedade.nomePropriedade}');
    _carregarTalhoes();
  }

  Future<void> _carregarTalhoes() async {
    try {
      final talhoes = await _talhaoService.getTalhoesPorPropriedade(widget.contexto.propriedade.id);
      debugPrint('🟢 Talhões carregados: ${talhoes.length}');
      if (mounted) {
        setState(() {
          _talhoes = talhoes;
        });
      }
    } catch (e) {
      debugPrint('🔴 Erro ao carregar talhões: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      title: 'Tratos Culturais',
      child: Column(
        children: [
          HeaderPropriedade(contexto: widget.contexto),
          _buildFiltros(),
          Expanded(
            child: _buildTabela(),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _filtroAnoSafra,
              decoration: const InputDecoration(
                labelText: 'Ano Safra',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: List.generate(5, (index) {
                final ano = DateTime.now().year - index;
                return DropdownMenuItem(
                  value: ano,
                  child: Text(ano.toString()),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _filtroAnoSafra = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabela() {
    return StreamBuilder<List<TratosCulturais>>(
      stream: _service.getTratosByPropriedadeStream(widget.contexto.propriedade.id),
      builder: (context, snapshot) {
        debugPrint('🟡 Stream State: ${snapshot.connectionState}');
        debugPrint('🟡 Has Data: ${snapshot.hasData}');
        debugPrint('🟡 Has Error: ${snapshot.hasError}');
        if (snapshot.hasError) {
          debugPrint('🔴 Stream Error: ${snapshot.error}');
        }
        if (snapshot.hasData) {
          debugPrint('🟢 Data recebida: ${snapshot.data?.length ?? 0} registros');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text('Erro: ${snapshot.error}'),
              ],
            ),
          );
        }

        var tratos = snapshot.data ?? [];
        debugPrint('🟢 Total de tratos antes do filtro: ${tratos.length}');

        tratos = tratos.where((t) => t.anoSafra == _filtroAnoSafra.toString()).toList();
        debugPrint('🟢 Total de tratos depois do filtro: ${tratos.length}');

        if (tratos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.agriculture, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('Nenhum trato cadastrado para este período'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Trato'),
                  onPressed: () => _abrirFormulario(),
                ),
              ],
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn(label: Text('Talhão', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Ano Safra', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Adubos', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Herbicidas', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Inseticidas', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Maturadores', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Calagem', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: tratos.map((trato) {
                  final talhao = _talhoes.firstWhere(
                    (t) => t.id == trato.talhaoId,
                    orElse: () => Talhao(
                      id: '',
                      propriedadeId: '',
                      numeroTalhao: 'N/A',
                      areaHa: 0,
                      cultura: '',
                      criadoEm: DateTime.now(),
                      atualizadoEm: DateTime.now(),
                    ),
                  );

                  return DataRow(
                    cells: [
                      DataCell(Text(talhao.numeroTalhao)),
                      DataCell(Text(trato.anoSafra.toString())),
                      DataCell(Text('${trato.adubos?.length ?? 0}')),
                      DataCell(Text('${trato.herbicidas?.length ?? 0}')),
                      DataCell(Text('${trato.inseticidas?.length ?? 0}')),
                      DataCell(Text('${trato.maturadores?.length ?? 0}')),
                      DataCell(Text(trato.calagem?.toStringAsFixed(2) ?? '-')),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _abrirFormulario(trato: trato),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _confirmarExclusao(trato),
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
      },
    );
  }

  Future<void> _abrirFormulario({TratosCulturais? trato}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TratosCulturaisFormScreen(
          propriedade: widget.contexto.propriedade,
          talhoes: _talhoes,
          tratos: trato,
        ),
      ),
    );

    if (resultado == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmarExclusao(TratosCulturais trato) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tratos?'),
        content: const Text('Deseja remover este registro de tratos culturais?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _service.deleteTratos(trato.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trato excluído com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }
}