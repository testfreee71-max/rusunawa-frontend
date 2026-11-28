import 'package:flutter/material.dart';

class RoomFilterOptions {
  const RoomFilterOptions({this.building, this.minCapacity, this.sort});

  final String? building;
  final int? minCapacity;
  final String? sort;

  bool get isActive => building != null || minCapacity != null || sort != null;
}

class RoomFilterPanel extends StatefulWidget {
  const RoomFilterPanel({
    super.key,
    required this.buildings,
    required this.initialOptions,
  });

  final List<String> buildings;
  final RoomFilterOptions initialOptions;

  @override
  State<RoomFilterPanel> createState() => _RoomFilterPanelState();
}

class _RoomFilterPanelState extends State<RoomFilterPanel> {
  String? _building;
  int? _minCapacity;
  String? _sort;

  @override
  void initState() {
    super.initState();

    _building = widget.initialOptions.building;
    _minCapacity = widget.initialOptions.minCapacity;
    _sort = widget.initialOptions.sort;
  }

  void _apply() {
    Navigator.pop(
      context,
      RoomFilterOptions(
        building: _building,
        minCapacity: _minCapacity,
        sort: _sort,
      ),
    );
  }

  void _reset() {
    Navigator.pop(context, const RoomFilterOptions());
  }

  @override
  Widget build(BuildContext context) {
    final buildings = {...widget.buildings, ?_building}.toList()..sort();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Filter Lanjutan',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 6),

            const Text('Sesuaikan kamar dengan kebutuhan Anda.'),

            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              initialValue: _building,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Gedung',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Semua Gedung'),
                ),
                ...buildings.map(
                  (building) => DropdownMenuItem<String>(
                    value: building,
                    child: Text(building),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _building = value);
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              initialValue: _minCapacity,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Kapasitas Minimum',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text('Semua Kapasitas'),
                ),
                DropdownMenuItem<int>(value: 1, child: Text('Minimal 1 orang')),
                DropdownMenuItem<int>(value: 2, child: Text('Minimal 2 orang')),
                DropdownMenuItem<int>(value: 3, child: Text('Minimal 3 orang')),
                DropdownMenuItem<int>(value: 4, child: Text('Minimal 4 orang')),
              ],
              onChanged: (value) {
                setState(() => _minCapacity = value);
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _sort,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Pengurutan',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem<String>(value: null, child: Text('Default')),
                DropdownMenuItem<String>(
                  value: 'capacity_asc',
                  child: Text('Kapasitas Terkecil'),
                ),
                DropdownMenuItem<String>(
                  value: 'capacity_desc',
                  child: Text('Kapasitas Terbesar'),
                ),
                DropdownMenuItem<String>(
                  value: 'available_from_asc',
                  child: Text('Tanggal Tersedia Terawal'),
                ),
                DropdownMenuItem<String>(
                  value: 'available_from_desc',
                  child: Text('Tanggal Tersedia Terbaru'),
                ),
              ],
              onChanged: (value) {
                setState(() => _sort = value);
              },
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _apply,
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
