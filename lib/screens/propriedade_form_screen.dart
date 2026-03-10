import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../services/proprietario_service.dart';

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
    return Scaffold(
      appBar: AppBarAfcrc(
        title: widget.propriedade == null ? 'Nova Propriedade' : 'Editar Propriedade',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Vinculo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildProprietarioField(),
                  const SizedBox(height: 24),
                  const Text(
                    'Informacoes Basicas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildNomeField(),
                  const SizedBox(height: 16),
                  _buildFAField(),
                  const SizedBox(height: 24),
                  const Text(
                    'Localizacao',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
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
                  const SizedBox(height: 24),
                  const Text(
                    'Area',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildAreaHaField()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildAreaAlqueiresField()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Propriedade Ativa'),
                    subtitle: const Text('A propriedade esta em operacao?'),
                    value: _ativa,
                    onChanged: (value) {
                      setState(() => _ativa = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildBotoes(),
                ],
              ),
            ),
    );
  }

  Widget _buildProprietarioField() {
    if (_proprietarios.isEmpty) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Proprietario',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.person),
        ),
        child: Text('Nenhum proprietario cadastrado'),
      );
    }

    return DropdownButtonFormField<String>(
      value: _proprietarioSelecionadoId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Proprietario',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
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
          return 'Selecione um proprietario';
        }
        return null;
      },
    );
  }

  Widget _buildNomeField() {
    return TextFormField(
      controller: _nomeController,
      decoration: const InputDecoration(
        labelText: 'Nome da Propriedade',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.home),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nome e obrigatorio';
        }
        return null;
      },
    );
  }

  Widget _buildFAField() {
    return TextFormField(
      controller: _faController,
      decoration: const InputDecoration(
        labelText: 'Numero FA (Inscricao Estadual)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.assignment),
        helperText: 'Numero de inscricao estadual da propriedade',
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\-.]')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Numero FA e obrigatorio';
        }
        return null;
      },
    );
  }

  Widget _buildEnderecoField() {
    return TextFormField(
      controller: _enderecoController,
      decoration: const InputDecoration(
        labelText: 'Endereco',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
        hintText: 'Rua, numero, bairro',
      ),
    );
  }

  Widget _buildCidadeField() {
    return TextFormField(
      controller: _cidadeController,
      decoration: const InputDecoration(
        labelText: 'Cidade',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_city),
      ),
    );
  }

  Widget _buildEstadoField() {
    return DropdownButtonFormField<String>(
      value: _estadoController.text.isEmpty ? null : _estadoController.text,
      decoration: const InputDecoration(
        labelText: 'Estado',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.map),
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
      decoration: const InputDecoration(
        labelText: 'CEP',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.mail),
        hintText: '00000-000',
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final cepRegex = RegExp(r'^\d{5}-?\d{3}$');
          if (!cepRegex.hasMatch(value)) {
            return 'CEP invalido';
          }
        }
        return null;
      },
    );
  }

  Widget _buildAreaHaField() {
    return TextFormField(
      controller: _areaHaController,
      decoration: const InputDecoration(
        labelText: 'Area (Hectares)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.agriculture),
        suffixText: 'ha',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value != null &&
            value.isNotEmpty &&
            double.tryParse(value) == null) {
          return 'Numero invalido';
        }
        return null;
      },
    );
  }

  Widget _buildAreaAlqueiresField() {
    return TextFormField(
      controller: _areaAlqueiresController,
      decoration: const InputDecoration(
        labelText: 'Area (Alqueires)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.agriculture),
        suffixText: 'alq',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value != null &&
            value.isNotEmpty &&
            double.tryParse(value) == null) {
          return 'Numero invalido';
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _salvar,
            child: const Text('Salvar'),
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
