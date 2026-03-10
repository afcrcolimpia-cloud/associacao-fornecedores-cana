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
  // 🔑 SUBSTITUA COM SUAS CREDENCIAIS DO SUPABASE
  static const String supabaseUrl = 'https://SEU_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'SUA_ANON_KEY_AQUI';
  
  // 📋 Nomes das tabelas (não precisa alterar)
  static const String tabelaProprietarios = 'proprietarios';
  static const String tabelaPropriedades = 'propriedades';
  static const String tabelaTalhoes = 'talhoes';
  static const String tabelaVariedades = 'variedades';
  static const String tabelaColheitas = 'colheitas';
  static const String tabelaAplicacoes = 'aplicacoes';
  static const String tabelaPrecipitacao = 'precipitacao';
}
