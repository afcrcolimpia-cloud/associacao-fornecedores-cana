// lib/screens/propriedade_detail_screen.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../utils/formatters.dart';
import 'propriedade_form_screen.dart';
import 'talhoes_screen.dart';
import 'anexos_screen.dart';
import 'precipitacao_screen.dart';

class PropriedadeDetailScreen extends StatefulWidget {
  final Propriedade propriedade;

  const PropriedadeDetailScreen({
    super.key,
    required this.propriedade,
  });

  @override
  State<PropriedadeDetailScreen> createState() =>
      _PropriedadeDetailScreenState();
}

class _PropriedadeDetailScreenState extends State<PropriedadeDetailScreen> {
  final _service = PropriedadeService();
  late Propriedade _propriedade;

  @override
  void initState() {
    super.initState();
    _propriedade = widget.propriedade;
  }

  Future<void> _deletar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Deseja realmente excluir a propriedade ${_propriedade.nomePropriedade}?'),
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

    if (confirm == true && mounted) {
      try {
        await _service.deletePropriedade(_propriedade.id);

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Propriedade excluída com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
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

  Future<void> _editar() async {
    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropriedadeFormScreen(
          propriedade: _propriedade,
        ),
      ),
    );

    if (result == true && mounted) {
      final atualizado = await _service.getPropriedade(_propriedade.id);
      if (atualizado != null && mounted) {
        setState(() {
          _propriedade = atualizado;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Propriedade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: _editar,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Excluir',
            onPressed: _deletar,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card Principal
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.secondary,
                    child: Text(
                      _propriedade.nomePropriedade.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _propriedade.nomePropriedade,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (_propriedade.ativa ?? true)
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (_propriedade.ativa ?? true) ? 'ATIVA' : 'INATIVA',
                      style: TextStyle(
                        color: (_propriedade.ativa ?? true)
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Card de Informações Básicas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'Informações Básicas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.secondary,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    label: 'F.A',
                    value: _propriedade.numeroFA,
                  ),
                  const SizedBox(height: 12),
                  if (_propriedade.areaHa != null) ...[
                    _buildInfoRow(
                      context,
                      label: 'Área Total',
                      value: Formatters.formatHectares(
                          _propriedade.areaHa!),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_propriedade.cidade != null) ...[
                    _buildInfoRow(
                      context,
                      label: 'Município',
                      value: _propriedade.cidade!,
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Card de Talhões
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.accent,
                child: Icon(Icons.grid_on, color: Colors.white),
              ),
              title: const Text('Talhões'),
              subtitle: const Text('Gerenciar talhões desta propriedade'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TalhoesScreen(
                      propriedadeId: _propriedade.id,
                      propriedadeNome: _propriedade.nomePropriedade,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Card de Anexos
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.info,
                child: Icon(Icons.attach_file, color: Colors.white),
              ),
              title: const Text('Anexos'),
              subtitle: const Text('Mapas, KML, Relatórios'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnexosScreen(propriedade: _propriedade),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Card de Precipitação por Propriedade
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.water_drop, color: Colors.white),
              ),
              title: const Text('PRECIPITAÇÃO POR PROPRIEDADES'),
              subtitle: const Text('Dados pluviométricos da propriedade'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrecipitacaoScreen(propriedade: _propriedade),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Card de Informações do Sistema
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Informações do Sistema',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    label: 'Cadastrada em',
                    value: Formatters.formatDateTime(_propriedade.criadoEm),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    label: 'Última atualização',
                    value: Formatters.formatDateTime(_propriedade.atualizadoEm),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 8),
        ],
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}