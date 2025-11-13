import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../services/proprietario_service.dart';

class PropriedadeFormScreen extends StatefulWidget {
  final Propriedade? propriedade;

  const PropriedadeFormScreen({
    super.key,
    this.propriedade,
  });

  @override
  State<PropriedadeFormScreen> createState() => _PropriedadeFormScreenState();
}

class _PropriedadeFormScreenState extends State<PropriedadeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propriedadeService = PropriedadeService();
  final _proprietarioService = ProprietarioService();

  late TextEditingController _nomeController;
  late TextEditingController _numeroFAController;
  late TextEditingController _inscricaoEstadualController;
  late TextEditingController _municipioController;
  late TextEditingController _coordenadasController;

  String? _proprietarioSelecionado;
  bool _isLoading = false;
  List<Proprietario> _proprietarios = [];

  @override
  void initState() {
    super.initState();
    final p = widget.propriedade;

    _nomeController = TextEditingController(text: p?.nomePropriedade);
    _numeroFAController = TextEditingController(text: p?.numeroFA);
    _inscricaoEstadualController = TextEditingController(text: p?.inscricaoEstadual);
    _municipioController = TextEditingController(text: p?.municipio);
    _coordenadasController = TextEditingController(text: p?.coordenadasGPS);

    _proprietarioSelecionado = p?.proprietarioId;

    _loadProprietarios();
  }

  Future<void> _loadProprietarios() async {
    _proprietarioService.getProprietariosStream().listen((proprietarios) {
      if (mounted) {
        setState(() {
          _proprietarios = proprietarios;
        });
      }
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _numeroFAController.dispose();
    _inscricaoEstadualController.dispose();
    _municipioController.dispose();
    _coordenadasController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_proprietarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um proprietário'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final propriedade = Propriedade(
        id: widget.propriedade?.id ?? '',
        proprietarioId: _proprietarioSelecionado!,
        nomePropriedade: _nomeController.text.trim(),
        numeroFA: _numeroFAController.text.trim(),
        inscricaoEstadual: _inscricaoEstadualController.text.trim(),
        municipio: _municipioController.text.trim(),
        coordenadasGPS: _coordenadasController.text.trim(),
        criadoEm: widget.propriedade?.criadoEm ?? DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      if (widget.propriedade == null) {
        await _propriedadeService.addPropriedade(propriedade);
      } else {
        await _propriedadeService.updatePropriedade(propriedade);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.propriedade == null
                  ? 'Propriedade cadastrada com sucesso!'
                  : 'Propriedade atualizada com sucesso!',
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
    final isEdicao = widget.propriedade != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Propriedade' : 'Nova Propriedade'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Card Proprietário
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proprietário',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _proprietarioSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Selecione o Proprietário *',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _proprietarios
                          .map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.nome),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _proprietarioSelecionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione um proprietário';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card Dados da Propriedade
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dados da Propriedade',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Propriedade *',
                        hintText: 'Ex: Fazenda Santa Maria',
                        prefixIcon: Icon(Icons.home_work),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numeroFAController,
                      decoration: const InputDecoration(
                        labelText: 'Número FA *',
                        hintText: 'Ex: 12345',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _inscricaoEstadualController,
                      decoration: const InputDecoration(
                        labelText: 'Inscrição Estadual',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _municipioController,
                      decoration: const InputDecoration(
                        labelText: 'Município',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _coordenadasController,
                      decoration: const InputDecoration(
                        labelText: 'Coordenadas GPS',
                        hintText: 'Ex: -21.123456, -48.123456',
                        prefixIcon: Icon(Icons.my_location),
                      ),
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