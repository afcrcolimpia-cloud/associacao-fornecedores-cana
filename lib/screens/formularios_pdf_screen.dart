import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import 'package:printing/printing.dart';
import '../services/pdf_generators/pdf_sphenophorus.dart';
import '../services/pdf_generators/pdf_broca_infestacao.dart';
import '../services/pdf_generators/pdf_broca_cigarrinha.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../services/talhao_service.dart';
import '../services/proprietario_service.dart';
import '../services/anexo_service.dart';

class FormulariosPdfScreen extends StatefulWidget {
  final ContextoPropriedade? contexto;
  final String? propriedadeId;
  final Propriedade? propriedade;

  const FormulariosPdfScreen({
    this.contexto,
    this.propriedadeId,
    this.propriedade,
    super.key,
  });

  @override
  State<FormulariosPdfScreen> createState() => _FormulariosPdfScreenState();
}

class _FormulariosPdfScreenState extends State<FormulariosPdfScreen> {
  int _tipoFormulario = -1; // -1: Seleção, 0: Sphenophorus, 1: Broca, 2: Broca+Cigarrinha
  
  late Propriedade _propriedade;
  late List<Talhao> _talhoes = [];
  late Proprietario? _proprietario;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Se contexto foi fornecido, usar dados dele diretamente
      if (widget.contexto != null) {
        _propriedade = widget.contexto!.propriedade;
        _proprietario = widget.contexto!.proprietario;
        
        final talhaoService = TalhaoService();
        _talhoes = await talhaoService
            .getTalhoesByPropriedadeStream(_propriedade.id)
            .first;
      } else {
        // Caso contrário, carregar manualmente
        final propriedadeService = PropriedadeService();
        final talhaoService = TalhaoService();
        final proprietarioService = ProprietarioService();

        // Buscar propriedade
        _propriedade = widget.propriedade ??
            (await propriedadeService.getPropriedadeById(widget.propriedadeId!))!;

        // Buscar talhões
        _talhoes = await talhaoService
            .getTalhoesByPropriedadeStream(_propriedade.id)
            .first;

        // Buscar proprietário
        _proprietario =
            await proprietarioService.getProprietario(_propriedade.proprietarioId);
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: AppBarAfcrc(title: 'Relatórios de Pragas'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const AppBarAfcrc(title: 'Relatórios de Pragas'),
      body: _tipoFormulario == -1 ? _buildSelectorPage() : _buildFormulario(),
    );
  }

  Widget _buildSelectorPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecione o Tipo de Relatório',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          // Card Sphenophorus
          _buildRelatorioCard(
            titulo: 'Sphenophorus',
            descricao: 'Bicudo da Cana',
            icone: Icons.pest_control,
            cor: Colors.brown,
            onTap: () => setState(() => _tipoFormulario = 0),
          ),
          const SizedBox(height: 16),
          // Card Broca
          _buildRelatorioCard(
            titulo: 'Broca',
            descricao: 'Diatraea saccharalis',
            icone: Icons.bug_report,
            cor: Colors.orange[600]!,
            onTap: () => setState(() => _tipoFormulario = 1),
          ),
          const SizedBox(height: 16),
          // Card Broca + Cigarrinha
          _buildRelatorioCard(
            titulo: 'Broca + Cigarrinha',
            descricao: 'Mahanarva fimbriolata',
            icone: Icons.grass,
            cor: Colors.green[600]!,
            onTap: () => setState(() => _tipoFormulario = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatorioCard({
    required String titulo,
    required String descricao,
    required IconData icone,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [cor.withOpacity(0.1), cor.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icone,
                  size: 48,
                  color: cor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: cor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              switch (_tipoFormulario) {
                0 => SphenophorusForm(
                    propriedadeId: _propriedade.id,
                    propriedade: _propriedade,
                    talhoes: _talhoes,
                    proprietario: _proprietario,
                  ),
                1 => BrocaForm(
                    propriedadeId: _propriedade.id,
                    propriedade: _propriedade,
                    talhoes: _talhoes,
                    proprietario: _proprietario,
                  ),
                2 => BrocaCigarrinhaForm(
                    propriedadeId: _propriedade.id,
                    propriedade: _propriedade,
                    talhoes: _talhoes,
                    proprietario: _proprietario,
                  ),
                _ => const SizedBox.shrink(),
              },
              const SizedBox(height: 20),
            ],
          ),
        ),
        // Botão voltar no topo
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: () => setState(() => _tipoFormulario = -1),
            tooltip: 'Voltar',
            child: const Icon(Icons.arrow_back),
          ),
        ),
      ],
    );
  }
}

// --------------------------------- SPHENOPHORUS FORM ---------------------------------
class SphenophorusForm extends StatefulWidget {
  final String propriedadeId;
  final Propriedade propriedade;
  final Proprietario? proprietario;
  final List<Talhao> talhoes;

  const SphenophorusForm({
    required this.propriedadeId,
    required this.propriedade,
    required this.proprietario,
    required this.talhoes,
    super.key,
  });

  @override
  State<SphenophorusForm> createState() => _SphenophorusFormState();
}

class _SphenophorusFormState extends State<SphenophorusForm> {
  late TextEditingController _fornecedorCtrl, _idCtrl, _propriedadeCtrl, _faCtrl, _dataCtrl, _tecnicoCtrl, _observacaoCtrl;
  late List<TextEditingController> _pontosCtrl, _larvaCtrl, _pupaCtrl, _adultoCtrl, _tocosAtacadosCtrl, _tocosSadiosCtrl;

  @override
  void initState() {
    super.initState();
    _fornecedorCtrl = TextEditingController(text: widget.proprietario?.nome ?? '');
    _idCtrl = TextEditingController(text: widget.propriedade.numeroFA);
    _propriedadeCtrl = TextEditingController(text: widget.propriedade.nomePropriedade);
    _faCtrl = TextEditingController(text: widget.propriedade.numeroFA);
    _dataCtrl = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
    _tecnicoCtrl = TextEditingController();
    _observacaoCtrl = TextEditingController();
    
    // Criar 16 controladores para possibilitar até 16 linhas de talhões
    _pontosCtrl = List.generate(16, (_) => TextEditingController());
    _larvaCtrl = List.generate(16, (_) => TextEditingController());
    _pupaCtrl = List.generate(16, (_) => TextEditingController());
    _adultoCtrl = List.generate(16, (_) => TextEditingController());
    _tocosAtacadosCtrl = List.generate(16, (_) => TextEditingController());
    _tocosSadiosCtrl = List.generate(16, (_) => TextEditingController());
  }

  @override
  void dispose() {
    _fornecedorCtrl.dispose();
    _idCtrl.dispose();
    _propriedadeCtrl.dispose();
    _faCtrl.dispose();
    _dataCtrl.dispose();
    _tecnicoCtrl.dispose();
    _observacaoCtrl.dispose();
    
    for (var ctrl in _pontosCtrl) { ctrl.dispose(); }
    for (var ctrl in _larvaCtrl) { ctrl.dispose(); }
    for (var ctrl in _pupaCtrl) { ctrl.dispose(); }
    for (var ctrl in _adultoCtrl) { ctrl.dispose(); }
    for (var ctrl in _tocosAtacadosCtrl) { ctrl.dispose(); }
    for (var ctrl in _tocosSadiosCtrl) { ctrl.dispose(); }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho
        Text(
          'Relatório de Sphenophorus (Bicudo da Cana)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 24),
        
        // Seção de identificação
        _buildCardSection(
          title: 'Identificação',
          child: Column(
            children: [
              _buildTextField('F.A. (Ficha de Acompanhamento) *', _faCtrl),
              const SizedBox(height: 12),
              _buildTextField('Fornecedor', _fornecedorCtrl),
              const SizedBox(height: 12),
              _buildTextField('ID (Número ID)', _idCtrl),
              const SizedBox(height: 12),
              _buildTextField('Propriedade', _propriedadeCtrl),
              const SizedBox(height: 12),
              _buildTextField('Data (dd/mm/aaaa)', _dataCtrl),
              const SizedBox(height: 12),
              _buildTextField('Técnico(s)', _tecnicoCtrl),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Tabela de dados
        _buildCardSection(
          title: 'Dados de Avaliação (Talhão - Até 16 linhas)',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 8,
              columns: [
                DataColumn(label: Text('TALHÃO', style: _tableHeaderStyle())),
                DataColumn(label: Text('PONTOS', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('LARVA', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('PUPA', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('ADULTO', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('TOCOS ATACADOS', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('TOCOS SADIOS', style: _tableHeaderStyle()), numeric: true),
              ],
              rows: List.generate(16, (index) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 80,
                        child: _buildSmallTextField(_pontosCtrl[index], hint: 'Talhão ${index + 1}'),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 70,
                        child: _buildSmallTextField(_pontosCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 70,
                        child: _buildSmallTextField(_larvaCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 70,
                        child: _buildSmallTextField(_pupaCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 70,
                        child: _buildSmallTextField(_adultoCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 80,
                        child: _buildSmallTextField(_tocosAtacadosCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 80,
                        child: _buildSmallTextField(_tocosSadiosCtrl[index]),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Observação
        _buildCardSection(
          title: 'Observação',
          child: _buildTextField('OBSERVAÇÃO', _observacaoCtrl, maxLines: 3),
        ),
        
        const SizedBox(height: 24),
        
        // Botões de ação
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _gerarPdfSphenophorus,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Gerar PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.brown,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _salvarComoAnexoSphenophorus,
                icon: const Icon(Icons.save_alt),
                label: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<SphenophorusData?> _coletarDadosSphenophorus() async {
    if (_faCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('F.A. é obrigatório'), backgroundColor: Colors.red),
      );
      return null;
    }

    final linhas = <SphenophorusLinha>[];
    for (int i = 0; i < widget.talhoes.length; i++) {
      if (_pontosCtrl[i].text.isNotEmpty) {
        linhas.add(SphenophorusLinha(
          talhao: _pontosCtrl[i].text,
          pontos: int.tryParse(_pontosCtrl[i].text) ?? 0,
          larva: int.tryParse(_larvaCtrl[i].text) ?? 0,
          pupa: int.tryParse(_pupaCtrl[i].text) ?? 0,
          adulto: int.tryParse(_adultoCtrl[i].text) ?? 0,
          tocosAtacados: int.tryParse(_tocosAtacadosCtrl[i].text) ?? 0,
          tocosSadios: int.tryParse(_tocosSadiosCtrl[i].text) ?? 0,
        ));
      }
    }

    if (linhas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha pelo menos um talhão'), backgroundColor: Colors.orange),
      );
      return null;
    }

    return SphenophorusData(
      fornecedor: _fornecedorCtrl.text.isEmpty ? 'N/A' : _fornecedorCtrl.text,
      id: _idCtrl.text.isEmpty ? 'N/A' : _idCtrl.text,
      propriedade: _propriedadeCtrl.text.isEmpty ? 'N/A' : _propriedadeCtrl.text,
      fa: _faCtrl.text,
      data: _dataCtrl.text,
      tecnico: _tecnicoCtrl.text.isEmpty ? 'N/A' : _tecnicoCtrl.text,
      linhas: linhas,
      observacao: _observacaoCtrl.text,
    );
  }

  Future<void> _gerarPdfSphenophorus() async {
    final dados = await _coletarDadosSphenophorus();
    if (dados == null) return;

    final bytes = await PdfSphenophorus.gerar(dados);
    if (mounted) {
      await Printing.layoutPdf(onLayout: (_) => bytes);
    }
  }

  Future<void> _salvarComoAnexoSphenophorus() async {
    final dados = await _coletarDadosSphenophorus();
    if (dados == null) return;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salvando relatério...'), duration: Duration(seconds: 2)),
        );
      }

      final bytes = await PdfSphenophorus.gerar(dados);
      final nomeArquivo = 'Sphenophorus_${dados.fa}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final anexoService = AnexoService();
      await anexoService.uploadAnexo(
        propriedadeId: widget.propriedadeId,
        nomeArquivo: nomeArquivo,
        bytes: bytes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  TextStyle _tableHeaderStyle() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.white,
    );
  }

  Widget _buildCardSection({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      minLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildSmallTextField(TextEditingController ctrl, {String? hint}) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
    );
  }
}

// --------------------------------- BROCA FORM ---------------------------------
class BrocaForm extends StatefulWidget {
  final String propriedadeId;
  final Propriedade propriedade;
  final Proprietario? proprietario;
  final List<Talhao> talhoes;

  const BrocaForm({
    required this.propriedadeId,
    required this.propriedade,
    required this.proprietario,
    required this.talhoes,
    super.key,
  });

  @override
  State<BrocaForm> createState() => _BrocaFormState();
}

class _BrocaFormState extends State<BrocaForm> {
  late TextEditingController _nomeCtrl, _dataCtrl, _faCtrl, _propriedadeCtrl, _variedadeCtrl, _nCorteCtrl, _talhaoCtrl, _nAvaliacaoCtrl, _blocoCtrl, _tecnicoCtrl;
  bool _avaliacaoFinal = true;
  late List<TextEditingController> _canaCtrl, _totalCtrl, _brocadosCtrl;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.proprietario?.nome ?? '');
    _dataCtrl = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
    _faCtrl = TextEditingController(text: widget.propriedade.numeroFA);
    _propriedadeCtrl = TextEditingController(text: widget.propriedade.nomePropriedade);
    _variedadeCtrl = TextEditingController();
    _nCorteCtrl = TextEditingController();
    _talhaoCtrl = TextEditingController();
    _nAvaliacaoCtrl = TextEditingController();
    _blocoCtrl = TextEditingController();
    _tecnicoCtrl = TextEditingController();
    
    // Criar 20 controladores para possibilitar até 20 linhas de cana
    _canaCtrl = List.generate(20, (_) => TextEditingController());
    _totalCtrl = List.generate(20, (_) => TextEditingController());
    _brocadosCtrl = List.generate(20, (_) => TextEditingController());
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _dataCtrl.dispose();
    _faCtrl.dispose();
    _propriedadeCtrl.dispose();
    _variedadeCtrl.dispose();
    _nCorteCtrl.dispose();
    _talhaoCtrl.dispose();
    _nAvaliacaoCtrl.dispose();
    _blocoCtrl.dispose();
    _tecnicoCtrl.dispose();
    
    for (var ctrl in _canaCtrl) { ctrl.dispose(); }
    for (var ctrl in _totalCtrl) { ctrl.dispose(); }
    for (var ctrl in _brocadosCtrl) { ctrl.dispose(); }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho
        Text(
          'Índice de Intensidade de Infestação - Broca',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.orange[700],
          ),
        ),
        const SizedBox(height: 24),
        
        // Seção de identificação
        _buildCardSection(
          title: 'Identificação da Avaliação',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildTextField('Nome', _nomeCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Data (dd/mm/aaaa)', _dataCtrl)),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField('Propriedade', _propriedadeCtrl),
              const SizedBox(height: 12),
              _buildTextField('Variedade (ex: CV-7870)', _variedadeCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField('F.A.', _faCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Nº de Corte (ex: 3º)', _nCorteCtrl)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField('Talhão', _talhaoCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Nº Avaliação', _nAvaliacaoCtrl)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField('Bloco', _blocoCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Técnico(s)', _tecnicoCtrl)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Avaliação Final'),
                      value: _avaliacaoFinal,
                      onChanged: (v) => setState(() => _avaliacaoFinal = v ?? true),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Avaliação Parcial'),
                      value: !_avaliacaoFinal,
                      onChanged: (v) => setState(() => _avaliacaoFinal = !(v ?? false)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Tabela de análise
        _buildCardSection(
          title: 'Análise por Cana (Até 20 linhas)',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              columns: [
                DataColumn(label: Text('CANA', style: _tableHeaderStyle())),
                DataColumn(label: Text('ENTRENÓS TOTAIS', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('ENTRENÓS BROCADOS', style: _tableHeaderStyle()), numeric: true),
              ],
              rows: List.generate(20, (index) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 60,
                        child: _buildSmallTextField(_canaCtrl[index], hint: '${index + 1}'),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: _buildSmallTextField(_totalCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 140,
                        child: _buildSmallTextField(_brocadosCtrl[index]),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Nível de infestação calculado
        _buildCardSection(
          title: 'Nível de Infestação Calculado',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _calcularNivelInfestacao(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _obterCorNivel(),
                ),
              ),
              const SizedBox(height: 16),
              _buildLegendaNiveis(),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Botões de ação
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _gerarPdfBroca,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Gerar PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange[700],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _salvarComoAnexoBroca,
                icon: const Icon(Icons.save_alt),
                label: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _calcularNivelInfestacao() {
    int totalEntrenoses = 0;
    int totalBrocados = 0;
    
    for (int i = 0; i < widget.talhoes.length; i++) {
      final total = int.tryParse(_totalCtrl[i].text) ?? 0;
      final brocados = int.tryParse(_brocadosCtrl[i].text) ?? 0;
      totalEntrenoses += total;
      totalBrocados += brocados;
    }
    
    if (totalEntrenoses == 0) {
      return 'Preencha os dados para calcular';
    }
    
    final percentual = (totalBrocados / totalEntrenoses) * 100;
    return 'NÍVEL DE INFESTAÇÃO: ${percentual.toStringAsFixed(2)}%';
  }

  Color _obterCorNivel() {
    int totalEntrenoses = 0;
    int totalBrocados = 0;
    
    for (int i = 0; i < widget.talhoes.length; i++) {
      final total = int.tryParse(_totalCtrl[i].text) ?? 0;
      final brocados = int.tryParse(_brocadosCtrl[i].text) ?? 0;
      totalEntrenoses += total;
      totalBrocados += brocados;
    }
    
    if (totalEntrenoses == 0) return Colors.grey;
    
    final percentual = (totalBrocados / totalEntrenoses) * 100;
    
    if (percentual <= 1.0) return Colors.green;
    if (percentual <= 3.0) return Colors.yellow[700]!;
    if (percentual <= 6.0) return Colors.orange;
    if (percentual <= 9.0) return Colors.red;
    return Colors.black;
  }

  Widget _buildLegendaNiveis() {
    final niveis = [
      ('ACEITÁVEL', '= 1,0%', Colors.green),
      ('BAIXO', '1,1% até 3%', Colors.yellow[700]!),
      ('MÉDIO', '3,1% até 6%', Colors.orange),
      ('ALTO', '6,1% até 9%', Colors.red),
      ('INACEITÁVEL', '> 9%', Colors.black),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legenda de Níveis:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...niveis.map((nivel) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: nivel.$3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${nivel.$1}: ${nivel.$2}'),
              ],
            ),
          );
        }),
      ],
    );
  }

  TextStyle _tableHeaderStyle() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 11,
      color: Colors.white,
    );
  }

  Widget _buildCardSection({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      minLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildSmallTextField(TextEditingController ctrl, {String? hint}) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
    );
  }

  Future<BrocaData?> _coletarDadosBroca() async {
    if (_faCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('F.A. é obrigatório'), backgroundColor: Colors.red),
      );
      return null;
    }

    return BrocaData(
      nome: _nomeCtrl.text.isEmpty ? 'N/A' : _nomeCtrl.text,
      propriedade: _propriedadeCtrl.text.isEmpty ? 'N/A' : _propriedadeCtrl.text,
      fa: _faCtrl.text,
      talhao: _talhaoCtrl.text.isEmpty ? 'N/A' : _talhaoCtrl.text,
      bloco: _blocoCtrl.text,
      data: _dataCtrl.text,
      variedade: _variedadeCtrl.text.isEmpty ? 'N/A' : _variedadeCtrl.text,
      nCorte: _nCorteCtrl.text.isEmpty ? 'N/A' : _nCorteCtrl.text,
      nAvaliacao: _nAvaliacaoCtrl.text,
      tecnico: _tecnicoCtrl.text.isEmpty ? 'N/A' : _tecnicoCtrl.text,
      avaliacaoFinal: _avaliacaoFinal,
      linhas: [],
    );
  }

  Future<void> _gerarPdfBroca() async {
    final dados = await _coletarDadosBroca();
    if (dados == null) return;

    final bytes = await PdfBroca.gerar(dados);
    if (mounted) {
      await Printing.layoutPdf(onLayout: (_) => bytes);
    }
  }

  Future<void> _salvarComoAnexoBroca() async {
    final dados = await _coletarDadosBroca();
    if (dados == null) return;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salvando relatério...'), duration: Duration(seconds: 2)),
        );
      }

      final bytes = await PdfBroca.gerar(dados);
      final nomeArquivo = 'Broca_${dados.fa}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final anexoService = AnexoService();
      await anexoService.uploadAnexo(
        propriedadeId: widget.propriedadeId,
        nomeArquivo: nomeArquivo,
        bytes: bytes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// --------------------------------- BROCA+CIGARRINHA FORM ---------------------------------
class BrocaCigarrinhaForm extends StatefulWidget {
  final String propriedadeId;
  final Propriedade propriedade;
  final Proprietario? proprietario;
  final List<Talhao> talhoes;

  const BrocaCigarrinhaForm({
    required this.propriedadeId,
    required this.propriedade,
    required this.proprietario,
    required this.talhoes,
    super.key,
  });

  @override
  State<BrocaCigarrinhaForm> createState() => _BrocaCigarrinhaFormState();
}

class _BrocaCigarrinhaFormState extends State<BrocaCigarrinhaForm> {
  late TextEditingController _dataCtrl, _faCtrl, _nomeCtrl, _propriedadeCtrl, _avaliacoesCtrl, _tecnicoCtrl;
  late List<TextEditingController> _talhaoCtrl, _pontosCigarrinhaCtrl, _espumaCtrl, _ninfaCtrl, _nmdCtrl;
  late List<TextEditingController> _pontosBrocaCtrl, _entrenosBrocadosCtrl, _danoCtrl, _larvaForaCtrl, _larvaDetroCtrl, _obsCtrl;

  @override
  void initState() {
    super.initState();
    _dataCtrl = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
    _faCtrl = TextEditingController(text: widget.propriedade.numeroFA);
    _nomeCtrl = TextEditingController(text: widget.proprietario?.nome ?? '');
    _propriedadeCtrl = TextEditingController(text: widget.propriedade.nomePropriedade);
    _avaliacoesCtrl = TextEditingController();
    _tecnicoCtrl = TextEditingController();
    
    // Criar 12 controladores para possibilitar até 12 linhas de talhões
    _talhaoCtrl = List.generate(12, (_) => TextEditingController());
    _pontosCigarrinhaCtrl = List.generate(12, (_) => TextEditingController());
    _espumaCtrl = List.generate(12, (_) => TextEditingController());
    _ninfaCtrl = List.generate(12, (_) => TextEditingController());
    _nmdCtrl = List.generate(12, (_) => TextEditingController());
    
    _pontosBrocaCtrl = List.generate(12, (_) => TextEditingController());
    _entrenosBrocadosCtrl = List.generate(12, (_) => TextEditingController());
    _danoCtrl = List.generate(12, (_) => TextEditingController());
    _larvaForaCtrl = List.generate(12, (_) => TextEditingController());
    _larvaDetroCtrl = List.generate(12, (_) => TextEditingController());
    _obsCtrl = List.generate(12, (_) => TextEditingController());
  }

  @override
  void dispose() {
    _dataCtrl.dispose();
    _faCtrl.dispose();
    _nomeCtrl.dispose();
    _propriedadeCtrl.dispose();
    _avaliacoesCtrl.dispose();
    _tecnicoCtrl.dispose();
    
    for (var ctrl in _talhaoCtrl) { ctrl.dispose(); }
    for (var ctrl in _pontosCigarrinhaCtrl) { ctrl.dispose(); }
    for (var ctrl in _espumaCtrl) { ctrl.dispose(); }
    for (var ctrl in _ninfaCtrl) { ctrl.dispose(); }
    for (var ctrl in _nmdCtrl) { ctrl.dispose(); }
    for (var ctrl in _pontosBrocaCtrl) { ctrl.dispose(); }
    for (var ctrl in _entrenosBrocadosCtrl) { ctrl.dispose(); }
    for (var ctrl in _danoCtrl) { ctrl.dispose(); }
    for (var ctrl in _larvaForaCtrl) { ctrl.dispose(); }
    for (var ctrl in _larvaDetroCtrl) { ctrl.dispose(); }
    for (var ctrl in _obsCtrl) { ctrl.dispose(); }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho
        Text(
          'Relatório de Broca e Cigarrinha',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 24),
        
        // Seção de identificação
        _buildCardSection(
          title: 'Identificação da Avaliação',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildTextField('Data (dd/mm/aaaa)', _dataCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('F.A.', _faCtrl)),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField('Nome do Fornecedor', _nomeCtrl),
              const SizedBox(height: 12),
              _buildTextField('Propriedade', _propriedadeCtrl),
              const SizedBox(height: 12),
              _buildTextField('Técnico(s)', _tecnicoCtrl),
              const SizedBox(height: 12),
              _buildTextField('Avaliações', _avaliacoesCtrl),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Tabela combinada
        _buildCardSection(
          title: 'Avaliação de Broca e Cigarrinha (Até 12 pontos)',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 8,
              dataRowHeight: 50,
              columns: [
                DataColumn(label: Text('Talhão', style: _tableHeaderStyle())),
                // Grupo Cigarrinha
                DataColumn(label: Text('Pts', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('Espuma', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('Ninfa', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('n/m', style: _tableHeaderStyle()), numeric: true),
                // Grupo Broca
                DataColumn(label: Text('Pts', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('Entrenós', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('Dano', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('L. Fora', style: _tableHeaderStyle()), numeric: true),
                DataColumn(label: Text('L. Dentro', style: _tableHeaderStyle()), numeric: true),
                // Observações
                DataColumn(label: Text('Observações (ID)', style: _tableHeaderStyle())),
              ],
              rows: List.generate(12, (index) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 50,
                        child: _buildSmallTextField(_talhaoCtrl[index]),
                      ),
                    ),
                    // Cigarrinha
                    DataCell(
                      SizedBox(
                        width: 40,
                        child: _buildSmallTextField(_pontosCigarrinhaCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 50,
                        child: _buildSmallTextField(_espumaCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 50,
                        child: _buildSmallTextField(_ninfaCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 50,
                        child: _buildSmallTextField(_nmdCtrl[index]),
                      ),
                    ),
                    // Broca
                    DataCell(
                      SizedBox(
                        width: 40,
                        child: _buildSmallTextField(_pontosBrocaCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 60,
                        child: _buildSmallTextField(_entrenosBrocadosCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 50,
                        child: _buildSmallTextField(_danoCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 60,
                        child: _buildSmallTextField(_larvaForaCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 70,
                        child: _buildSmallTextField(_larvaDetroCtrl[index]),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: _buildSmallTextField(_obsCtrl[index], hint: '1 Pts 5M...'),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Informação de controle
        _buildCardSection(
          title: 'Nível de Controle',
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[700]!, width: 2),
            ),
            child: Text(
              'NÍVEL DE CONTROLE - 2 NINFAS POR METRO (n/m)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange[900],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Botões de ação
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _gerarPdfBrocaCigarrinha,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Gerar PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green[700],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _salvarComoAnexoBrocaCigarrinha,
                icon: const Icon(Icons.save_alt),
                label: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  TextStyle _tableHeaderStyle() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
      color: Colors.white,
    );
  }

  Widget _buildCardSection({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      minLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildSmallTextField(TextEditingController ctrl, {String? hint}) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        isDense: true,
      ),
      keyboardType: TextInputType.text,
      textAlign: TextAlign.center,
    );
  }

  Future<BrocaCigarrinhaData?> _coletarDadosBrocaCigarrinha() async {
    if (_faCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('F.A. é obrigatório'), backgroundColor: Colors.red),
      );
      return null;
    }

    return BrocaCigarrinhaData(
      nome: _nomeCtrl.text.isEmpty ? 'N/A' : _nomeCtrl.text,
      propriedade: _propriedadeCtrl.text.isEmpty ? 'N/A' : _propriedadeCtrl.text,
      fa: _faCtrl.text,
      id: '', // Será preenchido automaticamente
      data: _dataCtrl.text,
      tecnico: _tecnicoCtrl.text.isEmpty ? 'N/A' : _tecnicoCtrl.text,
      linhas: [],
    );
  }

  Future<void> _gerarPdfBrocaCigarrinha() async {
    final dados = await _coletarDadosBrocaCigarrinha();
    if (dados == null) return;

    final bytes = await PdfBrocaCigarrinha.gerar(dados);
    if (mounted) {
      await Printing.layoutPdf(onLayout: (_) => bytes);
    }
  }

  Future<void> _salvarComoAnexoBrocaCigarrinha() async {
    final dados = await _coletarDadosBrocaCigarrinha();
    if (dados == null) return;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salvando relatério...'), duration: Duration(seconds: 2)),
        );
      }

      final bytes = await PdfBrocaCigarrinha.gerar(dados);
      final nomeArquivo = 'BrocaCigarrinha_${dados.fa}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final anexoService = AnexoService();
      await anexoService.uploadAnexo(
        propriedadeId: widget.propriedadeId,
        nomeArquivo: nomeArquivo,
        bytes: bytes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
