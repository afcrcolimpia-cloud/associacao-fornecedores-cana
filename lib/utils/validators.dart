/// Validadores de documentos e dados brasileiros
class BrazilianValidators {
  /// Valida CPF (11 dígitos)
  /// Exemplo: 123.456.789-09
  static bool isValidCPF(String cpf) {
    // Remove caracteres não numéricos
    final cleaned = cpf.replaceAll(RegExp(r'\D'), '');

    // Verifica se tem 11 dígitos
    if (cleaned.length != 11) return false;

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleaned)) return false;

    // Calcula o primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleaned[i]) * (10 - i);
    }
    int remainder = sum % 11;
    int firstDigit = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cleaned[9]) != firstDigit) return false;

    // Calcula o segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cleaned[i]) * (11 - i);
    }
    remainder = sum % 11;
    int secondDigit = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cleaned[10]) != secondDigit) return false;

    return true;
  }

  /// Formata CPF para o padrão XXX.XXX.XXX-XX
  static String formatCPF(String cpf) {
    final cleaned = cpf.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 11) return cpf;
    return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6, 9)}-${cleaned.substring(9)}';
  }

  /// Valida CNPJ (14 dígitos)
  /// Exemplo: 12.345.678/0001-90
  static bool isValidCNPJ(String cnpj) {
    // Remove caracteres não numéricos
    final cleaned = cnpj.replaceAll(RegExp(r'\D'), '');

    // Verifica se tem 14 dígitos
    if (cleaned.length != 14) return false;

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{13}$').hasMatch(cleaned)) return false;

    // Calcula o primeiro dígito verificador
    String order = "5432109876543";
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cleaned[i]) * int.parse(order[i]);
    }
    int firstDigit = sum % 11;
    firstDigit = firstDigit < 2 ? 0 : 11 - firstDigit;

    if (int.parse(cleaned[12]) != firstDigit) return false;

    // Calcula o segundo dígito verificador
    order = "9876543210987";
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cleaned[i]) * int.parse(order[i]);
    }
    int secondDigit = sum % 11;
    secondDigit = secondDigit < 2 ? 0 : 11 - secondDigit;

    if (int.parse(cleaned[13]) != secondDigit) return false;

    return true;
  }

  /// Formata CNPJ para o padrão XX.XXX.XXX/XXXX-XX
  static String formatCNPJ(String cnpj) {
    final cleaned = cnpj.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 14) return cnpj;
    return '${cleaned.substring(0, 2)}.${cleaned.substring(2, 5)}.${cleaned.substring(5, 8)}/${cleaned.substring(8, 12)}-${cleaned.substring(12)}';
  }

  /// Valida CPF ou CNPJ
  static bool isValidCPFOrCNPJ(String document) {
    final cleaned = document.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 11) {
      return isValidCPF(cleaned);
    } else if (cleaned.length == 14) {
      return isValidCNPJ(cleaned);
    }
    return false;
  }

  /// Formata CPF ou CNPJ de acordo com o tipo
  static String formatCPFOrCNPJ(String document) {
    final cleaned = document.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 11) {
      return formatCPF(cleaned);
    } else if (cleaned.length == 14) {
      return formatCNPJ(cleaned);
    }
    return document;
  }

  /// Detecta se é CPF ou CNPJ
  static String detectType(String document) {
    final cleaned = document.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 11) {
      return 'CPF';
    } else if (cleaned.length == 14) {
      return 'CNPJ';
    }
    return 'Inválido';
  }
}
