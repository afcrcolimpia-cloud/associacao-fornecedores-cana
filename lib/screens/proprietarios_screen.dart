// lib/screens/proprietarios_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_shell.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/proprietario_service.dart';
import '../utils/formatters.dart';
import 'proprietario_form_screen.dart';
import 'proprietario_detail_screen.dart';

class ProprietariosScreen extends StatefulWidget {
  const ProprietariosScreen({super.key});

  @override
  State<ProprietariosScreen> createState() => _ProprietariosScreenState();
}

class _ProprietariosScreenState extends State<ProprietariosScreen> {
  final _service = ProprietarioService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedNavigationIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      title: 'Proprietários',
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      child: Column(
        children: [
          // SEARCH BAR
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.bgDark,
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.newTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou CPF/CNPJ...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.newTextMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.newTextSecondary,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.newTextSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.newPrimary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // CONTENT
          Expanded(
            child: StreamBuilder<List<Proprietario>>(
              stream: _service.getProprietariosStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.newDanger,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar dados',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.newTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.newTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var proprietarios = snapshot.data ?? [];

                // Filtrar por busca
                if (_searchQuery.isNotEmpty) {
                  proprietarios = proprietarios.where((p) {
                    return p.nome.toLowerCase().contains(_searchQuery) ||
                        p.cpfCnpj.contains(_searchQuery);
                  }).toList();
                }

                if (proprietarios.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty
                              ? Icons.person_add_outlined
                              : Icons.search_off,
                          size: 64,
                          color: AppColors.newTextMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Nenhum proprietário cadastrado'
                              : 'Nenhum resultado encontrado',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.newTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Clique no botão + para adicionar'
                              : 'Tente buscar por outro termo',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.newTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // COUNTER
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            color: AppColors.newPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${proprietarios.length} ${proprietarios.length == 1 ? "proprietário" : "proprietários"}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.newTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // TABLE
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: proprietarios.isNotEmpty ? 200 : 100,
                          maxHeight: double.infinity,
                        ),
                        child: _buildProprietariosTable(proprietarios),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProprietariosTable(List<Proprietario> proprietarios) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            AppColors.borderDark.withOpacity(0.5),
          ),
          headingRowHeight: 48,
          dataRowHeight: 56,
          columns: [
            DataColumn(
              label: Text(
                'Nome',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.newTextPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'CPF/CNPJ',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.newTextPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Cidade',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.newTextPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.newTextPrimary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Ações',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.newTextPrimary,
                ),
              ),
            ),
          ],
          rows: proprietarios.map((p) {
            final cpfCnpj = p.cpfCnpj.length == 11
                ? Formatters.formatCPF(p.cpfCnpj)
                : Formatters.formatCNPJ(p.cpfCnpj);
            final cidade = p.cidade != null && p.estado != null
                ? '${p.cidade}, ${p.estado}'
                : p.cidade ?? 'N/A';
            
            return DataRow(
              onSelectChanged: (_) => _navigateToDetail(p),
              cells: [
                DataCell(
                  Text(
                    p.nome,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.newTextPrimary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    cpfCnpj,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.newTextSecondary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    cidade,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.newTextSecondary,
                    ),
                  ),
                ),
                DataCell(
                  _buildStatusBadge(p.ativo),
                ),
                DataCell(
                  _buildActionButtons(p),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool ativo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ativo ? AppColors.newSuccess.withOpacity(0.15) : AppColors.newDanger.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        ativo ? 'Ativo' : 'Inativo',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: ativo ? AppColors.newSuccess : AppColors.newDanger,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Proprietario p) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(
            Icons.visibility_outlined,
            size: 18,
            color: AppColors.newTextSecondary,
          ),
          onPressed: () => _navigateToDetail(p),
          tooltip: 'Visualizar',
        ),
        IconButton(
          icon: const Icon(
            Icons.edit_outlined,
            size: 18,
            color: AppColors.newPrimary,
          ),
          onPressed: () => _navigateToEdit(p),
          tooltip: 'Editar',
        ),
      ],
    );
  }

  Future<void> _navigateToDetail(Proprietario proprietario) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProprietarioDetailScreen(
          proprietario: proprietario,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _navigateToEdit(Proprietario proprietario) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProprietarioFormScreen(proprietario: proprietario),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }
}