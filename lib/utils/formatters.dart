import 'package:intl/intl.dart';

class Formatters {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  static String formatCNPJ(String cnpj) {
    cnpj = cnpj.replaceAll(RegExp(r'\D'), '');
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
  }

  static String formatNumber(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals).replaceAll('.', ',');
  }

  static String formatHectares(double value) {
    return '${formatNumber(value, decimals: 2)} ha';
  }

  static String formatAlqueires(double value) {
    return '${formatNumber(value, decimals: 2)} alq';
  }

  static double hectaresToAlqueires(double hectares) {
    return hectares / 2.42;
  }

  static double alqueiresToHectares(double alqueires) {
    return alqueires * 2.42;
  }
}