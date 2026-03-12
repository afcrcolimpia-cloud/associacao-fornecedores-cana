import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../models/models.dart';
import '../services/monitoramento_praga_service.dart';
import '../services/talhao_service.dart';
import 'monitoramento_praga_form_screen.dart';

class MonitoramentoPragasScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const MonitoramentoPragasScreen({
    super.key,
    required this.contexto,
  });

  @override
  State<MonitoramentoPragasScreen> createState() =>
      _MonitoramentoPragasScreenState();
}

class _MonitoramentoPragasScreenState extends State<MonitoramentoPragasScreen> {
  final MonitoramentoPragaService _service = MonitoramentoPragaService();
  final TalhaoService _talhaoService = TalhaoService();
  int _selectedNavigationIndex = 0;

  List<MonitoramentoPraga> _monitoramentos = [];
  List<MonitoramentoPraga> _monitoramentosFiltrados = [];
  Map<String, Talhao> _talhoesMap = {};
  bool _carregando = true;
  String? _erro;

  // Filtros
  String? _filtroTalhao;
  String? _filtroPraga;
  String? _filtroNivel;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resultados = await Future.wait([
        _service.buscarPorPropriedade(widget.contexto.propriedade.id),
        _talhaoService
            .getTalhoesPorPropriedade(widget.contexto.propriedade.id),
      ]);
      if (mounted) {
        final talhoes = resultados[1] as List<Talhao>;
        setState(() {
          _monitoramentos = resultados[0] as List<MonitoramentoPraga>;
          _talhoesMap = {for (final t in talhoes) t.id: t};
          _aplicarFiltros();
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = e.toString();
          _carregando = false;
        });
      }
    }
  }

  void _aplicarFiltros() {
    var lista = List<MonitoramentoPraga>.from(_monitoramentos);
    if (_filtroTalhao != null) {
      lista = lista.where((m) => m.talhaoId == _filtroTalhao).toList();
    }
    if (_filtroPraga != null) {
      lista = lista.where((m) => m.praga == _filtroPraga).toList();
    }
    if (_filtroNivel != null) {
      lista =
          lista.where((m) => m.nivelInfestacao == _filtroNivel).toList();
    }
    _monitoramentosFiltrados = lista;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: 'Monitoramento de Pragas',
      child: Stack(
        children: [
          _buildConteudo(),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: () => _abrirFormulario(),
              backgroundColor: AppColors.newPrimary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'Novo Registro',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    return Column(
      children: [
        HeaderPropriedade(contexto: widget.contexto),
        _buildBarraFiltros(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _monitoramentosFiltrados.isEmpty ? null : _gerarPdfTodas,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF Todas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.newPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Exportar PDF do monitoramento de pragas',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(child: _buildCorpo()),
      ],
    );
  }

  Widget _buildBarraFiltros() {
    // Pragas únicas presentes nos dados
    final pragasUnicas = _monitoramentos.map((m) => m.praga).toSet().toList()
      ..sort();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Filtro por talhão
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filtroTalhao,
                  decoration: InputDecoration(
                    labelText: 'Talhão',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text('Todos')),
                    ..._talhoesMap.values.map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text('Talhão ${t.numeroTalhao}'),
                        )),
                  ],
                  onChanged: (v) => setState(() {
                    _filtroTalhao = v;
                    _aplicarFiltros();
                  }),
                ),
              ),
              const SizedBox(width: 10),
              // Filtro por praga
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filtroPraga,
                  decoration: InputDecoration(
                    labelText: 'Praga',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text('Todas')),
                    ...pragasUnicas.map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            _pragaCurta(p),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
                  onChanged: (v) => setState(() {
                    _filtroPraga = v;
                    _aplicarFiltros();
                  }),
                ),
              ),
              const SizedBox(width: 10),
              // Filtro por nível
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filtroNivel,
                  decoration: InputDecoration(
                    labelText: 'Nível',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem<String>(
                        value: null, child: Text('Todos')),
                    DropdownMenuItem(value: 'baixo', child: Text('Baixo')),
                    DropdownMenuItem(value: 'medio', child: Text('Médio')),
                    DropdownMenuItem(value: 'alto', child: Text('Alto')),
                    DropdownMenuItem(
                        value: 'critico', child: Text('Crítico')),
                  ],
                  onChanged: (v) => setState(() {
                    _filtroNivel = v;
                    _aplicarFiltros();
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (!_carregando)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_monitoramentosFiltrados.length} de ${_monitoramentos.length} registros',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.newDanger),
            const SizedBox(height: 12),
            const Text('Erro ao carregar monitoramentos',
                style: TextStyle(color: AppColors.newDanger)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _carregarDados,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_monitoramentosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bug_report, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _monitoramentos.isEmpty
                  ? 'Nenhum monitoramento registrado'
                  : 'Nenhum registro encontrado com este filtro',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            if (_monitoramentos.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Clique em "Novo Registro" para começar',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: _monitoramentosFiltrados.length,
        itemBuilder: (context, index) =>
            _buildCard(_monitoramentosFiltrados[index]),
      ),
    );
  }

  Widget _buildCard(MonitoramentoPraga m) {
    final talhao = _talhoesMap[m.talhaoId];
    final corNivel = _corDoNivel(m.nivelInfestacao);
    final iconeNivel = _iconeDoNivel(m.nivelInfestacao);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: m.isCritico
            ? const BorderSide(color: AppColors.newDanger, width: 2)
            : m.isAlto
                ? BorderSide(color: AppColors.newWarning.withOpacity(0.6))
                : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Linha 1: Praga + badge + menu
            Row(
              children: [
                const Icon(Icons.bug_report,
                    color: AppColors.primary, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.pragaCurta,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildNivelBadge(m.nivelFormatado, corNivel, iconeNivel),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  onSelected: (value) => _acaoMenu(value, m),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                  ],
                ),
              ],
            ),
            const Divider(height: 14),

            // ── Linha 2: Talhão + Data
            Row(
              children: [
                _infoChip(Icons.agriculture,
                    talhao != null ? 'Talhão ${talhao.numeroTalhao}' : '—'),
                const SizedBox(width: 16),
                _infoChip(Icons.calendar_today, _formatarData(m.dataMonitoramento)),
                if (m.areaAfetadaHa != null) ...[
                  const Spacer(),
                  _infoChip(Icons.crop_square,
                      '${m.areaAfetadaHa!.toStringAsFixed(1)} ha afetados'),
                ],
              ],
            ),

            // ── Linha 3: Método e Responsável
            if (m.metodoAvaliacao != null || m.responsavel != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  if (m.metodoAvaliacao != null)
                    _infoChip(Icons.analytics, m.metodoAvaliacao!),
                  if (m.metodoAvaliacao != null && m.responsavel != null)
                    const SizedBox(width: 16),
                  if (m.responsavel != null)
                    _infoChip(Icons.person, m.responsavel!),
                ],
              ),
            ],

            // ── Linha 4: Ação recomendada
            if (m.acaoRecomendada != null &&
                m.acaoRecomendada!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.newWarning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: m.isCritico
                          ? const BorderSide(color: AppColors.newDanger, width: 2)
                          : m.isAlto
                              ? BorderSide(color: AppColors.newWarning.withOpacity(0.6))
                              : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Linha 1: Praga + badge + menu + PDF
                          Row(
                            children: [
                              const Icon(Icons.bug_report,
                                  color: AppColors.primary, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  m.pragaCurta,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _buildNivelBadge(m.nivelFormatado, corNivel, iconeNivel),
                              const SizedBox(width: 4),
                              IconButton(
                                tooltip: 'PDF deste registro',
                                icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
                                onPressed: () => _gerarPdfIndividual(m),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) => _acaoMenu(value, m),
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: 'editar', child: Text('Editar')),
                                  PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 14),
                          // ...restante do card...
                  // ── PDF ─────────────────────────────────────────────

                  Future<void> _gerarPdfTodas() async {
                    if (_monitoramentosFiltrados.isEmpty) return;
                    // Map talhaoId -> numeroTalhao
                    final talhoesNumeros = {for (final t in _talhoesMap.values) t.id: t.numeroTalhao.toString()};
                    final pdf = await PdfMonitoramentoPragas.gerar(
                      widget.contexto,
                      _monitoramentosFiltrados,
                      talhoesNumeros,
                    );
                    await Printing.layoutPdf(onLayout: (_) async => pdf);
                  }

                  Future<void> _gerarPdfIndividual(MonitoramentoPraga m) async {
                    final talhoesNumeros = {for (final t in _talhoesMap.values) t.id: t.numeroTalhao.toString()};
                    final pdf = await PdfMonitoramentoPragas.gerar(
                      widget.contexto,
                      [m],
                      talhoesNumeros,
                    );
                    await Printing.layoutPdf(onLayout: (_) async => pdf);
                  }
                m.observacoes!,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNivelBadge(String texto, Color cor, IconData icone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: cor),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _corDoNivel(String nivel) {
    switch (nivel) {
      case 'baixo':
        return AppColors.newPrimary;
      case 'medio':
        return AppColors.newWarning;
      case 'alto':
        return Colors.deepOrange;
      case 'critico':
        return AppColors.newDanger;
      default:
        return Colors.grey;
    }
  }

  IconData _iconeDoNivel(String nivel) {
    switch (nivel) {
      case 'baixo':
        return Icons.check_circle_outline;
      case 'medio':
        return Icons.warning_amber;
      case 'alto':
        return Icons.error_outline;
      case 'critico':
        return Icons.dangerous;
      default:
        return Icons.circle;
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  String _pragaCurta(String praga) {
    final idx = praga.indexOf('(');
    if (idx > 0) return praga.substring(0, idx).trim();
    return praga;
  }

  // ── Ações ──────────────────────────────────────────────────

  Future<void> _abrirFormulario({MonitoramentoPraga? monitoramento}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MonitoramentoPragaFormScreen(
          contexto: widget.contexto,
          monitoramento: monitoramento,
        ),
      ),
    );
    if (resultado == true) {
      _carregarDados();
    }
  }

  Future<void> _acaoMenu(String acao, MonitoramentoPraga m) async {
    switch (acao) {
      case 'editar':
        _abrirFormulario(monitoramento: m);
        break;
      case 'excluir':
        _confirmarExclusao(m);
        break;
    }
  }

  void _confirmarExclusao(MonitoramentoPraga m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Registro?'),
        content: Text(
          'Excluir monitoramento de "${m.pragaCurta}" em ${_formatarData(m.dataMonitoramento)}?\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _service.deletarMonitoramento(m.id);
                _carregarDados();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Registro excluído com sucesso')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newDanger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
