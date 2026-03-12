import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../models/models.dart';
import '../services/monitoramento_praga_service.dart';
import '../services/talhao_service.dart';
import '../services/safra_service.dart';

class MonitoramentoPragaFormScreen extends StatefulWidget {
  final ContextoPropriedade contexto;
  final MonitoramentoPraga? monitoramento;

  const MonitoramentoPragaFormScreen({
    super.key,
    required this.contexto,
    this.monitoramento,
  });

  bool get isEdicao => monitoramento != null;

  @override
  State<MonitoramentoPragaFormScreen> createState() =>
      _MonitoramentoPragaFormScreenState();
}

class _MonitoramentoPragaFormScreenState
    extends State<MonitoramentoPragaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MonitoramentoPragaService _service = MonitoramentoPragaService();
  final TalhaoService _talhaoService = TalhaoService();
  final SafraService _safraService = SafraService();
  int _selectedNavigationIndex = 0;
  bool _salvando = false;
  bool _carregando = true;

  List<Talhao> _talhoes = [];
  List<Safra> _safras = [];

  // Campos do formulário
  String? _talhaoId;
  String? _safraId;
  String? _praga;
  String _nivelInfestacao = 'baixo';
  DateTime _dataMonitoramento = DateTime.now();
  final TextEditingController _areaAfetadaController = TextEditingController();
  String? _metodoAvaliacao;
  final TextEditingController _acaoRecomendadaController =
      TextEditingController();
  final TextEditingController _acaoRealizadaController =
      TextEditingController();
  final TextEditingController _insumoController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _unidadeDoseController = TextEditingController();
  final TextEditingController _responsavelController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _areaAfetadaController.dispose();
    _acaoRecomendadaController.dispose();
    _acaoRealizadaController.dispose();
    _insumoController.dispose();
    _doseController.dispose();
    _unidadeDoseController.dispose();
    _responsavelController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final resultados = await Future.wait([
        _talhaoService
            .getTalhoesPorPropriedade(widget.contexto.propriedade.id),
        _safraService
            .buscarPorProprietario(widget.contexto.proprietario.id),
      ]);
      if (mounted) {
        setState(() {
          _talhoes = resultados[0] as List<Talhao>;
          _safras = resultados[1] as List<Safra>;
          _carregando = false;
        });
        _preencherCampos();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  void _preencherCampos() {
    final m = widget.monitoramento;
    if (m == null) return;
    setState(() {
      _talhaoId = m.talhaoId;
      _safraId = m.safraId;
      _praga = m.praga;
      _nivelInfestacao = m.nivelInfestacao;
      _dataMonitoramento = m.dataMonitoramento;
      _metodoAvaliacao = m.metodoAvaliacao;
    });
    if (m.areaAfetadaHa != null) {
      _areaAfetadaController.text = m.areaAfetadaHa.toString();
    }
    _acaoRecomendadaController.text = m.acaoRecomendada ?? '';
    _acaoRealizadaController.text = m.acaoRealizada ?? '';
    _insumoController.text = m.insumoUtilizado ?? '';
    if (m.doseAplicada != null) {
      _doseController.text = m.doseAplicada.toString();
    }
    _unidadeDoseController.text = m.unidadeDose ?? '';
    _responsavelController.text = m.responsavel ?? '';
    _observacoesController.text = m.observacoes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: widget.isEdicao
          ? 'Editar Monitoramento'
          : 'Novo Monitoramento de Praga',
      child: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                HeaderPropriedade(contexto: widget.contexto),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Seção: Identificação ──
                          _buildSecao('Identificação'),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Talhão
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _talhaoId,
                                  decoration: const InputDecoration(
                                    labelText: 'Talhão *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.agriculture),
                                  ),
                                  items: _talhoes
                                      .map((t) => DropdownMenuItem(
                                            value: t.id,
                                            child: Text(
                                                'Talhão ${t.numeroTalhao}${t.areaHa != null ? ' (${t.areaHa!.toStringAsFixed(1)} ha)' : ''}'),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _talhaoId = v),
                                  validator: (v) => v == null
                                      ? 'Selecione o talhão'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Safra (opcional)
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _safraId,
                                  decoration: const InputDecoration(
                                    labelText: 'Safra',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.date_range),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Nenhuma'),
                                    ),
                                    ..._safras.map((s) => DropdownMenuItem(
                                          value: s.id,
                                          child: Text(
                                              'Safra ${s.safra} (${s.statusFormatado})'),
                                        )),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _safraId = v),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Seção: Praga e Nível ──
                          _buildSecao('Praga e Nível de Infestação'),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Praga
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: _praga,
                                  decoration: const InputDecoration(
                                    labelText: 'Praga *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.bug_report),
                                  ),
                                  items: MonitoramentoPraga
                                      .pragasDisponiveis
                                      .map((p) => DropdownMenuItem(
                                            value: p,
                                            child: Text(p,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _praga = v),
                                  validator: (v) => v == null
                                      ? 'Selecione a praga'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Nível
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _nivelInfestacao,
                                  decoration: const InputDecoration(
                                    labelText: 'Nível *',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.bar_chart),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'baixo',
                                        child: Text('Baixo')),
                                    DropdownMenuItem(
                                        value: 'medio',
                                        child: Text('Médio')),
                                    DropdownMenuItem(
                                        value: 'alto',
                                        child: Text('Alto')),
                                    DropdownMenuItem(
                                        value: 'critico',
                                        child: Text('Crítico')),
                                  ],
                                  onChanged: (v) => setState(
                                      () => _nivelInfestacao = v ?? 'baixo'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Seção: Data e Área ──
                          _buildSecao('Data e Área Afetada'),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Data
                              Expanded(
                                child: InkWell(
                                  onTap: _selecionarData,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Data do Monitoramento *',
                                      border: OutlineInputBorder(),
                                      prefixIcon:
                                          Icon(Icons.calendar_today),
                                    ),
                                    child: Text(_formatarData(
                                        _dataMonitoramento)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Área afetada
                              Expanded(
                                child: TextFormField(
                                  controller: _areaAfetadaController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.,]')),
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Área Afetada (ha)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.crop_square),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Método
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _metodoAvaliacao,
                                  decoration: const InputDecoration(
                                    labelText: 'Método de Avaliação',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.analytics),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Nenhum')),
                                    ...MonitoramentoPraga.metodosAvaliacao
                                        .map((m) => DropdownMenuItem(
                                              value: m,
                                              child: Text(m),
                                            )),
                                  ],
                                  onChanged: (v) => setState(
                                      () => _metodoAvaliacao = v),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Seção: Ações ──
                          _buildSecao('Ações'),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _acaoRecomendadaController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Ação Recomendada',
                              hintText:
                                  'Ex: Aplicação de inseticida biológico',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lightbulb_outline),
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _acaoRealizadaController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Ação Realizada',
                              hintText:
                                  'Ex: Aplicação realizada em 10/03/2026',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.check_circle_outline),
                              alignLabelWithHint: true,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Seção: Insumo Aplicado ──
                          _buildSecao('Insumo Aplicado (opcional)'),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _insumoController,
                                  decoration: const InputDecoration(
                                    labelText: 'Insumo Utilizado',
                                    hintText: 'Ex: Actara 250 WG',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.shopping_bag),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _doseController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.,]')),
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Dose',
                                    hintText: '0.0',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.science),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _unidadeDoseController,
                                  decoration: const InputDecoration(
                                    labelText: 'Unidade',
                                    hintText: 'kg/ha',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.straighten),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Seção: Responsável e Observações ──
                          _buildSecao('Responsável e Observações'),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _responsavelController,
                            decoration: const InputDecoration(
                              labelText: 'Responsável',
                              hintText: 'Nome do técnico ou responsável',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _observacoesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Observações',
                              hintText:
                                  'Detalhes adicionais sobre o monitoramento...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.notes),
                              alignLabelWithHint: true,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ── Botão Salvar ──
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _salvando ? null : _salvar,
                              icon: _salvando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(
                                _salvando
                                    ? 'Salvando...'
                                    : widget.isEdicao
                                        ? 'Atualizar Registro'
                                        : 'Salvar Registro',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.newPrimary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSecao(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  Future<void> _selecionarData() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _dataMonitoramento,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('pt', 'BR'),
    );
    if (selecionada != null) {
      setState(() => _dataMonitoramento = selecionada);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final m = MonitoramentoPraga(
        id: widget.monitoramento?.id ?? '',
        talhaoId: _talhaoId!,
        safraId: _safraId,
        praga: _praga!,
        nivelInfestacao: _nivelInfestacao,
        dataMonitoramento: _dataMonitoramento,
        areaAfetadaHa: _areaAfetadaController.text.trim().isNotEmpty
            ? double.tryParse(
                _areaAfetadaController.text.replaceAll(',', '.'))
            : null,
        metodoAvaliacao: _metodoAvaliacao,
        acaoRecomendada: _acaoRecomendadaController.text.trim().isEmpty
            ? null
            : _acaoRecomendadaController.text.trim(),
        acaoRealizada: _acaoRealizadaController.text.trim().isEmpty
            ? null
            : _acaoRealizadaController.text.trim(),
        insumoUtilizado: _insumoController.text.trim().isEmpty
            ? null
            : _insumoController.text.trim(),
        doseAplicada: _doseController.text.trim().isNotEmpty
            ? double.tryParse(_doseController.text.replaceAll(',', '.'))
            : null,
        unidadeDose: _unidadeDoseController.text.trim().isEmpty
            ? null
            : _unidadeDoseController.text.trim(),
        responsavel: _responsavelController.text.trim().isEmpty
            ? null
            : _responsavelController.text.trim(),
        observacoes: _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
      );

      if (widget.isEdicao) {
        await _service.atualizarMonitoramento(m);
      } else {
        await _service.salvarMonitoramento(m);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEdicao
                ? 'Monitoramento atualizado com sucesso!'
                : 'Monitoramento registrado com sucesso!'),
            backgroundColor: AppColors.newPrimary,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _salvando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.newDanger,
          ),
        );
      }
    }
  }
}
