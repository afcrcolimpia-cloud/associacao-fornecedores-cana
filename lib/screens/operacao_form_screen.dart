import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../widgets/app_shell.dart';
import '../models/models.dart';
import '../services/operacao_cultivo_service.dart';
import '../services/talhao_service.dart';
import '../services/variedade_service.dart';
import '../constants/app_colors.dart';
import '../utils/formatters.dart';

class OperacaoFormScreen extends StatefulWidget {
  final Propriedade propriedade;
  final OperacaoCultivo? operacao;

  const OperacaoFormScreen({
    super.key,
    required this.propriedade,
    this.operacao,
  });

  @override
  State<OperacaoFormScreen> createState() => _OperacaoFormScreenState();
}

class _OperacaoFormScreenState extends State<OperacaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final OperacaoCultivoService _service = OperacaoCultivoService();
  final TalhaoService _talhaoService = TalhaoService();
  final VariedadeService _variedadeService = VariedadeService();

  List<Talhao> _talhoes = [];
  Map<String, Variedade> _variedadeMap = {};
  bool _isLoading = true;
  bool _isSaving = false;
  int _selectedNavigationIndex = 0;

  String? _talhaoSelecionado;
  DateTime? _dataPlantio;
  DateTime? _dataQuebraLombo;
  DateTime? _dataColheita;
  DateTime? _data1aHerbicida;
  DateTime? _data2aHerbicida;
  final _observacoesController = TextEditingController();

  bool _copiarParaOutros = false;
  final List<String> _talhoesSelecionados = [];

  @override
  void initState() {
    super.initState();
    _carregarTalhoes();
    _carregarDados();
    _carregarVariedades();
  }

  Future<void> _carregarVariedades() async {
    final mapa = await _variedadeService.getVariedadeMap();
    if (mounted) setState(() => _variedadeMap = mapa);
  }

  String _nomeVariedade(String? id) =>
      _variedadeService.resolverNomeSync(id, _variedadeMap);

  Future<void> _carregarTalhoes() async {
    try {
      final talhoes = await _talhaoService
          .getTalhoesByPropriedadeStream(widget.propriedade.id)
          .first;
      setState(() {
        _talhoes = talhoes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  void _carregarDados() {
    if (widget.operacao != null) {
      _talhaoSelecionado = widget.operacao!.talhaoId;
      _dataPlantio = widget.operacao!.dataPlantio;
      _dataQuebraLombo = widget.operacao!.dataQuebraLombo;
      _dataColheita = widget.operacao!.dataColheita;
      _data1aHerbicida = widget.operacao!.data1aAplicHerbicida;
      _data2aHerbicida = widget.operacao!.data2aAplicHerbicida;
      _observacoesController.text = widget.operacao!.observacoes ?? '';
    }
  }

  Future<void> _selecionarData(BuildContext context, String campo) async {
    DateTime? dataInicial;
    switch (campo) {
      case 'plantio': dataInicial = _dataPlantio; break;
      case 'quebraLombo': dataInicial = _dataQuebraLombo ?? _dataPlantio; break;
      case 'colheita': dataInicial = _dataColheita ?? _dataQuebraLombo ?? _dataPlantio; break;
      case '1aHerbicida': dataInicial = _data1aHerbicida ?? _dataPlantio; break;
      case '2aHerbicida': dataInicial = _data2aHerbicida ?? _data1aHerbicida ?? _dataPlantio; break;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: dataInicial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        switch (campo) {
          case 'plantio': _dataPlantio = picked; break;
          case 'quebraLombo': _dataQuebraLombo = picked; break;
          case 'colheita': _dataColheita = picked; break;
          case '1aHerbicida': _data1aHerbicida = picked; break;
          case '2aHerbicida': _data2aHerbicida = picked; break;
        }
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_talhaoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um talhão')),
      );
      return;
    }
    if (_dataPlantio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a data de plantio')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final operacao = OperacaoCultivo(
        id: widget.operacao?.id,
        propriedadeId: widget.propriedade.id,
        talhaoId: _talhaoSelecionado!,
        dataPlantio: _dataPlantio!,
        dataQuebraLombo: _dataQuebraLombo,
        dataColheita: _dataColheita,
        data1aAplicHerbicida: _data1aHerbicida,
        data2aAplicHerbicida: _data2aHerbicida,
        observacoes: _observacoesController.text.trim().isEmpty 
            ? null 
            : _observacoesController.text.trim(),
        createdAt: widget.operacao?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.operacao != null) {
        await _service.updateOperacao(operacao);
      } else {
        await _service.createOperacao(operacao);
        if (_copiarParaOutros && _talhoesSelecionados.isNotEmpty) {
          await _service.copiarParaTalhoes(operacao, _talhoesSelecionados);
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  int? _calcularDias(DateTime? inicio, DateTime? fim) {
    if (inicio == null || fim == null) return null;
    return fim.difference(inicio).inDays;
  }

  void _mostrarDadosTalhao(String talhaoId) {
    try {
      final talhao = _talhoes.firstWhere((t) => t.id == talhaoId);
      // Mostra um toast com as informa\u00e7\u00f5es do talh\u00e3o
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Talhão: ${talhao.nome} | Variedade: ${_nomeVariedade(talhao.variedade).isEmpty ? "N/A" : _nomeVariedade(talhao.variedade)} | Área: ${talhao.areaHa?.toStringAsFixed(2) ?? "N/A"} ha',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.success.withOpacity(0.8),
        ),
      );
    } catch (e) {
      debugPrint('Talh\u00e3o n\u00e3o encontrado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdicao = widget.operacao != null;
    
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      title: isEdicao ? 'Editar Operação' : 'Nova Operação',
      showBackButton: true,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildSelecaoTalhao(isEdicao),
                        const SizedBox(height: 16),
                        _buildDatasOperacoes(),
                        const SizedBox(height: 16),
                        _buildObservacoes(),
                        if (!isEdicao && _talhoes.length > 1) ...[
                          const SizedBox(height: 16),
                          _buildOpcaoCopiar(),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildBotaoSalvar(isEdicao),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSelecaoTalhao(bool isEdicao) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.landscape, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Talhão', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            DropdownSearch<Talhao>(
              selectedItem: _talhaoSelecionado != null
                  ? _talhoes.where((t) => t.id == _talhaoSelecionado).firstOrNull
                  : null,
              items: (filtro, _) {
                final f = filtro.toLowerCase();
                if (f.isEmpty) return _talhoes;
                return _talhoes.where((t) =>
                    t.numeroTalhao.toLowerCase().contains(f) ||
                    _nomeVariedade(t.variedade).toLowerCase().contains(f) ||
                    (t.cultura ?? '').toLowerCase().contains(f)).toList();
              },
              enabled: !isEdicao,
              itemAsString: (talhao) =>
                  '${talhao.numeroTalhao}'
                  '${talhao.variedade != null ? ' - ${_nomeVariedade(talhao.variedade)}' : ''}'
                  '${talhao.cultura != null ? ' (${talhao.cultura})' : ''}',
              compareFn: (a, b) => a.id == b.id,
              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: 'Selecione o talhão *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.landscape),
                ),
              ),
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Buscar por número ou variedade...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              validator: (value) => value == null ? 'Selecione um talhão' : null,
              onChanged: isEdicao ? null : (talhao) {
                setState(() {
                  _talhaoSelecionado = talhao?.id;
                  if (talhao != null) {
                    _mostrarDadosTalhao(talhao.id);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDatasOperacoes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Datas das Operações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildDateField(
            label: 'Data de Plantio *',
            icon: Icons.eco,
            data: _dataPlantio,
            onTap: () => _selecionarData(context, 'plantio'),
            color: AppColors.primary,
          ),
            const SizedBox(height: 12),
            _buildDateField(
            label: '1º Aplicação Herbicida',
            icon: Icons.science,
            data: _data1aHerbicida,
            onTap: () => _selecionarData(context, '1aHerbicida'),
            color: Colors.orange,
            dias: _calcularDias(_dataPlantio, _data1aHerbicida),
          ),
          const SizedBox(height: 12),
          
          // 3?? Data Quebra-lombo
          _buildDateField(
            label: 'Data Quebra-lombo',
            icon: Icons.construction,
            data: _dataQuebraLombo,
            onTap: () => _selecionarData(context, 'quebraLombo'),
            color: AppColors.info,
            dias: _calcularDias(_dataPlantio, _dataQuebraLombo),
          ),
          const SizedBox(height: 12),
          
          // 4?? 2º Aplicação Herbicida
          _buildDateField(
            label: '2º Aplicação Herbicida',
            icon: Icons.science,
            data: _data2aHerbicida,
            onTap: () => _selecionarData(context, '2aHerbicida'),
            color: Colors.deepOrange,
            dias: _calcularDias(_dataQuebraLombo, _data2aHerbicida),
          ),
          const SizedBox(height: 12),
          
          // 5?? Data de Colheita
          _buildDateField(
            label: 'Data de Colheita',
            icon: Icons.agriculture,
            data: _dataColheita,
            onTap: () => _selecionarData(context, 'colheita'),
            color: AppColors.success,
            dias: _calcularDias(_dataPlantio, _dataColheita),
            destaque: true,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildObservacoes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Observações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacoesController,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                hintText: 'Informações adicionais...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcaoCopiar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _copiarParaOutros,
                  onChanged: (value) {
                    setState(() {
                      _copiarParaOutros = value ?? false;
                      if (!_copiarParaOutros) _talhoesSelecionados.clear();
                    });
                  },
                ),
                const Expanded(
                  child: Text('Copiar para outros talhões', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            if (_copiarParaOutros) ...[
              const Divider(),
              const Text('Selecione os talhões:', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _talhoes
                    .where((t) => t.id != _talhaoSelecionado)
                    .map((talhao) {
                  final selecionado = _talhoesSelecionados.contains(talhao.id);
                  return FilterChip(
                    label: Text(talhao.numeroTalhao),
                    selected: selecionado,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _talhoesSelecionados.add(talhao.id);
                        } else {
                          _talhoesSelecionados.remove(talhao.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? data,
    required VoidCallback onTap,
    required Color color,
    int? dias,
    bool destaque = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderDark),
          borderRadius: BorderRadius.circular(8),
          color: destaque ? color.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 2),
                  Text(
                    data != null ? Formatters.formatDate(data) : 'Nºo informada',
                    style: TextStyle(
                      fontSize: destaque ? 15 : 14,
                      fontWeight: destaque ? FontWeight.bold : FontWeight.w500,
                      color: data != null ? AppColors.newTextPrimary : AppColors.newTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (dias != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('$dias dias', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
              ),
            const SizedBox(width: 8),
            Icon(Icons.calendar_today, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoSalvar(bool isEdicao) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          top: BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isSaving ? null : _salvar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  isEdicao ? 'Atualizar Operação' : 'Cadastrar Operação',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }
}
