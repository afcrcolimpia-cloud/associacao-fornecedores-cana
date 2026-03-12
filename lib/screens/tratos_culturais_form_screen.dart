import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../widgets/app_shell.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/tratos_culturais_service.dart';
import '../widgets/insumo_selector_widget.dart';

class TratosCulturaisFormScreen extends StatefulWidget {
  final Propriedade propriedade;
  final List<Talhao> talhoes;
  final TratosCulturais? tratos;

  const TratosCulturaisFormScreen({
    super.key,
    required this.propriedade,
    required this.talhoes,
    this.tratos,
  });

  @override
  State<TratosCulturaisFormScreen> createState() =>
      _TratosCulturaisFormScreenState();
}

class _TratosCulturaisFormScreenState extends State<TratosCulturaisFormScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<Insumo> _adubos;
  late List<Insumo> _herbicidas;
  late List<Insumo> _inseticidas;
  late List<Insumo> _maturadores;

  late TextEditingController _calagemController;
  late TextEditingController _gessagemController;
  late TextEditingController _oxidoController;
  late TextEditingController _extraNome1Controller;
  late TextEditingController _extraValor1Controller;
  late TextEditingController _extraNome2Controller;
  late TextEditingController _extraValor2Controller;
  late TextEditingController _extraNome3Controller;
  late TextEditingController _extraValor3Controller;

  int _selectedNavigationIndex = 0;
  Talhao? _talhaoSelecionado;
  int _anoSafra = DateTime.now().year;
  bool _salvando = false;

  final TratosCulturaisService _service = TratosCulturaisService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    if (widget.tratos != null) {
      _adubos = List.from(widget.tratos!.adubos ?? []);
      _herbicidas = List.from(widget.tratos!.herbicidas ?? []);
      _inseticidas = List.from(widget.tratos!.inseticidas ?? []);
      _maturadores = List.from(widget.tratos!.maturadores ?? []);
      _anoSafra = int.tryParse(widget.tratos!.anoSafra) ?? DateTime.now().year;

      // Selecionar talhão existente
      if (widget.tratos!.talhaoId != null) {
        final idx = widget.talhoes.indexWhere((t) => t.id == widget.tratos!.talhaoId);
        if (idx >= 0) _talhaoSelecionado = widget.talhoes[idx];
      }
    } else {
      _adubos = [];
      _herbicidas = [];
      _inseticidas = [];
      _maturadores = [];
    }

    _calagemController = TextEditingController(
      text: widget.tratos?.calagem?.toString() ?? '',
    );
    _gessagemController = TextEditingController(
      text: widget.tratos?.gessagem?.toString() ?? '',
    );
    _oxidoController = TextEditingController(
      text: widget.tratos?.oxidoDeCilcio?.toString() ?? '',
    );
    _extraNome1Controller = TextEditingController();
    _extraValor1Controller = TextEditingController();
    _extraNome2Controller = TextEditingController();
    _extraValor2Controller = TextEditingController();
    _extraNome3Controller = TextEditingController();
    _extraValor3Controller = TextEditingController();

    if (widget.tratos?.camposExtras != null) {
      final chaves = widget.tratos!.camposExtras!.keys.toList();
      if (chaves.isNotEmpty) {
        _extraNome1Controller.text = chaves[0];
        _extraValor1Controller.text = widget.tratos!.camposExtras![chaves[0]]?.toString() ?? '';
      }
      if (chaves.length > 1) {
        _extraNome2Controller.text = chaves[1];
        _extraValor2Controller.text = widget.tratos!.camposExtras![chaves[1]]?.toString() ?? '';
      }
      if (chaves.length > 2) {
        _extraNome3Controller.text = chaves[2];
        _extraValor3Controller.text = widget.tratos!.camposExtras![chaves[2]]?.toString() ?? '';
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _calagemController.dispose();
    _gessagemController.dispose();
    _oxidoController.dispose();
    _extraNome1Controller.dispose();
    _extraValor1Controller.dispose();
    _extraNome2Controller.dispose();
    _extraValor2Controller.dispose();
    _extraNome3Controller.dispose();
    _extraValor3Controller.dispose();
    super.dispose();
  }

  void _adicionarInsumo(List<Insumo> lista, String categoria) {
    if (lista.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo de 10 tipos por categoria'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => _DialogAdicionarInsumoV2(
        categoria: categoria,
        onSalvar: (insumo) {
          setState(() {
            lista.add(insumo);
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _removerInsumo(List<Insumo> lista, int index) {
    setState(() {
      lista.removeAt(index);
    });
  }

  double get _custoTotalInsumos {
    double total = 0.0;
    for (final i in _adubos) { total += i.custoTotal; }
    for (final i in _herbicidas) { total += i.custoTotal; }
    for (final i in _inseticidas) { total += i.custoTotal; }
    for (final i in _maturadores) { total += i.custoTotal; }
    return total;
  }

  Future<void> _salvar() async {
    if (_talhaoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um talhão'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      // Montar campos extras
      Map<String, double>? camposExtras;
      final extras = <String, double>{};
      if (_extraNome1Controller.text.isNotEmpty) {
        extras[_extraNome1Controller.text] =
            double.tryParse(_extraValor1Controller.text) ?? 0;
      }
      if (_extraNome2Controller.text.isNotEmpty) {
        extras[_extraNome2Controller.text] =
            double.tryParse(_extraValor2Controller.text) ?? 0;
      }
      if (_extraNome3Controller.text.isNotEmpty) {
        extras[_extraNome3Controller.text] =
            double.tryParse(_extraValor3Controller.text) ?? 0;
      }
      if (extras.isNotEmpty) camposExtras = extras;

      final trato = TratosCulturais(
        id: widget.tratos?.id ?? '',
        propriedadeId: widget.propriedade.id,
        talhaoId: _talhaoSelecionado!.id,
        anoSafra: _anoSafra.toString(),
        adubos: _adubos.isNotEmpty ? _adubos : null,
        herbicidas: _herbicidas.isNotEmpty ? _herbicidas : null,
        inseticidas: _inseticidas.isNotEmpty ? _inseticidas : null,
        maturadores: _maturadores.isNotEmpty ? _maturadores : null,
        calagem: double.tryParse(_calagemController.text),
        gessagem: double.tryParse(_gessagemController.text),
        oxidoDeCilcio: double.tryParse(_oxidoController.text),
        camposExtras: camposExtras,
        dataAplicacao: DateTime.now(),
        talhaoNumero: _talhaoSelecionado!.numeroTalhao,
        variedadeNome: _talhaoSelecionado!.variedade,
        areaHaTalhao: _talhaoSelecionado!.areaHa,
      );

      if (widget.tratos != null) {
        await _service.updateTratos(trato);
      } else {
        await _service.addTratos(trato);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trato salvo com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      title: widget.tratos == null ? 'Novo Trato Cultural' : 'Editar Trato',
      showBackButton: true,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      child: Column(
        children: [
          // Cabeçalho: Talhão + Ano Safra
          _buildCabecalhoForm(),
          // TabBar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Adubo', icon: Icon(Icons.grain)),
              Tab(text: 'Herbicida', icon: Icon(Icons.bug_report)),
              Tab(text: 'Inseticida', icon: Icon(Icons.pest_control)),
              Tab(text: 'Maturador', icon: Icon(Icons.local_florist)),
            ],
          ),
          // Abas de insumos
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAbaInsumo(_adubos, 'Adubo', 'kg/ha'),
                _buildAbaInsumo(_herbicidas, 'Herbicida', 'kg ou L/ha'),
                _buildAbaInsumo(_inseticidas, 'Inseticida', 'kg ou L/ha'),
                _buildAbaInsumo(_maturadores, 'Maturador', 'L/ha'),
              ],
            ),
          ),
          // Resumo de custo + botão salvar
          _buildRodapeForm(),
        ],
      ),
    );
  }

  Widget _buildCabecalhoForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownSearch<Talhao>(
                    selectedItem: _talhaoSelecionado,
                    items: (filtro, _) {
                      final f = filtro.toLowerCase();
                      if (f.isEmpty) return widget.talhoes;
                      return widget.talhoes.where((t) =>
                          t.nome.toLowerCase().contains(f) ||
                          (t.variedade ?? '').toLowerCase().contains(f) ||
                          t.numeroTalhao.toLowerCase().contains(f)).toList();
                    },
                    itemAsString: (t) =>
                        '${t.nome} — ${t.variedade ?? "sem variedade"} — ${t.areaHa?.toStringAsFixed(1) ?? "?"} ha',
                    compareFn: (a, b) => a.id == b.id,
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: 'Talhão',
                        prefixIcon: Icon(Icons.grid_view),
                        border: OutlineInputBorder(),
                        hintText: 'Selecione o talhão',
                      ),
                    ),
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Buscar por número, nome ou variedade...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    onChanged: (talhao) {
                      setState(() => _talhaoSelecionado = talhao);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Ano Safra',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    value: _anoSafra,
                    items: List.generate(5, (index) {
                      final ano = DateTime.now().year - index;
                      return DropdownMenuItem(value: ano, child: Text(ano.toString()));
                    }),
                    onChanged: (v) {
                      if (v != null) setState(() => _anoSafra = v);
                    },
                  ),
                ),
              ],
            ),
            if (_talhaoSelecionado != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Área: ${_talhaoSelecionado!.areaHa?.toStringAsFixed(1) ?? "?"} ha  |  '
                      'Variedade: ${_talhaoSelecionado!.variedade ?? "Não informada"}  |  '
                      'Corte: ${_talhaoSelecionado!.corte ?? "-"}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRodapeForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Icon(Icons.monetization_on, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Text(
            'Custo total insumos: R\$ ${_custoTotalInsumos.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _salvando ? null : () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _salvando ? null : _salvar,
            icon: _salvando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_salvando ? 'Salvando...' : 'Salvar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbaInsumo(
      List<Insumo> lista, String categoria, String unidade) {
    return Column(
      children: [
        Expanded(
          child: lista.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhum $categoria adicionado',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final insumo = lista[index];
                    return _buildInsumoCard(insumo, lista, index, unidade);
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: Text('Adicionar $categoria'),
            onPressed: lista.length < 10
                ? () => _adicionarInsumo(lista, categoria.toLowerCase())
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildInsumoCard(Insumo insumo, List<Insumo> lista, int index, String unidade) {
    final temDose = insumo.doseMinima != null && insumo.doseMaxima != null;
    final statusColor = !temDose
        ? Colors.grey
        : insumo.doseEstaNoRange
            ? Colors.green
            : Colors.orange;

    return Card(
      child: ListTile(
        leading: Icon(
          temDose
              ? (insumo.doseEstaNoRange ? Icons.check_circle : Icons.warning)
              : Icons.circle_outlined,
          color: statusColor,
        ),
        title: Text(insumo.nome),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${insumo.quantidade.toStringAsFixed(2)} ${insumo.unidade}'),
            if (temDose)
              Text(
                'Dose: ${insumo.doseMinima!.toStringAsFixed(2)} - ${insumo.doseMaxima!.toStringAsFixed(2)} ${insumo.unidade}  •  ${insumo.statusDose}',
                style: TextStyle(fontSize: 11, color: statusColor),
              ),
            if (insumo.precoUnitario != null && insumo.precoUnitario! > 0)
              Text(
                'Custo: R\$ ${insumo.custoTotal.toStringAsFixed(2)} (R\$ ${insumo.precoUnitario!.toStringAsFixed(2)}/${insumo.unidade})',
                style: TextStyle(fontSize: 11, color: Colors.green[700]),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removerInsumo(lista, index),
        ),
      ),
    );
  }
}

/// Dialog v2 para adicionar insumo — com InsumoSelectorWidget integrado
class _DialogAdicionarInsumoV2 extends StatefulWidget {
  final String categoria;
  final Function(Insumo insumo) onSalvar;

  const _DialogAdicionarInsumoV2({
    required this.categoria,
    required this.onSalvar,
  });

  @override
  State<_DialogAdicionarInsumoV2> createState() => _DialogAdicionarInsumoV2State();
}

class _DialogAdicionarInsumoV2State extends State<_DialogAdicionarInsumoV2> {
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  InsumoComDose? _insumoSelecionado;
  bool _usarCatalogo = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  void _salvar() {
    final nome = _usarCatalogo && _insumoSelecionado != null
        ? _insumoSelecionado!.produto
        : _nomeController.text;

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome do insumo'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final quantidadeText = _quantidadeController.text.replaceAll(',', '.');
    final quantidade = double.tryParse(quantidadeText);
    if (quantidade == null || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantidade inválida'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.onSalvar(Insumo(
      nome: nome,
      quantidade: quantidade,
      unidade: _insumoSelecionado?.unidade ?? 'kg/ha',
      dataAplicacao: DateTime.now(),
      doseMinima: _insumoSelecionado?.doseMinima,
      doseMaxima: _insumoSelecionado?.doseMaxima,
      precoUnitario: _insumoSelecionado?.precoUnitario,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar ${widget.categoria}'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle: Catálogo x Manual
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Catálogo'),
                      selected: _usarCatalogo,
                      onSelected: (v) => setState(() => _usarCatalogo = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Manual'),
                      selected: !_usarCatalogo,
                      onSelected: (v) => setState(() => _usarCatalogo = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_usarCatalogo) ...[
                InsumoSelectorWidget(
                  onInsumoSelecionado: (insumo) {
                    setState(() => _insumoSelecionado = insumo);
                    if (insumo != null) {
                      // Sugerir dose média
                      final doseSugerida = (insumo.doseMinima + insumo.doseMaxima) / 2;
                      _quantidadeController.text = doseSugerida.toStringAsFixed(2);
                    }
                  },
                ),
              ] else ...[
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Insumo',
                    hintText: 'Ex: Adubo NPK 4-14-8',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              TextField(
                controller: _quantidadeController,
                decoration: InputDecoration(
                  labelText: 'Quantidade (dose)',
                  suffixText: _insumoSelecionado?.unidade ?? 'kg/ha ou L/ha',
                  border: const OutlineInputBorder(),
                  helperText: _insumoSelecionado != null
                      ? 'Recomendado: ${_insumoSelecionado!.doseMinima} - ${_insumoSelecionado!.doseMaxima} ${_insumoSelecionado!.unidade}'
                      : null,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvar,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}