import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_text_styles.dart';
import '../auth/login_screen.dart';
import '../../widgets/header_scaffold.dart';
import 'about_screen.dart';
import 'change_password_screen.dart';
import 'help_center_screen.dart';
import 'my_documents_screen.dart';
import 'personal_data_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari akun?'),
          content: const Text(
            'Anda yakin ingin keluar dari akun SiRUNA?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    AppState.instance.logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final user = AppState.instance.user;

        return HeaderScaffold(
          title: 'Profil',
          onBack: () => AppState.instance.setTab(0),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: <Widget>[
                    Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Container(
                          width: 88,
                          height: 88,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.infoBg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 3,
                            ),
                          ),
                          child: Text(
                            user.initial,
                            style: AppTextStyles.display.copyWith(
                              fontSize: 34,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Material(
                            color: AppColors.primary,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _open(
                                context,
                                const PersonalDataScreen(),
                              ),
                              child: const SizedBox(
                                width: 28,
                                height: 28,
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name.isEmpty ? 'Mahasiswa' : user.name,
                      style: AppTextStyles.cardHeading,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.nim.isEmpty ? 'NIM -' : 'NIM ${user.nim}',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      user.studyProgram.isEmpty ? '-' : user.studyProgram,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _MenuCard(
                children: <Widget>[
                  _ProfileMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Data Pribadi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const PersonalDataScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _ProfileMenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Ubah Kata Sandi',
                    onTap: () => _open(context, const ChangePasswordScreen()),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _ProfileMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Dokumen Saya',
                    onTap: () => _open(context, const MyDocumentsScreen()),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Pusat Bantuan',
                    onTap: () => _open(context, const HelpCenterScreen()),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _ProfileMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang SiRUNA',
                    onTap: () => _open(context, const AboutScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _MenuCard(
                children: <Widget>[
                  _ProfileMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Keluar',
                    color: AppColors.danger,
                    showChevron: false,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppColors.textTitle,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 3,
      ),
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: AppTextStyles.bodySmallBold.copyWith(color: color),
      ),
      trailing: showChevron
          ? Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      )
          : null,
    );
  }
}