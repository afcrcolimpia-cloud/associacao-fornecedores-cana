// lib/screens/proprietario_detail_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../utils/formatters.dart';

class ProprietarioDetailScreen extends StatefulWidget {
  final Proprietario proprietario;

  const ProprietarioDetailScreen({
    super.key,
    required this.proprietario,
  });

  @override
  State<ProprietarioDetailScreen> createState() =>
      _ProprietarioDetailScreenState();
}

class _ProprietarioDetailScreenState extends State<ProprietarioDetailScreen> {
  late Proprietario _proprietario;
  int _selectedNavigationIndex = 0;

  @override
  void initState() {
    super.initState();
    _proprietario = widget.proprietario;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: 'Detalhes do Proprietário',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      _proprietario.nome.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _proprietario.nome,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _proprietario.ativo
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _proprietario.ativo ? 'ATIVO' : 'INATIVO',
                      style: TextStyle(
                        color: _proprietario.ativo
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.badge, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Documentos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    label: _proprietario.cpfCnpj.length == 11 ? 'CPF' : 'CNPJ',
                    value: _proprietario.cpfCnpj.length == 11
                        ? Formatters.formatCPF(_proprietario.cpfCnpj)
                        : Formatters.formatCNPJ(_proprietario.cpfCnpj),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_proprietario.telefone != null || _proprietario.email != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.contact_phone, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Contato',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.primary,
                                  ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (_proprietario.telefone != null) ...[
                      _buildInfoRow(
                        context,
                        label: 'Telefone',
                        value: _proprietario.telefone!,
                        icon: Icons.phone,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_proprietario.email != null)
                      _buildInfoRow(
                        context,
                        label: 'E-mail',
                        value: _proprietario.email!,
                        icon: Icons.email,
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          if (_proprietario.endereco != null ||
              _proprietario.cidade != null ||
              _proprietario.estado != null ||
              _proprietario.cep != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Endereço',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.primary,
                                  ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (_proprietario.cep != null) ...[
                      _buildInfoRow(
                        context,
                        label: 'CEP',
                        value: _proprietario.cep!,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_proprietario.endereco != null) ...[
                      _buildInfoRow(
                        context,
                        label: 'Endereço',
                        value: _proprietario.endereco!,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_proprietario.cidade != null ||
                        _proprietario.estado != null)
                      _buildInfoRow(
                        context,
                        label: 'Cidade/UF',
                        value:
                            '${_proprietario.cidade ?? ""}, ${_proprietario.estado ?? ""}',
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Informações do Sistema',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    label: 'Cadastrado em',
                    value: Formatters.formatDateTime(_proprietario.criadoEm),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    label: 'Última atualização',
                    value:
                        Formatters.formatDateTime(_proprietario.atualizadoEm),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 8),
        ],
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
