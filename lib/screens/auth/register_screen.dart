import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nimController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  String? _studyProgram;
  bool _acceptedTerms = false;

  static const List<String> _studyPrograms = <String>[
    'S1 Pendidikan Bahasa dan Sastra Aceh',
    'S1 Pendidikan Bahasa Indonesia',
    'S1 Pendidikan Bahasa Inggris',
    'S1 Pendidikan Guru Pendidikan Anak Usia Dini (PGPAUD)',
    'S1 Pendidikan Guru Sekolah Dasar (PGSD)',
    'S1 Pendidikan Ilmu Pengetahuan Alam (Pendidikan IPA)',
    'S1 Pendidikan Jasmani',
    'S1 Pendidikan Matematika',
    'S1 Pendidikan Seni Pertunjukan',
    'S1 Ilmu Komputer',
    'S1 Kebidanan',
    'S1 Keperawatan',
    'Pendidikan Profesi Bidan',
    'Pendidikan Profesi Ners',
    'S2 Pendidikan Dasar',
    'S2 Pendidikan Jasmani',
    'S2 Penjaminan Mutu Pendidikan',
  ];

  @override
  void dispose() {
    _nimController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  bool _busy = false;
  Future<void> _register() async {
    if (_busy) return;
    final valid = _formKey.currentState!.validate();

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui Syarat & Ketentuan'),
        ),
      );
      return;
    }

    if (!valid) {
      return;
    }

    setState(() => _busy = true);
    final success = await AppState.instance.register(
      _nimController.text.trim(),
      _nameController.text.trim(),
      _emailController.text.trim(),
      _studyProgram!,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _busy = false);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppState.instance.authError ?? 'Registrasi gagal')));
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Daftar Akun'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Buat Akun', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 6),
                Text(
                  'Lengkapi data berikut untuk membuat akun SiRUNA.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 22),
                AppTextField(
                  controller: _nimController,
                  label: 'NIM',
                  prefixIcon: Icons.badge_outlined,
                  validator: _requiredValidator('NIM wajib diisi'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: _requiredValidator('Nama lengkap wajib diisi'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailValidator,
                ),
                const SizedBox(height: 14),
                AppDropdownField(
                  label: 'Program Studi',
                  value: _studyProgram,
                  items: _studyPrograms,
                  prefixIcon: Icons.school_outlined,
                  onChanged: (value) {
                    setState(() {
                      _studyProgram = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Program studi wajib dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _passwordController,
                  label: 'Kata Sandi',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  validator: _passwordValidator,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _confirmationController,
                  label: 'Konfirmasi Kata Sandi',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Konfirmasi kata sandi tidak sama';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Checkbox(
                      value: _acceptedTerms,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 11),
                        child: Text(
                          'Saya menyetujui Syarat & Ketentuan yang berlaku.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppButton(
                  label: 'Daftar',
                  onPressed: _register,
                  isLoading: _busy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? Function(String?) _requiredValidator(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email wajib diisi';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Masukkan alamat email yang valid';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }

    return null;
  }
}