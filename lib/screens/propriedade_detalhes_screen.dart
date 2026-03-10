import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import '../models/models.dart';
import '../constants/app_colors.dart';
import 'talhoes_screen.dart';
import 'anexos_screen.dart';
import 'operacoes_cultivo_screen.dart';
import 'produtividade_screen.dart';
import 'precipitacao_screen.dart';
import 'custo_operacional_screen.dart';

class PropriedadeDetalhesScreen extends StatelessWidget {
  final Propriedade propriedade;

  const PropriedadeDetalhesScreen({
    super.key,
    required this.propriedade,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarAfcrc(title: propriedade.nome),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card com informações da propriedade
            _buildPropriedadeInfoCard(),
            const SizedBox(height: 32),

            // Título das opções
            Text(
              'Opções de Gestão',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Grid de opções
            _buildOpcoesGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPropriedadeInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              propriedade.nome,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Localização', propriedade.localizacao ?? 'Não informado'),
            _buildInfoRow('Área Total', '${propriedade.areaTotalHectares?.toStringAsFixed(2) ?? '0'} ha'),
            _buildInfoRow('Status', propriedade.ativa ? 'Ativa' : 'Inativa',
              color: propriedade.ativa ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcoesGrid(BuildContext context) {
    final opcoes = [
      {
        'titulo': 'Talhões',
        'icone': Icons.landscape,
        'cor': Colors.blue,
        'descricao': 'Gerenciar talhões',
        'onTap': () => _navegarPara(context, 
          TalhoesScreen(propriedade: propriedade)),
      },
      {
        'titulo': 'Anexos',
        'icone': Icons.attach_file,
        'cor': Colors.orange,
        'descricao': 'Documentos e arquivos',
        'onTap': () => _navegarPara(context,
          AnexosScreen(propriedade: propriedade)),
      },
      {
        'titulo': 'Operações',
        'icone': Icons.engineering,
        'cor': Colors.purple,
        'descricao': 'Tratos e operações',
        'onTap': () => _navegarPara(context,
          const OperacoesCultivoScreen()),
      },
      {
        'titulo': 'Produtividade',
        'icone': Icons.trending_up,
        'cor': Colors.green,
        'descricao': 'Análise de produção',
        'onTap': () => _navegarPara(context,
          ProdutividadeScreen(propriedade: propriedade)),
      },
      {
        'titulo': 'Precipitação',
        'icone': Icons.water_drop,
        'cor': Colors.cyan,
        'descricao': 'Dados de chuva',
        'onTap': () => _navegarPara(context,
          const PrecipitacaoScreen()),
      },
      {
        'titulo': 'Custo Operacional',
        'icone': Icons.attach_money,
        'cor': Colors.amber,
        'descricao': 'Análise de custos',
        'onTap': () => _navegarPara(context,
          CustoOperacionalScreen(propriedade: propriedade)),
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: opcoes.length,
      itemBuilder: (context, index) {
        final opcao = opcoes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOpcaoCard(
            context,
            titulo: opcao['titulo'] as String,
            icone: opcao['icone'] as IconData,
            cor: opcao['cor'] as Color,
            descricao: opcao['descricao'] as String,
            onTap: opcao['onTap'] as VoidCallback,
          ),
        );
      },
    );
  }

  Widget _buildOpcaoCard(
    BuildContext context, {
    required String titulo,
    required IconData icone,
    required Color cor,
    required String descricao,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cor.withOpacity(0.1),
                cor.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icone,
                    size: 28,
                    color: cor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descricao,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: cor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navegarPara(BuildContext context, Widget tela) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => tela),
    );
  }
}
