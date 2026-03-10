import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../widgets/kpi_card.dart';
import '../constants/app_colors.dart';
import '../services/operacao_cultivo_service.dart';
import '../services/talhao_service.dart';
import '../services/pdf_generators/pdf_operacoes.dart';
import '../models/models.dart';

class OperacoesCultivoScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const OperacoesCultivoScreen({
    super.key,
    required this.contexto,
  });

  @override
  State<OperacoesCultivoScreen> createState() => _OperacoesCultivoScreenState();
}

class _OperacoesCultivoScreenState extends State<OperacoesCultivoScreen> {
  List<OperacaoCultivo> _operacoes = [];
  List<Talhao> _talhoes = [];

  bool _loadingOperacoes = true;
  int _selectedNavigationIndex = 0;
  bool _loadingTalhoes = true;

  String? _talhaoSelecionado;

  DateTime? _dataPlantio;
  DateTime? _dataQuebraLombo;
  DateTime? _dataColheita;
  DateTime? _data1aAplic;
  DateTime? _data2aAplic;

  final TextEditingController _observacoesController = TextEditingController();

  final OperacaoCultivoService _serviceOperacoes = OperacaoCultivoService();
  final TalhaoService _serviceTalhoes = TalhaoService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadTalhoes(),
      _loadOperacoes(),
    ]);
  }

  Future<void> _loadTalhoes() async {
    try {
      if (!mounted) return;
      setState(() => _loadingTalhoes = true);

      final talhoes = await _serviceTalhoes.getTalhoesPorPropriedade(widget.contexto.propriedade.id);

      if (mounted) {
        setState(() {
          _talhoes = talhoes;
          _talhaoSelecionado = null;
          _loadingTalhoes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingTalhoes = false);
      }
    }
  }

  Future<void> _loadOperacoes() async {
    try {
      if (!mounted) return;
      setState(() => _loadingOperacoes = true);

      final operacoes = await _serviceOperacoes.getOperacoesPorPropriedade(widget.contexto.propriedade.id).first;

      if (mounted) {
        setState(() {
          _operacoes = operacoes;
          _loadingOperacoes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingOperacoes = false);
      }
    }
  }

  Future<void> _salvarOperacao() async {
    if (_talhaoSelecionado == null || _dataPlantio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios')),
      );
      return;
    }

    try {
      final operacao = OperacaoCultivo(
        propriedadeId: widget.contexto.propriedade.id,
        talhaoId: _talhaoSelecionado!,
        dataPlantio: _dataPlantio!,
        dataQuebraLombo: _dataQuebraLombo,
        dataColheita: _dataColheita,
        data1aAplicHerbicida: _data1aAplic,
        data2aAplicHerbicida: _data2aAplic,
        observacoes: _observacoesController.text.isNotEmpty ? _observacoesController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _serviceOperacoes.createOperacao(operacao);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operação salva com sucesso')),
        );
        _limparFormulario();
        _loadOperacoes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar operação: $e')),
        );
      }
    }
  }

  void _limparFormulario() {
    setState(() {
      _dataPlantio = null;
      _dataQuebraLombo = null;
      _dataColheita = null;
      _data1aAplic = null;
      _data2aAplic = null;
      _observacoesController.clear();
      _talhaoSelecionado = null;
    });
  }

  Future<void> _selecionarData(BuildContext context, Function(DateTime) onDateSelected) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.newPrimary,
              onPrimary: AppColors.bgDark,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.newTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (selected != null) {
      onDateSelected(selected);
    }
  }

  int _getTotalOperacoes() => _operacoes.length;

  int _getOperacoesAtuais() => _operacoes.where((op) => op.dataColheita == null).length;

  String _getUltimaOperacao() {
    if (_operacoes.isEmpty) return 'N/A';
    return '${_operacoes.first.dataPlantio.day}/${_operacoes.first.dataPlantio.month}/${_operacoes.first.dataPlantio.year}';
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      title: 'Operações de Cultivo',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderPropriedade(contexto: widget.contexto),
            const SizedBox(height: 24),
            // Títulos
            Text(
              'Operações de Cultivo',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.newTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Registre e acompanhe todas as operações realizar nos talhões',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.newTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),

            // KPI Cards Grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                KpiCard(
                  label: 'Total de Operações',
                  value: '${_getTotalOperacoes()}',
                  icon: Icons.agriculture_outlined,
                  iconColor: AppColors.newSuccess,
                ),
                KpiCard(
                  label: 'Em Progresso',
                  value: '${_getOperacoesAtuais()}',
                  icon: Icons.hourglass_bottom_outlined,
                  iconColor: AppColors.newWarning,
                ),
                KpiCard(
                  label: 'Última Plantio',
                  value: _getUltimaOperacao(),
                  icon: Icons.calendar_today_outlined,
                  iconColor: AppColors.newInfo,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Formulário de Nova Operação
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border.all(
                  color: AppColors.borderDark,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nova Operação',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.newTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seção: Identificação
                  Text(
                    'Identificação',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.newTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Propriedade
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Propriedade',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.newTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgDark,
                                      border: Border.all(
                                        color: AppColors.borderDark,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.contexto.nomePropriedade,
                                      style: GoogleFonts.inter(
                                        color: AppColors.newTextPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Talhão
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Talhão',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.newTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _loadingTalhoes
                                ? const SizedBox(
                                    height: 40,
                                    child: Center(child: CircularProgressIndicator()),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgDark,
                                      border: Border.all(
                                        color: AppColors.borderDark,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButton<String>(
                                      value: _talhaoSelecionado,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      onChanged: (value) {
                                        setState(() => _talhaoSelecionado = value);
                                      },
                                      dropdownColor: AppColors.surfaceDark,
                                      style: GoogleFonts.inter(
                                        color: AppColors.newTextPrimary,
                                        fontSize: 14,
                                      ),
                                      hint: Text(
                                        'Selecione um talhão',
                                        style: GoogleFonts.inter(
                                          color: AppColors.newTextSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      items: _talhoes
                                          .map((talhao) => DropdownMenuItem(
                                                value: talhao.id,
                                                child: Text(talhao.nome),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Data de Plantio
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data de Plantio',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.newTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selecionarData(context, (date) {
                                  setState(() => _dataPlantio = date);
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgDark,
                                    border: Border.all(
                                      color: AppColors.borderDark,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          color: AppColors.newTextSecondary, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _dataPlantio != null
                                              ? '${_dataPlantio!.day}/${_dataPlantio!.month}/${_dataPlantio!.year}'
                                              : 'Selecione',
                                          style: GoogleFonts.inter(
                                            color: _dataPlantio != null
                                                ? AppColors.newTextPrimary
                                                : AppColors.newTextSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Seção: Operação
                  Text(
                    'Operação',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.newTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quebra de Lombo',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.newTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selecionarData(context, (date) {
                                  setState(() => _dataQuebraLombo = date);
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgDark,
                                    border: Border.all(
                                      color: AppColors.borderDark,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          color: AppColors.newTextSecondary, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _dataQuebraLombo != null
                                              ? '${_dataQuebraLombo!.day}/${_dataQuebraLombo!.month}/${_dataQuebraLombo!.year}'
                                              : 'Opcional',
                                          style: GoogleFonts.inter(
                                            color: _dataQuebraLombo != null
                                                ? AppColors.newTextPrimary
                                                : AppColors.newTextSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data de Colheita',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.newTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selecionarData(context, (date) {
                                  setState(() => _dataColheita = date);
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgDark,
                                    border: Border.all(
                                      color: AppColors.borderDark,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          color: AppColors.newTextSecondary, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _dataColheita != null
                                              ? '${_dataColheita!.day}/${_dataColheita!.month}/${_dataColheita!.year}'
                                              : 'Opcional',
                                          style: GoogleFonts.inter(
                                            color: _dataColheita != null
                                                ? AppColors.newTextPrimary
                                                : AppColors.newTextSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Seção: Herbicidas
                  Text(
                    'Aplicações de Herbicida',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.newTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1ª Aplicação',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.newTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selecionarData(context, (date) {
                                  setState(() => _data1aAplic = date);
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgDark,
                                    border: Border.all(
                                      color: AppColors.borderDark,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          color: AppColors.newTextSecondary, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _data1aAplic != null
                                              ? '${_data1aAplic!.day}/${_data1aAplic!.month}/${_data1aAplic!.year}'
                                              : 'Opcional',
                                          style: GoogleFonts.inter(
                                            color: _data1aAplic != null
                                                ? AppColors.newTextPrimary
                                                : AppColors.newTextSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2ª Aplicação',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.newTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selecionarData(context, (date) {
                                  setState(() => _data2aAplic = date);
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgDark,
                                    border: Border.all(
                                      color: AppColors.borderDark,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          color: AppColors.newTextSecondary, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _data2aAplic != null
                                              ? '${_data2aAplic!.day}/${_data2aAplic!.month}/${_data2aAplic!.year}'
                                              : 'Opcional',
                                          style: GoogleFonts.inter(
                                            color: _data2aAplic != null
                                                ? AppColors.newTextPrimary
                                                : AppColors.newTextSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Observações
                  Text(
                    'Observações',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.newTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgDark,
                      border: Border.all(
                        color: AppColors.borderDark,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _observacoesController,
                      maxLines: 4,
                      style: GoogleFonts.inter(
                        color: AppColors.newTextPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Adicione observações sobre esta operação...',
                        hintStyle: GoogleFonts.inter(
                          color: AppColors.newTextSecondary,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botões de Ação
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Salvar'),
                        onPressed: _salvarOperacao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.newPrimary,
                          foregroundColor: AppColors.bgDark,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Gerar PDF'),
                        onPressed: () => _gerarPdfOperacoes(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.newWarning,
                          foregroundColor: AppColors.bgDark,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Histórico de Operações
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border.all(
                  color: AppColors.borderDark,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _loadingOperacoes
                  ? const Center(child: CircularProgressIndicator())
                  : _operacoes.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhuma operação registrada',
                            style: GoogleFonts.inter(
                              color: AppColors.newTextMuted,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Histórico de Operações',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.newTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 20,
                                dataRowColor: MaterialStateProperty.all(
                                  AppColors.bgDark,
                                ),
                                headingRowColor: MaterialStateProperty.all(
                                  AppColors.borderDark,
                                ),
                                columns: [
                                  DataColumn(
                                    label: Text(
                                      'Talhão',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newTextPrimary,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Data Plantio',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newTextPrimary,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Quebra Lombo',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newTextPrimary,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Colheita',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newTextPrimary,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Status',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newTextPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: _operacoes
                                    .map((op) => DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                op.talhaoId,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: AppColors.newTextPrimary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '${op.dataPlantio.day}/${op.dataPlantio.month}/${op.dataPlantio.year}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: AppColors.newTextPrimary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                op.dataQuebraLombo != null
                                                    ? '${op.dataQuebraLombo!.day}/${op.dataQuebraLombo!.month}/${op.dataQuebraLombo!.year}'
                                                    : '—',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: AppColors.newTextSecondary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                op.dataColheita != null
                                                    ? '${op.dataColheita!.day}/${op.dataColheita!.month}/${op.dataColheita!.year}'
                                                    : '—',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: AppColors.newTextSecondary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: op.dataColheita != null
                                                      ? AppColors.newSuccess.withOpacity(0.2)
                                                      : AppColors.newWarning.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  op.dataColheita != null ? 'Colhido' : 'Em Progresso',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: op.dataColheita != null
                                                        ? AppColors.newSuccess
                                                        : AppColors.newWarning,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _gerarPdfOperacoes() async {
    try {
      final pdfBytes = await PdfOperacoesCultivo.gerar(
        propriedade: widget.contexto.propriedade,
        operacoes: _operacoes,
      );
      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'Operacoes_Cultivo_${widget.contexto.nomePropriedade}.pdf',
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
