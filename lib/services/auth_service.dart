// lib/services/auth_service.dart
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
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Erro desconhecido: $e';
    }
  }

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Erro desconhecido: $e';
    }
  }

  // --- GOOGLE SIGN-IN ---
  Future<User?> signInWithGoogle() async {
    try {
      // IMPORTANTE: Configure no Supabase Dashboard:
      // 1. Authentication > Providers > Google
      // 2. Adicione suas credenciais OAuth
      // 3. Configure Redirect URL: io.supabase.flutterquickstart://login-callback
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback',
      );
      return _supabase.auth.currentUser;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Erro ao autenticar com Google: $e';
    }
  }

  // --- OUTROS MÉTODOS ---

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Erro ao redefinir senha: $e';
    }
  }

  // --- TRATAMENTO DE ERROS ---

  String _handleAuthError(AuthException e) {
    // Mensagens de erro em português
    final message = e.message.toLowerCase();
    
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
    
    // Mensagem genérica se não identificar o erro
    return 'Erro de autenticação: ${e.message}';
  }
}