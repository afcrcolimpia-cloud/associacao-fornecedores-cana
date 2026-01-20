// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'proprietarios_screen.dart';
import 'propriedades_screen.dart';
import 'talhoes_screen.dart';
import 'anexos_screen.dart';
import 'operacoes_cultivo_screen.dart';
import 'precipitacao_screen.dart';
import 'precipitacao_por_municipios_screen.dart';
import '../models/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AFCRC - Sistema de Gestão'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.dashboard),
                text: 'Dashboard',
              ),
              Tab(
                icon: Icon(Icons.settings),
                text: 'Gestão',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Aba 1: Dashboard
            DashboardScreen(),
            
            // Aba 2: Gestão (com sub-navegação)
            _GestaoTab(),
          ],
        ),
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
    _subTabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.secondary,
        bottom: TabBar(
          controller: _subTabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Proprietários', icon: Icon(Icons.person)),
            Tab(text: 'Propriedades', icon: Icon(Icons.home_work)),
            Tab(text: 'Talhões', icon: Icon(Icons.landscape)),
            Tab(text: 'Anexos', icon: Icon(Icons.attach_file)),
            Tab(text: 'Tratos', icon: Icon(Icons.agriculture)),
            Tab(text: 'Operações', icon: Icon(Icons.engineering)),
            Tab(text: 'Precipitação', icon: Icon(Icons.water_drop)),
            Tab(text: 'Precipit. Municípios', icon: Icon(Icons.location_city)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _subTabController,
        children: const [
          ProprietariosScreen(),
          PropriedadesScreen(),
          _TalhoesTabContent(),
          _AnexosTabContent(),
          _TratosTabContent(),
          _OperacoesTabContent(),
          _PrecipitacaoTabContent(),
          PrecipitacaoPorMunicipiosScreen(),
        ],
      ),
    );
  }
}

// ============ Talhões Tab ============
class _TalhoesTabContent extends StatefulWidget {
  const _TalhoesTabContent();

  @override
  State<_TalhoesTabContent> createState() => _TalhoesTabContentState();
}

class _TalhoesTabContentState extends State<_TalhoesTabContent> {
  Propriedade? _propriedadeSelecionada;

  @override
  Widget build(BuildContext context) {
    if (_propriedadeSelecionada == null) {
      return _SelectPropriedadeScreen(
        onSelect: (propriedade) {
          setState(() => _propriedadeSelecionada = propriedade);
        },
        tabIndex: 1,
      );
    }

    return TalhoesScreen(
      propriedadeId: _propriedadeSelecionada!.id,
      propriedadeNome: _propriedadeSelecionada!.nomePropriedade,
    );
  }
}

// ============ Anexos Tab ============
class _AnexosTabContent extends StatefulWidget {
  const _AnexosTabContent();

  @override
  State<_AnexosTabContent> createState() => _AnexosTabContentState();
}

class _AnexosTabContentState extends State<_AnexosTabContent> {
  Propriedade? _propriedadeSelecionada;

  @override
  Widget build(BuildContext context) {
    if (_propriedadeSelecionada == null) {
      return _SelectPropriedadeScreen(
        onSelect: (propriedade) {
          setState(() => _propriedadeSelecionada = propriedade);
        },
        tabIndex: 1,
      );
    }

    return AnexosScreen(propriedade: _propriedadeSelecionada!);
  }
}

// ============ Tratos Culturais Tab ============
class _TratosTabContent extends StatefulWidget {
  const _TratosTabContent();

  @override
  State<_TratosTabContent> createState() => _TratosTabContentState();
}

class _TratosTabContentState extends State<_TratosTabContent> {
  Propriedade? _propriedadeSelecionada;

  @override
  Widget build(BuildContext context) {
    if (_propriedadeSelecionada == null) {
      return _SelectPropriedadeScreen(
        onSelect: (propriedade) {
          setState(() => _propriedadeSelecionada = propriedade);
        },
        tabIndex: 1,
      );
    }

    return OperacoesCultivoScreen(propriedade: _propriedadeSelecionada!);
  }
}

// ============ Operações Tab ============
class _OperacoesTabContent extends StatefulWidget {
  const _OperacoesTabContent();

  @override
  State<_OperacoesTabContent> createState() => _OperacoesTabContentState();
}

class _OperacoesTabContentState extends State<_OperacoesTabContent> {
  Propriedade? _propriedadeSelecionada;

  @override
  Widget build(BuildContext context) {
    if (_propriedadeSelecionada == null) {
      return _SelectPropriedadeScreen(
        onSelect: (propriedade) {
          setState(() => _propriedadeSelecionada = propriedade);
        },
        tabIndex: 1,
      );
    }

    return OperacoesCultivoScreen(propriedade: _propriedadeSelecionada!);
  }
}

// ============ Precipitação Tab ============
class _PrecipitacaoTabContent extends StatefulWidget {
  const _PrecipitacaoTabContent();

  @override
  State<_PrecipitacaoTabContent> createState() => _PrecipitacaoTabContentState();
}

class _PrecipitacaoTabContentState extends State<_PrecipitacaoTabContent> {
  Propriedade? _propriedadeSelecionada;

  @override
  Widget build(BuildContext context) {
    if (_propriedadeSelecionada == null) {
      return _SelectPropriedadeScreen(
        onSelect: (propriedade) {
          setState(() => _propriedadeSelecionada = propriedade);
        },
        tabIndex: 1,
      );
    }

    return PrecipitacaoScreen(propriedade: _propriedadeSelecionada!);
  }
}
class _SelectPropriedadeScreen extends StatelessWidget {
  final Function(Propriedade) onSelect;
  final int tabIndex;

  const _SelectPropriedadeScreen({
    required this.onSelect,
    this.tabIndex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Selecione uma Propriedade',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Vá para a aba de Propriedades\ne escolha uma para acessar',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Ir para Propriedades'),
            onPressed: () {
              final tabController = DefaultTabController.of(context);
              tabController.animateTo(tabIndex);
            },
          ),
        ],
      ),
    );
  }
}
