// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/database_config.dart';
import 'constants/app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: DatabaseConfig.supabaseUrl,
    anonKey: DatabaseConfig.supabaseAnonKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AFCRC - Catanduva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.newPrimary,
          secondary: AppColors.newPrimary,
          surface: AppColors.surfaceDark,
          error: AppColors.newDanger,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.newTextPrimary,
          onError: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.newTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.newPrimary,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.newPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderDark),
          ),
        ),
        dividerColor: AppColors.borderDark,
        dividerTheme: const DividerThemeData(
          color: AppColors.borderDark,
          thickness: 1,
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedColor: AppColors.newPrimary,
          labelStyle: TextStyle(color: AppColors.newTextPrimary),
          secondaryLabelStyle: TextStyle(color: AppColors.bgDark),
          side: BorderSide(color: AppColors.borderDark),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.surfaceDark,
          titleTextStyle: TextStyle(
            color: AppColors.newTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
            color: AppColors.newTextSecondary,
            fontSize: 14,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
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
          filled: true,
          fillColor: AppColors.surfaceDark,
          labelStyle: const TextStyle(color: AppColors.newTextSecondary),
          hintStyle: const TextStyle(color: AppColors.newTextMuted),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.newTextPrimary),
          displayMedium: TextStyle(color: AppColors.newTextPrimary),
          displaySmall: TextStyle(color: AppColors.newTextPrimary),
          headlineLarge: TextStyle(color: AppColors.newTextPrimary),
          headlineMedium: TextStyle(color: AppColors.newTextPrimary),
          headlineSmall: TextStyle(color: AppColors.newTextPrimary),
          titleLarge: TextStyle(color: AppColors.newTextPrimary),
          titleMedium: TextStyle(color: AppColors.newTextPrimary),
          titleSmall: TextStyle(color: AppColors.newTextPrimary),
          bodyLarge: TextStyle(color: AppColors.newTextPrimary),
          bodyMedium: TextStyle(color: AppColors.newTextPrimary),
          bodySmall: TextStyle(color: AppColors.newTextSecondary),
          labelLarge: TextStyle(color: AppColors.newTextPrimary),
          labelMedium: TextStyle(color: AppColors.newTextSecondary),
          labelSmall: TextStyle(color: AppColors.newTextMuted),
        ),
        iconTheme: const IconThemeData(color: AppColors.newTextSecondary),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.newPrimary;
            }
            return AppColors.newTextMuted;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.newPrimary.withValues(alpha: 0.4);
            }
            return AppColors.borderDark;
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.newPrimary;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          side: const BorderSide(color: AppColors.newTextMuted),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            fillColor: AppColors.surfaceDark,
            filled: true,
          ),
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(AppColors.bgDark),
          dataRowColor: WidgetStateProperty.all(AppColors.surfaceDark),
          headingTextStyle: const TextStyle(
            color: AppColors.newTextPrimary,
            fontWeight: FontWeight.bold,
          ),
          dataTextStyle: const TextStyle(color: AppColors.newTextPrimary),
          dividerThickness: 1,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: AppColors.surfaceDark,
          textStyle: TextStyle(color: AppColors.newTextPrimary),
        ),
        listTileTheme: const ListTileThemeData(
          textColor: AppColors.newTextPrimary,
          iconColor: AppColors.newTextSecondary,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1E293B),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.newPrimary,
        ),
        tooltipTheme: const TooltipThemeData(
          decoration: BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          textStyle: TextStyle(color: Colors.white),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'),
      home: const AuthGate(),
    );
  }
}

// --- AUTH GATE (Guarda de Autenticação) ---

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('✅ AuthGate inicializado');
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Erro de Conexão',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => setState(() => _errorMessage = null),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        debugPrint('📡 AuthGate Stream State: ${snapshot.connectionState}');

        // Mostra loading enquanto verifica autenticação
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint('❌ AuthGate Error: ${snapshot.error}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _errorMessage = 'Erro ao conectar: ${snapshot.error}');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Verifica se há sessão ativa
        final session = snapshot.hasData ? snapshot.data!.session : null;
        debugPrint('📋 Session: ${session != null ? "Ativo" : "Inativo"}');

        if (session != null) {
          // Usuário autenticado -> HomeScreen
          debugPrint('✅ Usuário autenticado - Entrando no Home');
          return const HomeScreen();
        } else {
          // Usuário não autenticado -> LoginScreen
          debugPrint('🔐 Usuário não autenticado - Mostrando Login');
          return const LoginScreen();
        }
      },
    );
  }
}