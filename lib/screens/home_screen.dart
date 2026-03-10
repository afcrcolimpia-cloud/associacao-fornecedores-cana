// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/app_shell.dart';
import 'dashboard_screen.dart';
import 'proprietarios_screen.dart';
import 'propriedades_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Home',
      selectedIndex: _selectedIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedIndex = index);
      },
      child: Column(
        children: [
          // TabBar para alternare entre Dashboard e Gestão
          Container(
            color: AppColors.surfaceDark,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_outlined, size: 20), text: 'Dashboard'),
                Tab(icon: Icon(Icons.agriculture_outlined, size: 20), text: 'Gestão'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                DashboardScreen(),
                _GestaoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GestaoTab extends StatefulWidget {
  const _GestaoTab();

  @override
  State<_GestaoTab> createState() => _GestaoTabState();
}

class _GestaoTabState extends State<_GestaoTab> with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.surfaceDark,
          child: TabBar(
            controller: _subTabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Proprietários', icon: Icon(Icons.person_outline, size: 18)),
              Tab(text: 'Propriedades', icon: Icon(Icons.home_work_outlined, size: 18)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: const [
              ProprietariosScreen(),
              PropriedadesScreen(),
            ],
          ),
        ),
      ],
    );
  }
}