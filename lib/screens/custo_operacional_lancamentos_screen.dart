import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../services/custo_operacional_repository.dart';
import '../services/custo_operacional_service.dart';
import '../constants/app_colors.dart';
import 'custo_operacional_lancamento_screen.dart';

// ---------------------------------------------
// TELA: GERENCIADOR DE LANÇAMENTOS DINÂMICOS
// ---------------------------------------------

class CustoOperacionalLancamentosScreen extends StatefulWidget {
  final String propriedadeId;
  final String propriedadeNome;
  final String? talhaoId;
  final String? talhaoNome;
  final int safra;

  const CustoOperacionalLancamentosScreen({
    super.key,
    required this.propriedadeId,
    required this.propriedadeNome,
    this.talhaoId,
    this.talhaoNome,
    required this.safra,
  });

  @override
  State<CustoOperacionalLancamentosScreen> createState() =>
      _CustoOperacionalLancamentosScreenState();
}

class _CustoOperacionalLancamentosScreenState
    extends State<CustoOperacionalLancamentosScreen>
    with SingleTickerProviderStateMixin {
  final _repo = CustoOperacionalRepository();
  final _service = CustoOperacionalService();
  late TabController _tabCtrl;
  int _selectedNavigationIndex = 0;

  final List<String> _abasNomes = [
    'Conservação de Solo',
    'Preparo de Solo',
    'Plantio',
    'Manutenção de Soqueira',
    'Sistema de Colheita',
  ];

  List<CategoriaModel> _categorias = [];
  Map<String, List<LancamentoModel>> _lancamentos = {};
  Map<String, double> _totaisPorCateg = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _abasNomes.length, vsync: this);
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final resultados = await Future.wait([
      _repo.getCategorias(),
      _repo.getLancamentos(
        propriedadeId: widget.propriedadeId,
        safra: widget.safra,
      ),
    ]);

    final cats = resultados[0] as List<CategoriaModel>;
    final todos = resultados[1] as List<LancamentoModel>;

    final Map<String, List<LancamentoModel>> map = {};
    for (final c in cats) {
      map[c.id] = todos.where((l) => l.categoriaId == c.id).toList();
    }

    final totais = <String, double>{};
    for (final entrada in map.entries) {
      totais[entrada.key] = entrada.value.fold<double>(
        0.0,
        (soma, lancamento) => soma + (lancamento.custoTotalRha ?? 0.0),
      );
    }

    if (mounted) {
      setState(() {
        _categorias = cats;
        _lancamentos = map;
        _totaisPorCateg = totais;
        _carregando = false;
      });
    }
  }

  Future<void> _recalcularECarregar() async {
    await _service.recalcularTotaisPorPropriedadeSafra(
      widget.propriedadeId,
      widget.safra,
    );
    await _carregar();
  }

  Future<void> _abrirEditar(LancamentoModel lancamento) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CustoOperacionalLancamentoScreen(
          propriedadeId: widget.propriedadeId,
          talhaoId: widget.talhaoId,
          safra: widget.safra,
          edicao: lancamento,
        ),
      ),
    );
    if (ok != true) return;
    await _recalcularECarregar();
  }

  Future<void> _confirmarExcluir(LancamentoModel l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir lançamento?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final sucesso = await _repo.deletarLancamento(l.id!);
    if (!sucesso) return;

    await _recalcularECarregar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lançamento excluído'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      title: 'Custo Operacional Dinâmico',
      child: Column(
        children: [
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: _abasNomes.map((a) => Tab(text: a)).toList(),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabCtrl,
                    children: _abasNomes.map((nomeAba) {
                      final indiceCategoria =
                          _categorias.indexWhere((c) => c.nome == nomeAba);
                      if (indiceCategoria < 0) {
                        return _buildCategoriaNaoEncontrada(nomeAba);
                      }
                      final cat = _categorias[indiceCategoria];
                      final lista = _lancamentos[cat.id] ?? [];
                      final total = _totaisPorCateg[cat.id] ?? 0.0;
                      return _buildListaTab(cat, lista, total);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaTab(
    CategoriaModel cat,
    List<LancamentoModel> lista,
    double total,
  ) {
    return Column(
      children: [
        // Total da categoria
        Container(
          width: double.infinity,
          color: AppColors.lightBackground,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total da Categoria',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    'R\$ ${total.toStringAsFixed(2)}/ha',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${lista.length} item(ns)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (lista.isNotEmpty)
                    Text(
                      '${(total / lista.length).toStringAsFixed(2)}/média',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Lista de lançamentos
        Expanded(
          child: lista.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.agriculture_outlined,
                          size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhum lançamento\npara esta etapa',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _cardLancamento(lista[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoriaNaoEncontrada(String nomeAba) {
    return Center(
      child: Text(
        'Categoria "$nomeAba" não encontrada no catálogo.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _cardLancamento(LancamentoModel l) {
    final operacao = l.operacaoCustom ?? 'N/A';

    return Card(
      child: InkWell(
        onTap: () => _abrirEditar(l),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primeira linha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      operacao,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${(l.custoTotalRha ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                      const Text('/ha',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Detalhes
              if (l.maquinaCustom != null && l.maquinaCustom!.isNotEmpty)
                _detalhe('Máquina: ${l.maquinaCustom}'),
              if (l.implementoCustom != null && l.implementoCustom!.isNotEmpty)
                _detalhe('Implemento: ${l.implementoCustom}'),
              if (l.insumoCustom != null && l.insumoCustom!.isNotEmpty)
                _detalhe(
                    'Insumo: ${l.insumoCustom} ${l.insumoDose?.toStringAsFixed(2) ?? ''}/ha'),
              const SizedBox(height: 8),
              // Breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Operação: R\$ ${(l.operacaoRha ?? 0).toStringAsFixed(2)}/ha',
                      style: const TextStyle(fontSize: 11)),
                  Text(
                      'Insumo: R\$ ${(l.insumoRha ?? 0).toStringAsFixed(2)}/ha',
                      style: const TextStyle(fontSize: 11)),
                ],
              ),
              const SizedBox(height: 8),
              // Ações
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _abrirEditar(l),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child:
                          Icon(Icons.edit, size: 18, color: AppColors.primary),
                    ),
                  ),
                  InkWell(
                    onTap: () => _confirmarExcluir(l),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.delete, size: 18, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detalhe(String texto) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(texto,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      );

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }
}
