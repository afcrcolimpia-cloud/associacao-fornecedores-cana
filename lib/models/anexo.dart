// lib/models/anexo.dart
class Anexo {
  final String id;
  final String propriedadeId;
  final String tipoAnexo;
  final String nomeArquivo;
  final String? urlArquivo;
  final String caminhoStorage;
  final int tamanhoBytes;
  final String? tipoMime;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  Anexo({
    required this.id,
    required this.propriedadeId,
    required this.tipoAnexo,
    required this.nomeArquivo,
    this.urlArquivo,
    required this.caminhoStorage,
    required this.tamanhoBytes,
    this.tipoMime,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Anexo.fromJson(Map<String, dynamic> json) {
    return Anexo(
      id: json['id'] ?? '',
      propriedadeId: json['propriedade_id'] ?? '',
      tipoAnexo: json['tipo_anexo'] ?? 'Documento',
      nomeArquivo: json['nome_arquivo'] ?? '',
      urlArquivo: json['url_arquivo'],
      caminhoStorage: json['caminho_storage'] ?? '',
      tamanhoBytes: json['tamanho_bytes'] ?? 0,
      tipoMime: json['tipo_mime'],
      criadoEm: json['criado_em'] != null 
          ? DateTime.tryParse(json['criado_em'].toString())
          : null,
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.tryParse(json['atualizado_em'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propriedade_id': propriedadeId,
      'tipo_anexo': tipoAnexo,
      'nome_arquivo': nomeArquivo,
      'url_arquivo': urlArquivo,
      'caminho_storage': caminhoStorage,
      'tamanho_bytes': tamanhoBytes,
      'tipo_mime': tipoMime,
      if (criadoEm != null) 'criado_em': criadoEm!.toIso8601String(),
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm!.toIso8601String(),
    };
  }

  // Getter para URL pública (calculada dinamicamente)
  String getUrlPublica(String bucketName, String supabaseUrl) {
    return '$supabaseUrl/storage/v1/object/public/$bucketName/$caminhoStorage';
  }
}