import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/analise_solo_service.dart';

class AnaliseSoloFormScreen extends StatefulWidget {
  final ContextoPropriedade contexto;
  final List<Talhao> talhoes;
  final AnaliseSolo? analise;

  const AnaliseSoloFormScreen({
    super.key,
    required this.contexto,
    required this.talhoes,
    this.analise,
  });

  @override
  State<AnaliseSoloFormScreen> createState() => _AnaliseSoloFormScreenState();
}

class _AnaliseSoloFormScreenState extends State<AnaliseSoloFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AnaliseSoloService _service = AnaliseSoloService();
  int _selectedNavigationIndex = 0;
  bool _salvando = false;

  bool get _editando => widget.analise != null;

  // Dados gerais
  String? _talhaoId;
  final _laboratorioController = TextEditingController();
  final _numeroAmostraController = TextEditingController();
  DateTime? _dataColeta;
  DateTime? _dataResultado;
  final _profundidadeController = TextEditingController();

  // Macronutrientes
  final _phController = TextEditingController();
  final _materiaOrganicaController = TextEditingController();
  final _fosforoController = TextEditingController();
  final _potassioController = TextEditingController();
  final _calcioController = TextEditingController();
  final _magnesioController = TextEditingController();
  final _enxofreController = TextEditingController();

  // Acidez e CTC
  final _acidezPotencialController = TextEditingController();
  final _aluminioController = TextEditingController();
  final _somasBasesController = TextEditingController();
  final _ctcController = TextEditingController();
  final _saturacaoBasesController = TextEditingController();

  // Micronutrientes
  final _boroController = TextEditingController();
  final _cobreController = TextEditingController();
  final _ferroController = TextEditingController();
  final _manganesController = TextEditingController();
  final _zincoController = TextEditingController();

  // Textura
  final _argilaController = TextEditingController();
  final _silteController = TextEditingController();
  final _areiaController = TextEditingController();

  final _observacoesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_editando) {
      _carregarDadosExistentes();
    }
  }

  void _carregarDadosExistentes() {
    final a = widget.analise!;
    _talhaoId = a.talhaoId;
    _laboratorioController.text = a.laboratorio ?? '';
    _numeroAmostraController.text = a.numeroAmostra ?? '';
    _dataColeta = a.dataColeta;
    _dataResultado = a.dataResultado;
    if (a.profundidadeCm != null) {
      _profundidadeController.text = a.profundidadeCm.toString();
    }

    _phController.text = a.ph?.toString() ?? '';
    _materiaOrganicaController.text = a.materiaOrganica?.toString() ?? '';
    _fosforoController.text = a.fosforo?.toString() ?? '';
    _potassioController.text = a.potassio?.toString() ?? '';
    _calcioController.text = a.calcio?.toString() ?? '';
    _magnesioController.text = a.magnesio?.toString() ?? '';
    _enxofreController.text = a.enxofre?.toString() ?? '';

    _acidezPotencialController.text = a.acidezPotencial?.toString() ?? '';
    _aluminioController.text = a.aluminio?.toString() ?? '';
    _somasBasesController.text = a.somasBases?.toString() ?? '';
    _ctcController.text = a.ctc?.toString() ?? '';
    _saturacaoBasesController.text = a.saturacaoBases?.toString() ?? '';

    _boroController.text = a.boro?.toString() ?? '';
    _cobreController.text = a.cobre?.toString() ?? '';
    _ferroController.text = a.ferro?.toString() ?? '';
    _manganesController.text = a.manganes?.toString() ?? '';
    _zincoController.text = a.zinco?.toString() ?? '';

    _argilaController.text = a.argila?.toString() ?? '';
    _silteController.text = a.silte?.toString() ?? '';
    _areiaController.text = a.areia?.toString() ?? '';

    _observacoesController.text = a.observacoes ?? '';
  }

  @override
  void dispose() {
    _laboratorioController.dispose();
    _numeroAmostraController.dispose();
    _profundidadeController.dispose();
    _phController.dispose();
    _materiaOrganicaController.dispose();
    _fosforoController.dispose();
    _potassioController.dispose();
    _calcioController.dispose();
    _magnesioController.dispose();
    _enxofreController.dispose();
    _acidezPotencialController.dispose();
    _aluminioController.dispose();
    _somasBasesController.dispose();
    _ctcController.dispose();
    _saturacaoBasesController.dispose();
    _boroController.dispose();
    _cobreController.dispose();
    _ferroController.dispose();
    _manganesController.dispose();
    _zincoController.dispose();
    _argilaController.dispose();
    _silteController.dispose();
    _areiaController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  double? _parseDouble(String text) {
    if (text.trim().isEmpty) return null;
    return double.tryParse(text.trim().replaceAll(',', '.'));
  }

  int? _parseInt(String text) {
    if (text.trim().isEmpty) return null;
    return int.tryParse(text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: _editando ? 'Editar Análise de Solo' : 'Nova Análise de Solo',
      child: Column(
        children: [
          HeaderPropriedade(contexto: widget.contexto),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSecaoDadosGerais(),
                    const SizedBox(height: 24),
                    _buildSecaoMacronutrientes(),
                    const SizedBox(height: 24),
                    _buildSecaoAcidezCTC(),
                    const SizedBox(height: 24),
                    _buildSecaoMicronutrientes(),
                    const SizedBox(height: 24),
                    _buildSecaoTextura(),
                    const SizedBox(height: 24),
                    _buildSecaoObservacoes(),
                    const SizedBox(height: 24),
                    _buildBotaoSalvar(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTituloSecao(String titulo, IconData icone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icone, size: 20, color: AppColors.newPrimary),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoDadosGerais() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao('Dados Gerais', Icons.info_outline),
            DropdownButtonFormField<String?>(
              value: _talhaoId,
              decoration: const InputDecoration(
                labelText: 'Talhão *',
                prefixIcon: Icon(Icons.agriculture),
              ),
              validator: (value) =>
                  value == null ? 'Selecione um talhão' : null,
              items: widget.talhoes
                  .map((t) => DropdownMenuItem<String?>(
                        value: t.id,
                        child: Text(t.nome),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _talhaoId = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _laboratorioController,
                    decoration: const InputDecoration(
                      labelText: 'Laboratório',
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _numeroAmostraController,
                    decoration: const InputDecoration(
                      labelText: 'Nº Amostra',
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildCampoData('Data Coleta', _dataColeta,
                    (d) => setState(() => _dataColeta = d))),
                const SizedBox(width: 12),
                Expanded(child: _buildCampoData('Data Resultado', _dataResultado,
                    (d) => setState(() => _dataResultado = d))),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: TextFormField(
                controller: _profundidadeController,
                decoration: const InputDecoration(
                  labelText: 'Profundidade (cm)',
                  prefixIcon: Icon(Icons.height),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoData(
      String label, DateTime? data, ValueChanged<DateTime> onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: data ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          data != null
              ? '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}'
              : 'Selecionar',
          style: TextStyle(
            color: data != null
                ? AppColors.newTextPrimary
                : AppColors.newTextMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildSecaoMacronutrientes() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao('Macronutrientes', Icons.eco),
            _buildLinhaInputs([
              _buildCampoNumerico('pH (CaCl₂)', _phController),
              _buildCampoNumerico('M.O. (g/dm³)', _materiaOrganicaController),
              _buildCampoNumerico('P resina (mg/dm³)', _fosforoController),
            ]),
            const SizedBox(height: 12),
            _buildLinhaInputs([
              _buildCampoNumerico('K (mmolc/dm³)', _potassioController),
              _buildCampoNumerico('Ca (mmolc/dm³)', _calcioController),
              _buildCampoNumerico('Mg (mmolc/dm³)', _magnesioController),
            ]),
            const SizedBox(height: 12),
            _buildLinhaInputs([
              _buildCampoNumerico('S-SO₄ (mg/dm³)', _enxofreController),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoAcidezCTC() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao('Acidez e CTC', Icons.science),
            _buildLinhaInputs([
              _buildCampoNumerico('H+Al (mmolc/dm³)', _acidezPotencialController),
              _buildCampoNumerico('Al (mmolc/dm³)', _aluminioController),
              _buildCampoNumerico('SB (mmolc/dm³)', _somasBasesController),
            ]),
            const SizedBox(height: 12),
            _buildLinhaInputs([
              _buildCampoNumerico('CTC (mmolc/dm³)', _ctcController),
              _buildCampoNumerico('V%', _saturacaoBasesController),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoMicronutrientes() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao('Micronutrientes', Icons.grain),
            _buildLinhaInputs([
              _buildCampoNumerico('B (mg/dm³)', _boroController),
              _buildCampoNumerico('Cu (mg/dm³)', _cobreController),
              _buildCampoNumerico('Fe (mg/dm³)', _ferroController),
            ]),
            const SizedBox(height: 12),
            _buildLinhaInputs([
              _buildCampoNumerico('Mn (mg/dm³)', _manganesController),
              _buildCampoNumerico('Zn (mg/dm³)', _zincoController),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoTextura() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao('Textura do Solo', Icons.texture),
            _buildLinhaInputs([
              _buildCampoNumerico('Argila (g/kg)', _argilaController),
              _buildCampoNumerico('Silte (g/kg)', _silteController),
              _buildCampoNumerico('Areia (g/kg)', _areiaController),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoObservacoes() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao('Observações', Icons.notes),
            TextFormField(
              controller: _observacoesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Observações adicionais...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinhaInputs(List<Widget> campos) {
    return Row(
      children: campos
          .map((campo) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: campo,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCampoNumerico(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
      ],
    );
  }

  Widget _buildBotaoSalvar() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _salvando ? null : _salvar,
        icon: _salvando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: Text(_editando ? 'Atualizar Análise' : 'Salvar Análise'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.newPrimary,
          foregroundColor: AppColors.bgDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final analise = AnaliseSolo(
        id: widget.analise?.id ?? '',
        propriedadeId: widget.contexto.propriedade.id,
        talhaoId: _talhaoId,
        laboratorio: _laboratorioController.text.isNotEmpty
            ? _laboratorioController.text
            : null,
        numeroAmostra: _numeroAmostraController.text.isNotEmpty
            ? _numeroAmostraController.text
            : null,
        dataColeta: _dataColeta,
        dataResultado: _dataResultado,
        profundidadeCm: _parseInt(_profundidadeController.text),
        ph: _parseDouble(_phController.text),
        materiaOrganica: _parseDouble(_materiaOrganicaController.text),
        fosforo: _parseDouble(_fosforoController.text),
        potassio: _parseDouble(_potassioController.text),
        calcio: _parseDouble(_calcioController.text),
        magnesio: _parseDouble(_magnesioController.text),
        enxofre: _parseDouble(_enxofreController.text),
        acidezPotencial: _parseDouble(_acidezPotencialController.text),
        aluminio: _parseDouble(_aluminioController.text),
        somasBases: _parseDouble(_somasBasesController.text),
        ctc: _parseDouble(_ctcController.text),
        saturacaoBases: _parseDouble(_saturacaoBasesController.text),
        boro: _parseDouble(_boroController.text),
        cobre: _parseDouble(_cobreController.text),
        ferro: _parseDouble(_ferroController.text),
        manganes: _parseDouble(_manganesController.text),
        zinco: _parseDouble(_zincoController.text),
        argila: _parseDouble(_argilaController.text),
        silte: _parseDouble(_silteController.text),
        areia: _parseDouble(_areiaController.text),
        observacoes: _observacoesController.text.isNotEmpty
            ? _observacoesController.text
            : null,
      );

      if (_editando) {
        await _service.atualizarAnalise(analise);
      } else {
        await _service.criarAnalise(analise);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editando
                ? 'Análise atualizada com sucesso'
                : 'Análise salva com sucesso'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _salvando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }
}
