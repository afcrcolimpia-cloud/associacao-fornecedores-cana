// lib/models/variedade.dart

class Variedade {
  final String id;
  final String codigo; // CTC9001, RB86-7515, IACSP95-5094, SP80-1842, etc
  final String nome; // Nome descritivo da variedade
  final String instituicao; // CTC, RB, IAC, SP, CV
  final String destaque; // Característica agronômica principal
  final String ambienteProducao; // "A B C D E" — ambientes recomendados
  final String epocaColheita; // "Jun Jul Ago Set" — meses de colheita
  final bool ativa;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Variedade({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.instituicao,
    required this.destaque,
    required this.ambienteProducao,
    required this.epocaColheita,
    required this.ativa,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory Variedade.fromJson(Map<String, dynamic> json) {
    return Variedade(
      id: json['id'] ?? '',
      codigo: json['codigo'] ?? '',
      nome: json['nome'] ?? '',
      instituicao: json['instituicao'] ?? '',
      destaque: json['destaque'] ?? '',
      ambienteProducao: json['ambiente_producao'] ?? '',
      epocaColheita: json['epoca_colheita'] ?? '',
      ativa: json['ativa'] ?? true,
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : DateTime.now(),
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nome': nome,
      'instituicao': instituicao,
      'destaque': destaque,
      'ambiente_producao': ambienteProducao,
      'epoca_colheita': epocaColheita,
      'ativa': ativa,
    };
  }

  Variedade copyWith({
    String? id,
    String? codigo,
    String? nome,
    String? instituicao,
    String? destaque,
    String? ambienteProducao,
    String? epocaColheita,
    bool? ativa,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Variedade(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nome: nome ?? this.nome,
      instituicao: instituicao ?? this.instituicao,
      destaque: destaque ?? this.destaque,
      ambienteProducao: ambienteProducao ?? this.ambienteProducao,
      epocaColheita: epocaColheita ?? this.epocaColheita,
      ativa: ativa ?? this.ativa,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  /// Lista de ambientes como List<String> (ex: ['A', 'B', 'C'])
  List<String> get ambientes => ambienteProducao.split(' ').where((s) => s.isNotEmpty).toList();

  /// Lista de meses como List<String> (ex: ['Jun', 'Jul', 'Ago'])
  List<String> get meses => epocaColheita.split(' ').where((s) => s.isNotEmpty).toList();

  @override
  String toString() => codigo;
}