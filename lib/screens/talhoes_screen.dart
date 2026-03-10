import 'package:flutter/material.dart';
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
      child: Column(
        children: [
          HeaderPropriedade(contexto: widget.contexto),
          _buildFiltros(),
          Expanded(
            child: _buildTalhoes(),
          ),
        ],
      ),
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
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.green[300],
    );
  }

  Widget _buildTalhoes() {
    return StreamBuilder<List<Talhao>>(
      stream: _service.getTalhoesStream(widget.contexto.propriedade.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        var talhoes = snapshot.data ?? [];

        // Filtrar por status
        if (_filtro == 'ativos') {
          talhoes = talhoes.where((t) => t.ativo).toList();
        } else if (_filtro == 'inativos') {
          talhoes = talhoes.where((t) => !t.ativo).toList();
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
          padding: const EdgeInsets.all(16),
          itemCount: talhoes.length,
          itemBuilder: (context, index) {
            final talhao = talhoes[index];
            return _buildTalhaoCard(talhao);
          },
        );
      },
    );
  }

  Widget _buildTalhaoCard(Talhao talhao) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _mostrarFormulario(talhao: talhao),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Talhão ${talhao.numeroTalhao}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (talhao.cultura != null)
                          Text(
                            talhao.cultura!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (talhao.variedade != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Variedade: ${talhao.variedade}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: talhao.ativo ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(20),
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
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.agriculture,
                      'Área',
                      '${talhao.areaHa} ha',
                    ),
                  ),
                  if (talhao.areaAlqueires != null)
                    Expanded(
                      child: _buildInfoItem(
                        Icons.agriculture,
                        'Alqueires',
                        '${talhao.areaAlqueires} alq',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: 'Editar',
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      iconSize: 20,
                      onPressed: () => _mostrarFormulario(talhao: talhao),
                    ),
                  ),
                  Tooltip(
                    message: 'Deletar',
                    child: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      iconSize: 20,
                      onPressed: () => _confirmarExclusao(talhao.id),
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

  Widget _buildInfoItem(IconData icon, String label, String? value) {
    if (value == null) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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