// ⚠️ ESTE É UM ARQUIVO DE EXEMPLO
// Copie este arquivo para database_config.dart e adicione suas chaves reais

class DatabaseConfig {
  // 🔑 SUBSTITUA COM SUAS CHAVES DO SUPABASE
  static const String supabaseUrl = 'https://SEU_PROJETO.supabase.co';
  static const String supabaseAnonKey = 'SUA_CHAVE_ANON_AQUI';
  
  // 📋 Nomes das tabelas (não precisa mudar)
  static const String tabelaProprietarios = 'proprietarios';
  static const String tabelaPropriedades = 'propriedades';
  static const String tabelaTalhoes = 'talhoes';
  static const String tabelaVariedades = 'variedades';
  static const String tabelaColheitas = 'colheitas';
  static const String tabelaAplicacoes = 'aplicacoes';
  static const String tabelaPrecipitacao = 'precipitacao';
}