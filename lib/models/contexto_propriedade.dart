import 'proprietario.dart';
import 'propriedade.dart';

/// Agrupa Proprietário + Propriedade com atalhos úteis para telas operacionais
class ContextoPropriedade {
  final Proprietario proprietario;
  final Propriedade propriedade;

  const ContextoPropriedade({
    required this.proprietario,
    required this.propriedade,
  });

  // Getters de conveniência
  String get nomeProprietario => proprietario.nome;
  String get nomePropriedade => propriedade.nomePropriedade;
  String get numeroFA => propriedade.numeroFA;
  String get municipio => propriedade.cidade ?? '';
  String get estado => propriedade.estado ?? '';
  String get endereco => propriedade.endereco ?? '';
  
  String get areaHa => propriedade.areaHa != null
      ? '${propriedade.areaHa!.toStringAsFixed(1)} ha'
      : 'Não informado';
  
  String get localizacao => '$municipio${estado.isNotEmpty ? ' - $estado' : ''}';
  
  // IDs para queries
  String get proprietarioId => proprietario.id;
  String get propriedadeId => propriedade.id;
}
