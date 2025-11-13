import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../services/proprietario_service.dart';
import 'propriedade_form_screen.dart';
import 'propriedade_detail_screen.dart';

class PropriedadesScreen extends StatefulWidget {
  const PropriedadesScreen({super.key});

  @override
  State<PropriedadesScreen> createState() => _PropriedadesScreenState();
}

class _PropriedadesScreenState extends State<PropriedadesScreen> {
  final _propriedadeService = PropriedadeService();
  final _proprietarioService = ProprietarioService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _proprietarioSelecionado;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propriedades'),
      ),
      body: Column(
        children: [
          // Filtro por Proprietário
          StreamBuilder<List<Proprietario>>(
            stream: _proprietarioService.getProprietariosStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final proprietarios = snapshot.data!;

              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: DropdownButtonFormField<String>(
                  initialValue: _proprietarioSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por Proprietário',
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todos os proprietários'),
                    ),
                    ...proprietarios.map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.nome),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _proprietarioSelecionado = value;
                    });
                  },
                ),
              );
            },
          ),

          // Campo de Busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar propriedade...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Lista de Propriedades
          Expanded(
            child: StreamBuilder<List<Proprietario>>(
              stream: _proprietarioService.getProprietariosStream(),
              builder: (context, propSnapshot) {
                if (propSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (propSnapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${propSnapshot.error}'),
                  );
                }

                final todosProprietarios = propSnapshot.data ?? [];

                return StreamBuilder<List<Propriedade>>(
                  stream: _proprietarioSelecionado != null
                      ? _propriedadeService.getPropriedadesByProprietarioStream(
                          _proprietarioSelecionado!)
                      : _getAllPropriedades(todosProprietarios),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }

                    var propriedades = snapshot.data ?? [];

                    // Filtrar por busca
                    if (_searchQuery.isNotEmpty) {
                      propriedades = propriedades.where((p) {
                        return p.nomePropriedade.toLowerCase().contains(_searchQuery) ||
                            p.numeroFA.toLowerCase().contains(_searchQuery);
                      }).toList();
                    }

                    if (propriedades.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_work_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Nenhuma propriedade cadastrada'
                                  : 'Nenhum resultado encontrado',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Clique no botão + para adicionar',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: propriedades.length,
                      itemBuilder: (context, index) {
                        final propriedade = propriedades[index];
                        final proprietario = todosProprietarios.firstWhere(
                          (p) => p.id == propriedade.proprietarioId,
                          orElse: () => Proprietario(
                            id: '',
                            nome: 'Desconhecido',
                            cpfCnpj: '',
                            criadoEm: DateTime.now(),
                            atualizadoEm: DateTime.now(),
                          ),
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.secondary,
                              child: const Icon(
                                Icons.home_work,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              propriedade.nomePropriedade,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('FA: ${propriedade.numeroFA}'),
                                Text(
                                  'Proprietário: ${proprietario.nome}',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PropriedadeDetailScreen(
                                    propriedade: propriedade,
                                  ),
                                ),
                              );

                              if (result == true && mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PropriedadeFormScreen(),
            ),
          );

          if (result == true && mounted) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Stream<List<Propriedade>> _getAllPropriedades(
      List<Proprietario> proprietarios) async* {
    final allPropriedades = <Propriedade>[];

    for (final proprietario in proprietarios) {
      await for (final propriedades in _propriedadeService
          .getPropriedadesByProprietarioStream(proprietario.id)) {
        allPropriedades.addAll(propriedades);
        yield List.from(allPropriedades);
      }
    }
  }
}