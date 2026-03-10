import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../services/proprietario_service.dart';
import '../utils/formatters.dart';
import '../widgets/propriedade_card.dart';
import 'propriedade_form_screen.dart';
import 'propriedade_detalhes_screen.dart';

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

class _PropriedadesPorProprietarioScreenState
    extends State<PropriedadesPorProprietarioScreen> {
  final PropriedadeService _service = PropriedadeService();
  String _filtro = 'todas';
  String _busca = '';
  int _selectedNavigationIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      title: 'Propriedades de ${widget.proprietarioNome}',
      child: Column(
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
      onSelected: (_) {
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
        propriedades = propriedades
            .where((p) => p.proprietarioId == widget.proprietarioId)
            .toList();

        if (_filtro == 'ativas') {
          propriedades = propriedades.where((p) => p.ativa).toList();
        } else if (_filtro == 'inativas') {
          propriedades = propriedades.where((p) => !p.ativa).toList();
        }

        if (_busca.isNotEmpty) {
          propriedades = propriedades
              .where(
                (p) =>
                    p.nomePropriedade.toLowerCase().contains(_busca) ||
                    p.numeroFA.toLowerCase().contains(_busca) ||
                    (p.cidade?.toLowerCase().contains(_busca) ?? false),
              )
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
        title: const Text('Confirmar Exclusao'),
        content: Text(
          'Deseja realmente excluir "${propriedade.nomePropriedade}"?\n\nEsta acao nao pode ser desfeita.',
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

    if (confirmar != true || !mounted) return;

    try {
      await _service.deletePropriedade(propriedade.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Propriedade excluida com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    }
  }

  void _abrirDetalhes(Propriedade propriedade) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropriedadeDetalhesScreen(
          propriedade: propriedade,
        ),
      ),
    );
  }
}

class PropriedadesScreen extends StatefulWidget {
  const PropriedadesScreen({
    super.key,
  });

  @override
  State<PropriedadesScreen> createState() => _PropriedadesScreenState();
}

class _PropriedadesScreenState extends State<PropriedadesScreen> {
  final PropriedadeService _propriedadeService = PropriedadeService();
  final ProprietarioService _proprietarioService = ProprietarioService();
  final TextEditingController _buscaController = TextEditingController();
  String _busca = '';
  int _selectedNavigationIndex = 0;

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      title: 'Propriedades por Proprietário',
      child: Column(
        children: [
          _buildBuscaProprietario(),
          Expanded(
            child: _buildListaProprietarios(),
          ),
        ],
      ),
    );
  }

  Widget _buildBuscaProprietario() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _buscaController,
        decoration: InputDecoration(
          hintText: 'Buscar proprietario...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _busca.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _buscaController.clear();
                      _busca = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          setState(() => _busca = value.toLowerCase());
        },
      ),
    );
  }

  Widget _buildListaProprietarios() {
    return StreamBuilder<List<Proprietario>>(
      stream: _proprietarioService.getProprietariosStream(),
      builder: (context, proprietariosSnapshot) {
        if (proprietariosSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (proprietariosSnapshot.hasError) {
          return Center(child: Text('Erro: ${proprietariosSnapshot.error}'));
        }

        var proprietarios = proprietariosSnapshot.data ?? [];
        if (_busca.isNotEmpty) {
          proprietarios = proprietarios
              .where(
                (p) =>
                    p.nome.toLowerCase().contains(_busca) ||
                    p.cpfCnpj.contains(_busca),
              )
              .toList();
        }

        if (proprietarios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_search,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum proprietario encontrado',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return StreamBuilder<List<Propriedade>>(
          stream: _propriedadeService.getPropriedadesStream(),
          builder: (context, propriedadesSnapshot) {
            final propriedades = propriedadesSnapshot.data ?? [];
            final contagemPorProprietario = <String, int>{};

            for (final propriedade in propriedades) {
              contagemPorProprietario[propriedade.proprietarioId] =
                  (contagemPorProprietario[propriedade.proprietarioId] ?? 0) +
                      1;
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: proprietarios.length,
              itemBuilder: (context, index) {
                final proprietario = proprietarios[index];
                final total = contagemPorProprietario[proprietario.id] ?? 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        proprietario.nome.isEmpty
                            ? '?'
                            : proprietario.nome.substring(0, 1).toUpperCase(),
                      ),
                    ),
                    title: Text(proprietario.nome),
                    subtitle: Text(
                      proprietario.cpfCnpj.length == 11
                          ? 'CPF: ${Formatters.formatCPF(proprietario.cpfCnpj)}'
                          : 'CNPJ: ${Formatters.formatCNPJ(proprietario.cpfCnpj)}',
                    ),
                    trailing: Text(
                      '$total ${total == 1 ? "propriedade" : "propriedades"}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () => _abrirPropriedadesDoProprietario(proprietario),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _abrirPropriedadesDoProprietario(Proprietario proprietario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropriedadesPorProprietarioScreen(
          proprietarioId: proprietario.id,
          proprietarioNome: proprietario.nome,
        ),
      ),
    );
  }
}
