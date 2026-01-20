import 'package:flutter/material.dart';
import '../models/models.dart';
import '../constants/app_colors.dart';
import '../utils/formatters.dart';

class PropriedadeCard extends StatelessWidget {
  final Propriedade propriedade;
  final String? nomeProprietario;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onManageTalhoes;
  final VoidCallback? onManageAnexos;
  final VoidCallback? onManageTratos;
  final VoidCallback? onManageOperacoes;

  const PropriedadeCard({
    super.key,
    required this.propriedade,
    this.nomeProprietario,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.onManageTalhoes,
    this.onManageAnexos,
    this.onManageTratos,
    this.onManageOperacoes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (propriedade.ativa ?? true)
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com informações principais
              Row(
                children: [
                  // Ícone de status
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (propriedade.ativa ?? true)
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      (propriedade.ativa ?? true) ? Icons.check_circle : Icons.cancel,
                      color: (propriedade.ativa ?? true) ? AppColors.success : AppColors.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Informações da propriedade
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          propriedade.nomePropriedade,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'F.A: ${propriedade.numeroFA}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (nomeProprietario != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Proprietário: $nomeProprietario',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Chip de status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (propriedade.ativa ?? true)
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (propriedade.ativa ?? true) ? 'Ativa' : 'Inativa',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: (propriedade.ativa ?? true) ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Detalhes da propriedade
              if (propriedade.areaHa != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.square_foot,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Área: ${Formatters.formatHectares(propriedade.areaHa!)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              // Botões de ação
              if (onEdit != null ||
                  onDelete != null ||
                  onToggleStatus != null ||
                  onManageTalhoes != null ||
                  onManageAnexos != null ||
                  onManageTratos != null ||
                  onManageOperacoes != null) ...[
                const Divider(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (onManageTalhoes != null)
                      _buildActionButton(
                        icon: Icons.landscape,
                        label: 'Talhões',
                        color: AppColors.primary,
                        onPressed: onManageTalhoes!,
                      ),
                    if (onManageAnexos != null)
                      _buildActionButton(
                        icon: Icons.attach_file,
                        label: 'Anexos',
                        color: AppColors.secondary,
                        onPressed: onManageAnexos!,
                      ),
                    if (onManageTratos != null)
                      _buildActionButton(
                        icon: Icons.medication,
                        label: 'Tratos',
                        color: Colors.green,
                        onPressed: onManageTratos!,
                      ),
                    if (onManageOperacoes != null)
                      _buildActionButton(
                        icon: Icons.agriculture,
                        label: 'Operações',
                        color: Colors.brown,
                        onPressed: onManageOperacoes!,
                      ),
                    if (onEdit != null)
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Editar',
                        color: AppColors.info,
                        onPressed: onEdit!,
                      ),
                    if (onToggleStatus != null)
                      _buildActionButton(
                        icon: (propriedade.ativa ?? true) ? Icons.block : Icons.check_circle,
                        label: (propriedade.ativa ?? true) ? 'Desativar' : 'Ativar',
                        color: (propriedade.ativa ?? true) ? AppColors.warning : AppColors.success,
                        onPressed: onToggleStatus!,
                      ),
                    if (onDelete != null)
                      _buildActionButton(
                        icon: Icons.delete,
                        label: 'Deletar',
                        color: AppColors.error,
                        onPressed: onDelete!,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
