import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/propriedade_service.dart';
import '../services/proprietario_service.dart';

class PropriedadesScreen extends StatefulWidget {
  const PropriedadesScreen({super.key});

  @override
  State<PropriedadesScreen> createState() => _PropriedadesScreenState();
}

class _PropriedadesScreenState extends State<PropriedadesScreen> {
  final _propriedadeService = PropriedadeService();
  final _proprietarioService = ProprietarioService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propriedades'),
      ),
      body: StreamBuilder<List<Proprietario>>(
        stream: _proprietarioService.getProprietariosStream(),
        builder: (context, proprietariosSnapshot) {
          if (proprietariosSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (proprietariosSnapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Erro: ${proprietariosSnapshot.error}'),
                ],
              ),
            );
          }

          final proprietarios = proprietariosSnapshot.data ?? [];

          if (proprietarios.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('Nenhum proprietário cadastrado'),
                  const SizedBox(height: 8),
                  const Text('Cadastre proprietários primeiro'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: proprietarios.length,
            itemBuilder: (context, index) {
              final proprietario = proprietarios[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: StreamBuilder<List<Propriedade>>(
                  stream: _propriedadeService.getPropriedadesByProprietarioStream(proprietario.id),
                  builder: (context, propriedadesSnapshot) {
                    final propriedades = propriedadesSnapshot.data ?? [];
                    
                    return ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondary,
                        child: Text(
                          proprietario.nome.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        proprietario.nome,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        '${propriedades.length} ${propriedades.length == 1 ? "propriedade" : "propriedades"}',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      children: propriedades.isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Nenhuma propriedade cadastrada',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ]
                          : propriedades.map((prop) {
                              return ListTile(
                                leading: const Icon(Icons.home_work, color: AppColors.secondary),
                                title: Text(prop.nomePropriedade),
                                subtitle: Text(
                                  '${prop.municipio ?? "Município não informado"} - ${prop.areaTotalHectares.toStringAsFixed(2)} ha',
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Detalhes da propriedade: ${prop.nomePropriedade}'),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Formulário de propriedade em desenvolvimento...'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}