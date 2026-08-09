import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../features/home/screens/home_screen.dart';
import '../features/my_reservations/screens/my_reservations_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'liquid_glass_nav_bar.dart';

/// Main bottom tab navigation shell shared across the 3 primary screens.
/// Persists tab state using IndexedStack.
class MainTabShell extends StatefulWidget {
  const MainTabShell({super.key});

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends State<MainTabShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeScreen(),
    MyReservationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      // Let content flow behind the translucent (liquid-glass) nav bar.
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: LiquidGlassNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          NavSpec(Icons.home_outlined, Icons.home, l10n?.tabHome ?? 'Inicio'),
          NavSpec(
            Icons.calendar_today_outlined,
            Icons.calendar_today,
            l10n?.tabReservations ?? 'Reserva',
          ),
          NavSpec(
            Icons.account_circle_outlined,
            Icons.account_circle,
            l10n?.tabProfile ?? 'Perfil',
          ),
        ],
      ),
    );
  }
}
