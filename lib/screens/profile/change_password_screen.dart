import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/header_scaffold.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateOld(String? value) {
    if (value == null || value.isEmpty) return 'Kata sandi lama wajib diisi';
    return null;
  }

  String? _validateNew(String? value) {
    if (value == null || value.isEmpty) return 'Kata sandi baru wajib diisi';
    if (value.length < 6) return 'Minimal 6 karakter';
    if (value == _oldController.text) {
      return 'Tidak boleh sama dengan kata sandi lama';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Konfirmasi wajib diisi';
    if (value != _newController.text) return 'Kata sandi tidak sama';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kata sandi berhasil diubah')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return HeaderScaffold(
      title: 'Ubah Kata Sandi',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Keamanan Akun', style: AppTextStyles.cardHeading),
                const SizedBox(height: 4),
                Text(
                  'Gunakan kata sandi yang sulit ditebak.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _oldController,
                  label: 'Kata Sandi Lama',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: _validateOld,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _newController,
                  label: 'Kata Sandi Baru',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: _validateNew,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _confirmController,
                  label: 'Konfirmasi Kata Sandi Baru',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: _validateConfirm,
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 20),
                AppButton(label: 'Simpan Kata Sandi', onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
