import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/app_text_styles.dart';
import '../../models/room.dart';
import '../../widgets/header_scaffold.dart';
import '../../widgets/room_card.dart';
import 'room_detail_screen.dart';

enum _RoomFilter {
  all,
  male,
  female,
  available,
}

enum _RoomSort {
  name,
  availableFirst,
}

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  late final TextEditingController _searchController;
  _RoomFilter _filter = _RoomFilter.all;
  _RoomSort _sort = _RoomSort.name;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _lastQuery = AppState.instance.roomQuery;
    _searchController = TextEditingController(text: _lastQuery);
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Room> get _filteredRooms {
    final query = _searchController.text.trim().toLowerCase();
    var rooms = List<Room>.from(AppState.instance.rooms);

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

    return rooms;
  }

  void _applyFilters() { if (mounted) setState(() {}); }

  void _handleSearch(String value) {
    AppState.instance.roomQuery = value;
    _applyFilters();
  }

  void _syncQueryFromState() {
    final query = AppState.instance.roomQuery;
    if (query == _lastQuery) {
      return;
    }

    _lastQuery = query;
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _applyFilters();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        _syncQueryFromState();

        return HeaderScaffold(
          title: 'Cari Kamar',
          onBack: () => AppState.instance.setTab(0),
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
                  onChanged: (value) {
                    setState(() {
                      _filter = value;
                    });
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Text('Cari Kamar', style: AppTextStyles.cardHeading),
                    const Spacer(),
                    _SortMenu(
                      value: _sort,
                      onChanged: (value) {
                        setState(() {
                          _sort = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: AppState.instance.roomsLoading
                      ? const Center(child: CircularProgressIndicator())
                      : AppState.instance.roomsError != null
                      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(AppState.instance.roomsError!, textAlign: TextAlign.center),
                          TextButton(onPressed: AppState.instance.refreshRooms, child: const Text('Coba Lagi')),
                        ]))
                      : RefreshIndicator(onRefresh: AppState.instance.refreshRooms,
                        child: _filteredRooms.isEmpty
                      ? ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
                    Center(child: Text('Kamar tidak ditemukan', style: AppTextStyles.body)),
                  ])
                      : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _filteredRooms.length,
                    separatorBuilder: (_, _) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final room = _filteredRooms[index];

                      return RoomCard(
                        room: room,
                        type: RoomCardType.horizontal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  RoomDetailScreen(roomId: room.id),
                            ),
                          );
                        },
                      );
                    },
                  )),
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
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

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
  const _FilterRow({
    required this.selected,
    required this.onChanged,
  });

  final _RoomFilter selected;
  final ValueChanged<_RoomFilter> onChanged;

  static const List<(String, _RoomFilter)> _items = <(String, _RoomFilter)>[
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
  const _SortMenu({
    required this.value,
    required this.onChanged,
  });

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
          child: Text('Tersedia ', style: AppTextStyles.input),
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
