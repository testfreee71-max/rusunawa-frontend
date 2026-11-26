import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../main_shell.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = AppState.instance.login(
      _identifierController.text.trim(),
      _passwordController.text,
    );

    if (!success) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const MainShell(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Background biru.
          Positioned.fill(
            child: Container(
              color: AppColors.primary,
            ),
          ),

          // Background langit.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 410,
            child: Image.asset(
              'assets/images/login_sky.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // Foto gedung.
          Positioned(
            top: 160,
            left: -1,
            right: -1,
            height: 205,
            child: Image.asset(
              'assets/images/campus.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // Form login.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            top: isKeyboardOpen ? 200 : 350,
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    28,
                    24,
                    24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Masuk Ke Akun',
                          style: AppTextStyles.sectionTitle,
                        ),
                        const SizedBox(height: 6),

                        Text(
                          'Masuk untuk melanjutkan ke SiRUNA',
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: 24),

                        AppTextField(
                          controller: _identifierController,
                          label: 'NIM / Email',
                          hint: 'Masukkan NIM atau email',
                          prefixIcon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'NIM atau email wajib diisi';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        AppTextField(
                          controller: _passwordController,
                          label: 'Kata Sandi',
                          hint: 'Masukkan kata sandi',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Kata sandi minimal 6 karakter';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 28,
                              height: 32,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primary,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Ingat Saya',
                              style: AppTextStyles.bodySmall,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                    const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Lupa Password?',
                                style: AppTextStyles.linkText,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        AppButton(
                          label: 'Masuk',
                          onPressed: _login,
                        ),

                        const SizedBox(height: 24),

                        const _LoginDivider(),

                        const SizedBox(height: 20),

                        AppButton(
                          label: 'Daftar',
                          variant: AppButtonVariant.outline,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                const RegisterScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginDivider extends StatelessWidget {
  const _LoginDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Divider(color: AppColors.border),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Belum Punya Akun?',
            style: AppTextStyles.bodySmall,
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.border),
        ),
      ],
    );
  }
}