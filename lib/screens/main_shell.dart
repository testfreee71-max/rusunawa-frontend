import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../widgets/bottom_nav.dart';
import 'booking/booking_list_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'rooms/room_list_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        return PopScope(
          canPop: AppState.instance.tabIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && AppState.instance.tabIndex != 0) {
              AppState.instance.setTab(0);
            }
          },
          child: Scaffold(
            body: IndexedStack(
              index: AppState.instance.tabIndex,
              children: const <Widget>[
                HomeScreen(),
                RoomListScreen(),
                BookingListScreen(),
                ProfileScreen(),
              ],
            ),
            // BottomNav menangani area gesture sistem sendiri.
            bottomNavigationBar: const BottomNav(),
          ),
        );
      },
    );
  }
}