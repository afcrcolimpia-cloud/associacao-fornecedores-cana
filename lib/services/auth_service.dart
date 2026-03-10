// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Stream de estado de autenticação
  Stream<User?> get userStream {
    return _supabase.auth.onAuthStateChange.map((data) => data.session?.user);
  }

  // Usuário atual
  User? get currentUser => _supabase.auth.currentUser;

  // --- AUTENTICAÇÃO PADRÃO (E-mail e Senha) ---

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      debugPrint('?? [Auth] Iniciando login com email: $email');
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('? [Auth] Login bem-sucedido! Usuario: ${response.user?.email}');
      return response.user;
    } on AuthException catch (e) {
      debugPrint('? [Auth] AuthException: ${e.message} (Code: ${e.statusCode})');
      throw _handleAuthError(e);
    } catch (e) {
      debugPrint('? [Auth] Erro desconhecido: $e');
      throw 'Erro desconhecido: $e';
    }
  }

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      debugPrint('?? [Auth] Iniciando registro com email: $email');
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      debugPrint('? [Auth] Registro bem-sucedido! Usuario: ${response.user?.email}');
      return response.user;
    } on AuthException catch (e) {
      debugPrint('? [Auth] AuthException no registro: ${e.message} (Code: ${e.statusCode})');
      throw _handleAuthError(e);
    } catch (e) {
      debugPrint('? [Auth] Erro desconhecido no registro: $e');
      throw 'Erro desconhecido: $e';
    }
  }

  // --- GOOGLE SIGN-IN ---
  Future<void> signInWithGoogle() async {
    try {
      debugPrint('🔐 [Auth] Iniciando login com Google...');
      // IMPORTANTE: Configure no Supabase Dashboard:
      // 1. Authentication > Providers > Google
      // 2. Adicione suas credenciais OAuth (Client ID + Client Secret)
      // 3. No Google Cloud Console, adicione a Redirect URL do Supabase
      //    como Authorized Redirect URI

      // No Flutter Web, signInWithOAuth abre uma nova aba para o Google.
      // O retorno é capturado automaticamente pelo AuthGate via onAuthStateChange.
      // redirectTo deve ser a URL da aplicação web (não deep link mobile).
      final redirectUrl = Uri.base.origin;
      debugPrint('🔐 [Auth] Redirect URL: $redirectUrl');

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? redirectUrl : null,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
      debugPrint('✅ [Auth] OAuth iniciado — aguardando retorno do Google...');
    } on AuthException catch (e) {
      debugPrint('❌ [Auth] AuthException no Google login: ${e.message} (Code: ${e.statusCode})');
      throw _handleAuthError(e);
    } catch (e) {
      debugPrint('❌ [Auth] Erro ao autenticar com Google: $e');
      throw 'Erro ao autenticar com Google: $e';
    }
  }

  // --- OUTROS MÉTODOS ---

  Future<void> signOut() async {
    debugPrint('?? [Auth] Fazendo logout...');
    await _supabase.auth.signOut();
    debugPrint('? [Auth] Logout bem-sucedido!');
  }

  Future<void> resetPassword(String email) async {
    try {
      debugPrint('?? [Auth] Enviando link de recuperação para: $email');
      await _supabase.auth.resetPasswordForEmail(email);
      debugPrint('? [Auth] Link de recuperação enviado!');
    } on AuthException catch (e) {
      debugPrint('? [Auth] AuthException na recuperação: ${e.message}');
      throw _handleAuthError(e);
    } catch (e) {
      debugPrint('? [Auth] Erro ao redefinir senha: $e');
      throw 'Erro ao redefinir senha: $e';
    }
  }

  // --- TRATAMENTO DE ERROS ---

  String _handleAuthError(AuthException e) {
    // Mensagens de erro em português
    final message = e.message.toLowerCase();
    
    debugPrint('?? [Auth] Processando erro: $message (Code: ${e.statusCode})');
    
    if (message.contains('invalid login credentials') || 
        message.contains('invalid email or password')) {
      return 'E-mail ou senha incorretos';
    }
    
    if (message.contains('user already registered') || 
        message.contains('already registered')) {
      return 'Este e-mail já está cadastrado';
    }
    
    if (message.contains('email not confirmed')) {
      return 'Por favor, confirme seu e-mail antes de fazer login';
    }
    
    if (message.contains('invalid email')) {
      return 'E-mail inválido';
    }
    
    if (message.contains('password should be at least')) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    
    if (e.statusCode == '429') {
      return 'Muitas tentativas. Aguarde alguns minutos';
    }
    
    if (message.contains('network') || message.contains('connection')) {
      return 'Erro de conexão. Verifique sua internet';
    }
    
    // Mensagem genérica se não identificar o erro
    return 'Erro de autenticação: ${e.message}';
  }
}