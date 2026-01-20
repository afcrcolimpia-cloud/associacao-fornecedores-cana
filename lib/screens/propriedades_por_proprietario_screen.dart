// lib/screens/propriedades_por_proprietario_screen.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../utils/formatters.dart';
import 'propriedade_detail_screen.dart';
import 'propriedade_form_screen.dart';
import 'operacoes_cultivo_screen.dart';

class PropriedadesPorProprietarioScreen extends StatefulWidget {
  final Proprietario proprietario;

  const PropriedadesPorProprietarioScreen({
    super.key,
    required this.proprietario,
  });

  @override
  State<PropriedadesPorProprietarioScreen> createState() =>
      _PropriedadesPorProprietarioScreenState();
}

class _PropriedadesPorProprietarioScreenState
    extends State<PropriedadesPorProprietarioScreen> {
  final _propriedadeService = PropriedadeService();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navegarParaOperacoes(Propriedade propriedade) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OperacoesCultivoScreen(propriedade: propriedade),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propriedades'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Header com info do proprietário
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primary.withOpacity(0.1),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 25,
                      child: Text(
                        widget.proprietario.nome.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.proprietario.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.proprietario.cpfCnpj.length == 11
                                ? 'CPF: ${Formatters.formatCPF(widget.proprietario.cpfCnpj)}'
                                : 'CNPJ: ${Formatters.formatCNPJ(widget.proprietario.cpfCnpj)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Campo de busca
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por F.A (ex: 3280)...',
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
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<Propriedade>>(
        stream: _propriedadeService
            .getPropriedadesByProprietarioStream(widget.proprietario.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                    'Erro ao carregar propriedades',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          var propriedades = snapshot.data ?? [];

          // Filtrar apenas ativas
          propriedades = propriedades.where((p) => p.ativa ?? true).toList();

          // Buscar por FA
          if (_searchQuery.isNotEmpty) {
            propriedades = propriedades.where((p) {
              return p.numeroFA.toLowerCase().contains(_searchQuery) ||
                  p.nomePropriedade.toLowerCase().contains(_searchQuery);
            }).toList();
          }

          if (propriedades.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isEmpty
                        ? Icons.home_work_outlined
                        : Icons.search_off,
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
                    _searchQuery.isEmpty
                        ? 'Clique no botão + para adicionar'
                        : 'Tente buscar por outro F.A',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.background,
                child: Row(
                  children: [
                    const Icon(
                      Icons.home_work,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${propriedades.length} ${propriedades.length == 1 ? "propriedade" : "propriedades"}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.secondary,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: propriedades.length,
                  itemBuilder: (context, index) {
                    final propriedade = propriedades[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.secondary,
                          child: Icon(
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
                            Text('F.A: ${propriedade.numeroFA}'),
                            if (propriedade.areaHa != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Área: ${Formatters.formatHectares(propriedade.areaHa!)}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: PopupMenuButton(
                          child: const Icon(
                            Icons.more_vert,
                            color: AppColors.textSecondary,
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text('Detalhes'),
                                ],
                              ),
                              onTap: () async {
                                if (!mounted) return;

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
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.agriculture_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Operações'),
                                ],
                              ),
                              onTap: () => _navegarParaOperacoes(propriedade),
                            ),
                          ],
                        ),
                        onTap: () async {
                          if (!mounted) return;

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
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!mounted) return;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropriedadeFormScreen(
                proprietarioId: widget.proprietario.id,
              ),
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