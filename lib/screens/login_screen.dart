import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
// A navegação é delegada ao AuthGate que observa o stream de autenticação.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // Variável para controle de estado do botão de recuperar senha
  bool _isResettingPassword = false; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // Função auxiliar para exibir mensagens (melhora a padronização e a leitura)
  void _showSnackbar(String message, {Color color = AppColors.primary}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // A função de login agora apenas chama o serviço.
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // Sucesso: O AuthGate fará o redirecionamento.
      
    } catch (e) {
      // Tratamento de erro refinado para feedback mais claro
      final errorMessage = e.toString().contains('user-not-found')
          ? 'E-mail ou senha inválidos.'
          : 'Ocorreu um erro no login. Verifique sua conexão ou tente novamente.';
      _showSnackbar(errorMessage, color: AppColors.error);

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // O login com Google também é simplificado.
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();

    } catch (e) {
      _showSnackbar('Erro ao fazer login com Google: Por favor, tente novamente.', color: AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  // Esqueleto para a recuperação de senha
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackbar('Por favor, preencha o campo de e-mail primeiro.', color: AppColors.warning);
      return;
    }
    
    setState(() => _isResettingPassword = true);
    
    try {
      await _authService.resetPassword(email);
      _showSnackbar('Link de recuperação enviado para $email. Verifique sua caixa de entrada.');
      
    } catch (e) {
      _showSnackbar('Erro ao enviar link de recuperação. Verifique se o e-mail está correto.', color: AppColors.error);
    } finally {
      if (mounted) setState(() => _isResettingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const corTexto = AppColors.primary; 
    
    // Define se qualquer ação de autenticação está em andamento
    final isAnyLoading = _isLoading || _isResettingPassword;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    // Lembrete: Certifique-se de que este asset existe em pubspec.yaml
                    'assets/logo/logo.png',
                    width: 160,
                    height: 160,
                  ),
                  const SizedBox(height: 16),
                  // Nome da empresa
                  Text(
                    'Associação dos Fornecedores de Cana da Região de Catanduva',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: corTexto,
                        ),
                  ),
                  const SizedBox(height: 40),
                  // Texto de boas-vindas
                  Text(
                    'Bem-vindo!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: corTexto,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistema de Gestão Agrícola',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: corTexto,
                        ),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isAnyLoading, // Desabilita durante o loading
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            hintText: 'seu@email.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite seu e-mail';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Digite um e-mail válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          enabled: !isAnyLoading, // Desabilita durante o loading
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: isAnyLoading ? null : () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Digite sua senha';
                            }
                            if (value.length < 6) {
                              return 'Senha deve ter no mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'ENTRAR',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        
                        // --- LINHAS ADAPTADAS CONFORME SUA SOLICITAÇÃO ---
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Divider(color: corTexto.withOpacity(0.5))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OU',
                                style: TextStyle(
                                  color: corTexto,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: corTexto.withOpacity(0.5))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            // Ajustado para o onPressed solicitado (_isResettingPassword foi removido do check)
                            onPressed: _isLoading ? null : _loginWithGoogle,
                            icon: Image.asset(
                              'assets/icons/google.png',
                              width: 32,
                              height: 32,
                              // Adicionado o errorBuilder para fallback visual
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.login, size: 24);
                              },
                            ),
                            label: const Text( // Mantido const para otimização, pois corTexto é constante
                              'Entrar com Google',
                              style: TextStyle(color: corTexto),
                            ),
                            style: OutlinedButton.styleFrom(
                              // Cor da borda alterada para corTexto total (sem opacidade)
                              side: const BorderSide(color: corTexto), 
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        // --- FIM DAS LINHAS ADAPTADAS ---
                        
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: _isResettingPassword ? null : _resetPassword,
                          child: _isResettingPassword 
                            ? SizedBox(
                                width: 14, height: 14, 
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, 
                                  color: corTexto.withOpacity(0.7)
                                )
                              )
                            : const Text(
                              'Esqueci minha senha',
                              style: TextStyle(color: corTexto),
                            ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Desenvolvido por Rafael Henrique Vernici',
                      style: TextStyle(
                        fontSize: 12,
                        color: corTexto.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}