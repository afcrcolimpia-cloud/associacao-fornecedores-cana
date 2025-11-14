import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants/app_colors.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/database_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Conectar ao Supabase
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
        primaryColor: AppColors.verdeMusgo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.verdeMusgo,
          primary: AppColors.verdeMusgo,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.verdeMusgo,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.verdeMusgo,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.verdeMusgo,
            foregroundColor: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}