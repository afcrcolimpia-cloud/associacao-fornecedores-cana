import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import '../constants/app_colors.dart';
import '../services/custo_operacional_service.dart';

class HistoricoCustoOperacionalScreen extends StatefulWidget {
  final String cenarioId;
  final String nomeCenario;

  const HistoricoCustoOperacionalScreen({
    super.key,
    required this.cenarioId,
    required this.nomeCenario,
  });

  @override
  State<HistoricoCustoOperacionalScreen> createState() =>
      _HistoricoCustoOperacionalScreenState();
}

class _HistoricoCustoOperacionalScreenState
    extends State<HistoricoCustoOperacionalScreen> {
  final _service = CustoOperacionalService();
  late Future<List<Map<String, dynamic>>> _historicoFuture;

  @override
  void initState() {
    super.initState();
    _historicoFuture = _service.getHistoricoCenario(widget.cenarioId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarAfcrc(title: 'Histórico — ${widget.nomeCenario}'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historicoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          }

          final historico = snapshot.data ?? [];

          if (historico.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Nenhuma alteracao registrada'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: historico.length,
            itemBuilder: (context, index) {
              final item = historico[index];
              return _buildHistoricoCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoricoCard(Map<String, dynamic> item) {
    final dataAlteracao = item['alterado_em'] != null
        ? DateTime.parse(item['alterado_em'].toString())
        : null;
    final dataFormatada = dataAlteracao != null
        ? '${dataAlteracao.day}/${dataAlteracao.month}/${dataAlteracao.year} ${dataAlteracao.hour}:${dataAlteracao.minute.toString().padLeft(2, '0')}'
        : '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['campo_alterado'] ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dataFormatada,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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
                    color: Colors.blue.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Alterado',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Valor Anterior',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['valor_anterior'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.grey,
                    size: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Novo Valor',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['valor_novo'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
