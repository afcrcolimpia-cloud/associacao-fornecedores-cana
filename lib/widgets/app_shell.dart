import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String? title;
  final int selectedIndex;
  final ValueChanged<int> onNavigationSelect;
  final bool showBackButton;
  final bool showSidebar;

  const AppShell({
    super.key,
    required this.child,
    this.title,
    required this.selectedIndex,
    required this.onNavigationSelect,
    this.showBackButton = false,
    this.showSidebar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SelectionArea(
              child: Row(
                children: [
                  if (showSidebar && isWide) _buildSidebar(context),
                  Expanded(
                    child: Container(
                      color: AppColors.bgDark,
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF16A34A), // newPrimary
            Color(0xFF15803D), // verde médio
            Color(0xFF166534), // verde escuro
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo
          Image.asset(
            'assets/logo/logo.png',
            width: 80,
            height: 80,
            colorBlendMode: BlendMode.multiply,
          ),
          const SizedBox(height: 12),
          Text(
            'AFCRC',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            'Gestão Agrícola',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 32),
          // Itens de navegação
          _buildSidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            selected: selectedIndex == 0,
            onTap: () => onNavigationSelect(0),
          ),
          _buildSidebarItem(
            icon: Icons.agriculture_outlined,
            label: 'Gestão',
            selected: selectedIndex == 1,
            onTap: () => onNavigationSelect(1),
          ),
          const Spacer(),
          // Rodapé da sidebar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Catanduva/SP\n© AFCRC 2026',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.white.withValues(alpha: selected ? 1 : 0.8)),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: Colors.white.withValues(alpha: selected ? 1 : 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (showBackButton)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.newTextPrimary),
                tooltip: 'Voltar',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          Text(
            'AFCRC',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.newPrimary,
            ),
          ),
          if (title != null) ...[
            const SizedBox(width: 16),
            Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.newTextPrimary,
              ),
            ),
          ],
          const Spacer(),
          const Icon(
            Icons.account_circle_outlined,
            color: AppColors.newTextSecondary,
            size: 28,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
