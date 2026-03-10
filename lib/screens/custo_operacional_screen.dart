import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import '../models/models.dart';
import '../services/custo_operacional_service.dart';
import '../services/exportacao_pdf_service.dart';
import '../constants/app_colors.dart';
import 'custo_operacional_form_screen.dart';
import 'historico_custo_operacional_screen.dart';
import 'matriz_sensibilidade_screen.dart';
import 'graficos_comparativo_screen.dart';
import 'projecao_financeira_screen.dart';
import 'operacoes_detalhes_screen.dart';

class CustoOperacionalScreen extends StatefulWidget {
  final Propriedade propriedade;

  const CustoOperacionalScreen({
    super.key,
    required this.propriedade,
  });

  @override
  State<CustoOperacionalScreen> createState() => _CustoOperacionalScreenState();
}

class _CustoOperacionalScreenState extends State<CustoOperacionalScreen> {
  final _service = CustoOperacionalService();
  String? _cenarioSelecionadoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarAfcrc(
        title: 'Custo Operacional',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _criarNovoCenario,
          ),
        ],
      ),
      body: StreamBuilder<List<CustoOperacionalCenario>>(
        stream: _service.getCenariosByPropriedadeStream(widget.propriedade.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Erro: ${snapshot.error}'),
                ],
              ),
            );
          }

          final cenarios = snapshot.data ?? [];

          if (cenarios.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.note_add, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Nenhum cenario cadastrado'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _criarNovoCenario,
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Primeiro Cenario'),
                  ),
                ],
              ),
            );
          }

          final cenarioSelecionado = _resolverCenarioSelecionado(cenarios);

          if (_cenarioSelecionadoId != cenarioSelecionado.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _cenarioSelecionadoId = cenarioSelecionado.id);
              _garantirTotais(cenarioSelecionado);
            });
          }

          return Column(
            children: [
              // Lista de cenários em abas
              Container(
                color: Colors.grey.withOpacity(0.1),
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemCount: cenarios.length,
                  itemBuilder: (context, index) {
                    final cenario = cenarios[index];
                    final isSelected = _cenarioSelecionadoId == cenario.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cenario.nomeCenario),
                        onSelected: (_) {
                          setState(() => _cenarioSelecionadoId = cenario.id);
                          _garantirTotais(cenario);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Conteúdo do cenário selecionado
              Expanded(
                child: _buildCenarioDetalhes(cenarioSelecionado),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCenarioDetalhes(CustoOperacionalCenario cenario) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PARÂMETROS
          _buildCard(
            title: 'Parâmetros Tecnicas',
            children: [
              _buildParametroRow(
                  'Produtividade', '${cenario.produtividade} t/ha'),
              _buildParametroRow('ATR', '${cenario.atr} kg/t'),
              _buildParametroRow(
                'Longevidade',
                '${cenario.longevidade ?? '-'} safras',
              ),
              _buildParametroRow(
                'Dose de Muda',
                '${cenario.doseMuda?.toStringAsFixed(2) ?? '-'} t/ha',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // PREÇOS
          _buildCard(
            title: 'Precos de Mercado',
            children: [
              _buildParametroRow(
                'Diesel',
                'R\$ ${cenario.precoDiesel?.toStringAsFixed(3) ?? '-'}/L',
              ),
              _buildParametroRow(
                'Preco ATR',
                'R\$ ${cenario.precoAtr?.toStringAsFixed(4) ?? '-'}/kg',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // CUSTOS
          _buildCard(
            title: 'Custos de Operacao',
            children: [
              _buildParametroRow(
                'Arrendamento',
                '${cenario.arrendamento?.toStringAsFixed(2) ?? '-'} t/ha',
              ),
              _buildParametroRow(
                'ATR Arrendamento',
                '${cenario.atrArrend ?? '-'} kg/t',
              ),
              _buildParametroRow(
                'Administrativo',
                'R\$ ${cenario.custoAdministrativo?.toStringAsFixed(2) ?? '168,00'}/ha',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // RESULTADOS
          if (cenario.totalOperacional != null && cenario.margemLucro != null)
            _buildCard(
              title: 'Resultados Economicos',
              children: [
                _buildParametroRow(
                  'Total Operacional',
                  'R\$ ${cenario.totalOperacional?.toStringAsFixed(2) ?? '-'}/ha',
                  color: AppColors.primary,
                ),
                _buildParametroRow(
                  'Margem de Lucro',
                  '${cenario.margemLucro?.toStringAsFixed(2) ?? '-'}%',
                  color: cenario.margemLucro! > 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          const SizedBox(height: 24),

          // BOTÕES DE AÇÃO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () => _editarCenario(cenario),
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
              OutlinedButton.icon(
                onPressed: () => _verHistorico(cenario),
                icon: const Icon(Icons.history),
                label: const Text('Histórico'),
              ),
              OutlinedButton.icon(
                onPressed: () => _deletarCenario(cenario),
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Deletar'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // BOTÕES DE ANÁLISE
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 48) / 2,
                child: ElevatedButton.icon(
                  onPressed: () => _abrirOperacoesDetalhes(cenario),
                  icon: const Icon(Icons.list_alt),
                  label: const Text(
                    'Operações',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 48) / 2,
                child: ElevatedButton.icon(
                  onPressed: () => _abrirMatrizSensibilidade(cenario),
                  icon: const Icon(Icons.grid_on),
                  label: const Text(
                    'Sensibilidade',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 48) / 2,
                child: ElevatedButton.icon(
                  onPressed: () => _abrirProjecaoFinanceira(cenario),
                  icon: const Icon(Icons.trending_up),
                  label: const Text(
                    'Projeção',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 48) / 2,
                child: ElevatedButton.icon(
                  onPressed: _abrirGraficosComparativos,
                  icon: const Icon(Icons.bar_chart),
                  label: const Text(
                    'Comparar',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 48) / 2,
                child: ElevatedButton.icon(
                  onPressed: () => _exportarPDF(cenario),
                  icon: const Icon(Icons.file_download),
                  label: const Text(
                    'Exportar PDF',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  CustoOperacionalCenario _resolverCenarioSelecionado(
    List<CustoOperacionalCenario> cenarios,
  ) {
    if (_cenarioSelecionadoId == null) return cenarios.first;

    for (final cenario in cenarios) {
      if (cenario.id == _cenarioSelecionadoId) {
        return cenario;
      }
    }

    return cenarios.first;
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildParametroRow(
    String label,
    String valor, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _criarNovoCenario() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CustoOperacionalFormScreen(
          propriedade: widget.propriedade,
        ),
      ),
    );

    if (resultado == true && mounted) {
      setState(() => _cenarioSelecionadoId = null);
    }
  }

  Future<void> _editarCenario(CustoOperacionalCenario cenario) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CustoOperacionalFormScreen(
          propriedade: widget.propriedade,
          cenarioEditando: cenario,
        ),
      ),
    );

    if (resultado == true && mounted) {
      setState(() => _cenarioSelecionadoId = null);
    }
  }

  Future<void> _verHistorico(CustoOperacionalCenario cenario) async {
    if (cenario.id == null) return;

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistoricoCustoOperacionalScreen(
          cenarioId: cenario.id!,
          nomeCenario: cenario.nomeCenario,
        ),
      ),
    );
  }

  Future<void> _deletarCenario(CustoOperacionalCenario cenario) async {
    if (cenario.id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusao'),
        content: Text(
          'Deseja realmente deletar o cenario "${cenario.nomeCenario}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await _service.deletarCenario(cenario.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cenario deletado com sucesso'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() => _cenarioSelecionadoId = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao deletar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _abrirMatrizSensibilidade(
    CustoOperacionalCenario cenario,
  ) async {
    final atualizado = await _obterCenarioAtualizado(cenario);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatrizSensibilidadeScreen(cenario: atualizado),
      ),
    );
  }

  Future<void> _abrirProjecaoFinanceira(
    CustoOperacionalCenario cenario,
  ) async {
    final atualizado = await _obterCenarioAtualizado(cenario);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjecaoFinanceiraScreen(cenario: atualizado),
      ),
    );
  }

  Future<void> _abrirGraficosComparativos() async {
    final cenarios = await _obterCenariosAtualizadosParaComparacao();

    if (cenarios.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum cenário para comparar'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GraficosComparativoScreen(cenarios: cenarios),
      ),
    );
  }

  Future<void> _exportarPDF(CustoOperacionalCenario cenario) async {
    try {
      final atualizado = await _obterCenarioAtualizado(cenario);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gerando relatório...'),
        ),
      );

      await ExportacaoPDFService.imprimirRelatorio(
        atualizado,
        widget.propriedade,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relatório gerado com sucesso'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _abrirOperacoesDetalhes(CustoOperacionalCenario cenario) async {
    final atualizado = await _obterCenarioAtualizado(cenario);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OperacoesDetalhesScreen(cenario: atualizado),
      ),
    );
  }

  Future<CustoOperacionalCenario> _obterCenarioAtualizado(
    CustoOperacionalCenario cenario,
  ) async {
    final cenarioId = cenario.id;
    if (cenarioId == null) return cenario;

    try {
      await _service.recalcularTotaisCenario(cenarioId);
      final atualizado = await _service.getCenario(cenarioId);
      if (atualizado != null) return atualizado;
    } catch (_) {
      // Em caso de falha, usa o cenário em memória para não bloquear o fluxo.
    }

    return cenario;
  }

  Future<List<CustoOperacionalCenario>>
      _obterCenariosAtualizadosParaComparacao() async {
    final cenarios = await _service.getCenariosByPropriedade(
      widget.propriedade.id,
    );

    for (final cenario in cenarios) {
      final cenarioId = cenario.id;
      if (cenarioId == null) continue;
      try {
        await _service.recalcularTotaisCenario(cenarioId);
      } catch (_) {
        // Mantém os dados existentes caso um cenário falhe no recálculo.
      }
    }

    return _service.getCenariosByPropriedade(widget.propriedade.id);
  }

  void _garantirTotais(CustoOperacionalCenario cenario) {
    if (cenario.id == null) return;
    if (cenario.totalOperacional != null && cenario.margemLucro != null) {
      return;
    }
    _service.recalcularTotaisCenario(cenario.id!).catchError((_) {});
  }
}
