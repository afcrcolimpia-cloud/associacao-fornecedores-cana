import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/talhao_service.dart';
import '../services/tratos_culturais_service.dart';
import '../services/pdf_generators/pdf_tratos.dart';
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
  List<TratosCulturais> _tratosAtuais = [];

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
      showBackButton: true,
      title: 'Tratos Culturais',
      child: Stack(
        children: [
          Column(
            children: [
              HeaderPropriedade(contexto: widget.contexto),
              _buildFiltros(),
              Expanded(
                child: _buildTabela(),
              ),
            ],
          ),
          Positioned(
            bottom: 88,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: _tratosAtuais.isEmpty ? null : () => _gerarPdf(),
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
              onPressed: () => _abrirFormulario(),
              backgroundColor: AppColors.newPrimary,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text(
                'Novo Trato',
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

        tratos = tratos.where((t) => t.anoSafra == _filtroAnoSafra.toString()).toList();
        _tratosAtuais = tratos;

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

        // Agrupar por talhão
        final agrupado = <String, List<TratosCulturais>>{};
        for (final trato in tratos) {
          final chave = trato.talhaoId ?? 'desconhecido';
          agrupado.putIfAbsent(chave, () => []).add(trato);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: agrupado.entries.map((entry) {
              return _buildTalhaoAgrupado(entry.key, entry.value);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTalhaoAgrupado(String talhaoId, List<TratosCulturais> tratos) {
    if (tratos.isEmpty) return const SizedBox.shrink();

    final talhao = _talhoes.firstWhere(
      (t) => t.id == talhaoId,
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

    final custoTotal = tratos.fold(0.0, (sum, t) => sum + t.custoTotalCompleto);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Cabeçalho do grupo — talhão
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.grid_view, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          talhao.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '${talhao.variedade ?? "Sem variedade"} — ${talhao.areaHa?.toStringAsFixed(1) ?? "?"} ha',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                if (custoTotal > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Custo Total:', style: TextStyle(fontSize: 11)),
                      Text(
                        'R\$ ${custoTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Tratos do talhão
          ...tratos.map((trato) => _buildTratoListTile(trato, talhao)),
        ],
      ),
    );
  }

  Widget _buildTratoListTile(TratosCulturais trato, Talhao talhao) {
    final totalInsumos = (trato.adubos?.length ?? 0) +
        (trato.herbicidas?.length ?? 0) +
        (trato.inseticidas?.length ?? 0) +
        (trato.maturadores?.length ?? 0);

    return ListTile(
      title: Text('Safra ${trato.anoSafra}'),
      subtitle: Text(
        '$totalInsumos insumos  •  '
        '${trato.adubos?.length ?? 0} adubos  •  '
        '${trato.herbicidas?.length ?? 0} herb.  •  '
        '${trato.inseticidas?.length ?? 0} inset.  •  '
        '${trato.maturadores?.length ?? 0} mat.'
        '${trato.custoTotalInsumos > 0 ? "  •  R\$ ${trato.custoTotalInsumos.toStringAsFixed(2)}" : ""}',
      ),
      trailing: Row(
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

  Future<void> _gerarPdf() async {
    try {
      final pdfBytes = await PdfTratosCulturais.gerar(
        propriedade: widget.contexto.propriedade,
        tratos: _tratosAtuais,
        anoSafra: _filtroAnoSafra,
      );
      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'Tratos_Culturais_${widget.contexto.nomePropriedade}.pdf',
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
