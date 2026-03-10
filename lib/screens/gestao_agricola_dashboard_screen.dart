import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/app_bar_afcrc.dart';

class GestaoAgricolaDashboardScreen extends StatelessWidget {
  const GestaoAgricolaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para definir se o layout fica em colunas (Desktop) ou empilhado (Mobile)
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBarAfcrc(
        actions: [
          IconButton(
            icon: const Icon(Icons.nightlight_round, color: Colors.grey),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text('JD', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs e Título
            _buildHeader(context),
            const SizedBox(height: 32),
            
            // Layout Principal (Responsivo)
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  // Desktop/Tablet Paisagem: Duas Colunas
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Coluna Esquerda (Menor)
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildTalhoesCard(),
                            const SizedBox(height: 24),
                            _buildCensoVarietalCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Coluna Direita (Maior)
                      Expanded(
                        flex: 7,
                        child: Column(
                          children: [
                            _buildAnexosArea(),
                            const SizedBox(height: 32),
                            _buildAnaliseSoloArea(),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile/Tablet Retrato: Empilhado
                  return Column(
                    children: [
                      _buildTalhoesCard(),
                      const SizedBox(height: 24),
                      _buildCensoVarietalCard(),
                      const SizedBox(height: 24),
                      _buildAnexosArea(),
                      const SizedBox(height: 24),
                      _buildAnaliseSoloArea(),
                    ],
                  );
                }
              },
            ),
            
            const SizedBox(height: 48),
            // Footer
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2023 AFCRC - Catanduva/SP. Todos os direitos reservados.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Row(
                    children: [
                      TextButton(onPressed: () {}, child: Text('Documentação', style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                      TextButton(onPressed: () {}, child: Text('Suporte Técnico', style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                      TextButton(onPressed: () {}, child: Text('Status do Sistema', style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.home, size: 16, color: Colors.grey),
            SizedBox(width: 8),
            Text('Início', style: TextStyle(color: Colors.grey, fontSize: 13)),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            Text('Dashboard', style: TextStyle(color: Colors.grey, fontSize: 13)),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            Text('Gestão Agrícola', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Dashboard de Gestão Agrícola',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Visão geral da propriedade e monitoramento técnico.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTalhoesCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.map, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Talhões', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dashboard, size: 32, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('VISUALIZAÇÃO DE MAPA / LISTA', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL DE ÁREA', style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('450 ha', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL TALHÕES', style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('24', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCensoVarietalCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.eco, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Censo Varietal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 32, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('DISTRIBUIÇÃO DE VARIEDADES', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildProgressBar('CTC 4', 0.45, '45%', AppColors.primary),
            const SizedBox(height: 16),
            _buildProgressBar('RB 966928', 0.30, '30%', Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, String percentageText, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
            Text(percentageText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildAnexosArea() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.folder, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Anexos e Documentação Técnica', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.filter_list, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.bug_report, color: Colors.red),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Relatórios de Pragas', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('2 documentos arquivados', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.trending_up, color: Colors.blue),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Estimativa de Produtividade', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Última atualização: Out/2023', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnaliseSoloArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text('DOCUMENTO ATIVO: ANÁLISE DE SOLO', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Análise de Solo: Método Boletim 100', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Referência técnica para Catanduva e região.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Exportar PDF'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                  label: const Text('Editar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dados Gerais
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text('Dados Gerais', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDataRow('PROPRIEDADE', 'Fazenda Santa Rita'),
                    const SizedBox(height: 16),
                    _buildDataRow('TALHÃO / LOTE', 'T-104 (Setor Norte)'),
                    const SizedBox(height: 16),
                    _buildDataRow('DATA DE AMOSTRAGEM', '12/10/2023'),
                    const SizedBox(height: 16),
                    _buildDataRow('PROFUNDIDADE', '0 - 20 cm'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Caracterização Física
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.landscape, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text('Caracterização Física', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFisicaBox('ARGILA', '28%'),
                        _buildFisicaBox('SILTE', '12%'),
                        _buildFisicaBox('AREIA', '60%'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CLASSIFICAÇÃO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          SizedBox(height: 4),
                          Text('Franco-Arenoso', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Análise Química Table
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.science, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text('Resultados da Análise Química', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                      child: const Text('BOLETIM 100', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildQuimicaRowHeader(),
              const Divider(height: 1),
              _buildQuimicaRow('pH (CaCl₂)', '5.2', 'MÉDIO', Colors.amber),
              const Divider(height: 1),
              _buildQuimicaRow('P (Resina)', '14.0', 'BAIXO', Colors.red),
              const Divider(height: 1),
              _buildQuimicaRow('K (Potássio)', '1.8', 'ADEQUADO', AppColors.success),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildFisicaBox(String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuimicaRowHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('PARÂMETRO', style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('VALOR', style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('STATUS', style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildQuimicaRow(String label, String value, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(width: 24, height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 12),
                Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
