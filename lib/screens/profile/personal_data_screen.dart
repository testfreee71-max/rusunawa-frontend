import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_text_styles.dart';
import '../../models/user_profile.dart';
import '../../widgets/app_button.dart';
import '../../widgets/header_scaffold.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _nimController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  DateTime? _birthDate;
  String? _gender;

  static const List<String> _genders = <String>[
    'Laki-laki',
    'Perempuan',
  ];

  @override
  void initState() {
    super.initState();

    final user = AppState.instance.user;

    _nameController = TextEditingController(text: user.name);
    _nimController = TextEditingController(text: user.nim);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address);
    _birthDate = user.birthDate;
    _gender = user.gender.isEmpty ? null : user.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal lahir';

    const months = <String>[
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1950),
      lastDate: now,
    );

    if (selected != null) {
      setState(() {
        _birthDate = selected;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = AppState.instance.user;

    final updatedUser = UserProfile(
      nim: _nimController.text.trim(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      studyProgram: currentUser.studyProgram,
      birthDate: _birthDate,
      gender: _gender ?? '',
      address: _addressController.text.trim(),
    );

    AppState.instance.updateUser(updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil diperbarui'),
      ),
    );

    Navigator.pop(context);
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.hint,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    );
  }

  Widget _labeled(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: 6),
          field,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HeaderScaffold(
      title: 'Informasi Data Diri',
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Informasi Data Diri',
                      style: AppTextStyles.cardHeading,
                    ),
                    const SizedBox(height: 14),
                    _labeled(
                      'Nama Lengkap',
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.input,
                        decoration: _decoration('Nama Lengkap'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama lengkap wajib diisi';
                          }
                          return null;
                        },
                      ),
                    ),
                    _labeled(
                      'NIM',
                      TextFormField(
                        controller: _nimController,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.input,
                        decoration: _decoration('Masukkan NIM'),
                      ),
                    ),
                    _labeled(
                      'Email',
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextStyles.input,
                        decoration: _decoration('Masukkan alamat email'),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isNotEmpty && !email.contains('@')) {
                            return 'Email tidak valid';
                          }
                          return null;
                        },
                      ),
                    ),
                    _labeled(
                      'Nomor Telepon',
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTextStyles.input,
                        decoration: _decoration('Masukkan nomor telepon'),
                      ),
                    ),
                    _labeled(
                      'Tanggal Lahir',
                      InkWell(
                        onTap: _pickBirthDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: _decoration('').copyWith(
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                          ),
                          child: Text(
                            _formatDate(_birthDate),
                            style: _birthDate == null
                                ? AppTextStyles.hint
                                : AppTextStyles.input,
                          ),
                        ),
                      ),
                    ),
                    _labeled(
                      'Jenis Kelamin',
                      DropdownButtonFormField<String>(
                        initialValue: _gender,
                        isExpanded: true,
                        style: AppTextStyles.input,
                        decoration: _decoration('Pilih jenis kelamin'),
                        items: _genders
                            .map(
                              (gender) => DropdownMenuItem<String>(
                                value: gender,
                                child: Text(
                                  gender,
                                  style: AppTextStyles.input,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                    ),
                    _labeled(
                      'Alamat Lengkap',
                      TextFormField(
                        controller: _addressController,
                        minLines: 3,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        style: AppTextStyles.input,
                        decoration: _decoration('Masukkan alamat lengkap'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AppButton(label: 'Simpan Perubahan', onPressed: _save),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
