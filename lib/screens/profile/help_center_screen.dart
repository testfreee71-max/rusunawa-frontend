import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/header_scaffold.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const List<(String, String)> _faqs = <(String, String)>[
    (
      'Bagaimana cara mengajukan kamar?',
      'Buka tab Cari Kamar, pilih kamar yang tersedia, lalu tekan Booking '
          'Sekarang dan lengkapi tiga langkah pengajuan.',
    ),
    (
      'Berapa lama pengajuan diproses?',
      'Pengajuan diproses oleh pengelola rusunawa. Pantau statusnya di tab '
          'Booking Saya.',
    ),
    (
      'Apakah saya bisa membatalkan pengajuan?',
      'Bisa, selama statusnya masih Menunggu Persetujuan. Buka Detail '
          'Booking lalu tekan Batalkan Pengajuan.',
    ),
    (
      'Berapa biaya sewa kamar?',
      'Kamar rusunawa gratis karena disubsidi kampus.',
    ),
    (
      'Dokumen apa yang perlu disiapkan?',
      'KTM aktif, KTP, dan surat keterangan mahasiswa aktif dari kampus.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return HeaderScaffold(
      title: 'Pusat Bantuan',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: <Widget>[
          Text('Pertanyaan Umum', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < _faqs.length; i++) ...<Widget>[
                    if (i != 0)
                      const Divider(height: 1, color: AppColors.border),
                    ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        14,
                      ),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      iconColor: AppColors.primary,
                      collapsedIconColor: AppColors.textMuted,
                      title: Text(
                        _faqs[i].$1,
                        style: AppTextStyles.cardTitle,
                      ),
                      children: <Widget>[
                        Text(_faqs[i].$2, style: AppTextStyles.body),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Hubungi Admin', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          const _ContactTile(
            icon: Icons.mail_outline_rounded,
            title: 'Email',
            value: 'rusunawa@ubbg.ac.id',
          ),
          const SizedBox(height: 10),
          const _ContactTile(
            icon: Icons.phone_outlined,
            title: 'Telepon',
            value: '0651-000000',
          ),
          const SizedBox(height: 10),
          const _ContactTile(
            icon: Icons.schedule_rounded,
            title: 'Jam Layanan',
            value: 'Senin - Jumat, 08.00 - 16.00 WIB',
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTextStyles.bodySmall),
                Text(value, style: AppTextStyles.cardTitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
