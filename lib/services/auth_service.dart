import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<User?> get userStream {
    return _supabase.auth.onAuthStateChange.map((data) => data.session?.user);
  }

  User? get currentUser => _supabase.auth.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
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
      final response = await _supabase.auth.signUp(
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

  Future<User?> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.afcrc.gestao://login-callback',
      );
      return _supabase.auth.currentUser;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Erro ao autenticar com Google: $e';
    }
  }

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

  String _handleAuthError(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('Invalid login credentials')) {
          return 'Credenciais inválidas. Verifique seu email e senha.';
        }
        if (e.message.contains('User already registered')) {
          return 'E-mail já está em uso.';
        }
        return e.message;
      case '429':
        return 'Limite de requisições excedido. Tente novamente mais tarde.';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
}