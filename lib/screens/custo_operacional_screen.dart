import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../models/models.dart';
import '../services/custo_operacional_service.dart';
import '../services/dados_custo_operacional.dart';
import '../services/exportacao_pdf_service.dart';
import '../services/pdf_generators/pdf_custo.dart';
import '../services/anexo_service.dart';
import '../constants/app_colors.dart';
import 'custo_operacional_form_screen.dart';
import 'historico_custo_operacional_screen.dart';
import 'matriz_sensibilidade_screen.dart';
import 'projecao_financeira_screen.dart';
import 'graficos_comparativo_screen.dart';
import 'operacoes_detalhes_screen.dart';

class CustoOperacionalScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const CustoOperacionalScreen({
    super.key,
    required this.contexto,
  });

  @override
  State<CustoOperacionalScreen> createState() => _CustoOperacionalScreenState();
}

class _CustoOperacionalScreenState extends State<CustoOperacionalScreen> {
    // Função para salvar PDF no Supabase
    Future<void> _salvarPDF(CustoOperacionalCenario cenario) async {
      try {
        final propriedade = widget.contexto.propriedade;
        final pdfBytes = await PdfCustoOperacional.gerar(
          propriedade: propriedade,
          cenario: cenario,
        );
        final dataStr = DateTime.now().toIso8601String().substring(0,10);
        final nomeArquivo = 'CustoOperacional_${propriedade.nomePropriedade}_${cenario.nomeCenario}_$dataStr.pdf'
          .replaceAll(' ', '_');
        final anexoService = AnexoService();
        await anexoService.uploadAnexo(
          propriedadeId: propriedade.id,
          nomeArquivo: nomeArquivo,
          bytes: pdfBytes,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Relatório salvo com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar PDF: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  final _service = CustoOperacionalService();
  String? _cenarioSelecionadoId;
  int _selectedNavigationIndex = 0;
  bool _recalculado = false;

  @override
  void initState() {
    super.initState();
    _recalcularCenariosOnce();
  }

  Future<void> _recalcularCenariosOnce() async {
    if (_recalculado) return;
    _recalculado = true;
    try {
      final count = await _service.recalcularTodosCenarios();
      debugPrint('Recálculo concluído: $count cenários atualizados');
    } catch (e) {
      debugPrint('Erro ao recalcular cenários: $e');
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
      title: 'Custo Operacional',
      child: StreamBuilder<List<CustoOperacionalCenario>>(
        stream: _service.getCenariosByPropriedadeStream(widget.contexto.propriedade.id),
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

          return Stack(
            children: [
              Column(
                children: [
                  HeaderPropriedade(contexto: widget.contexto),
                  Expanded(
                    child: _buildContenudoCenarios(cenarioSelecionado, cenarios),
                  ),
                ],
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton.extended(
                  onPressed: _criarNovoCenario,
                  backgroundColor: AppColors.newPrimary,
                  foregroundColor: Colors.black,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Novo Cenário',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContenudoCenarios(CustoOperacionalCenario cenarioSelecionado, List<CustoOperacionalCenario> cenarios) {
    return Column(
      children: [
        // Seletor de cenários
        if (cenarios.length > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: cenarios.map((cenario) {
                  final selecionado = cenario.id == cenarioSelecionado.id;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(cenario.nomeCenario),
                      selected: selecionado,
                      onSelected: (_) {
                        setState(() => _cenarioSelecionadoId = cenario.id);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        // Detalhe do cenário selecionado
        Expanded(
          child: _buildCenarioDetalhes(cenarioSelecionado),
        ),
      ],
    );
  }

  Widget _buildCenarioDetalhes(CustoOperacionalCenario cenario) {
    final resumo = _service.calcularResumoComTotais(cenario: cenario);
    final longevidade = cenario.longevidade ?? DadosCustoOperacional.parametros.longevidade;
    final precoAtr = cenario.precoAtr ?? DadosCustoOperacional.parametros.precoATR;
    final receitaRT = resumo.precoRecebido.rT;
    final margemRT = resumo.margemLucro.rT;
    final margemPct = resumo.margemPercentual;

    // Cálculo do Ponto de Equilíbrio
    final custoHa = resumo.totalOperacional.rHa;
    final breakEven = receitaRT > 0 ? custoHa / receitaRT : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ══════ HEADER KPI — Margem Projetada ══════
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF16A34A).withAlpha(60)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cenario.nomeCenario.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Período: ${cenario.periodoRef}',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'MARGEM LÍQUIDA PROJETADA',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${margemRT.toStringAsFixed(2)}/t',
                      style: TextStyle(
                        color: margemRT >= 0 ? const Color(0xFFFDD835) : Colors.redAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ══════ KPIs ROW ══════
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  'Custo R\$/t',
                  'R\$ ${resumo.totalOperacional.rT.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKpiCard(
                  'Receita R\$/t',
                  'R\$ ${receitaRT.toStringAsFixed(2)}',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKpiCard(
                  'Margem %',
                  '${margemPct.toStringAsFixed(1)}%',
                  Icons.pie_chart,
                  margemPct >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ══════ PONTO DE EQUILÍBRIO + PREMISSAS ══════
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ponto de Equilíbrio
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF16A34A).withAlpha(60)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PONTO DE EQUILÍBRIO',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            breakEven > 0 && breakEven < 300
                                ? breakEven.toStringAsFixed(1)
                                : '---',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            't/ha',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Produtividade mínima para cobrir custos + arrendamento.',
                        style: TextStyle(color: Colors.white70, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Premissas resumidas
              Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PREMISSAS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.newTextSecondary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPremissaItem('Produtividade', '${cenario.produtividade} t/ha'),
                        _buildPremissaItem('ATR Médio', '${cenario.atr} kg/t'),
                        _buildPremissaItem('Preço ATR', 'R\$ ${precoAtr.toStringAsFixed(4)}/kg'),
                        _buildPremissaItem('Longevidade', '$longevidade safras'),
                        _buildPremissaItem('Diesel', 'R\$ ${cenario.precoDiesel?.toStringAsFixed(3) ?? '-'}/L'),
                        _buildPremissaItem('Arrendamento', '${cenario.arrendamento?.toStringAsFixed(1) ?? '-'} t/ha'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ══════ DRE — DEMONSTRATIVO DE RESULTADOS ══════
          _buildDRE(cenario, resumo, longevidade),
          const SizedBox(height: 24),

          // ══════ BOTÕES DE AÇÃO ══════
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

          // ══════ BOTÕES DE ANÁLISE ══════
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
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _exportarPDF(cenario),
                        icon: const Icon(Icons.file_download),
                        label: const Text(
                          'Exportar PDF',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _salvarPDF(cenario),
                        icon: const Icon(Icons.save_alt),
                        label: const Text(
                          'Salvar',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String valor, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.newTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremissaItem(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.newTextSecondary)),
          Text(valor, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDRE(
    CustoOperacionalCenario cenario,
    ResumoCustoOperacionalCalculado resumo,
    int longevidade,
  ) {
    final receitaRT = resumo.precoRecebido.rT;
    final linhasFormacao = resumo.linhasResumo.where((r) => r.ehFormacao).toList();
    final linhasRecorrentes = resumo.linhasResumo.where((r) => !r.ehFormacao).toList();
    final precoAtr = cenario.precoAtr ?? DadosCustoOperacional.parametros.precoATR;
    final atr = cenario.atr > 0 ? cenario.atr.toDouble() : 138.0;
    final margemRT = resumo.margemLucro.rT;
    final margemPct = resumo.margemPercentual;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Cabeçalho DRE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF15803D),
            child: const Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Estrutura Analítica de Custos (DRE)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'R\$/t',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    '% Receita',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // (+) Receita Bruta
          _dreRow(
            '(+) Receita Bruta (ATR: ${atr.toStringAsFixed(0)}kg × R\$ ${precoAtr.toStringAsFixed(4)})',
            receitaRT,
            100.0,
            isHeader: true,
            bgColor: const Color(0xFFDBEAFE),
          ),
          // (-) Formação Amortizada
          ...linhasFormacao.map((r) => _dreRow(
            '    (-) ${r.estagio}',
            r.rT,
            receitaRT > 0 ? (r.rT / receitaRT) * 100 : 0,
            isNegative: true,
          )),
          // (-) Recorrentes
          ...linhasRecorrentes.map((r) => _dreRow(
            '    (-) ${r.estagio}',
            r.rT,
            receitaRT > 0 ? (r.rT / receitaRT) * 100 : 0,
            isNegative: true,
          )),
          // (=) COE
          _dreRow(
            '(=) Custo Operacional Total',
            resumo.totalOperacional.rT,
            receitaRT > 0 ? (resumo.totalOperacional.rT / receitaRT) * 100 : 0,
            isHeader: true,
            bgColor: const Color(0xFFF1F5F9),
          ),
          // MARGEM FINAL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: margemRT >= 0 ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              border: Border(
                top: BorderSide(
                  color: margemRT >= 0 ? AppColors.newPrimary : AppColors.newDanger,
                  width: 2,
                ),
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'MARGEM LÍQUIDA FINAL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: margemRT >= 0 ? AppColors.newPrimary : AppColors.newDanger,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'R\$ ${margemRT.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: margemRT >= 0 ? AppColors.newPrimary : AppColors.newDanger,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    '${margemPct.toStringAsFixed(1)}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: margemRT >= 0 ? AppColors.newPrimary : AppColors.newDanger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dreRow(
    String label,
    double valorRT,
    double percentual, {
    bool isHeader = false,
    bool isNegative = false,
    Color? bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isHeader ? 12 : 11,
                fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              isNegative
                  ? valorRT.toStringAsFixed(2)
                  : 'R\$ ${valorRT.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: isHeader ? 12 : 11,
                fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
                color: isNegative ? const Color(0xFFDC2626) : AppColors.newTextPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${percentual.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.newTextMuted,
              ),
            ),
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

  Future<void> _criarNovoCenario() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CustoOperacionalFormScreen(
          propriedade: widget.contexto.propriedade,
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
          propriedade: widget.contexto.propriedade,
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
        builder: (_) => const HistoricoCustoOperacionalScreen(),
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
        widget.contexto.propriedade,
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
      widget.contexto.propriedade.id,
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

    return _service.getCenariosByPropriedade(widget.contexto.propriedade.id);
  }

  void _garantirTotais(CustoOperacionalCenario cenario) {
    if (cenario.id == null) return;
    if (cenario.totalOperacional != null && cenario.margemLucro != null) {
      return;
    }
    _service.recalcularTotaisCenario(cenario.id!).catchError((_) {});
  }
}
