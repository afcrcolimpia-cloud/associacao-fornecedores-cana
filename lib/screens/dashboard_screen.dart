import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/proprietario_service.dart';
import '../services/propriedade_service.dart';
import '../services/talhao_service.dart';
import 'proprietarios_screen.dart';
import 'propriedades_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _proprietarioService = ProprietarioService();
  final _propriedadeService = PropriedadeService();
  final _talhaoService = TalhaoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Estatísticas resumidas no topo
            StreamBuilder<List<Proprietario>>(
              stream: _proprietarioService.getProprietariosStream(),
              builder: (context, proprietariosSnapshot) {
                if (proprietariosSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final proprietarios = proprietariosSnapshot.data ?? [];

                return Column(
                  children: [
                    _buildResumoCards(proprietarios),
                    const SizedBox(height: 24),
                    
                    // Título
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Menu Principal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // MENU EM LISTA HORIZONTAL
                    _buildMenuItem(
                      icon: Icons.person,
                      title: 'Proprietários',
                      subtitle: 'Gerenciar proprietários',
                      color: Colors.blue,
                      count: proprietarios.length.toString(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProprietariosScreen()),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildMenuItemWithStream(
                      icon: Icons.location_city,
                      title: 'Propriedades',
                      subtitle: 'Visualizar propriedades',
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PropriedadesScreen()),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildMenuItem(
                      icon: Icons.landscape,
                      title: 'Talhões',
                      subtitle: 'Gerenciar talhões',
                      color: Colors.brown,
                      count: '',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecione uma propriedade primeiro')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildMenuItem(
                      icon: Icons.attach_file,
                      title: 'Anexos',
                      subtitle: 'Documentos e arquivos',
                      color: Colors.orange,
                      count: '',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecione uma propriedade primeiro')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildMenuItem(
                      icon: Icons.agriculture,
                      title: 'Operações',
                      subtitle: 'Operações de cultivo',
                      color: Colors.teal,
                      count: '',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecione uma propriedade primeiro')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildMenuItem(
                      icon: Icons.trending_up,
                      title: 'Produtividade',
                      subtitle: 'Análise de produção',
                      color: Colors.purple,
                      count: '',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Em desenvolvimento')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildMenuItem(
                      icon: Icons.water_drop,
                      title: 'Precipitação',
                      subtitle: 'Dados de chuvas',
                      color: Colors.lightBlue,
                      count: '',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Em desenvolvimento')),
                        );
                      },
                    ),
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

    return StreamBuilder<List<Propriedade>>(
      stream: _propriedadeService.getAllPropriedadesStream(),
      builder: (context, snapshotPropriedades) {
        final propriedades = snapshotPropriedades.data ?? [];
        final propriedadesAtivas = propriedades.where((p) => p.ativa ?? true).length;

        return FutureBuilder<double>(
          future: _computeTotalAreaFromPropriedades(propriedades),
          builder: (context, snapshotAreaTotal) {
            final areaTotalGeral = snapshotAreaTotal.data ?? 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 88,
                  child: _buildStatCard(
                    title: 'Proprietários',
                    value: proprietarios.length.toString(),
                    icon: Icons.people,
                    color: AppColors.primary,
                    subtitle: '$proprietariosAtivos ativos',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 88,
                  child: _buildStatCard(
                    title: 'Propriedades',
                    value: propriedades.length.toString(),
                    icon: Icons.home_work,
                    color: AppColors.secondary,
                    subtitle: '$propriedadesAtivas ativas',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 88,
                  child: _buildStatCard(
                    title: 'Área total (ha)',
                    value: areaTotalGeral.toStringAsFixed(2),
                    icon: Icons.terrain,
                    color: AppColors.primary,
                    subtitle: null,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<double> _computeTotalAreaFromPropriedades(List<Propriedade> propriedades) async {
    double total = 0.0;
    for (var p in propriedades) {
      if (p.areaHa != null && p.areaHa! > 0) {
        total += p.areaHa!;
      } else {
        try {
          final area = await _talhaoService.getAreaTotalPropriedade(p.id);
          total += area;
        } catch (_) {}
      }
    }
    return total;
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 76,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: color.withOpacity(0.12),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.bodyMedium),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MENU ITEM EM LISTA HORIZONTAL
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String count,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              // Ícone
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contador (se tiver)
              if (count.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    count,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              // Seta
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menu com contador dinâmico
  Widget _buildMenuItemWithStream({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return StreamBuilder<List<Propriedade>>(
      stream: _propriedadeService.getAllPropriedadesStream(),
      builder: (context, snapshot) {
        final count = (snapshot.data ?? []).length.toString();
        
        return _buildMenuItem(
          icon: icon,
          title: title,
          subtitle: subtitle,
          color: color,
          count: count,
          onTap: onTap,
        );
      },
    );
  }
}