import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techstax_assign/app/theme.dart';
import 'package:techstax_assign/auth/auth_service.dart';
import 'package:techstax_assign/auth/login_screen.dart';
import 'package:techstax_assign/dashboard/dashboard_screen.dart';

// Replace these with your own Supabase credentials
const String supabaseUrl = 'https://zgkqyuujnggeasbtyltr.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpna3F5dXVqbmdnZWFzYnR5bHRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwODc4NDIsImV4cCI6MjA2MDY2Mzg0Mn0.CjZpnlA2A4w7bqqVQVEdxEQtUQILBap5ECVp-UQWwV8';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            title: 'Mini TaskHub',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: authService.currentUser != null
                ? const DashboardScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
