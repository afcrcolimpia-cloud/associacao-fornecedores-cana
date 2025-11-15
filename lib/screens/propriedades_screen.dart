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
              child: Text('Erro: ${proprietariosSnapshot.error}'),
            );
          }

          final proprietarios = proprietariosSnapshot.data ?? [];

          if (proprietarios.isEmpty) {
            return const Center(
              child: Text('Nenhum proprietário cadastrado'),
            );
          }

          return ListView.builder(
            itemCount: proprietarios.length,
            itemBuilder: (context, index) {
              final proprietario = proprietarios[index];
              
              return StreamBuilder<List<Propriedade>>(
                stream: _propriedadeService.getPropriedadesByProprietarioStream(proprietario.id),
                builder: (context, propriedadesSnapshot) {
                  final propriedades = propriedadesSnapshot.data ?? [];
                  
                  return ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary,
                      child: Text(
                        proprietario.nome.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(proprietario.nome),
                    subtitle: Text('${propriedades.length} propriedades'),
                    children: propriedades.map((prop) {
                      return ListTile(
                        leading: const Icon(Icons.home_work),
                        title: Text(prop.nomePropriedade),
                        subtitle: Text(prop.municipio ?? 'Município não informado'),
                      );
                    }).toList(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
