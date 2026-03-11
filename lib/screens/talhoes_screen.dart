import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../models/models.dart';
import '../services/talhao_service.dart';
import 'talhao_form_screen.dart';

class TalhoesScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const TalhoesScreen({
    super.key,
    required this.contexto,
  });

  @override
  State<TalhoesScreen> createState() => _TalhoesScreenState();
}

class _TalhoesScreenState extends State<TalhoesScreen> {
  final TalhaoService _service = TalhaoService();
  int _selectedNavigationIndex = 0;
  String _filtro = 'todos';
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: 'Talhões',
      child: _buildConteudo(),
    );
  }

  Widget _buildConteudo() {
    return StreamBuilder<List<Talhao>>(
      stream: _service.getTalhoesStream(widget.contexto.propriedade.id),
      builder: (context, snapshot) {
        final todosTalhoes = snapshot.data ?? [];
        final somaArea = _calcularSomaArea(todosTalhoes);
        final areaReforma = _calcularAreaReforma(todosTalhoes);
        final areaLiquida = somaArea - areaReforma;
        return Column(
          children: [
            HeaderPropriedade(
              contexto: widget.contexto,
              infoExtra: [
                MapEntry('Área Total', '${somaArea.toStringAsFixed(1)} ha'),
                MapEntry('Reforma', '${areaReforma.toStringAsFixed(1)} ha'),
                MapEntry('Área Líquida', '${areaLiquida.toStringAsFixed(1)} ha'),
                MapEntry('Qtd Talhões', '${todosTalhoes.length}'),
              ],
            ),
            _buildFiltros(),
            Expanded(
              child: _buildTalhoesFiltrados(todosTalhoes, snapshot),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar talhão...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() => _busca = value.toLowerCase());
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFiltroChip('Todos', 'todos'),
                const SizedBox(width: 8),
                _buildFiltroChip('Ativos', 'ativos'),
                const SizedBox(width: 8),
                _buildFiltroChip('Inativos', 'inativos'),
                const SizedBox(width: 8),
                _buildFiltroChip('Reforma', 'reforma'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroChip(String label, String value) {
    final isSelected = _filtro == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filtro = value);
      },
      backgroundColor: AppColors.surfaceDark,
      selectedColor: AppColors.newPrimary.withOpacity(0.3),
    );
  }

  double _calcularSomaArea(List<Talhao> talhoes) {
    return talhoes.fold<double>(0, (soma, t) => soma + (t.areaHa ?? 0));
  }

  double _calcularAreaReforma(List<Talhao> talhoes) {
    return talhoes
        .where((t) => t.isReforma)
        .fold<double>(0, (soma, t) => soma + (t.areaHa ?? 0));
  }

  Widget _buildTalhoesFiltrados(List<Talhao> todosTalhoes, AsyncSnapshot<List<Talhao>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Erro: ${snapshot.error}'));
    }

    var talhoes = List<Talhao>.from(todosTalhoes);

        // Filtrar por status
        if (_filtro == 'ativos') {
          talhoes = talhoes.where((t) => t.ativo).toList();
        } else if (_filtro == 'inativos') {
          talhoes = talhoes.where((t) => !t.ativo).toList();
        } else if (_filtro == 'reforma') {
          talhoes = talhoes.where((t) => t.isReforma).toList();
        }

        // Aplicar busca
        if (_busca.isNotEmpty) {
          talhoes = talhoes
              .where((t) =>
                  t.numeroTalhao.toLowerCase().contains(_busca) ||
                  (t.cultura?.toLowerCase().contains(_busca) ?? false))
              .toList();
        }

        if (talhoes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.grass,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum talhão encontrado',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: talhoes.length,
          itemBuilder: (context, index) {
            final talhao = talhoes[index];
            return _buildTalhaoCard(talhao);
          },
        );
  }

  Widget _buildTalhaoCard(Talhao talhao) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _mostrarFormulario(talhao: talhao),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Número do talhão
              SizedBox(
                width: 90,
                child: Text(
                  'Talhão ${talhao.numeroTalhao}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Área
              SizedBox(
                width: 80,
                child: Text(
                  '${talhao.areaHa ?? 0} ha',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              // Cultura
              Expanded(
                child: Text(
                  talhao.cultura ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Variedade
              Expanded(
                child: Text(
                  talhao.variedade ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: talhao.ativo ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  talhao.ativo ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                    color: talhao.ativo ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Ações
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: Colors.blue,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Editar',
                onPressed: () => _mostrarFormulario(talhao: talhao),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                color: Colors.red,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Deletar',
                onPressed: () => _confirmarExclusao(talhao.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarFormulario({Talhao? talhao}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TalhaoFormScreen(
          propriedade: widget.contexto.propriedade,
          talhao: talhao,
        ),
      ),
    );

    if (resultado == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmarExclusao(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir este talhão?'),
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

    if (confirmar == true) {
      try {
        await _service.deleteTalhao(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Talhão excluído com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }
}