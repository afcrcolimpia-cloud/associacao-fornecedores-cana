import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../services/proprietario_service.dart';
import '../utils/formatters.dart';
import 'propriedade_form_screen.dart';
import 'talhoes_screen.dart';

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
  final _propriedadeService = PropriedadeService();
  final _proprietarioService = ProprietarioService();
  late Propriedade _propriedade;
  Proprietario? _proprietario;

  @override
  void initState() {
    super.initState();
    _propriedade = widget.propriedade;
    _loadProprietario();
  }

  Future<void> _loadProprietario() async {
    final proprietario =
        await _proprietarioService.getProprietario(_propriedade.proprietarioId);
    if (mounted) {
      setState(() {
        _proprietario = proprietario;
      });
    }
  }

  Future<void> _deletar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir ${_propriedade.nomePropriedade}?'),
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
        await _propriedadeService.deletePropriedade(_propriedade.id);

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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropriedadeFormScreen(
          propriedade: _propriedade,
        ),
      ),
    );

    if (result == true && mounted) {
      final atualizada =
          await _propriedadeService.getPropriedade(_propriedade.id);
      if (atualizada != null) {
        setState(() {
          _propriedade = atualizada;
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
          // Card Cabeçalho
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.secondary,
                    child: const Icon(
                      Icons.home_work,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _propriedade.nomePropriedade,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FA: ${_propriedade.numeroFA}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Card Proprietário
          if (_proprietario != null)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _proprietario!.nome.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: const Text('Proprietário'),
                subtitle: Text(_proprietario!.nome),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),

          const SizedBox(height: 16),

          // Card Informações
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                  const Divider(height: 24),
                  if (_propriedade.inscricaoEstadual != null) ...[
                    _buildInfoRow('Inscrição Estadual',
                        _propriedade.inscricaoEstadual!),
                    const SizedBox(height: 12),
                  ],
                  if (_propriedade.municipio != null) ...[
                    _buildInfoRow('Município', _propriedade.municipio!),
                    const SizedBox(height: 12),
                  ],
                  if (_propriedade.coordenadasGPS != null) ...[
                    _buildInfoRow('Coordenadas GPS', _propriedade.coordenadasGPS!),
                    const SizedBox(height: 12),
                  ],
                  _buildInfoRow(
                    'Cadastrado em',
                    Formatters.formatDateTime(_propriedade.criadoEm),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Botão Talhões
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.accent,
                child: const Icon(
                  Icons.grid_on,
                  color: Colors.white,
                ),
              ),
              title: const Text('Talhões'),
              subtitle: const Text('Gerenciar talhões desta propriedade'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TalhoesScreen(
                      propriedade: _propriedade,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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