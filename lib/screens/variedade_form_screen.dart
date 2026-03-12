import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../models/models.dart';
import '../services/variedade_service.dart';

class VariedadeFormScreen extends StatefulWidget {
  final Variedade? variedade;

  const VariedadeFormScreen({super.key, this.variedade});

  @override
  State<VariedadeFormScreen> createState() => _VariedadeFormScreenState();
}

class _VariedadeFormScreenState extends State<VariedadeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = VariedadeService();

  final _codigoController = TextEditingController();
  final _destaqueController = TextEditingController();

  String _instituicaoSelecionada = 'CTC';
  final List<String> _ambientesSelecionados = [];
  final List<String> _mesesSelecionados = [];
  bool _isLoading = false;
  int _selectedNavigationIndex = 0;

  static const List<String> _instituicoes = ['CTC', 'RB', 'IAC', 'SP', 'CV', 'CT'];
  static const List<String> _ambientes = ['A', 'B', 'C', 'D', 'E'];
  static const List<String> _meses = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.variedade != null) {
      _carregarDados();
    }
  }

  void _carregarDados() {
    final v = widget.variedade!;
    _codigoController.text = v.codigo;
    _destaqueController.text = v.destaque;
    _instituicaoSelecionada = v.instituicao.isNotEmpty ? v.instituicao : 'CTC';
    _ambientesSelecionados.addAll(v.ambientes);
    _mesesSelecionados.addAll(v.meses);
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _destaqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.variedade != null;
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      title: isEditing ? 'Editar Variedade' : 'Nova Variedade',
      showBackButton: true,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Dados da Variedade',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  _buildCodigoField(),
                  const SizedBox(height: 16),
                  _buildInstituicaoField(),
                  const SizedBox(height: 16),
                  _buildDestaqueField(),
                  const SizedBox(height: 24),
                  const Text(
                    'Ambiente de Produção',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '(A) Alta fertilidade → (E) Baixa fertilidade',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  _buildAmbienteChips(),
                  const SizedBox(height: 24),
                  const Text(
                    'Época de Colheita',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  _buildMesesChips(),
                  const SizedBox(height: 32),
                  _buildBotoes(),
                ],
              ),
            ),
    );
  }

  Widget _buildCodigoField() {
    return TextFormField(
      controller: _codigoController,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: 'Código da Variedade',
        hintText: 'Ex: CTC9001, RB86-7515, SP80-1842',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.grass),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Código é obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildInstituicaoField() {
    return DropdownButtonFormField<String>(
      value: _instituicaoSelecionada,
      dropdownColor: const Color(0xFF1E293B),
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: 'Instituição',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
      ),
      items: _instituicoes.map((inst) {
        final descricao = _descricaoInstituicao(inst);
        return DropdownMenuItem(
          value: inst,
          child: Text('$inst — $descricao'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _instituicaoSelecionada = value);
        }
      },
    );
  }

  String _descricaoInstituicao(String sigla) {
    switch (sigla) {
      case 'CTC':
        return 'Centro de Tecnologia Canavieira';
      case 'RB':
        return 'RIDESA';
      case 'IAC':
        return 'Instituto Agronômico de Campinas';
      case 'SP':
        return 'Programa Copersucar';
      case 'CV':
        return 'CanaVialis';
      case 'CT':
        return 'Centro de Tecnologia';
      default:
        return sigla;
    }
  }

  Widget _buildDestaqueField() {
    return TextFormField(
      controller: _destaqueController,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: 'Destaque / Características',
        hintText: 'Ex: Alta produtividade, rusticidade',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.star_outline),
      ),
      maxLines: 2,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Destaque é obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildAmbienteChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _ambientes.map((ambiente) {
        final selecionado = _ambientesSelecionados.contains(ambiente);
        return FilterChip(
          label: Text(ambiente),
          selected: selecionado,
          selectedColor: const Color(0xFF16A34A).withValues(alpha: 0.3),
          checkmarkColor: const Color(0xFF16A34A),
          onSelected: (value) {
            setState(() {
              if (value) {
                _ambientesSelecionados.add(ambiente);
              } else {
                _ambientesSelecionados.remove(ambiente);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildMesesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _meses.map((mes) {
        final selecionado = _mesesSelecionados.contains(mes);
        return FilterChip(
          label: Text(mes),
          selected: selecionado,
          selectedColor: const Color(0xFF3B82F6).withValues(alpha: 0.3),
          checkmarkColor: const Color(0xFF3B82F6),
          onSelected: (value) {
            setState(() {
              if (value) {
                _mesesSelecionados.add(mes);
              } else {
                _mesesSelecionados.remove(mes);
              }
            });
          },
        );
      }).toList(),
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

    if (_ambientesSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um ambiente de produção')),
      );
      return;
    }

    if (_mesesSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um mês de colheita')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ordenar ambientes e meses
      _ambientesSelecionados.sort();
      final mesesOrdenados = _ordenarMeses(_mesesSelecionados);

      final codigo = _codigoController.text.trim();

      final variedade = Variedade(
        id: widget.variedade?.id ?? '',
        codigo: codigo,
        nome: codigo,
        instituicao: _instituicaoSelecionada,
        destaque: _destaqueController.text.trim(),
        ambienteProducao: _ambientesSelecionados.join(' '),
        epocaColheita: mesesOrdenados.join(' '),
        ativa: true,
        criadoEm: widget.variedade?.criadoEm ?? DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      if (widget.variedade == null) {
        await _service.createVariedade(variedade);
      } else {
        await _service.updateVariedade(variedade);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.variedade == null
                ? 'Variedade criada com sucesso'
                : 'Variedade atualizada com sucesso'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> _ordenarMeses(List<String> meses) {
    const ordem = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final copia = List<String>.from(meses);
    copia.sort((a, b) => ordem.indexOf(a).compareTo(ordem.indexOf(b)));
    return copia;
  }
}
