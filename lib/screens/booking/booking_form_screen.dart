import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_text_styles.dart';
import '../../models/booking.dart';
import '../../models/room.dart';
import '../../widgets/header_scaffold.dart';
import 'booking_success_screen.dart';

const String _emptyLabel = 'Belum diisi';

const List<String> _studyPrograms = <String>[
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

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  int _step = 1;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _purpose;
  final _noteController = TextEditingController();

  late final TextEditingController _nameController;
  late final TextEditingController _nimController;
  String? _studyProgram;
  late final TextEditingController _phoneController;

  final List<String> _purposes = <String>[
    'Kuliah',
    'Magang',
    'Penelitian',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final user = AppState.instance.user;
    _nameController = TextEditingController(text: user.name);
    _nimController = TextEditingController(text: user.nim);
    _studyProgram =
    _studyPrograms.contains(user.studyProgram) ? user.studyProgram : null;
    _phoneController = TextEditingController(text: user.phone);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _nameController.dispose();
    _nimController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Room get _room {
    return AppState.instance.rooms.firstWhere(
          (room) => room.id == widget.roomId,
    );
  }

  String _displayValue(String value) {
    return value.trim().isEmpty ? _emptyLabel : value;
  }

  Future<void> _selectDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate?.add(const Duration(days: 30)) ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;

        if (_endDate != null && !_endDate!.isAfter(picked)) {
          _endDate = null;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  int get _durationMonths {
    if (_startDate == null || _endDate == null) return 0;

    final months =
        (_endDate!.year - _startDate!.year) * 12 +
            _endDate!.month -
            _startDate!.month;

    return months <= 0 ? 1 : months;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal';

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _nextStep() {
    if (_step == 1) {
      if (_nameController.text.trim().isEmpty) {
        _showMessage('Nama lengkap wajib diisi.');
        return;
      }

      if (_nimController.text.trim().isEmpty) {
        _showMessage('NIM wajib diisi.');
        return;
      }

      if (_studyProgram == null) {
        _showMessage('Program studi wajib diisi.');
        return;
      }

      if (_phoneController.text.trim().isEmpty) {
        _showMessage('No. HP wajib diisi.');
        return;
      }

      setState(() => _step = 2);
      return;
    }

    if (_step == 2) {
      if (_startDate == null || _endDate == null) {
        _showMessage('Tanggal masuk dan keluar wajib dipilih.');
        return;
      }

      if (!_endDate!.isAfter(_startDate!)) {
        _showMessage('Tanggal keluar harus setelah tanggal masuk.');
        return;
      }

      if (_purpose == null) {
        _showMessage('Silakan pilih keperluan tinggal.');
        return;
      }

      setState(() => _step = 3);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _goBack() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _confirmBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Booking'),
          content: Text(
            'Apakah Anda yakin ingin mengajukan booking untuk ${_room.name}?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final Booking booking = AppState.instance.submitBooking(
      room: _room,
      startDate: _startDate!,
      endDate: _endDate!,
      purpose: _purpose!,
      note: _noteController.text.trim(),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BookingSuccessScreen(
          bookingId: booking.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        return HeaderScaffold(
          title: 'Ajukan Kamar',
          onBack: _goBack,
          bottomBar: _BottomAction(
            step: _step,
            onNext: _step == 3 ? _confirmBooking : _nextStep,
          ),
          child: Column(
            children: <Widget>[
              _StepIndicator(currentStep: _step),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildStep(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1:
        return _FormCard(
          key: const ValueKey<int>(11),
          child: _buildPersonalData(),
        );
      case 2:
        return _FormCard(
          key: const ValueKey<int>(12),
          child: _buildPeriod(),
        );
      case 3:
        return _buildConfirmation();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalData() {
    return Column(
      key: const ValueKey<int>(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Data Diri', style: AppTextStyles.cardHeading),
        const SizedBox(height: 6),
        Text(
          'Pastikan data mahasiswa Anda sudah sesuai.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 18),
        _buildInputField(
          label: 'Nama Lengkap',
          controller: _nameController,
          icon: Icons.person_outline_rounded,
          hint: 'Masukkan nama lengkap',
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        _buildInputField(
          label: 'NIM',
          controller: _nimController,
          icon: Icons.badge_outlined,
          hint: 'Masukkan NIM',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        Text('Program Studi', style: AppTextStyles.label),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          initialValue: _studyProgram,
          isExpanded: true,
          menuMaxHeight: 320,
          style: AppTextStyles.input,
          decoration: _inputDecoration(
            icon: Icons.school_outlined,
            hint: 'Pilih program studi',
          ),
          selectedItemBuilder: (context) {
            return _studyPrograms
                .map(
                  (item) => Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.input,
              ),
            )
                .toList();
          },
          items: _studyPrograms
              .map(
                (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.input,
              ),
            ),
          )
              .toList(),
          onChanged: (value) {
            setState(() => _studyProgram = value);
          },
        ),
        const SizedBox(height: 12),
        _buildInputField(
          label: 'No. HP',
          controller: _phoneController,
          icon: Icons.phone_outlined,
          hint: 'Masukkan nomor HP',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 22),
        _RoomInfoCard(room: _room),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: AppTextStyles.input,
          decoration: _inputDecoration(icon: icon, hint: hint),
        ),
      ],
    );
  }

  Widget _buildPeriod() {
    return Column(
      key: const ValueKey<int>(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Pilih Periode', style: AppTextStyles.cardHeading),
        const SizedBox(height: 6),
        Text(
          'Tentukan periode tinggal dan keperluan Anda.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 20),
        _DateField(
          label: 'Tanggal Masuk',
          value: _formatDate(_startDate),
          onTap: () => _selectDate(isStart: true),
        ),
        const SizedBox(height: 14),
        _DateField(
          label: 'Tanggal Keluar',
          value: _formatDate(_endDate),
          onTap: () => _selectDate(isStart: false),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.infoBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Durasi Tinggal', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 3),
                  Text(
                    _durationMonths == 0
                        ? '-'
                        : '$_durationMonths bulan',
                    style: AppTextStyles.cardHeading.copyWith(fontSize: 16),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text('Periode', style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('Keperluan', style: AppTextStyles.label),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          initialValue: _purpose,
          isExpanded: true,
          style: AppTextStyles.input,
          decoration: _inputDecoration(
            icon: Icons.assignment_outlined,
            hint: 'Pilih keperluan',
          ),
          items: _purposes
              .map(
                (purpose) => DropdownMenuItem<String>(
              value: purpose,
              child: Text(purpose, style: AppTextStyles.input),
            ),
          )
              .toList(),
          onChanged: (value) {
            setState(() => _purpose = value);
          },
        ),
        const SizedBox(height: 18),
        Text('Catatan (Opsional)', style: AppTextStyles.label),
        const SizedBox(height: 7),
        TextField(
          controller: _noteController,
          maxLines: 4,
          style: AppTextStyles.input,
          decoration: _inputDecoration(
            icon: Icons.note_alt_outlined,
            hint: 'Tambahkan catatan jika diperlukan',
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    return Column(
      key: const ValueKey<int>(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Konfirmasi Booking', style: AppTextStyles.cardHeading),
        const SizedBox(height: 6),
        Text(
          'Periksa kembali data pengajuan Anda.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 20),
        _SummaryCard(
          title: 'Data Mahasiswa',
          icon: Icons.person_outline_rounded,
          rows: <_SummaryRowData>[
            _SummaryRowData('Nama', _displayValue(_nameController.text)),
            _SummaryRowData('NIM', _displayValue(_nimController.text)),
            _SummaryRowData(
              'Program Studi',
              _displayValue(_studyProgram ?? ''),
            ),
            _SummaryRowData('No. HP', _displayValue(_phoneController.text)),
          ],
        ),
        const SizedBox(height: 14),
        _SummaryCard(
          title: 'Informasi Kamar',
          icon: Icons.meeting_room_outlined,
          rows: <_SummaryRowData>[
            _SummaryRowData('Kamar', _room.name),
            _SummaryRowData('Lokasi', '${_room.building} - Lantai ${_room.floor}'),
            _SummaryRowData('Biaya', 'Gratis (Subsidi Kampus)'),
          ],
        ),
        const SizedBox(height: 14),
        _SummaryCard(
          title: 'Periode Tinggal',
          icon: Icons.calendar_today_outlined,
          rows: <_SummaryRowData>[
            _SummaryRowData('Masuk', _formatDate(_startDate)),
            _SummaryRowData('Keluar', _formatDate(_endDate)),
            _SummaryRowData('Durasi', '$_durationMonths bulan'),
            _SummaryRowData('Keperluan', _purpose ?? _emptyLabel),
            if (_noteController.text.trim().isNotEmpty)
              _SummaryRowData('Catatan', _noteController.text.trim()),
          ],
        ),
        const SizedBox(height: 14),
        const _InfoNote(
          text: 'Pengajuan akan diperiksa pengelola. Status bisa kamu pantau '
              'di menu Booking Saya.',
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
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
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const labels = <String>[
      'Data Diri',
      'Pilih Periode',
      'Konfirmasi',
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Stack(
        children: <Widget>[
          // Garis penghubung: dari tengah lingkaran 1 -> 2 -> 3
          Positioned(
            top: 13,
            left: 0,
            right: 0,
            child: Row(
              children: <Widget>[
                const Spacer(flex: 1),
                for (var i = 1; i <= 2; i++)
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: currentStep > i
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                const Spacer(flex: 1),
              ],
            ),
          ),
          // Lingkaran + label, 3 kolom sama lebar & rata tengah
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(3, (index) {
              final step = index + 1;
              final active = step <= currentStep;

              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? AppColors.primary
                            : AppColors.placeholder,
                      ),
                      child: Text(
                        '$step',
                        style: AppTextStyles.bodySmallBold.copyWith(
                          color: active ? Colors.white : AppColors.inactive,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10,
                        fontWeight: step == currentStep
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: active
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 7),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(value, style: AppTextStyles.input),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _RoomInfoCard extends StatelessWidget {
  const _RoomInfoCard({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 72,
      height: 72,
      color: AppColors.placeholder,
      child: const Icon(Icons.image_outlined, color: AppColors.inactive),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Informasi Kamar', style: AppTextStyles.cardHeading),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: room.images.isEmpty
                  ? placeholder
                  : Image.network(
                room.images.first,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(room.name, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 2),
                  Text(
                    '${room.building} - Lantai ${room.floor}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${room.capacity} Orang  •  AC  •  WiFi',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: room.available
                          ? AppColors.successBg
                          : AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      room.available ? 'Tersedia' : 'Habis',
                      style: AppTextStyles.badge.copyWith(
                        color: room.available
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryRowData {
  const _SummaryRowData(this.label, this.value);

  final String label;
  final String value;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_SummaryRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.infoBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          for (var i = 0; i < rows.length; i++) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 100,
                    child: Text(
                      rows[i].label,
                      style: AppTextStyles.body.copyWith(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rows[i].value,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: rows[i].value == _emptyLabel
                            ? AppColors.textMuted
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(
                height: 1,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.step,
    required this.onNext,
  });

  final int step;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isConfirmation = step == 3;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isConfirmation ? 'Konfirmasi' : 'Lanjut',
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}