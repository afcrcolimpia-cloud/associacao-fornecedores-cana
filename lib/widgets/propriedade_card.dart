import 'package:flutter/material.dart';
import '../models/models.dart';
import '../constants/app_colors.dart';

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
  final VoidCallback? onManageProdutividade;

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
    this.onManageProdutividade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: propriedade.ativa
              ? AppColors.success.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
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
              // Cabeçalho
              Row(
                children: [
                  // Ícone de status
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: propriedade.ativa
                          ? AppColors.success.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.home_work,
                      color: propriedade.ativa ? AppColors.success : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Nome da propriedade
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          propriedade.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (nomeProprietario != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  nomeProprietario!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Menu de ações
                  if (onEdit != null || 
                      onDelete != null || 
                      onToggleStatus != null ||
                      onManageTalhoes != null ||
                      onManageAnexos != null ||
                      onManageTratos != null ||
                      onManageOperacoes != null ||
                      onManageProdutividade != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                          case 'toggle':
                            onToggleStatus?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                        if (onToggleStatus != null)
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  propriedade.ativa ? Icons.cancel : Icons.check_circle,
                                  size: 20,
                                  color: propriedade.ativa ? Colors.orange : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  propriedade.ativa ? 'Inativar' : 'Ativar',
                                  style: TextStyle(
                                    color: propriedade.ativa ? Colors.orange : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Informações
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (propriedade.numeroFA.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.tag,
                        label: 'F.A.',
                        value: propriedade.numeroFA,
                        color: AppColors.primary,
                      ),
                    if (propriedade.areaTotalHectares != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.terrain,
                        label: 'Área Total',
                        value: '${propriedade.areaTotalHectares!.toStringAsFixed(2)} ha',
                        color: AppColors.secondary,
                      ),
                    ],
                    if (propriedade.localizacao?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.location_on,
                        label: 'Localização',
                        value: propriedade.localizacao!,
                        color: Colors.red,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Botões de ação
              if (onManageTalhoes != null ||
                  onManageAnexos != null ||
                  onManageTratos != null ||
                  onManageOperacoes != null ||
                  onManageProdutividade != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (onManageTalhoes != null)
                      _buildActionButton(
                        icon: Icons.landscape,
                        label: 'Talhões',
                        color: Colors.brown,
                        onPressed: onManageTalhoes!,
                      ),
                    if (onManageAnexos != null)
                      _buildActionButton(
                        icon: Icons.attach_file,
                        label: 'Anexos',
                        color: Colors.orange,
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
                        color: Colors.teal,
                        onPressed: onManageOperacoes!,
                      ),
                    if (onManageProdutividade != null)
                      _buildActionButton(
                        icon: Icons.show_chart,
                        label: 'Produtividade',
                        color: Colors.purple,
                        onPressed: onManageProdutividade!,
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }
}