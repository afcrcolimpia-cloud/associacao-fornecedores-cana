import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../utils/formatters.dart';
import 'talhao_form_screen.dart';

class TalhoesScreen extends StatefulWidget {
  final Propriedade propriedade;

  const TalhoesScreen({
    super.key,
    required this.propriedade,
  });

  @override
  State<TalhoesScreen> createState() => _TalhoesScreenState();
}

class _TalhoesScreenState extends State<TalhoesScreen> {
  final _service = PropriedadeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talhões'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withOpacity(0.1),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.propriedade.nomePropriedade,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'FA: ${widget.propriedade.numeroFA}',
                        style: TextStyle(
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
        ),
      ),
      body: StreamBuilder<List<Talhao>>(
        stream: _service.getTalhoesByPropriedadeStream(widget.propriedade.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar talhões',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          final talhoes = snapshot.data ?? [];

          if (talhoes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.grid_on,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum talhão cadastrado',
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

          // Calcular totais
          final totalHectares = talhoes.fold<double>(
            0,
            (sum, t) => sum + t.areaHectares,
          );
          final totalAlqueires = talhoes.fold<double>(
            0,
            (sum, t) => sum + t.areaAlqueires,
          );

          return Column(
            children: [
              // Card de Totais
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${talhoes.length}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Talhões',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.divider,
                    ),
                    Column(
                      children: [
                        Text(
                          Formatters.formatNumber(totalHectares),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Hectares',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.divider,
                    ),
                    Column(
                      children: [
                        Text(
                          Formatters.formatNumber(totalAlqueires),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Alqueires',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Lista de Talhões
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: talhoes.length,
                  itemBuilder: (context, index) {
                    final talhao = talhoes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.accent,
                          child: Text(
                            talhao.numeroTalhao,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          'Talhão ${talhao.numeroTalhao}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          '${Formatters.formatHectares(talhao.areaHectares)} • ${Formatters.formatAlqueires(talhao.areaAlqueires)}',
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                              onTap: () async {
                                await Future.delayed(Duration.zero);
                                if (!mounted) return;
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TalhaoFormScreen(
                                      propriedade: widget.propriedade,
                                      talhao: talhao,
                                    ),
                                  ),
                                );

                                if (mounted && result == true) {
                                  setState(() {});
                                }
                              },
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Excluir', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                              onTap: () async {
                                await Future.delayed(Duration.zero);
                                if (!mounted) return;
                                _deletarTalhao(talhao);
                              },
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildInfoRow('Variedade', talhao.variedade),
                                const Divider(height: 16),
                                _buildInfoRow('Ano Plantio', talhao.anoPlantio.toString()),
                                const Divider(height: 16),
                                _buildInfoRow('Corte', '${talhao.corte}º corte'),
                                if (talhao.observacoes != null && talhao.observacoes!.isNotEmpty) ...[
                                  const Divider(height: 16),
                                  _buildInfoRow('Observações', talhao.observacoes!),
                                ],
                              ],
                            ),
                          ),
                        ],
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
              builder: (_) => TalhaoFormScreen(
                propriedade: widget.propriedade,
              ),
            ),
          );

          if (mounted && result == true) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deletarTalhao(Talhao talhao) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o Talhão ${talhao.numeroTalhao}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteTalhao(talhao.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Talhão excluído com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
