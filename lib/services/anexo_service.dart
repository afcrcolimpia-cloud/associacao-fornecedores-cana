// lib/services/anexo_service.dart

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AnexoService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String tableName = 'anexos';
  final String bucketName = 'anexos-propriedades';

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
          .select()
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
          .select()
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

  // ------------------------------
  // UPLOAD COMPLETO E CORRIGIDO
  // ------------------------------
  Future<String> uploadAnexo({
    required String propriedadeId,
    required String nomeArquivo,
    required List<int> bytes,
    String? tipoDocumento,
    String? descricao,
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

      // 4. Detectar MIME
      String mimeType;
      switch (extensao) {
        case 'pdf':
          mimeType = 'application/pdf';
          break;
        case 'kml':
          mimeType = 'application/vnd.google-earth.kml+xml';
          break;
        case 'kmz':
          mimeType = 'application/vnd.google-earth.kmz';
          break;
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'doc':
          mimeType = 'application/msword';
          break;
        case 'docx':
          mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          break;
        case 'xls':
          mimeType = 'application/vnd.ms-excel';
          break;
        case 'xlsx':
          mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
          break;
        case 'csv':
          mimeType = 'text/csv';
          break;
        case 'txt':
          mimeType = 'text/plain';
          break;
        default:
          mimeType = 'application/octet-stream';
      }

      // 5. Upload com metadata OBRIGATÓRIA
      final uploadResponse = await _supabase.storage.from(bucketName).uploadBinary(
            nomeUnico,
            uint8bytes,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: false,
              metadata: {
                'owner': user.id,            // 🔥 OBRIGATÓRIO PARA RLS
                'propriedade_id': propriedadeId,
              },
            ),
          );

      if (uploadResponse.isEmpty) {
        throw 'Falha no upload do arquivo';
      }

      // 6. URL pública
      final urlPublica = _supabase.storage.from(bucketName).getPublicUrl(nomeUnico);

      // 7. Registrar no banco
      final anexo = Anexo(
        id: '',
        propriedadeId: propriedadeId,
        nomeArquivo: nomeArquivo,
        tipoArquivo: mimeType,
        tamanhoBytes: bytes.length,
        caminhoStorage: nomeUnico,
        urlPublica: urlPublica,
        descricao: descricao,
        tipoDocumento: tipoDocumento,
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      final json = anexo.toJson();
      json.remove('id');

      final data = await _supabase
          .from(tableName)
          .insert(json)
          .select('id')
          .single();

      return data['id'];
    } catch (e) {
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

  String getNomeTipoDocumento(String? tipo) {
    switch (tipo) {
      case 'mapa_pdf':
        return 'Mapa PDF';
      case 'arquivo_kml':
        return 'Arquivo KML';
      case 'relatorio_word':
        return 'Relatório Word';
      case 'relatorio_excel':
        return 'Relatório Excel';
      default:
        return 'Outro';
    }
  }
}
