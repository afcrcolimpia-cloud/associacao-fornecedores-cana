import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/anexo_service.dart';
import '../constants/app_colors.dart';
import '../utils/file_utils.dart';
import 'anexo_upload_screen.dart';

class AnexosScreen extends StatefulWidget {
  final Propriedade propriedade;

  const AnexosScreen({super.key, required this.propriedade});

  @override
  State<AnexosScreen> createState() => _AnexosScreenState();
}

class _AnexosScreenState extends State<AnexosScreen> {
  final AnexoService _anexoService = AnexoService();

  Future<void> _abrirArquivo(Anexo anexo) async {
    final sucesso = await FileUtils.openFile(anexo.urlPublica);
    if (!mounted) return;
    if (!sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o arquivo'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _excluirAnexo(Anexo anexo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o arquivo "${anexo.nomeArquivo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _anexoService.deleteAnexo(anexo.id);
      if (!mounted) return;
      // Forçar rebuild do StreamBuilder
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anexo excluído com sucesso!'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anexos da Propriedade')),
      body: StreamBuilder<List<Anexo>>(
        stream: _anexoService.getAnexosByPropriedadeStream(widget.propriedade.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Erro ao carregar anexos: ${snapshot.error}'));

          final anexos = snapshot.data ?? [];
          if (anexos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_file, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Nenhum anexo cadastrado'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: anexos.length,
            itemBuilder: (context, index) {
              final anexo = anexos[index];
              return Card(
                child: ListTile(
                  leading: Text(_anexoService.getIconePorExtensao(anexo.nomeArquivo), style: const TextStyle(fontSize: 24)),
                  title: Text(anexo.nomeArquivo),
                  subtitle: Text('${_anexoService.getNomeTipoDocumento(anexo.tipoDocumento)} • ${_anexoService.formatarTamanho(anexo.tamanhoBytes)}'),
                  trailing: PopupMenuButton<int>(
                    onSelected: (v) async {
                      if (v == 1) {
                        if (!context.mounted) return;
                        _abrirArquivo(anexo);
                      }
                      if (v == 2) {
                        if (!context.mounted) return;
                        _excluirAnexo(anexo);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 1, child: Text('Abrir')),
                      const PopupMenuItem(value: 2, child: Text('Excluir')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!context.mounted) return;
          final result = await Navigator.push<String?>(
            context,
            MaterialPageRoute(builder: (_) => AnexoUploadScreen(propriedade: widget.propriedade)),
          );
          if (!mounted) return;
          if (result != null) {
            // safe: verificamos `context.mounted` e `mounted` antes deste ponto
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Arquivo enviado'), backgroundColor: AppColors.success));
          }
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Novo Anexo'),
      ),
    );
  }
}