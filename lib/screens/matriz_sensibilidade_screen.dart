import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../services/custo_operacional_analise.dart';
import '../services/custo_operacional_service.dart';
import '../constants/app_colors.dart';

class MatrizSensibilidadeScreen extends StatefulWidget {
  final CustoOperacionalCenario cenario;

  const MatrizSensibilidadeScreen({
    required this.cenario,
    super.key,
  });

  @override
  State<MatrizSensibilidadeScreen> createState() => _MatrizSensibilidadeScreenState();
}

class _MatrizSensibilidadeScreenState extends State<MatrizSensibilidadeScreen> {
  int _selectedNavigationIndex = 0;

  @override
  Widget build(BuildContext context) {
    final matrizSensibilidade =
        CustoOperacionalAnalise.gerarMatrizSensibilidade(widget.cenario);

    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) => setState(() => _selectedNavigationIndex = index),
      showBackButton: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Matriz de Sensibilidade',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              // Card com informações do cenário
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cenario.nomeCenario,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Produtividade Base',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${matrizSensibilidade.produtividadeBase.toStringAsFixed(2)} t/ha',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Preço ATR Base',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'R\$ ${matrizSensibilidade.precoBase.toStringAsFixed(2)}/kg',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Legenda — 3 níveis
              Card(
                color: AppColors.bgDark,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Margem por Tonelada (R\$/t)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withAlpha(100),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Lucrativo (> R\$ 15/t)', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9A825).withAlpha(100),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Atenção (R\$ 0 a R\$ 15/t)', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC62828).withAlpha(100),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Prejuízo (< R\$ 0/t)', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Matriz de Sensibilidade
              _buildMatrizTable(matrizSensibilidade),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatrizTable(MatrizSensibilidade matriz) {
    final variacoes = [-20, -15, -10, -5, 0, 5, 10, 15, 20];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preço ATR →  |  Produtividade ↓',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Table(
              border: TableBorder.all(
                color: Colors.grey,
                width: 0.5,
              ),
              columnWidths: {
                0: const FixedColumnWidth(50),
                for (int i = 1; i < variacoes.length + 1; i++)
                  i: const FixedColumnWidth(45),
              },
              children: [
                // Cabeçalho com variações de preço
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        'Prod %',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    ...variacoes.map((v) => Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        '$v%',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    )),
                  ],
                ),
                // Linhas da matriz
                for (int i = 0; i < matriz.produtividadesVariadas.length; i++)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          '${variacoes[i]}%',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      ...matriz.matriz[i].map((margem) {
                        final Color cor;
                        final Color textColor;
                        if (margem > 15) {
                          cor = const Color(0xFF2E7D32).withAlpha(100);
                          textColor = const Color(0xFF66BB6A);
                        } else if (margem >= 0) {
                          cor = const Color(0xFFF9A825).withAlpha(100);
                          textColor = const Color(0xFFFDD835);
                        } else {
                          cor = const Color(0xFFC62828).withAlpha(100);
                          textColor = const Color(0xFFEF5350);
                        }

                        return Container(
                          color: cor,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              margem.toStringAsFixed(0),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInterpretacao(matriz),
        ],
      ),
    );
  }

  Widget _buildInterpretacao(MatrizSensibilidade matriz) {
    // Encontrar valor mínimo e máximo
    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;

    for (var linha in matriz.matriz) {
      for (var valor in linha) {
        if (valor < minValue) minValue = valor;
        if (valor > maxValue) maxValue = valor;
      }
    }

    // Contar lucrativo, atenção e prejuízo
    int lucrativo = 0;
    int atencao = 0;
    int prejuizo = 0;

    for (var linha in matriz.matriz) {
      for (var valor in linha) {
        if (valor > 15) {
          lucrativo++;
        } else if (valor >= 0) {
          atencao++;
        } else {
          prejuizo++;
        }
      }
    }

    return Card(
      color: AppColors.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Análise da Matriz',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Lucrativo (> R\$ 15/t)',
              '$lucrativo de 81',
              const Color(0xFF66BB6A),
            ),
            const SizedBox(height: 6),
            _buildInfoRow(
              'Atenção (R\$ 0–15/t)',
              '$atencao de 81',
              const Color(0xFFFDD835),
            ),
            const SizedBox(height: 6),
            _buildInfoRow(
              'Prejuízo (< R\$ 0/t)',
              '$prejuizo de 81',
              const Color(0xFFEF5350),
            ),
            const SizedBox(height: 6),
            _buildInfoRow(
              'Margem Máxima',
              'R\$ ${maxValue.toStringAsFixed(2)}/t',
              AppColors.success,
            ),
            const SizedBox(height: 6),
            _buildInfoRow(
              'Margem Mínima',
              'R\$ ${minValue.toStringAsFixed(2)}/t',
              AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
