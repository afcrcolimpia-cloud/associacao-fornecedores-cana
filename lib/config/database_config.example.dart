// ⚠️ ESTE É UM ARQUIVO DE EXEMPLO
// 
// Para configurar o projeto:
// 1. Copie este arquivo
// 2. Renomeie para: database_config.dart
// 3. Substitua as credenciais abaixo
// 
// Onde encontrar suas credenciais:
// 1. Acesse: https://supabase.com
// 2. Abra seu projeto
// 3. Settings → API
// 4. Copie "Project URL" e "anon public key"

class DatabaseConfig {
  // 🔑 CREDENCIAIS REAIS DO SEU SUPABASE
  static const String supabaseUrl = 'https://ffiqzxvglfgcczrwohja.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZmaXF6eHZnbGZnY2N6cndvaGphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMwMDkxNjcsImV4cCI6MjA3ODU4NTE2N30.W_fez15AEensrdOxflmVuDtspNU9ImIuW2IdnEOUbOE';
  
  // 📋 Nomes das tabelas (não precisa alterar)
  static const String tabelaProprietarios = 'proprietarios';
  static const String tabelaPropriedades = 'propriedades';
  static const String tabelaTalhoes = 'talhoes';
  static const String tabelaVariedades = 'variedades';
  static const String tabelaColheitas = 'colheitas';
  static const String tabelaAplicacoes = 'aplicacoes';
  static const String tabelaPrecipitacao = 'precipitacao';
}
