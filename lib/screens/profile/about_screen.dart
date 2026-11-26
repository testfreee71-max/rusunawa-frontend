import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/header_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HeaderScaffold(
      title: 'Tentang SiRUNA',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
        children: <Widget>[
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.infoBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.apartment_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('SiRUNA', style: AppTextStyles.display)),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Sistem Rusunawa • Versi 1.0.0',
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Tentang Aplikasi', style: AppTextStyles.cardHeading),
                const SizedBox(height: 8),
                Text(
                  'SiRUNA membantu mahasiswa Universitas Bina Bangsa '
                  'Getsempena mencari kamar rusunawa, mengajukan booking, '
                  'dan memantau status pengajuan dengan mudah.',
                  style: AppTextStyles.body.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '© 2026 Universitas Bina Bangsa Getsempena',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
