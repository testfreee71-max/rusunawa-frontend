import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/header_scaffold.dart';

enum _DocStatus { notUploaded, pending, accepted }

class _DocItem {
  _DocItem(this.title, this.description, this.status);

  final String title;
  final String description;
  _DocStatus status;
}

class MyDocumentsScreen extends StatefulWidget {
  const MyDocumentsScreen({super.key});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  final List<_DocItem> _documents = <_DocItem>[
    _DocItem('KTM', 'Kartu Tanda Mahasiswa aktif', _DocStatus.accepted),
    _DocItem('KTP', 'Kartu Tanda Penduduk', _DocStatus.pending),
    _DocItem(
      'Surat Keterangan',
      'Surat keterangan mahasiswa aktif dari kampus',
      _DocStatus.notUploaded,
    ),
  ];

  void _upload(_DocItem item) {
    setState(() => item.status = _DocStatus.pending);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} berhasil diunggah')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HeaderScaffold(
      title: 'Dokumen Saya',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: <Widget>[
          Text('Dokumen Persyaratan', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          for (final item in _documents) ...<Widget>[
            _DocumentCard(item: item, onUpload: () => _upload(item)),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.item, required this.onUpload});

  final _DocItem item;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (item.status) {
      _DocStatus.accepted => (
          'Diterima',
          AppColors.success,
          AppColors.successBg,
        ),
      _DocStatus.pending => (
          'Menunggu',
          AppColors.warning,
          AppColors.warningBg,
        ),
      _DocStatus.notUploaded => (
          'Belum diunggah',
          AppColors.textMuted,
          AppColors.placeholder,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 2),
                Text(item.description, style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: AppTextStyles.badge.copyWith(color: fg),
                  ),
                ),
              ],
            ),
          ),
          if (item.status != _DocStatus.accepted)
            IconButton(
              tooltip: 'Unggah',
              onPressed: onUpload,
              icon: const Icon(
                Icons.upload_rounded,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
