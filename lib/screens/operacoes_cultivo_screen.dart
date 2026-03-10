import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import '../models/models.dart';
import '../services/operacao_cultivo_service.dart';
import '../services/talhao_service.dart';
import '../services/pdf_generators/pdf_operacoes.dart';
import '../constants/app_colors.dart';
import '../widgets/operacao_card.dart';
import 'operacao_form_screen.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class OperacoesCultivoScreen extends StatefulWidget {
  final Propriedade propriedade;

  const OperacoesCultivoScreen({
    super.key,
    required this.propriedade,
  });

  @override
  State<OperacoesCultivoScreen> createState() => _OperacoesCultivoScreenState();
}

class _OperacoesCultivoScreenState extends State<OperacoesCultivoScreen> {
  final OperacaoCultivoService _service = OperacaoCultivoService();
  final TalhaoService _talhaoService = TalhaoService();
  
  Map<String, String> _talhoesNomes = {};
  bool _isLoading = true;
  String? _talhaoFiltro;

  @override
  void initState() {
    super.initState();
    _carregarTalhoes();
  }

  Future<void> _carregarTalhoes() async {
    try {
      final talhoes = await _talhaoService
          .getTalhoesByPropriedadeStream(widget.propriedade.id)
          .first;
      
      setState(() {
        _talhoesNomes = {
          for (var t in talhoes) t.id: t.numeroTalhao,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar talhões: $e')),
        );
      }
    }
  }

  void _navegarParaFormulario([OperacaoCultivo? operacao]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OperacaoFormScreen(
          propriedade: widget.propriedade,
          operacao: operacao,
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            operacao == null
                ? 'Operação cadastrada com sucesso!'
                : 'Operação atualizada com sucesso!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _confirmarExclusao(OperacaoCultivo operacao) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir esta operação de ${_talhoesNomes[operacao.talhaoId] ?? "talhão"}?',
        ),
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

    if (confirm == true) {
      try {
        await _service.deleteOperacao(operacao.id!);
        if (mounted) {
          // Forçar rebuild do StreamBuilder
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Operação excluída com sucesso!'),
              backgroundColor: AppColors.success,
            ),
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
      final operacoes = await _service.getOperacoesPorPropriedade(
        widget.propriedade.id,
      ).first;

      if (!mounted) return;

      final pdf = await PdfOperacoesCultivo.gerar(
        propriedade: widget.propriedade,
        operacoes: operacoes,
      );

      await Printing.layoutPdf(
        name: 'Relatorio_Operacoes_${widget.propriedade.nomePropriedade}.pdf',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarAfcrc(
        title: 'Operações de Cultivo — ${widget.propriedade.nomePropriedade}',
        actions: [
          // Filtro por talhão
          PopupMenuButton<String?>(
            icon: Icon(
              _talhaoFiltro != null ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _talhaoFiltro != null ? AppColors.primary : null,
            ),
            tooltip: 'Filtrar por talhão',
            onSelected: (value) {
              setState(() => _talhaoFiltro = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todos os talhões'),
              ),
              const PopupMenuDivider(),
              ..._talhoesNomes.entries.map(
                (entry) => PopupMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _gerarPdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<OperacaoCultivo>>(
              stream: _service.getOperacoesPorPropriedade(widget.propriedade.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var operacoes = snapshot.data ?? [];

                // Aplicar filtro de talhão
                if (_talhaoFiltro != null) {
                  operacoes = operacoes
                      .where((o) => o.talhaoId == _talhaoFiltro)
                      .toList();
                }

                if (operacoes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.agriculture_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _talhaoFiltro != null
                              ? 'Nenhuma operação neste talhão'
                              : 'Nenhuma operação cadastrada',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Clique no + para adicionar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Card de estatísticas
                    _buildEstatisticasCard(operacoes),
                    
                    // Lista de operações
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: operacoes.length,
                        itemBuilder: (context, index) {
                          final operacao = operacoes[index];
                          return OperacaoCard(
                            operacao: operacao,
                            nomeTalhao: _talhoesNomes[operacao.talhaoId],
                            onTap: () => _navegarParaFormulario(operacao),
                            onEdit: () => _navegarParaFormulario(operacao),
                            onDelete: () => _confirmarExclusao(operacao),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navegarParaFormulario(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Nova Operação'),
      ),
    );
  }

  Widget _buildEstatisticasCard(List<OperacaoCultivo> operacoes) {
    final total = operacoes.length;
    final colhidas = operacoes.where((o) => o.dataColheita != null).length;
    final emCultivo = operacoes.where((o) => 
      o.dataQuebraLombo != null && o.dataColheita == null
    ).length;
    final plantadas = total - colhidas - emCultivo;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.eco,
            label: 'Plantadas',
            value: plantadas.toString(),
            color: Colors.white,
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStatItem(
            icon: Icons.grass,
            label: 'Em Cultivo',
            value: emCultivo.toString(),
            color: Colors.white,
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStatItem(
            icon: Icons.agriculture,
            label: 'Colhidas',
            value: colhidas.toString(),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}
