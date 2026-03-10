import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/tratos_culturais_service.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _service = TratosCulturaisService();

  late TabController _tabController;
  late String _talhaoSelecionado;
  late int _anoSafra;
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    if (widget.tratos != null) {
      _talhaoSelecionado = widget.tratos!.talhaoId ?? '';
      _anoSafra = int.tryParse(widget.tratos!.anoSafra) ?? DateTime.now().year;
      _adubos = List.from(widget.tratos!.adubos ?? []);
      _herbicidas = List.from(widget.tratos!.herbicidas ?? []);
      _inseticidas = List.from(widget.tratos!.inseticidas ?? []);
      _maturadores = List.from(widget.tratos!.maturadores ?? []);
    } else {
      // Se houver talhões disponíveis, seleciona o primeiro; caso contrário, deixa vazio
      _talhaoSelecionado = widget.talhoes.isNotEmpty ? widget.talhoes.first.id : '';
      _anoSafra = DateTime.now().year;
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
      builder: (context) => _DialogAdicionarInsumo(
        categoria: categoria,
        onSalvar: (nome, quantidade) {
          setState(() {
            lista.add(Insumo(
              nome: nome,
              quantidade: quantidade,
              unidade: 'kg/ha',
              dataAplicacao: DateTime.now(),
            ));
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removerInsumo(List<Insumo> lista, int index) {
    setState(() {
      lista.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      title: widget.tratos == null ? 'Novo Trato Cultural' : 'Editar Trato',
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      child: Column(
        children: [
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
        ],
      ),
    );
  }

  Widget _buildAbaInsumo(
      List<Insumo> lista, String categoria, String unidade) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final insumo = lista[index];
              return Card(
                child: ListTile(
                  title: Text(insumo.nome),
                  subtitle: Text('${insumo.quantidade.toStringAsFixed(2)} $unidade'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removerInsumo(lista, index),
                  ),
                ),
              );
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
}

class _DialogAdicionarInsumo extends StatefulWidget {
  final String categoria;
  final Function(String nome, double quantidade) onSalvar;

  const _DialogAdicionarInsumo({
    required this.categoria,
    required this.onSalvar,
  });

  @override
  State<_DialogAdicionarInsumo> createState() => _DialogAdicionarInsumoState();
}

class _DialogAdicionarInsumoState extends State<_DialogAdicionarInsumo> {
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_nomeController.text.isEmpty || _quantidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final quantidade = double.tryParse(_quantidadeController.text);
    if (quantidade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantidade invalida'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.onSalvar(_nomeController.text, quantidade);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar ${widget.categoria}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome do Insumo',
              hintText: 'Ex: Adubo NPK 4-14-8',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantidadeController,
            decoration: const InputDecoration(
              labelText: 'Quantidade',
              suffixText: 'kg/ha ou L/ha',
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}