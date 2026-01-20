// lib/utils/municipios_sp.dart
class MunicipiosSP {
  static List<String> get municipiosList {
    return <String>[
      'Altair',
      'Ariranha',
      'Barretos',
      'Bebedouro',
      'Cajobi',
      'Catanduva',
      'Catiguá',
      'Cedral',
      'Colina',
      'Elisiário',
      'Embaúba',
      'Fernando Prestes',
      'Gastão Vidigal',
      'Guapiaçu',
      'Guaraci',
      'Ibirá',
      'Irapuã',
      'Itajobi',
      'Itápolis',
      'Marapoama',
      'Mirassolândia',
      'Monte Alto',
      'Monte Aprazível',
      'Monte Azul Paulista',
      'Neves Paulista',
      'Novo Horizonte',
      'Novais',
      'Onda Verde',
      'Olímpia',
      'Palestina',
      'Palmares Paulista',
      'Paraíso',
      'Pindorama',
      'Pirangi',
      'Potirenda',
      'Sales',
      'Santa Adélia',
      'São José do Rio Preto',
      'Severínia',
      'Tabapiã',
      'Taiaçu',
      'Uchoa',
      'Ubarana',
      'Urupês',
      'Vista Alegre do Alto',
      'Nova Granada',
      'Nova Luzitânia',
    ]..sort();
  }

  static List<int> get yearsAvailable {
    final currentYear = DateTime.now().year;
    return List<int>.generate(currentYear - 2024, (index) => 2025 + index);
  }
}
