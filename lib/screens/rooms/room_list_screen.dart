import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_text_styles.dart';
import '../../models/room.dart';
import '../../widgets/header_scaffold.dart';
import '../../widgets/room_card.dart';
import 'room_detail_screen.dart';
import 'room_filter_panel.dart';

enum _RoomFilter { all, male, female, available }

enum _RoomSort { name, availableFirst }

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  late final TextEditingController _searchController;

  _RoomFilter _filter = _RoomFilter.all;
  _RoomSort _sort = _RoomSort.name;

  RoomFilterOptions _advancedOptions = const RoomFilterOptions();

  String _lastQuery = '';

  final _app = AppState.instance;

  @override
  void initState() {
    super.initState();

    _lastQuery = _app.roomQuery;

    _searchController = TextEditingController(text: _lastQuery);
  }

  @override
  void dispose() {
    _app.roomViewModel.resetFilters();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAdvancedFilter() async {
    final buildings = _app.rooms.map((room) => room.building).toSet().toList()
      ..sort();

    final result = await showModalBottomSheet<RoomFilterOptions>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RoomFilterPanel(
        buildings: buildings,
        initialOptions: _advancedOptions,
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _advancedOptions = result;
    });

    await _loadAdvancedFilters();
  }

  Future<void> _loadAdvancedFilters() async {
    final vm = _app.roomViewModel;

    if (!_advancedOptions.isActive) {
      vm.resetFilters();

      if (mounted) {
        setState(() {});
      }

      return;
    }

    final pending = vm.loadFiltered(
      building: _advancedOptions.building,
      minCapacity: _advancedOptions.minCapacity,
      sort: _advancedOptions.sort,
      gender: switch (_filter) {
        _RoomFilter.male => 'Putra',
        _RoomFilter.female => 'Putri',
        _ => null,
      },
      available: _filter == _RoomFilter.available ? true : null,
    );

    if (mounted) {
      setState(() {});
    }

    await pending;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshRooms() async {
    await _app.refreshRooms();

    if (!mounted) return;

    if (_advancedOptions.isActive) {
      await _loadAdvancedFilters();
    }
  }

  void _resetAdvancedFilters() {
    _app.roomViewModel.resetFilters();

    setState(() {
      _advancedOptions = const RoomFilterOptions();
    });
  }

  List<Room> get _filteredRooms {
    final query = _searchController.text.trim().toLowerCase();

    final source = _advancedOptions.isActive
        ? _app.roomViewModel.filteredRooms
        : _app.rooms;

    var rooms = List<Room>.from(source);

    if (_filter == _RoomFilter.male) {
      rooms = rooms.where((room) => room.gender == 'Putra').toList();
    } else if (_filter == _RoomFilter.female) {
      rooms = rooms.where((room) => room.gender == 'Putri').toList();
    } else if (_filter == _RoomFilter.available) {
      rooms = rooms.where((room) => room.available).toList();
    }

    if (query.isNotEmpty) {
      rooms = rooms.where((room) {
        final searchable = <String>[
          room.name,
          room.building,
          room.gender,
          ...room.facilities,
        ].join(' ').toLowerCase();

        return searchable.contains(query);
      }).toList();
    }

    // Pertahankan urutan server ketika advanced sort aktif.
    if (_advancedOptions.sort == null) {
      if (_sort == _RoomSort.name) {
        rooms.sort((a, b) => a.name.compareTo(b.name));
      } else {
        rooms.sort((a, b) {
          if (a.available == b.available) {
            return a.name.compareTo(b.name);
          }

          return a.available ? -1 : 1;
        });
      }
    }

    return rooms;
  }

  void _handleSearch(String value) {
    _lastQuery = value;
    _app.roomQuery = value;

    setState(() {});
  }

  void _syncQueryFromState() {
    final query = _app.roomQuery;

    if (query == _lastQuery) return;

    _lastQuery = query;

    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }

  String get _advancedSummary {
    final options = _advancedOptions;

    return [
      if (options.building != null) options.building!,
      if (options.minCapacity != null) 'Min. ${options.minCapacity} orang',
      if (options.sort != null)
        switch (options.sort) {
          'capacity_asc' => 'Kapasitas terkecil',
          'capacity_desc' => 'Kapasitas terbesar',
          'available_from_asc' => 'Tanggal terawal',
          'available_from_desc' => 'Tanggal terbaru',
          _ => 'Pengurutan lanjutan',
        },
    ].join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _app,
      builder: (context, _) {
        _syncQueryFromState();

        final vm = _app.roomViewModel;
        final advanced = _advancedOptions.isActive;

        final loading = advanced ? vm.filterLoading : _app.roomsLoading;

        final error = advanced ? vm.filterError : _app.roomsError;

        final rooms = _filteredRooms;

        return HeaderScaffold(
          title: 'Cari Kamar',
          onBack: () => _app.setTab(0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SearchField(
                  controller: _searchController,
                  onChanged: _handleSearch,
                ),

                const SizedBox(height: 14),

                Text('Ketersediaan Kamar', style: AppTextStyles.cardHeading),

                const SizedBox(height: 9),

                _FilterRow(
                  selected: _filter,
                  onChanged: (value) async {
                    setState(() {
                      _filter = value;
                    });

                    if (_advancedOptions.isActive) {
                      await _loadAdvancedFilters();
                    }
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _app.roomsLoading
                            ? null
                            : _openAdvancedFilter,
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: Text(
                          advanced ? 'Filter Aktif' : 'Filter Lanjutan',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    if (advanced) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Reset Filter',
                        onPressed: _resetAdvancedFilters,
                        icon: const Icon(
                          Icons.restart_alt_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),

                if (advanced) ...[
                  const SizedBox(height: 6),
                  Text(
                    _advancedSummary,
                    style: AppTextStyles.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                Row(
                  children: <Widget>[
                    Text('Cari Kamar', style: AppTextStyles.cardHeading),
                    const Spacer(),
                    _SortMenu(
                      value: _sort,
                      onChanged: (value) async {
                        final hadAdvancedSort = _advancedOptions.sort != null;

                        setState(() {
                          _sort = value;

                          _advancedOptions = RoomFilterOptions(
                            building: _advancedOptions.building,
                            minCapacity: _advancedOptions.minCapacity,
                          );
                        });

                        if (hadAdvancedSort) {
                          await _loadAdvancedFilters();
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(error, textAlign: TextAlign.center),
                              TextButton(
                                onPressed: advanced
                                    ? _loadAdvancedFilters
                                    : _refreshRooms,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _refreshRooms,
                          child: rooms.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    const SizedBox(height: 24),
                                    Center(
                                      child: Text(
                                        'Kamar tidak ditemukan',
                                        style: AppTextStyles.body,
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(bottom: 16),
                                  itemCount: rooms.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final room = rooms[index];

                                    return RoomCard(
                                      room: room,
                                      type: RoomCardType.horizontal,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (_) => RoomDetailScreen(
                                              roomId: room.id,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.input,
        decoration: InputDecoration(
          hintText: 'Cari nama kamar, gedung, atau fasilitas...',
          hintStyle: AppTextStyles.hint,
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.hint,
          ),
          filled: true,
          fillColor: AppColors.surface,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onChanged});

  final _RoomFilter selected;
  final ValueChanged<_RoomFilter> onChanged;

  static const List<(String, _RoomFilter)> _items = [
    ('Semua', _RoomFilter.all),
    ('Putra', _RoomFilter.male),
    ('Putri', _RoomFilter.female),
    ('Tersedia', _RoomFilter.available),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < _items.length; i++) ...<Widget>[
          if (i != 0) const SizedBox(width: 8),
          Expanded(
            child: _FilterChip(
              label: _items[i].$1,
              isSelected: _items[i].$2 == selected,
              onTap: () => onChanged(_items[i].$2),
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.chipLabel(selected: isSelected),
        ),
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.value, required this.onChanged});

  final _RoomSort value;
  final ValueChanged<_RoomSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_RoomSort>(
      initialValue: value,
      onSelected: onChanged,
      color: AppColors.surface,
      itemBuilder: (_) => <PopupMenuEntry<_RoomSort>>[
        PopupMenuItem<_RoomSort>(
          value: _RoomSort.name,
          child: Text('Nama A-Z', style: AppTextStyles.input),
        ),
        PopupMenuItem<_RoomSort>(
          value: _RoomSort.availableFirst,
          child: Text('Tersedia', style: AppTextStyles.input),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Urutkan', style: AppTextStyles.body),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
