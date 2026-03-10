import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../widgets/propriedade_card.dart';
import 'propriedade_form_screen.dart';
import 'propriedade_detail_screen.dart';

class PropriedadesPorProprietarioScreen extends StatefulWidget {
  final String proprietarioId;
  final String proprietarioNome;

  const PropriedadesPorProprietarioScreen({
    super.key,
    required this.proprietarioId,
    required this.proprietarioNome,
  });

  @override
  State<PropriedadesPorProprietarioScreen> createState() => 
      _PropriedadesPorProprietarioScreenState();
}

class _PropriedadesPorProprietarioScreenState extends State<PropriedadesPorProprietarioScreen> {
  final PropriedadeService _service = PropriedadeService();
  String _filtro = 'todas';
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarAfcrc(
        title: 'Propriedades de ${widget.proprietarioNome}',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _mostrarFormulario,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltros(),
          Expanded(
            child: _buildPropriedades(),
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
              hintText: 'Buscar propriedade...',
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
                _buildFiltroChip('Todas', 'todas'),
                const SizedBox(width: 8),
                _buildFiltroChip('Ativas', 'ativas'),
                const SizedBox(width: 8),
                _buildFiltroChip('Inativas', 'inativas'),
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

  Widget _buildPropriedades() {
    return StreamBuilder<List<Propriedade>>(
      stream: _service.getPropriedadesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        var propriedades = snapshot.data ?? [];

        // Filtrar por proprietário
        propriedades = propriedades
            .where((p) => p.proprietarioId == widget.proprietarioId)
            .toList();

        // Aplicar filtro de status
        if (_filtro == 'ativas') {
          propriedades = propriedades.where((p) => p.ativa).toList();
        } else if (_filtro == 'inativas') {
          propriedades = propriedades.where((p) => !p.ativa).toList();
        }

        // Aplicar busca
        if (_busca.isNotEmpty) {
          propriedades = propriedades
              .where((p) =>
                  p.nomePropriedade.toLowerCase().contains(_busca) ||
                  p.numeroFA.toLowerCase().contains(_busca) ||
                  (p.cidade?.toLowerCase().contains(_busca) ?? false))
              .toList();
        }

        if (propriedades.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_city,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma propriedade encontrada',
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
          itemCount: propriedades.length,
          itemBuilder: (context, index) {
            final propriedade = propriedades[index];
            return PropriedadeCard(
              propriedade: propriedade,
              onTap: () => _abrirDetalhes(propriedade),
              onEdit: () => _mostrarFormulario(propriedade: propriedade),
              onDelete: () => _confirmarExclusao(propriedade),
            );
          },
        );
      },
    );
  }

  Future<void> _mostrarFormulario({Propriedade? propriedade}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PropriedadeFormScreen(
          propriedade: propriedade,
          proprietarioIdInicial: widget.proprietarioId,
          bloquearProprietario: true,
        ),
      ),
    );

    if (resultado == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmarExclusao(Propriedade propriedade) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir "${propriedade.nomePropriedade}"?\n\nEsta ação não pode ser desfeita.',
        ),
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

    if (confirmar == true && mounted) {
      try {
        await _service.deletePropriedade(propriedade.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Propriedade excluída com sucesso')),
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

  void _abrirDetalhes(Propriedade propriedade) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropriedadeDetailScreen(
          propriedadeId: propriedade.id,
        ),
      ),
    );
  }
}
