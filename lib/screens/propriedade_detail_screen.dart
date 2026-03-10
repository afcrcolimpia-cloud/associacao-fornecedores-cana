import 'package:flutter/material.dart';
import '../widgets/app_bar_afcrc.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../services/talhao_service.dart';
import 'propriedade_form_screen.dart';
import 'talhao_form_screen.dart';

class PropriedadeDetailScreen extends StatefulWidget {
  final String propriedadeId;

  const PropriedadeDetailScreen({
    super.key,
    required this.propriedadeId,
  });

  @override
  State<PropriedadeDetailScreen> createState() => _PropriedadeDetailScreenState();
}

class _PropriedadeDetailScreenState extends State<PropriedadeDetailScreen> {
  final PropriedadeService _service = PropriedadeService();
  final TalhaoService _talhaoService = TalhaoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarAfcrc(
        title: 'Detalhes da Propriedade',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editarPropriedade,
          ),
        ],
      ),
      body: FutureBuilder<Propriedade?>(
        future: _service.getPropriedadeById(widget.propriedadeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final propriedade = snapshot.data;

          if (propriedade == null) {
            return const Center(
              child: Text('Propriedade não encontrada'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(propriedade),
                const SizedBox(height: 24),
                _buildInfoCard(propriedade),
                const SizedBox(height: 24),
                _buildLocalizacaoCard(propriedade),
                const SizedBox(height: 24),
                _buildAreaCard(propriedade),
                const SizedBox(height: 24),
                _buildTalhoesSection(propriedade),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(Propriedade propriedade) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              propriedade.nomePropriedade,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  propriedade.ativa ? Icons.check_circle : Icons.cancel,
                  color: propriedade.ativa ? Colors.greenAccent : Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  propriedade.ativa ? 'Ativa' : 'Inativa',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Propriedade propriedade) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Básicas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow('Número FA', propriedade.numeroFA),
            const SizedBox(height: 12),
            _buildInfoRow('Proprietário ID', propriedade.proprietarioId),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Criado em',
              _formatarData(propriedade.criadoEm),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Atualizado em',
              _formatarData(propriedade.atualizadoEm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalizacaoCard(Propriedade propriedade) {
    final temLocalizacao = propriedade.endereco != null ||
        propriedade.cidade != null ||
        propriedade.estado != null ||
        propriedade.cep != null;

    if (!temLocalizacao) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Localização',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Nenhuma informação de localização',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Localização',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            if (propriedade.endereco != null)
              _buildInfoRow('Endereço', propriedade.endereco.toString()),
            if (propriedade.endereco != null && (propriedade.cidade != null || propriedade.estado != null))
              const SizedBox(height: 12),
            if (propriedade.cidade != null && propriedade.estado != null)
              _buildInfoRow(
                'Cidade/Estado',
                '${propriedade.cidade.toString()} - ${propriedade.estado.toString()}',
              ),
            if ((propriedade.cidade != null || propriedade.estado != null) && propriedade.cep != null)
              const SizedBox(height: 12),
            if (propriedade.cep != null)
              _buildInfoRow('CEP', propriedade.cep.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaCard(Propriedade propriedade) {
    final temArea = propriedade.areaHa != null || propriedade.areaAlqueires != null;

    if (!temArea) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Área',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Nenhuma informação de área',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Área',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            if (propriedade.areaHa != null)
              _buildInfoRow('Hectares', '${propriedade.areaHa} ha'),
            if (propriedade.areaHa != null && propriedade.areaAlqueires != null)
              const SizedBox(height: 12),
            if (propriedade.areaAlqueires != null)
              _buildInfoRow('Alqueires', '${propriedade.areaAlqueires} alq'),
          ],
        ),
      ),
    );
  }

  Widget _buildTalhoesSection(Propriedade propriedade) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Talhões',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Novo'),
              onPressed: () => _criarNovoTalhao(propriedade),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Talhao>>(
          future: _talhaoService.getTalhoesPorPropriedade(propriedade.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            final talhoes = snapshot.data ?? [];

            if (talhoes.isEmpty) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Nenhum talhão cadastrado',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: talhoes.length,
              itemBuilder: (context, index) {
                final talhao = talhoes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(talhao.numeroTalhao),
                    ),
                    title: Text(talhao.numeroTalhao),
                    subtitle: Text('${talhao.areaHa} ha'),
                    trailing: talhao.ativo
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red),
                    onTap: () => _criarNovoTalhao(propriedade),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute}';
  }

  Future<void> _editarPropriedade() async {
    final propriedade = await _service.getPropriedadeById(widget.propriedadeId);
    
    if (propriedade != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropriedadeFormScreen(
            propriedade: propriedade,
          ),
        ),
      );
      
      setState(() {});
    }
  }

  Future<void> _criarNovoTalhao(Propriedade propriedade) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TalhaoFormScreen(
          propriedade: propriedade,
        ),
      ),
    );
    setState(() {});
  }
}