// lib/screens/proprietarios_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/proprietario_service.dart';
import '../utils/formatters.dart';
import 'proprietario_form_screen.dart';
import 'proprietario_detail_screen.dart';

class ProprietariosScreen extends StatefulWidget {
  const ProprietariosScreen({super.key});

  @override
  State<ProprietariosScreen> createState() => _ProprietariosScreenState();
}

class _ProprietariosScreenState extends State<ProprietariosScreen> {
  final _service = ProprietarioService();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarAfcrc(
        title: 'Proprietários',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar proprietário...',
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
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Proprietario>>(
        stream: _service.getProprietariosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar dados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          var proprietarios = snapshot.data ?? [];

          // Filtrar por busca
          if (_searchQuery.isNotEmpty) {
            proprietarios = proprietarios.where((p) {
              return p.nome.toLowerCase().contains(_searchQuery) ||
                  p.cpfCnpj.contains(_searchQuery);
            }).toList();
          }

          if (proprietarios.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isEmpty
                        ? Icons.person_add_outlined
                        : Icons.search_off,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Nenhum proprietário cadastrado'
                        : 'Nenhum resultado encontrado',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Clique no botão + para adicionar'
                        : 'Tente buscar por outro termo',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Contador
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.background,
                child: Row(
                  children: [
                    const Icon(
                      Icons.people,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${proprietarios.length} ${proprietarios.length == 1 ? "proprietário" : "proprietários"}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lista
              Expanded(
                child: ListView.builder(
                  itemCount: proprietarios.length,
                  itemBuilder: (context, index) {
                    final proprietario = proprietarios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            proprietario.nome.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          proprietario.nome,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              proprietario.cpfCnpj.length == 11
                                  ? 'CPF: ${Formatters.formatCPF(proprietario.cpfCnpj)}'
                                  : 'CNPJ: ${Formatters.formatCNPJ(proprietario.cpfCnpj)}',
                            ),
                            if (proprietario.cidade != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${proprietario.cidade}, ${proprietario.estado ?? ""}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProprietarioDetailScreen(
                                proprietario: proprietario,
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
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProprietarioFormScreen(),
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
}