// lib/services/anexo_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AnexoService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String tableName = 'anexos';
  final String bucketName = 'anexos-propriedades';
  static const String _cols = 'id, propriedade_id, tipo_anexo, nome_arquivo, url_arquivo, caminho_storage, tamanho_bytes, tipo_mime, criado_em, atualizado_em';

  // ------------------------------
  // STREAM DE ANEXOS POR PROPRIEDADE
  // ------------------------------
  Stream<List<Anexo>> getAnexosByPropriedadeStream(String propriedadeId) {
    return _supabase
        .from(tableName)
        .stream(primaryKey: ['id'])
        .eq('propriedade_id', propriedadeId)
        .order('criado_em', ascending: false)
        .map((data) => data.map((map) => Anexo.fromJson(map)).toList());
  }

  // ------------------------------
  // BUSCAR ANEXOS
  // ------------------------------
  Future<List<Anexo>> getAnexosByPropriedade(String propriedadeId) async {
    try {
      final data = await _supabase
          .from(tableName)
          .select(_cols)
          .eq('propriedade_id', propriedadeId)
          .order('criado_em', ascending: false);

      return (data as List).map((map) => Anexo.fromJson(map)).toList();
    } catch (e) {
      throw 'Erro ao buscar anexos: $e';
    }
  }

  Future<Anexo?> getAnexo(String id) async {
    try {
      final data = await _supabase
          .from(tableName)
          .select(_cols)
          .eq('id', id)
          .single();

      return Anexo.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') return null;
      throw 'Erro ao buscar anexo: ${e.message}';
    } catch (e) {
      throw 'Erro ao buscar anexo: $e';
    }
  }

  // Função auxiliar para detectar tipo MIME pela extensão
  String _detectarTipoMime(String nomeArquivo) {
    final extensao = nomeArquivo.split('.').last.toLowerCase();
    const mimeTypes = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'bmp': 'image/bmp',
      'mp4': 'video/mp4',
      'avi': 'video/x-msvideo',
      'mov': 'video/quicktime',
      'txt': 'text/plain',
      'csv': 'text/csv',
      'zip': 'application/zip',
    };
    return mimeTypes[extensao] ?? 'application/octet-stream';
  }

  // Função auxiliar para determinar tipo de anexo pela extensão
  String _determinarTipoAnexo(String nomeArquivo) {
    final extensao = nomeArquivo.split('.').last.toLowerCase();
    const tiposImagem = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
    const tiposVideo = ['mp4', 'avi', 'mov', 'mkv'];
    const tiposPlanilha = ['xls', 'xlsx', 'csv'];
    const tiposApresentacao = ['ppt', 'pptx'];

    if (tiposImagem.contains(extensao)) return 'Imagem';
    if (tiposVideo.contains(extensao)) return 'Vídeo';
    if (tiposPlanilha.contains(extensao)) return 'Planilha';
    if (tiposApresentacao.contains(extensao)) return 'Apresentação';
    if (extensao == 'pdf') return 'PDF';
    
    return 'Documento';
  }

  // ------------------------------
  // UPLOAD COMPLETO E CORRIGIDO
  // ------------------------------
  Future<String> uploadAnexo({
    required String propriedadeId,
    required String nomeArquivo,
    required List<int> bytes,
  }) async {
    try {
      // 1. Pegar usuário autenticado
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw 'Usuário não autenticado';
      }

      // 2. Converter List<int> para Uint8List
      final uint8bytes = Uint8List.fromList(bytes);

      // 3. Criar nome único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extensao = nomeArquivo.split('.').last.toLowerCase();
      final nomeUnico = '$propriedadeId/$timestamp.$extensao';

      // 4. Upload com metadata
      final uploadResponse = await _supabase.storage.from(bucketName).uploadBinary(
            nomeUnico,
            uint8bytes,
            fileOptions: FileOptions(
              upsert: false,
              metadata: {
                'owner': user.id,
                'propriedade_id': propriedadeId,
              },
            ),
          );

      if (uploadResponse.isEmpty) {
        throw 'Falha no upload do arquivo';
      }

      // 5. Determinar tipo MIME e tipo de anexo
      final tipoMime = _detectarTipoMime(nomeArquivo);
      final tipoAnexo = _determinarTipoAnexo(nomeArquivo);

      // 6. Inserir com todos os campos obrigatórios
      try {
        final data = await _supabase
            .from(tableName)
            .insert({
              'propriedade_id': propriedadeId,
              'tipo_anexo': tipoAnexo,
              'nome_arquivo': nomeArquivo,
              'url_arquivo': '$propriedadeId/$timestamp.$extensao',
              'caminho_storage': nomeUnico,
              'tamanho_bytes': bytes.length,
              'tipo_mime': tipoMime,
            })
            .select('id')
            .single();

        debugPrint('✅ Upload bem-sucedido: ${data['id']}');
        return (data['id'] as String?) ?? '';
      } catch (dbError) {
        debugPrint('❌ Erro ao inserir no banco: $dbError');
        // Se falhar no banco, tenta remover o arquivo do storage
        try {
          await _supabase.storage.from(bucketName).remove([nomeUnico]);
        } catch (e) {
          debugPrint('❌ Erro ao limpar storage: $e');
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('❌ Erro ao fazer upload: $e');
      throw 'Erro ao fazer upload: $e';
    }
  }

  // ------------------------------
  // DELETE
  // ------------------------------
  Future<void> deleteAnexo(String id) async {
    try {
      final anexo = await getAnexo(id);

      if (anexo != null) {
        await _supabase.storage.from(bucketName).remove([anexo.caminhoStorage]);

        await _supabase.from(tableName).delete().eq('id', id);
      }
    } catch (e) {
      throw 'Erro ao deletar anexo: $e';
    }
  }

  // ------------------------------
  // AUXILIARES
  // ------------------------------
  String getIconePorExtensao(String nomeArquivo) {
    final extensao = nomeArquivo.split('.').last.toLowerCase();
    switch (extensao) {
      case 'pdf':
        return '📄';
      case 'kml':
      case 'kmz':
        return '🗺️';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'csv':
        return '📋';
      case 'txt':
        return '📃';
      case 'zip':
        return '🗜️';
      default:
        return '📎';
    }
  }

  String formatarTamanho(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
