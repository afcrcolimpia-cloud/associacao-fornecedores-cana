import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../services/proprietario_service.dart';

class PropriedadeFormScreen extends StatefulWidget {
  final Propriedade? propriedade;
  final String? proprietarioId;

  const PropriedadeFormScreen({
    super.key,
    this.propriedade,
    this.proprietarioId,
  });

  @override
  State<PropriedadeFormScreen> createState() => _PropriedadeFormScreenState();
}

class _PropriedadeFormScreenState extends State<PropriedadeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propriedadeService = PropriedadeService();
  final _proprietarioService = ProprietarioService();

  // Controllers
  final _nomeController = TextEditingController();
  final _faController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cepController = TextEditingController();
  final _areaHaController = TextEditingController();
  final _areaAlqController = TextEditingController();

  // Variáveis
  String? _proprietarioSelecionado;
  bool _isLoading = false;
  bool _isAtiva = true;
  List<Proprietario> _proprietarios = [];

  @override
  void initState() {
    super.initState();
    _carregarProprietarios();
    
    if (widget.propriedade != null) {
      _carregarDados();
    } else if (widget.proprietarioId != null) {
      _proprietarioSelecionado = widget.proprietarioId;
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
    _areaAlqController.dispose();
    super.dispose();
  }

  void _carregarDados() {
    final prop = widget.propriedade!;
    _nomeController.text = prop.nome ?? '';
    _faController.text = prop.fa ?? '';
    _enderecoController.text = prop.endereco ?? '';
    _cidadeController.text = prop.cidade ?? '';
    _estadoController.text = prop.estado ?? '';
    _cepController.text = prop.cep ?? '';
    _areaHaController.text = prop.areaHa?.toString() ?? '';
    _areaAlqController.text = prop.areaAlqueires?.toString() ?? '';
    _proprietarioSelecionado = prop.proprietarioId;
    _isAtiva = prop.ativa ?? true;
  }

  Future<void> _carregarProprietarios() async {
    try {
      final proprietarios = await _proprietarioService.getProprietarios();
      setState(() => _proprietarios = proprietarios);
    } catch (e) {
      _mostrarErro('Erro ao carregar proprietários: $e');
    }
  }

  // Calcular área em alqueires quando digitar hectares
  void _calcularAreaAlqueires(String hectares) {
    if (hectares.isEmpty) {
      _areaAlqController.clear();
      return;
    }
    
    final ha = double.tryParse(hectares);
    if (ha != null) {
      // 1 alqueire paulista = 2.42 hectares
      final alqueires = ha / 2.42;
      _areaAlqController.text = alqueires.toStringAsFixed(2);
    }
  }

  // Calcular área em hectares quando digitar alqueires
  void _calcularAreaHectares(String alqueires) {
    if (alqueires.isEmpty) {
      _areaHaController.clear();
      return;
    }
    
    final alq = double.tryParse(alqueires);
    if (alq != null) {
      // 1 alqueire paulista = 2.42 hectares
      final hectares = alq * 2.42;
      _areaHaController.text = hectares.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.propriedade == null 
            ? 'Nova Propriedade' 
            : 'Editar Propriedade'),
        actions: [
          if (widget.propriedade != null)
            IconButton(
              icon: Icon(_isAtiva ? Icons.toggle_on : Icons.toggle_off),
              tooltip: _isAtiva ? 'Ativa' : 'Inativa',
              onPressed: () {
                setState(() => _isAtiva = !_isAtiva);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Status da propriedade
                  if (widget.propriedade != null) ...[
                    Card(
                      color: _isAtiva ? Colors.green.shade50 : Colors.red.shade50,
                      child: ListTile(
                        leading: Icon(
                          _isAtiva ? Icons.check_circle : Icons.cancel,
                          color: _isAtiva ? Colors.green : Colors.red,
                        ),
                        title: Text(_isAtiva ? 'Propriedade Ativa' : 'Propriedade Inativa'),
                        subtitle: Text(_isAtiva 
                            ? 'Propriedade disponível para uso'
                            : 'Propriedade desativada'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Dados Principais
                  const Text(
                    'Dados Principais',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  _buildProprietarioField(),
                  const SizedBox(height: 16),

                  _buildNomeField(),
                  const SizedBox(height: 16),

                  _buildFAField(),
                  const SizedBox(height: 24),

                  // Localização
                  const Text(
                    'Localização',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  _buildEnderecoField(),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(child: _buildCidadeField()),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 100,
                        child: _buildEstadoField(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildCEPField(),
                  const SizedBox(height: 24),

                  // Área
                  const Text(
                    'Área',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(child: _buildAreaHaField()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildAreaAlqField()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildBotoes(),
                ],
              ),
            ),
    );
  }

  Widget _buildProprietarioField() {
    return DropdownButtonFormField<String>(
      value: _proprietarioSelecionado,
      decoration: const InputDecoration(
        labelText: 'Proprietário',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      items: _proprietarios.map((proprietario) {
        return DropdownMenuItem(
          value: proprietario.id,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(proprietario.nome),
              Text(
                proprietario.cpfCnpj,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _proprietarioSelecionado = value);
      },
      validator: (value) => value == null ? 'Selecione um proprietário' : null,
    );
  }

  Widget _buildNomeField() {
    return TextFormField(
      controller: _nomeController,
      decoration: const InputDecoration(
        labelText: 'Nome da Propriedade',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.home),
        hintText: 'Ex: Fazenda São João',
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Digite o nome da propriedade';
        }
        return null;
      },
    );
  }

  Widget _buildFAField() {
    return TextFormField(
      controller: _faController,
      decoration: const InputDecoration(
        labelText: 'F.A (Número de Identificação)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.tag),
        hintText: 'Ex: FA-001',
        helperText: 'Identificador único da propriedade',
      ),
      textCapitalization: TextCapitalization.characters,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Digite o número F.A';
        }
        return null;
      },
    );
  }

  Widget _buildEnderecoField() {
    return TextFormField(
      controller: _enderecoController,
      decoration: const InputDecoration(
        labelText: 'Endereço',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
        hintText: 'Ex: Rodovia SP-310, Km 45',
      ),
      textCapitalization: TextCapitalization.words,
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
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildEstadoField() {
    return TextFormField(
      controller: _estadoController,
      decoration: const InputDecoration(
        labelText: 'UF',
        border: OutlineInputBorder(),
        hintText: 'SP',
      ),
      textCapitalization: TextCapitalization.characters,
      maxLength: 2,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
        UpperCaseTextFormatter(),
      ],
    );
  }

  Widget _buildCEPField() {
    return TextFormField(
      controller: _cepController,
      decoration: const InputDecoration(
        labelText: 'CEP',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.pin_drop),
        hintText: '00000-000',
      ),
      keyboardType: TextInputType.number,
      maxLength: 9,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CepInputFormatter(),
      ],
    );
  }

  Widget _buildAreaHaField() {
    return TextFormField(
      controller: _areaHaController,
      decoration: const InputDecoration(
        labelText: 'Área (ha)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.straighten),
        suffixText: 'hectares',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      onChanged: _calcularAreaAlqueires,
    );
  }

  Widget _buildAreaAlqField() {
    return TextFormField(
      controller: _areaAlqController,
      decoration: const InputDecoration(
        labelText: 'Área (Alqs)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.straighten),
        suffixText: 'alqueires',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      onChanged: _calcularAreaHectares,
    );
  }

  Widget _buildBotoes() {
    return Row(
      children: [
        if (widget.propriedade != null) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _confirmarExclusao,
              icon: const Icon(Icons.delete),
              label: const Text('Excluir'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
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

    setState(() => _isLoading = true);

    try {
      final propriedade = Propriedade(
        id: widget.propriedade?.id ?? '',
        proprietarioId: _proprietarioSelecionado!,
        nomePropriedade: _nomeController.text,
        numeroFA: _faController.text,
        endereco: _enderecoController.text.isNotEmpty 
            ? _enderecoController.text 
            : null,
        cidade: _cidadeController.text.isNotEmpty 
            ? _cidadeController.text 
            : null,
        estado: _estadoController.text.isNotEmpty 
            ? _estadoController.text 
            : null,
        cep: _cepController.text.isNotEmpty 
            ? _cepController.text 
            : null,
        areaHa: _areaHaController.text.isNotEmpty
            ? double.parse(_areaHaController.text)
            : null,
        areaAlqueires: _areaAlqController.text.isNotEmpty
            ? double.parse(_areaAlqController.text)
            : null,
        ativa: _isAtiva,
        criadoEm: widget.propriedade?.criadoEm ?? DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      if (widget.propriedade == null) {
        await _propriedadeService.addPropriedade(propriedade);
      } else {
        await _propriedadeService.updatePropriedade(propriedade);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Propriedade salva com sucesso!')),
        );
      }
    } catch (e) {
      _mostrarErro('Erro ao salvar: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Deseja realmente excluir esta propriedade?\n\n'
          'ATENÇÃO: Todos os talhões e dados relacionados também serão excluídos!',
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

    if (confirmar == true && widget.propriedade != null) {
      setState(() => _isLoading = true);

      try {
        await _propriedadeService.deletePropriedade(widget.propriedade!.id);
        
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Propriedade excluída com sucesso')),
          );
        }
      } catch (e) {
        _mostrarErro('Erro ao excluir: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Formatador para CEP
class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length > 8) {
      return oldValue;
    }

    if (text.length <= 5) {
      return newValue;
    }

    return TextEditingValue(
      text: '${text.substring(0, 5)}-${text.substring(5)}',
      selection: TextSelection.collapsed(offset: newValue.text.length + 1),
    );
  }
}

// Formatador para maiúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}