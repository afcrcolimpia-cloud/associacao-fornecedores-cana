// lib/utils/formatters.dart
import 'package:intl/intl.dart';

class Formatters {
  // Formata CPF: 000.000.000-00
  static String formatCPF(String cpf) {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }

  // Formata CNPJ: 00.000.000/0000-00
  static String formatCNPJ(String cnpj) {
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12, 14)}';
  }

  // Formata telefone: (00) 00000-0000 ou (00) 0000-0000
  static String formatTelefone(String telefone) {
    final digitsOnly = telefone.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length == 11) {
      // Celular: (00) 00000-0000
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7, 11)}';
    } else if (digitsOnly.length == 10) {
      // Fixo: (00) 0000-0000
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6, 10)}';
    }
    
    return telefone;
  }

  // Formata CEP: 00000-000
  static String formatCEP(String cep) {
    final digitsOnly = cep.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 8) return cep;
    return '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5, 8)}';
  }

  // Formata data: 15/11/2025
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Formata data e hora: 15/11/2025 14:30
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // Formata número com 2 casas decimais: 1.234,56
  static String formatNumber(double value) {
    return NumberFormat('#,##0.00', 'pt_BR').format(value);
  }

  // Formata hectares: 150,50 ha
  static String formatHectares(double hectares) {
    return '${formatNumber(hectares)} ha';
  }

  // Formata alqueires: 62,19 alq
  static String formatAlqueires(double alqueires) {
    return '${formatNumber(alqueires)} alq';
  }

  // Converte hectares para alqueires (1 alqueire paulista = 2.42 hectares)
  static double hectaresToAlqueires(double hectares) {
    return hectares / 2.42;
  }

  // Converte alqueires para hectares (1 alqueire paulista = 2.42 hectares)
  static double alqueiresToHectares(double alqueires) {
    return alqueires * 2.42;
  }

  // Formata moeda: R$ 1.234,56
  static String formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(value);
  }

  // Remove formatação de CPF/CNPJ/Telefone (deixa só números)
  static String removeFormatting(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }
}