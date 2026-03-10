import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_shell.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../services/proprietario_service.dart';
import '../constants/app_colors.dart';

class PropriedadeFormScreen extends StatefulWidget {
  final Propriedade? propriedade;
  final String? proprietarioIdInicial;
  final bool bloquearProprietario;

  const PropriedadeFormScreen({
    super.key,
    this.propriedade,
    this.proprietarioIdInicial,
    this.bloquearProprietario = false,
  });

  @override
  State<PropriedadeFormScreen> createState() => _PropriedadeFormScreenState();
}

class _PropriedadeFormScreenState extends State<PropriedadeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _faController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cepController = TextEditingController();
  final _areaHaController = TextEditingController();
  final _areaAlqueiresController = TextEditingController();

  late PropriedadeService _service;
  late ProprietarioService _proprietarioService;
  List<Proprietario> _proprietarios = [];
  String? _proprietarioSelecionadoId;

  bool _isLoading = false;
  bool _ativa = true;
  int _selectedNavigationIndex = 0;

  final List<String> _estados = [
    'SP',
    'MG',
    'RJ',
    'BA',
    'RS',
    'PR',
    'SC',
    'GO',
    'MS',
    'MT',
    'DF',
    'AL',
    'AM',
    'AP',
    'CE',
    'ES',
    'MA',
    'PA',
    'PB',
    'PE',
    'PI',
    'RN',
    'RO',
    'RR',
    'SE',
    'TO',
  ];

  @override
  void initState() {
    super.initState();
    _service = PropriedadeService();
    _proprietarioService = ProprietarioService();
    _proprietarioSelecionadoId =
        widget.propriedade?.proprietarioId ?? widget.proprietarioIdInicial;

    if (widget.propriedade != null) {
      _carregarDados();
    }
    _carregarProprietarios();
  }

  void _carregarDados() {
    final prop = widget.propriedade!;
    _proprietarioSelecionadoId = prop.proprietarioId;
    _nomeController.text = prop.nomePropriedade;
    _faController.text = prop.numeroFA;
    _enderecoController.text = prop.endereco ?? '';
    _cidadeController.text = prop.cidade ?? '';
    _estadoController.text = prop.estado ?? '';
    _cepController.text = prop.cep ?? '';
    _areaHaController.text = prop.areaHa?.toString() ?? '';
    _areaAlqueiresController.text = prop.areaAlqueires?.toString() ?? '';
    _ativa = prop.ativa;
  }

  Future<void> _carregarProprietarios() async {
    try {
      final proprietarios = await _proprietarioService.getProprietarios();
      if (!mounted) return;

      setState(() {
        _proprietarios = proprietarios;
        if (_proprietarioSelecionadoId == null && proprietarios.isNotEmpty) {
          _proprietarioSelecionadoId = proprietarios.first.id;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _proprietarios = []);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _faController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    _areaHaController.dispose();
    _areaAlqueiresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      title: widget.propriedade == null ? 'Nova Propriedade' : 'Editar Propriedade',
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION 1: VÍNCULO
                    _buildSectionTitle('Vínculo'),
                    const SizedBox(height: 16),
                    _buildProprietarioField(),
                    
                    const SizedBox(height: 32),
                    
                    // SECTION 2: INFORMAÇÕES BÁSICAS
                    _buildSectionTitle('Informações Básicas'),
                    const SizedBox(height: 16),
                    _buildNomeField(),
                    const SizedBox(height: 16),
                    _buildFAField(),
                    
                    const SizedBox(height: 32),
                    
                    // SECTION 3: LOCALIZAÇÃO
                    _buildSectionTitle('Localização'),
                    const SizedBox(height: 16),
                    _buildEnderecoField(),
                    const SizedBox(height: 16),
                    _buildCidadeField(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildEstadoField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCEPField()),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // SECTION 4: ÁREA
                    _buildSectionTitle('Medidas de Área'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildAreaHaField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildAreaAlqueiresField()),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // SECTION 5: STATUS
                    _buildSectionTitle('Status'),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          'Propriedade Ativa',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.newTextPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Esta propriedade está em operação?',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.newTextSecondary,
                          ),
                        ),
                        value: _ativa,
                        onChanged: (value) {
                          setState(() => _ativa = value);
                        },
                        activeColor: AppColors.newPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // BUTTONS
                    _buildBotoes(),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.newTextPrimary,
      ),
    );
  }

  Widget _buildProprietarioField() {
    if (_proprietarios.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderDark),
        ),
        padding: const EdgeInsets.all(12),
        child: Text(
          'Nenhum proprietário cadastrado',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.newTextMuted,
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _proprietarioSelecionadoId,
      isExpanded: true,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.newTextPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'Proprietário',
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.newTextSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.newPrimary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
        prefixIcon: const Icon(Icons.person, color: AppColors.newTextSecondary, size: 20),
      ),
      items: _proprietarios
          .map(
            (proprietario) => DropdownMenuItem<String>(
              value: proprietario.id,
              child: Text(proprietario.nome),
            ),
          )
          .toList(),
      onChanged: widget.bloquearProprietario
          ? null
          : (value) {
              setState(() => _proprietarioSelecionadoId = value);
            },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecione um proprietário';
        }
        return null;
      },
    );
  }

  Widget _buildNomeField() {
    return TextFormField(
      controller: _nomeController,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.newTextPrimary),
      decoration: InputDecoration(
        labelText: 'Nome da Propriedade',
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.newTextSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.newPrimary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
        prefixIcon: const Icon(Icons.home, color: AppColors.newTextSecondary, size: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nome é obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildFAField() {
    return TextFormField(
      controller: _faController,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.newTextPrimary),
      decoration: InputDecoration(
        labelText: 'Número FA (Inscrição Estadual)',
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.newTextSecondary,
        ),
        helperText: 'Número de inscrição estadual da propriedade',
        helperStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.newTextMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.newPrimary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
        prefixIcon: const Icon(Icons.assignment, color: AppColors.newTextSecondary, size: 20),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\-.]')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Número FA é obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildEnderecoField() {
    return TextFormField(
      controller: _enderecoController,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.newTextPrimary),
      decoration: InputDecoration(
        labelText: 'Endereço',
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.newTextSecondary,
        ),
        hintText: 'Rua, número, bairro',
        hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.newTextMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.newPrimary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
        prefixIcon: const Icon(Icons.location_on, color: AppColors.newTextSecondary, size: 20),
      ),
    );
  }

  Widget _buildCidadeField() {
    return TextFormField(
      controller: _cidadeController,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.newTextPrimary),
      decoration: InputDecoration(
        labelText: 'Cidade',
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.newTextSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.newPrimary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
        prefixIcon: const Icon(Icons.location_city, color: AppColors.newTextSecondary, size: 20),
      ),
    );
  }

  Widget _buildEstadoField() {
    return DropdownButtonFormField<String>(
      value: _estadoController.text.isEmpty ? null : _estadoController.text,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.newTextPrimary),
      decoration: InputDecoration(
        labelText: 'Estado',
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.newTextSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.newPrimary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
        prefixIcon: const Icon(Icons.map, color: AppColors.newTextSecondary, size: 20),
      ),
      items: _estados
          .map(
            (estado) => DropdownMenuItem(
              value: estado,
              child: Text(estado),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() => _estadoController.text = value ?? '');
      },
    );
  }

  Widget _buildCEPField() {
    return TextFormField(
      controller: _cepController,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.newTextPrimary),
      decoration: InputDecoration(
        labelText: 'CEP',
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.newTextSecondary,
        ),
        hintText: '00000-000',
        hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.newTextMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.newPrimary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
        prefixIcon: const Icon(Icons.mail, color: AppColors.newTextSecondary, size: 20),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final cepRegex = RegExp(r'^\d{5}-?\d{3}$');
          if (!cepRegex.hasMatch(value)) {
            return 'CEP inválido';
          }
        }
        return null;
      },
    );
  }

  Widget _buildAreaHaField() {
    return TextFormField(
      controller: _areaHaController,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.newTextPrimary),
      decoration: InputDecoration(
        labelText: 'Área (Hectares)',
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.newTextSecondary,
        ),
        suffixText: 'ha',
        suffixStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.newTextMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.newPrimary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
        prefixIcon: const Icon(Icons.agriculture, color: AppColors.newTextSecondary, size: 20),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value != null &&
            value.isNotEmpty &&
            double.tryParse(value) == null) {
          return 'Número inválido';
        }
        return null;
      },
    );
  }

  Widget _buildAreaAlqueiresField() {
    return TextFormField(
      controller: _areaAlqueiresController,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.newTextPrimary),
      decoration: InputDecoration(
        labelText: 'Área (Alqueires)',
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.newTextSecondary,
        ),
        suffixText: 'alq',
        suffixStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.newTextMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.newPrimary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
        prefixIcon: const Icon(Icons.agriculture, color: AppColors.newTextSecondary, size: 20),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value != null &&
            value.isNotEmpty &&
            double.tryParse(value) == null) {
          return 'Número inválido';
        }
        return null;
      },
    );
  }

  Widget _buildBotoes() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.borderDark),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.newTextPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _salvar,
            child: Text(
              'Salvar',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_proprietarioSelecionadoId == null ||
        _proprietarioSelecionadoId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um proprietario')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final propriedade = Propriedade(
        id: widget.propriedade?.id ?? '',
        proprietarioId: _proprietarioSelecionadoId!,
        nomePropriedade: _nomeController.text,
        numeroFA: _faController.text,
        endereco:
            _enderecoController.text.isEmpty ? null : _enderecoController.text,
        cidade: _cidadeController.text.isEmpty ? null : _cidadeController.text,
        estado: _estadoController.text.isEmpty ? null : _estadoController.text,
        cep: _cepController.text.isEmpty ? null : _cepController.text,
        areaHa: _areaHaController.text.isEmpty
            ? null
            : double.parse(_areaHaController.text),
        areaAlqueires: _areaAlqueiresController.text.isEmpty
            ? null
            : double.parse(_areaAlqueiresController.text),
        ativa: _ativa,
        criadoEm: widget.propriedade?.criadoEm ?? DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      if (widget.propriedade == null) {
        await _service.createPropriedade(propriedade);
      } else {
        await _service.updatePropriedade(propriedade);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.propriedade == null
                ? 'Propriedade criada com sucesso'
                : 'Propriedade atualizada com sucesso',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
