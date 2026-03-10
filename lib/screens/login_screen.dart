import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';

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
  bool _isResettingPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {Color color = AppColors.newSuccess}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.inter()),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      _showSnackbar(e.toString(), color: AppColors.newDanger);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      _showSnackbar('Erro ao fazer login com Google', color: AppColors.newDanger);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackbar('Por favor, preencha o e-mail', color: AppColors.newWarning);
      return;
    }

    setState(() => _isResettingPassword = true);

    try {
      await _authService.resetPassword(email);
      _showSnackbar('Link enviado para $email');
    } catch (e) {
      _showSnackbar('Erro ao enviar link de recuperação', color: AppColors.newDanger);
    } finally {
      if (mounted) setState(() => _isResettingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnyLoading = _isLoading || _isResettingPassword;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Row(
        children: [
          // Coluna esquerda — Info AFCRC (40%)
          if (!isMobile)
            Expanded(
              flex: 2,
              child: Container(
                color: AppColors.newPrimary,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/logo/logo.png',
                          width: 140,
                          height: 140,
                          colorBlendMode: BlendMode.multiply,
                        ),
                        const SizedBox(height: 40),
                        // Título
                        Text(
                          'Gestão Agrícola\nInteligente',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Descrição
                        Text(
                          'Sistema completo para gerenciar propriedades agrícolas com dados em tempo real',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Recursos
                        Column(
                          children: [
                            _buildFeature('📊', 'Dados em Tempo Real'),
                            const SizedBox(height: 16),
                            _buildFeature('📈', 'Análises Detalhadas'),
                            const SizedBox(height: 16),
                            _buildFeature('📱', 'Acesso em Qualquer Lugar'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Coluna direita — Formulário (60%)
          Expanded(
            flex: isMobile ? 5 : 3,
            child: Container(
              color: AppColors.bgDark,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: SizedBox(
                    width: 380,
                    child: Column(
                      children: [
                        // Título
                        Text(
                          'Bem-vindo',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.newTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sistema de Gestão AFCRC',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.newTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Formulário
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email Field
                              _buildInputField(
                                label: 'E-mail ou CPF',
                                controller: _emailController,
                                hint: 'seu@email.com',
                                prefix: Icons.email_outlined,
                                enabled: !isAnyLoading,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo obrigatório';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Password Field
                              _buildInputField(
                                label: 'Senha',
                                controller: _passwordController,
                                hint: '••••••••',
                                prefix: Icons.lock_outlined,
                                obscure: _obscurePassword,
                                enabled: !isAnyLoading,
                                onSuffixTap: isAnyLoading ? null : () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                                suffix: _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo obrigatório';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              // Botão Entrar
                              _buildPrimaryButton(
                                label: 'Entrar',
                                onPressed: _isLoading ? null : _login,
                                isLoading: _isLoading,
                              ),
                              const SizedBox(height: 20),
                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.borderDark,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'OU',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.newTextSecondary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.borderDark,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Google Button
                              _buildSecondaryButton(
                                label: 'Entrar com Google',
                                icon: Icons.login_outlined,
                                onPressed: _isLoading ? null : _loginWithGoogle,
                              ),
                              const SizedBox(height: 24),
                              // Link Recuperar Senha
                              TextButton(
                                onPressed: _isResettingPassword ? null : _resetPassword,
                                child: Text(
                                  'Esqueci minha senha',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.newPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData prefix,
    bool obscure = false,
    bool enabled = true,
    IconData? suffix,
    VoidCallback? onSuffixTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.newTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.newTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.newTextMuted,
            ),
            filled: true,
            fillColor: AppColors.bgDark,
            prefixIcon: Icon(prefix, color: AppColors.newTextSecondary, size: 20),
            suffixIcon: suffix != null
                ? IconButton(
                    icon: Icon(suffix, color: AppColors.newTextSecondary, size: 20),
                    onPressed: onSuffixTap,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderDark, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderDark, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.newPrimary, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.newDanger, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.newPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.newPrimary, size: 18),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.newPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.newPrimary, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildFeature(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }
}

