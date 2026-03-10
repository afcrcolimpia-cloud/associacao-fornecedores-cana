import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  final String? title;
  final int selectedIndex;
  final ValueChanged<int> onNavigationSelect;

  const AppShell({
    Key? key,
    required this.child,
    this.title,
    required this.selectedIndex,
    required this.onNavigationSelect,
  }) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late bool _sidebarExpanded;

  @override
  void initState() {
    super.initState();
    _sidebarExpanded = true;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final sidebarWidth = _sidebarExpanded ? 240.0 : 80.0;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(isMobile, sidebarWidth),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                // Content
                Expanded(
                  child: Container(
                    color: AppColors.bgDark,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isMobile, double width) {
    final sidebarItems = [
      ('Dashboard', Icons.dashboard_outlined, 0),
      ('Proprietários', Icons.person_outline, 1),
      ('Propriedades', Icons.home_outlined, 2),
      ('Talhões', Icons.agriculture_outlined, 3),
      ('Produtividade', Icons.trending_up_outlined, 4),
      ('Precipitação', Icons.cloud_queue_outlined, 5),
      ('Operações', Icons.construction_outlined, 6),
      ('Custo Operacional', Icons.attach_money_outlined, 7),
      ('Tratos Culturais', Icons.eco_outlined, 8),
      ('Anexos', Icons.attachment_outlined, 9),
      ('Relatórios', Icons.assessment_outlined, 10),
      ('Configurações', Icons.settings_outlined, 11),
    ];

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          right: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo/Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 40,
              child: _sidebarExpanded
                  ? Text(
                      'AFCRC',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.newPrimary,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppColors.newPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'A',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.bgDark,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: sidebarItems.length,
              itemBuilder: (context, index) {
                final (label, icon, value) = sidebarItems[index];
                final isSelected = widget.selectedIndex == value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    selected: isSelected,
                    selectedTileColor: AppColors.newPrimary.withOpacity(0.15),
                    leading: Icon(
                      icon,
                      color: isSelected
                          ? AppColors.newPrimary
                          : AppColors.newTextSecondary,
                      size: 20,
                    ),
                    title: _sidebarExpanded
                        ? Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.newPrimary
                                  : AppColors.newTextSecondary,
                            ),
                          )
                        : null,
                    onTap: () => widget.onNavigationSelect(value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
          // Toggle Button
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: Icon(
                _sidebarExpanded
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: AppColors.newTextSecondary,
              ),
              onPressed: () {
                setState(() {
                  _sidebarExpanded = !_sidebarExpanded;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (widget.title != null)
            Text(
              widget.title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.newTextPrimary,
              ),
            ),
          const Spacer(),
          // User Menu (placeholder)
          Icon(
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
