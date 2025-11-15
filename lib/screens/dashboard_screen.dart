import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/proprietario_service.dart';
import '../services/propriedade_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _proprietarioService = ProprietarioService();
  final _propriedadeService = PropriedadeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StreamBuilder<List<Proprietario>>(
              stream: _proprietarioService.getProprietariosStream(),
              builder: (context, proprietariosSnapshot) {
                if (proprietariosSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (proprietariosSnapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${proprietariosSnapshot.error}'),
                  );
                }

                final proprietarios = proprietariosSnapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResumoCards(proprietarios),
                    const SizedBox(height: 24),
                    _buildPropriedadesList(proprietarios),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoCards(List<Proprietario> proprietarios) {
    final proprietariosAtivos = proprietarios.where((p) => p.ativo).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Proprietários',
          value: proprietarios.length.toString(),
          icon: Icons.people,
          color: AppColors.primary,
          subtitle: '$proprietariosAtivos ativos',
        ),
        _buildStatCard(
          title: 'Propriedades',
          value: '0',
          icon: Icons.home_work,
          color: AppColors.secondary,
          subtitle: 'Carregando...',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPropriedadesList(List<Proprietario> proprietarios) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Propriedades por Proprietário',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 16),
            ...proprietarios.map((proprietario) {
              return StreamBuilder<List<Propriedade>>(
                stream: _propriedadeService.getPropriedadesByProprietarioStream(proprietario.id),
                builder: (context, snapshot) {
                  final propriedades = snapshot.data ?? [];
                  
                  if (propriedades.isEmpty) return const SizedBox.shrink();
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        proprietario.nome.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(proprietario.nome),
                    subtitle: Text('${propriedades.length} propriedades'),
                    trailing: Text(
                      '${propriedades.fold<double>(0, (sum, p) => sum + p.areaTotalHectares).toStringAsFixed(2)} ha',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}