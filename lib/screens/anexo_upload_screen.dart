import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import 'package:file_picker/file_picker.dart';
import '../models/models.dart';
import '../services/anexo_service.dart';
import '../constants/app_colors.dart';

class AnexoUploadScreen extends StatefulWidget {
  final Propriedade propriedade;

  const AnexoUploadScreen({super.key, required this.propriedade});

  @override
  State<AnexoUploadScreen> createState() => _AnexoUploadScreenState();
}

class _AnexoUploadScreenState extends State<AnexoUploadScreen> {
  final AnexoService _anexoService = AnexoService();
  PlatformFile? _file;
  bool _isUploading = false;
  int _selectedNavigationIndex = 0;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) {
      return;
    }
    setState(() {
      _file = result.files.first;
    });
  }

  Widget _buildPreview() {
    if (_file == null) {
      return const SizedBox.shrink();
    }

    final name = _file!.name.toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png')) {
      return Image.memory(_file!.bytes!, fit: BoxFit.contain, height: 220);
    }

    // For other types show icon + name
    return ListTile(
      leading: const Icon(Icons.insert_drive_file, size: 40),
      title: Text(_file!.name),
      subtitle: Text('${(_file!.size / 1024).toStringAsFixed(2)} KB'),
    );
  }

  Future<void> _upload() async {
    if (_file == null) {
      return;
    }
    setState(() {
      _isUploading = true;
    });
    try {
      final id = await _anexoService.uploadAnexo(
        propriedadeId: widget.propriedade.id,
        nomeArquivo: _file!.name,
        bytes: _file!.bytes!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload concluído'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context, id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no upload: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      title: 'Enviar Anexo',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Selecionar Arquivo'),
            ),
            const SizedBox(height: 12),
            _buildPreview(),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _isUploading ? null : _upload,
              child: _isUploading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
