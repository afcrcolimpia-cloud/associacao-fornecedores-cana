import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/app_shell.dart';
import '../models/insumo_com_dose.dart';
import '../services/insumo_com_dose_service.dart';
import 'insumo_form_screen.dart';

class InsumosScreen extends StatefulWidget {
  const InsumosScreen({super.key});

  @override
  State<InsumosScreen> createState() => _InsumosScreenState();
}

class _InsumosScreenState extends State<InsumosScreen> {
  final InsumoComDoseService _service = InsumoComDoseService();
  int _selectedNavigationIndex = 0;

  List<InsumoComDose> _todosInsumos = [];
  List<InsumoComDose> _insumosFiltrados = [];
  List<String> _categorias = [];
  bool _carregando = true;
  String? _erro;

  String? _categoriaFiltro;
  String? _tipoFiltro;
  List<String> _tiposDisponiveis = [];
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resultados = await Future.wait([
        _service.buscarInsumos(),
        _service.buscarCategorias(),
      ]);
      if (mounted) {
        setState(() {
          _todosInsumos = resultados[0] as List<InsumoComDose>;
          _categorias = resultados[1] as List<String>;
          _aplicarFiltros();
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = e.toString();
          _carregando = false;
        });
      }
    }
  }

  void _aplicarFiltros() {
    var lista = List<InsumoComDose>.from(_todosInsumos);

    if (_categoriaFiltro != null) {
      lista = lista.where((i) => i.categoria == _categoriaFiltro).toList();
    }
    if (_tipoFiltro != null) {
      lista = lista.where((i) => i.tipo == _tipoFiltro).toList();
    }

    final busca = _buscaController.text.toLowerCase().trim();
    if (busca.isNotEmpty) {
      lista = lista.where((i) =>
          i.produto.toLowerCase().contains(busca) ||
          i.tipo.toLowerCase().contains(busca) ||
          i.categoria.toLowerCase().contains(busca)).toList();
    }

    _insumosFiltrados = lista;
  }

  void _onCategoriaChanged(String? categoria) {
    setState(() {
      _categoriaFiltro = categoria;
      _tipoFiltro = null;
      if (categoria != null) {
        _tiposDisponiveis = _todosInsumos
            .where((i) => i.categoria == categoria)
            .map((i) => i.tipo)
            .toSet()
            .toList()
          ..sort();
      } else {
        _tiposDisponiveis = [];
      }
      _aplicarFiltros();
    });
  }

  void _onTipoChanged(String? tipo) {
    setState(() {
      _tipoFiltro = tipo;
      _aplicarFiltros();
    });
  }

  void _onBuscaChanged(String _) {
    setState(() => _aplicarFiltros());
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: 'Catálogo de Insumos',
      child: Stack(
        children: [
          _buildConteudo(),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: () => _abrirFormulario(),
              backgroundColor: AppColors.newPrimary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'Novo Insumo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    return Column(
      children: [
        _buildFiltros(),
        Expanded(child: _buildCorpo()),
      ],
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de busca
          TextField(
            controller: _buscaController,
            onChanged: _onBuscaChanged,
            decoration: InputDecoration(
              hintText: 'Buscar por produto, tipo ou categoria...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _buscaController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _buscaController.clear();
                        _onBuscaChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          // Filtros por categoria e tipo
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _categoriaFiltro,
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todas'),
                    ),
                    ..._categorias.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: _onCategoriaChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _tipoFiltro,
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    ..._tiposDisponiveis.map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: _categoriaFiltro != null ? _onTipoChanged : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Contagem
          if (!_carregando)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_insumosFiltrados.length} de ${_todosInsumos.length} insumos',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.newDanger),
            const SizedBox(height: 12),
            const Text('Erro ao carregar insumos',
                style: TextStyle(color: AppColors.newDanger)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _carregarDados,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_insumosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _todosInsumos.isEmpty
                  ? 'Nenhum insumo cadastrado'
                  : 'Nenhum insumo encontrado com este filtro',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            if (_todosInsumos.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Clique em "Novo Insumo" para começar',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: _insumosFiltrados.length,
        itemBuilder: (context, index) =>
            _buildInsumoCard(_insumosFiltrados[index]),
      ),
    );
  }

  Widget _buildInsumoCard(InsumoComDose insumo) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + menu
            Row(
              children: [
                const Icon(Icons.shopping_bag, color: AppColors.primary, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    insumo.produto,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (insumo.situacao != null && insumo.situacao!.isNotEmpty)
                  _buildSituacaoBadge(insumo.situacao!),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  onSelected: (value) => _acaoMenu(value, insumo),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),
            // Info em row
            Row(
              children: [
                _infoChip(Icons.category, insumo.categoria),
                const SizedBox(width: 16),
                _infoChip(Icons.label, insumo.tipo),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _infoChip(
                  Icons.science,
                  'Dose: ${insumo.doseMinima} – ${insumo.doseMaxima} ${insumo.unidade}',
                ),
                const Spacer(),
                Text(
                  'R\$ ${insumo.precoUnitario.toStringAsFixed(2)} / ${insumo.unidade}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.newPrimary,
                  ),
                ),
              ],
            ),
            if (insumo.observacoes != null && insumo.observacoes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                insumo.observacoes!,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSituacaoBadge(String situacao) {
    final cor = situacao.toLowerCase() == 'ativo'
        ? AppColors.newPrimary
        : AppColors.newWarning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.4)),
      ),
      child: Text(
        situacao,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cor),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }

  // ── Ações ──────────────────────────────────────────────────

  Future<void> _abrirFormulario({InsumoComDose? insumo}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => InsumoFormScreen(
          insumo: insumo,
          categoriasExistentes: _categorias,
        ),
      ),
    );
    if (resultado == true) {
      _carregarDados();
    }
  }

  Future<void> _acaoMenu(String acao, InsumoComDose insumo) async {
    switch (acao) {
      case 'editar':
        _abrirFormulario(insumo: insumo);
        break;
      case 'excluir':
        _confirmarExclusao(insumo);
        break;
    }
  }

  void _confirmarExclusao(InsumoComDose insumo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Insumo?'),
        content: Text(
          'Deseja excluir "${insumo.produto}"?\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _service.deletarInsumo(insumo.id);
                _carregarDados();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Insumo excluído com sucesso')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newDanger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
