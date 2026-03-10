import 'package:flutter/material.dart';
import '../models/models.dart';

class ProdutividadeCard extends StatelessWidget {
  final Produtividade produtividade;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProdutividadeCard({
    super.key,
    required this.produtividade,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tch = _calcularTCH();
    final nomeEstagio = _getNomeEstagio();
    final nomeMes = _getNomeMes();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com variedade e estágio
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produtividade.variedade ?? 'Variedade N/A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nomeEstagio,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${tch.toStringAsFixed(2)} TCH',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Informações principais
              _buildInfoRow(
                Icons.agriculture,
                'Peso',
                '${produtividade.pesoLiquidoToneladas?.toStringAsFixed(2) ?? '0'} T',
              ),
              _buildInfoRow(
                Icons.analytics,
                'ATR',
                produtividade.mediaATR?.toStringAsFixed(2) ?? '0',
              ),
              _buildInfoRow(
                Icons.calendar_today,
                'Mês',
                nomeMes,
              ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              // Observações (se existirem)
              if (produtividade.observacoes != null &&
                  produtividade.observacoes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    produtividade.observacoes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              
              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: 'Editar',
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      iconSize: 20,
                      onPressed: onEdit,
                    ),
                  ),
                  Tooltip(
                    message: 'Deletar',
                    child: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      iconSize: 20,
                      onPressed: onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  double _calcularTCH() {
    // TCH = Toneladas de Cana por Hectare (estimado)
    // Cálculo simplificado: peso / (Área manuseada ou 1 como padrão)
    final peso = produtividade.pesoLiquidoToneladas ?? 0;
    if (peso == 0) return 0;
    return peso; // Simplificado - pode ser expandido com Área
  }

  String _getNomeEstagio() {
    final estagio = produtividade.estagio;
    if (estagio == null) return 'Estágio N/A';
    
    // Extrai apenas o número do estágio
    if (estagio.contains('1º')) return '1º Corte';
    if (estagio.contains('2º')) return '2º Corte';
    if (estagio.contains('3º')) return '3º Corte';
    if (estagio.contains('4º')) return '4º Corte';
    if (estagio.contains('5º')) return '5º Corte';
    if (estagio.contains('6º')) return '6º Corte';
    if (estagio.contains('7º')) return '7º Corte ou mais';
    
    return estagio;
  }

  String _getNomeMes() {
    const meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    
    final mes = produtividade.mesColheita;
    if (mes == null || mes < 1 || mes > 12) return 'Mês N/A';
    
    return meses[mes - 1];
  }
}