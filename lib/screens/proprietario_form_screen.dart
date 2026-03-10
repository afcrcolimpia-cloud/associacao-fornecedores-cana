// lib/screens/proprietario_form_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/proprietario_service.dart';
import '../utils/validators.dart';

class ProprietarioFormScreen extends StatefulWidget {
  final Proprietario? proprietario;

  const ProprietarioFormScreen({
    super.key,
    this.proprietario,
  });

  @override
  State<ProprietarioFormScreen> createState() => _ProprietarioFormScreenState();
}

class _ProprietarioFormScreenState extends State<ProprietarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProprietarioService();
  
  late TextEditingController _nomeController;
  late TextEditingController _cpfCnpjController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;
  late TextEditingController _enderecoController;
  late TextEditingController _cidadeController;
  late TextEditingController _estadoController;
  late TextEditingController _cepController;
  
  bool _isLoading = false;
  bool _isCPF = true;

  @override
  void initState() {
    super.initState();
    final p = widget.proprietario;
    
    _nomeController = TextEditingController(text: p?.nome);
    _cpfCnpjController = TextEditingController(text: p?.cpfCnpj);
    _telefoneController = TextEditingController(text: p?.telefone);
    _emailController = TextEditingController(text: p?.email);
    _enderecoController = TextEditingController(text: p?.endereco);
    _cidadeController = TextEditingController(text: p?.cidade);
    _estadoController = TextEditingController(text: p?.estado);
    _cepController = TextEditingController(text: p?.cep);
    
    if (p != null) {
      _isCPF = p.cpfCnpj.length == 11;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final proprietario = Proprietario(
        id: widget.proprietario?.id ?? '',
        nome: _nomeController.text.trim(),
        cpfCnpj: _cpfCnpjController.text.replaceAll(RegExp(r'\D'), ''),
        telefone: _telefoneController.text.trim().isNotEmpty 
            ? _telefoneController.text.trim() 
            : null,
        email: _emailController.text.trim().isNotEmpty 
            ? _emailController.text.trim() 
            : null,
        endereco: _enderecoController.text.trim().isNotEmpty 
            ? _enderecoController.text.trim() 
            : null,
        cidade: _cidadeController.text.trim().isNotEmpty 
            ? _cidadeController.text.trim() 
            : null,
        estado: _estadoController.text.trim().isNotEmpty 
            ? _estadoController.text.trim() 
            : null,
        cep: _cepController.text.replaceAll(RegExp(r'\D'), '').isNotEmpty
            ? _cepController.text.replaceAll(RegExp(r'\D'), '')
            : null,
        ativo: widget.proprietario?.ativo ?? true,
        criadoEm: widget.proprietario?.criadoEm ?? DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      if (widget.proprietario == null) {
        await _service.addProprietario(proprietario);
      } else {
        await _service.updateProprietario(proprietario);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.proprietario == null
                  ? 'Proprietário cadastrado com sucesso!'
                  : 'Proprietário atualizado com sucesso!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.proprietario != null;

    return Scaffold(
      appBar: AppBarAfcrc(title: isEdicao ? 'Editar Proprietário' : 'Novo Proprietário'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Card de Dados Básicos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dados Básicos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Nome
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo *',
                        hintText: 'Digite o nome completo',
                        prefixIcon: Icon(Icons.person),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (value.trim().length < 3) {
                          return 'Nome deve ter no mínimo 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tipo de Documento
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('CPF'),
                            value: true,
                            groupValue: _isCPF,
                            onChanged: (value) {
                              setState(() {
                                _isCPF = value!;
                                _cpfCnpjController.clear();
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('CNPJ'),
                            value: false,
                            groupValue: _isCPF,
                            onChanged: (value) {
                              setState(() {
                                _isCPF = value!;
                                _cpfCnpjController.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // CPF/CNPJ
                    TextFormField(
                      controller: _cpfCnpjController,
                      decoration: InputDecoration(
                        labelText: '${_isCPF ? "CPF" : "CNPJ"} *',
                        hintText: _isCPF ? '000.000.000-00' : '00.000.000/0000-00',
                        prefixIcon: const Icon(Icons.badge),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(_isCPF ? 11 : 14),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                        if (_isCPF) {
                          if (digitsOnly.length != 11) {
                            return 'CPF deve ter 11 dígitos';
                          }
                          if (!BrazilianValidators.isValidCPF(digitsOnly)) {
                            return 'CPF inválido';
                          }
                        } else {
                          if (digitsOnly.length != 14) {
                            return 'CNPJ deve ter 14 dígitos';
                          }
                          if (!BrazilianValidators.isValidCNPJ(digitsOnly)) {
                            return 'CNPJ inválido';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Card de Contato
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contato',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Telefone
                    TextFormField(
                      controller: _telefoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        hintText: '(00) 00000-0000',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'email@exemplo.com',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!value.contains('@')) {
                            return 'E-mail inválido';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Card de Endereço
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Endereço',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // CEP
                    TextFormField(
                      controller: _cepController,
                      decoration: const InputDecoration(
                        labelText: 'CEP',
                        hintText: '00000-000',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Endereço
                    TextFormField(
                      controller: _enderecoController,
                      decoration: const InputDecoration(
                        labelText: 'Endereço',
                        hintText: 'Rua, número, complemento',
                        prefixIcon: Icon(Icons.home),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Cidade e Estado
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _cidadeController,
                            decoration: const InputDecoration(
                              labelText: 'Cidade',
                              prefixIcon: Icon(Icons.location_city),
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _estadoController,
                            decoration: const InputDecoration(
                              labelText: 'UF',
                              hintText: 'SP',
                            ),
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(2),
                              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('CANCELAR'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _salvar,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEdicao ? 'ATUALIZAR' : 'SALVAR'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}