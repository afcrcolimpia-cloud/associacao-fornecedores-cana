import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/produtividade_service.dart';
import '../services/talhao_service.dart';
import '../services/variedade_service.dart';

class ProdutividadeFormScreen extends StatefulWidget {
  final Propriedade propriedade;
  final Produtividade? produtividade;

  const ProdutividadeFormScreen({
    super.key,
    required this.propriedade,
    this.produtividade,
  });

  @override
  State<ProdutividadeFormScreen> createState() => _ProdutividadeFormScreenState();
}

class _ProdutividadeFormScreenState extends State<ProdutividadeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _anoSafraController = TextEditingController();
  final _variedadeController = TextEditingController();
  final _estagioController = TextEditingController();
  final _pesoLiquidoController = TextEditingController();
  final _mediaATRController = TextEditingController();
  final _observacoesController = TextEditingController();

  late ProdutividadeService _produtividadeService;
  late TalhaoService _talhaoService;
  final VariedadeService _variedadeService = VariedadeService();
  
  String? _talhaoSelecionado;
  int? _mesSelecionado;
  bool _isLoading = false;
  int _selectedNavigationIndex = 0;
  List<Talhao> _talhoes = [];
  Map<String, Variedade> _variedadeMap = {};

  final List<String> _meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  @override
  void initState() {
    super.initState();
    _produtividadeService = ProdutividadeService();
    _talhaoService = TalhaoService();
    _carregarTalhoes();
    _carregarVariedades();
    if (widget.produtividade != null) {
      _carregarDados();
    }
  }

  Future<void> _carregarVariedades() async {
    final mapa = await _variedadeService.getVariedadeMap();
    if (mounted) setState(() => _variedadeMap = mapa);
  }

  String _nomeVariedade(String? id) =>
      _variedadeService.resolverNomeSync(id, _variedadeMap);

  Future<void> _carregarTalhoes() async {
    try {
      final talhoes = await _talhaoService.getTalhoesPorPropriedade(widget.propriedade.id);
      setState(() => _talhoes = talhoes);
    } catch (e) {
      debugPrint('Erro ao carregar talhões: $e');
    }
  }

  void _carregarDados() {
    final prod = widget.produtividade!;
    _anoSafraController.text = prod.anoSafra;
    _talhaoSelecionado = prod.talhaoId;
    _mesSelecionado = prod.mesColheita;
    _pesoLiquidoController.text = prod.pesoLiquidoToneladas?.toString() ?? '';
    _mediaATRController.text = prod.mediaATR?.toString() ?? '';
    _observacoesController.text = prod.observacoes ?? '';
    
    // Carregar dados do talhão se disponível
    if (_talhaoSelecionado != null && _talhaoSelecionado!.isNotEmpty) {
      _carregarDadosTalhao(_talhaoSelecionado!);
    } else {
      _variedadeController.text = _nomeVariedade(prod.variedade);
      _estagioController.text = prod.estagio ?? '';
    }
  }

  void _carregarDadosTalhao(String talhaoId) {
    try {
      final talhao = _talhoes.firstWhere((t) => t.id == talhaoId);
      setState(() {
        // Preenche automaticamente os campos com os dados do talhão
        _variedadeController.text = _nomeVariedade(talhao.variedade);
        // Se a variedade já estava preenchida diferente, apenas sobrescreve se o talhão tem dados
        if (talhao.variedade != null) {
          _estagioController.text = ''; // Limpa o estágio para o usuário preencher
        }
      });
    } catch (e) {
      debugPrint('Talhão não encontrado: $e');
    }
  }

  @override
  void dispose() {
    _anoSafraController.dispose();
    _variedadeController.dispose();
    _estagioController.dispose();
    _pesoLiquidoController.dispose();
    _mediaATRController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      title: widget.produtividade == null ? 'Nova Produtividade' : 'Editar Produtividade',
      showBackButton: true,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Informações da Produtividade',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildAnoSafraField(),
                  const SizedBox(height: 16),
                  _buildTalhaoField(),
                  const SizedBox(height: 16),
                  _buildVariedadeField(),
                  const SizedBox(height: 16),
                  _buildMesField(),
                  const SizedBox(height: 16),
                  _buildEstagioField(),
                  const SizedBox(height: 24),
                  const Text(
                    'Dados de Colheita',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildPesoLiquidoField(),
                  const SizedBox(height: 16),
                  _buildMediaATRField(),
                  const SizedBox(height: 24),
                  _buildObservacoesField(),
                  const SizedBox(height: 24),
                  _buildBotoes(),
                ],
              ),
            ),
    );
  }

  Widget _buildAnoSafraField() {
    return TextFormField(
      controller: _anoSafraController,
      decoration: const InputDecoration(
        labelText: 'Ano da Safra',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
        hintText: 'YYYY',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ano da safra é obrigatório';
        }
        if (value.length != 4) {
          return 'Digite um ano válido (YYYY)';
        }
        return null;
      },
    );
  }

  Widget _buildTalhaoField() {
    return DropdownButtonFormField<String>(
      value: _talhaoSelecionado?.isNotEmpty ?? false ? _talhaoSelecionado : null,
      decoration: const InputDecoration(
        labelText: 'Talhão *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.landscape),
        hintText: 'Selecione um talhão',
      ),
      items: _talhoes.map((talhao) {
        return DropdownMenuItem(
          value: talhao.id,
          child: Text(
            '${talhao.nome}${talhao.variedade != null ? ' - ${_nomeVariedade(talhao.variedade)}' : ''}',
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _talhaoSelecionado = value;
          if (value != null && value.isNotEmpty) {
            _carregarDadosTalhao(value);
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecione um talhão antes de salvar';
        }
        return null;
      },
    );
  }

  Widget _buildVariedadeField() {
    return TextFormField(
      controller: _variedadeController,
      decoration: const InputDecoration(
        labelText: 'Variedade',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.nature),
        hintText: 'Preenchida automaticamente do talhão',
      ),
      readOnly: true,
    );
  }

  Widget _buildMesField() {
    return DropdownButtonFormField<int>(
      value: _mesSelecionado,
      decoration: const InputDecoration(
        labelText: 'Mês de Colheita',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_month),
      ),
      items: List.generate(_meses.length, (index) {
        return DropdownMenuItem(
          value: index + 1,
          child: Text(_meses[index]),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _mesSelecionado = value);
      },
    );
  }

  Widget _buildEstagioField() {
    return TextFormField(
      controller: _estagioController,
      decoration: const InputDecoration(
        labelText: 'Estágio',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.info),
        hintText: 'Ex: Meio de safra, Final de safra',
      ),
    );
  }

  Widget _buildPesoLiquidoField() {
    return TextFormField(
      controller: _pesoLiquidoController,
      decoration: const InputDecoration(
        labelText: 'Peso Líquido',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.scale),
        suffixText: 'toneladas',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
    );
  }

  Widget _buildMediaATRField() {
    return TextFormField(
      controller: _mediaATRController,
      decoration: const InputDecoration(
        labelText: 'Média ATR',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.functions),
        hintText: 'Açúcar Total Recuperável',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
    );
  }

  Widget _buildObservacoesField() {
    return TextFormField(
      controller: _observacoesController,
      decoration: const InputDecoration(
        labelText: 'Observações',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.notes),
      ),
      maxLines: 3,
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

    // Validação adicional para talhaoId
    if (_talhaoSelecionado == null || _talhaoSelecionado!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Selecione um talhão antes de salvar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final produtividade = Produtividade(
        id: widget.produtividade?.id ?? '',
        propriedadeId: widget.propriedade.id,
        talhaoId: _talhaoSelecionado?.isEmpty ?? true ? null : _talhaoSelecionado,
        anoSafra: _anoSafraController.text,
        variedade: _variedadeController.text.isEmpty 
            ? null 
            : _variedadeController.text,
        estagio: _estagioController.text.isEmpty
            ? null
            : _estagioController.text,
        mesColheita: _mesSelecionado,
        pesoLiquidoToneladas: _pesoLiquidoController.text.isEmpty
            ? null
            : double.parse(_pesoLiquidoController.text),
        mediaATR: _mediaATRController.text.isEmpty
            ? null
            : double.parse(_mediaATRController.text),
        observacoes: _observacoesController.text.isEmpty
            ? null
            : _observacoesController.text,
        createdAt: widget.produtividade?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.produtividade == null) {
        await _produtividadeService.createProdutividade(produtividade);
      } else {
        await _produtividadeService.updateProdutividade(produtividade);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.produtividade == null
                ? 'Produtividade registrada com sucesso'
                : 'Produtividade atualizada com sucesso'),
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
}