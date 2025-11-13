class DatabaseConfig {
  // 🔑 EXEMPLO COM CHAVES REAIS
  static const String supabaseUrl = 'https://abc123xyz.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiYzEyM3h5eiIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNjk1MDAwMDAwLCJleHAiOjIwMTA1NzYwMDB9.abcdefghijklmnopqrstuvwxyz123456789';
  
  // 📋 Nomes das tabelas
  static const String tabelaProprietarios = 'proprietarios';
  static const String tabelaPropriedades = 'propriedades';
  static const String tabelaTalhoes = 'talhoes';
  static const String tabelaVariedades = 'variedades';
  static const String tabelaColheitas = 'colheitas';
  static const String tabelaAplicacoes = 'aplicacoes';
  static const String tabelaPrecipitacao = 'precipitacao';
}