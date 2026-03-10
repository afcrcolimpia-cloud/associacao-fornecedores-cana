import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/anexo_service.dart';
import '../constants/app_colors.dart';
import '../config/database_config.dart';
import '../utils/file_utils.dart';
import '../widgets/app_shell.dart';
import 'anexo_upload_screen.dart';
import 'formularios_pdf_screen.dart';

class AnexosScreen extends StatefulWidget {
  final Propriedade propriedade;

  const AnexosScreen({super.key, required this.propriedade});

  @override
  State<AnexosScreen> createState() => _AnexosScreenState();
}

class _AnexosScreenState extends State<AnexosScreen> {
  final AnexoService _anexoService = AnexoService();

  Future<void> _abrirArquivo(Anexo anexo) async {
    final urlPublica = anexo.getUrlPublica('anexos-propriedades', DatabaseConfig.supabaseUrl);
    final sucesso = await FileUtils.openFile(urlPublica);
    if (!mounted) return;
    if (!sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o arquivo'), backgroundColor: AppColors.newDanger),
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
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anexo excluído com sucesso!'), backgroundColor: AppColors.newSuccess),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: AppColors.newDanger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      onNavigationSelect: (index) {},
      selectedIndex: 6,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header com título e ações
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Anexos da Propriedade',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Tooltip(
                    message: 'Gerar Relatórios de Pragas',
                    child: IconButton(
                      icon: const Icon(Icons.note_add, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormulariosPdfScreen(
                              propriedadeId: widget.propriedade.id,
                              propriedade: widget.propriedade,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Lista de Anexos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<List<Anexo>>(
                stream: _anexoService.getAnexosByPropriedadeStream(widget.propriedade.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.error, size: 48, color: AppColors.newDanger),
                          const SizedBox(height: 12),
                          Text('Erro ao carregar anexos: ${snapshot.error}'),
                        ],
                      ),
                    );
                  }

                  final anexos = snapshot.data ?? [];

                  if (anexos.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(Icons.attach_file, size: 64, color: Colors.grey[600]),
                          const SizedBox(height: 12),
                          const Text('Nenhum anexo cadastrado'),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _abrirTelaDeUpload,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Adicionar Arquivo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.newSuccess,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: List.generate(
                      anexos.length,
                      (index) {
                        final anexo = anexos[index];
                        final iconeData = _obterIconeECorPorExtensao(anexo.nomeArquivo);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 2,
                            color: AppColors.bgDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () => _abrirArquivo(anexo),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Ícone
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: (iconeData['cor'] as Color).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        iconeData['icone'] as IconData,
                                        color: iconeData['cor'] as Color,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Informações
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            anexo.nomeArquivo,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _anexoService.formatarTamanho(anexo.tamanhoBytes),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Menu de ações
                                    PopupMenuButton<int>(
                                      color: AppColors.surfaceDark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
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
                                        const PopupMenuItem(
                                          value: 1,
                                          child: Row(
                                            children: [
                                              Icon(Icons.open_in_new, size: 18, color: Colors.white),
                                              SizedBox(width: 8),
                                              Text('Abrir', style: TextStyle(color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 2,
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, size: 18, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Excluir', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Botão flutuante para novo anexo
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _abrirTelaDeUpload,
                icon: const Icon(Icons.upload_file),
                label: const Text('Novo Anexo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.newSuccess,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirTelaDeUpload() async {
    if (!context.mounted) return;
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => AnexoUploadScreen(propriedade: widget.propriedade)),
    );
    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo enviado com sucesso!'), backgroundColor: AppColors.newSuccess),
      );
    }
  }

  /// Retorna ícone e cor baseado na extensão do arquivo
  Map<String, dynamic> _obterIconeECorPorExtensao(String nomeArquivo) {
    final extensao = nomeArquivo.split('.').last.toLowerCase();
    
    switch (extensao) {
      case 'pdf':
        return {
          'icone': Icons.picture_as_pdf,
          'cor': Colors.red[600] ?? Colors.red,
        };
      case 'kml':
      case 'kmz':
        return {
          'icone': Icons.location_on,
          'cor': Colors.green[600] ?? Colors.green,
        };
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return {
          'icone': Icons.image,
          'cor': Colors.purple[600] ?? Colors.purple,
        };
      case 'doc':
      case 'docx':
        return {
          'icone': Icons.description,
          'cor': Colors.blue[600] ?? Colors.blue,
        };
      case 'xls':
      case 'xlsx':
        return {
          'icone': Icons.table_chart,
          'cor': Colors.green[700] ?? Colors.green,
        };
      case 'csv':
        return {
          'icone': Icons.data_usage,
          'cor': Colors.orange[600] ?? Colors.orange,
        };
      case 'txt':
        return {
          'icone': Icons.text_fields,
          'cor': Colors.grey[600] ?? Colors.grey,
        };
      case 'zip':
      case 'rar':
      case '7z':
        return {
          'icone': Icons.folder_zip,
          'cor': Colors.amber[700] ?? Colors.amber,
        };
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return {
          'icone': Icons.videocam,
          'cor': Colors.red[700] ?? Colors.red,
        };
      case 'mp3':
      case 'wav':
      case 'm4a':
        return {
          'icone': Icons.audio_file,
          'cor': Colors.indigo[600] ?? Colors.indigo,
        };
      default:
        return {
          'icone': Icons.attach_file,
          'cor': Colors.grey[500] ?? Colors.grey,
        };
    }
  }
}