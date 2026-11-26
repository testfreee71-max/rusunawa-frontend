import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/app_colors.dart';
import 'core/app_state.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SiRunaApp());
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
          home: AppState.instance.isLoggedIn
              ? const MainShell()
              : const LoginScreen(),
        );
      },
    );
  }
}