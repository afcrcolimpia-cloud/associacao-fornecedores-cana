// lib/models/anexo.dart
class Anexo {
  final String id;
  final String propriedadeId;  // ← MUDOU
  final String nomeArquivo;
  final String tipoArquivo;
  final int tamanhoBytes;
  final String caminhoStorage;
  final String urlPublica;
  final String? descricao;
  final String? tipoDocumento;  // ← NOVO
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Anexo({
    required this.id,
    required this.propriedadeId,
    required this.nomeArquivo,
    required this.tipoArquivo,
    required this.tamanhoBytes,
    required this.caminhoStorage,
    required this.urlPublica,
    this.descricao,
    this.tipoDocumento,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory Anexo.fromJson(Map<String, dynamic> json) {
    return Anexo(
      id: json['id'] ?? '',
      propriedadeId: json['propriedade_id'] ?? '',
      nomeArquivo: json['nome_arquivo'] ?? '',
      tipoArquivo: json['tipo_arquivo'] ?? '',
      tamanhoBytes: json['tamanho_bytes'] ?? 0,
      caminhoStorage: json['caminho_storage'] ?? '',
      urlPublica: json['url_publica'] ?? '',
      descricao: json['descricao'],
      tipoDocumento: json['tipo_documento'],
      criadoEm: DateTime.parse(json['criado_em']),
      atualizadoEm: DateTime.parse(json['atualizado_em']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propriedade_id': propriedadeId,
      'nome_arquivo': nomeArquivo,
      'tipo_arquivo': tipoArquivo,
      'tamanho_bytes': tamanhoBytes,
      'caminho_storage': caminhoStorage,
      'url_publica': urlPublica,
      'descricao': descricao,
      'tipo_documento': tipoDocumento,
      'criado_em': criadoEm.toIso8601String(),
      'atualizado_em': atualizadoEm.toIso8601String(),
    };
  }
}