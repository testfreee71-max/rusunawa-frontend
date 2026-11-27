import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/app_colors.dart';
import 'core/app_state.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider.value(value: AppState.instance, child: const SiRunaApp()));
  AppState.instance.restoreSession();
}

class SiRunaApp extends StatelessWidget {
  const SiRunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SiRUNA',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          home: AppState.instance.restoring
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : AppState.instance.isLoggedIn
              ? const MainShell()
              : const LoginScreen(),
        );
      },
    );
  }
}