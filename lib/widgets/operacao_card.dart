import 'package:flutter/material.dart';
import '../models/models.dart';
import '../constants/app_colors.dart';
import '../utils/formatters.dart';

class OperacaoCard extends StatelessWidget {
  final OperacaoCultivo operacao;
  final String? nomeTalhao;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const OperacaoCard({
    super.key,
    required this.operacao,
    this.nomeTalhao,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  int? _calcularDias(DateTime? dataInicio, DateTime? dataFim) {
    if (dataInicio == null || dataFim == null) return null;
    return dataFim.difference(dataInicio).inDays;
  }

  String _getStatusOperacao() {
    if (operacao.dataColheita != null) return 'Colhida';
    if (operacao.dataQuebraLombo != null) return 'Em Cultivo';
    return 'Plantada';
  }

  Color _getStatusColor() {
    if (operacao.dataColheita != null) return AppColors.success;
    if (operacao.dataQuebraLombo != null) return AppColors.info;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final diasPlantioColheita = _calcularDias(
      operacao.dataPlantio,
      operacao.dataColheita,
    );
    final diasPlantioQuebraLombo = _calcularDias(
      operacao.dataPlantio,
      operacao.dataQuebraLombo,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _getStatusColor().withOpacity(0.3)),
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
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusOperacao() == 'Colhida'
                          ? Icons.agriculture
                          : _getStatusOperacao() == 'Em Cultivo'
                              ? Icons.grass
                              : Icons.yard,
                      color: _getStatusColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nome do talhão
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nomeTalhao ?? 'Talhão ${operacao.talhaoId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusOperacao(),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Menu de ações
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
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
              const SizedBox(height: 16),

              // Informações de datas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Plantio
                    _buildDateRow(
                      icon: Icons.eco,
                      label: 'Plantio',
                      date: operacao.dataPlantio,
                      color: AppColors.primary,
                    ),

                    // Quebra-lombo
                    if (operacao.dataQuebraLombo != null) ...[
                      const SizedBox(height: 8),
                      _buildDateRow(
                        icon: Icons.construction,
                        label: 'Quebra-lombo',
                        date: operacao.dataQuebraLombo,
                        color: AppColors.info,
                        dias: diasPlantioQuebraLombo,
                      ),
                    ],

                    // 1º Aplicação Herbicida
                    if (operacao.data1aAplicHerbicida != null) ...[
                      const SizedBox(height: 8),
                      _buildDateRow(
                        icon: Icons.science,
                        label: '1º Herbicida',
                        date: operacao.data1aAplicHerbicida,
                        color: Colors.orange,
                        dias: _calcularDias(
                          operacao.dataPlantio,
                          operacao.data1aAplicHerbicida,
                        ),
                      ),
                    ],

                    // 2º Aplicação Herbicida
                    if (operacao.data2aAplicHerbicida != null) ...[
                      const SizedBox(height: 8),
                      _buildDateRow(
                        icon: Icons.science,
                        label: '2º Herbicida',
                        date: operacao.data2aAplicHerbicida,
                        color: Colors.deepOrange,
                        dias: _calcularDias(
                          operacao.dataPlantio,
                          operacao.data2aAplicHerbicida,
                        ),
                      ),
                    ],

                    // Colheita
                    if (operacao.dataColheita != null) ...[
                      const SizedBox(height: 8),
                      _buildDateRow(
                        icon: Icons.agriculture,
                        label: 'Colheita',
                        date: operacao.dataColheita,
                        color: AppColors.success,
                        dias: diasPlantioColheita,
                        destaque: true,
                      ),
                    ],
                  ],
                ),
              ),

              // Observações
              if (operacao.observacoes?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          operacao.observacoes!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow({
    required IconData icon,
    required String label,
    required DateTime? date,
    required Color color,
    int? dias,
    bool destaque = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: destaque ? 14 : 13,
              fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          date != null ? Formatters.formatDate(date) : '-',
          style: TextStyle(
            fontSize: destaque ? 14 : 13,
            fontWeight: destaque ? FontWeight.bold : FontWeight.w600,
            color: Colors.grey[900],
          ),
        ),
        if (dias != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$dias dias',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
