import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String? title;
  final int selectedIndex;
  final ValueChanged<int> onNavigationSelect;
  final bool showBackButton;

  const AppShell({
    super.key,
    required this.child,
    this.title,
    required this.selectedIndex,
    required this.onNavigationSelect,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SelectionArea(
              child: Container(
                color: AppColors.bgDark,
                child: child,
              ),
            ),
          ),
        ],
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
