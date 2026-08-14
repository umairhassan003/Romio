import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../features/home/screens/home_screen.dart';
import '../features/my_reservations/screens/my_reservations_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'liquid_glass_nav_bar.dart';

/// Allows any descendant to switch the main tab without navigation.
class TabSwitcher extends InheritedWidget {
  final ValueNotifier<int> notifier;

  const TabSwitcher({
    super.key,
    required this.notifier,
    required super.child,
  });

  /// Switch to [index] from any descendant context.
  static void switchTo(BuildContext context, int index) {
    context
        .getInheritedWidgetOfExactType<TabSwitcher>()
        ?.notifier
        .value = index;
  }

  @override
  bool updateShouldNotify(TabSwitcher old) => false;
}

class MainTabShell extends StatefulWidget {
  const MainTabShell({super.key});

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends State<MainTabShell> {
  final _tabNotifier = ValueNotifier<int>(0);

  static const List<Widget> _tabs = [
    HomeScreen(),
    MyReservationsScreen(),
    ProfileScreen(),
  ];

  @override
  void dispose() {
    _tabNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TabSwitcher(
      notifier: _tabNotifier,
      child: ValueListenableBuilder<int>(
        valueListenable: _tabNotifier,
        builder: (context, currentIndex, _) {
          return Scaffold(
            body: Stack(
              children: [
                IndexedStack(index: currentIndex, children: _tabs),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: LiquidGlassNavBar(
                    currentIndex: currentIndex,
                    onTap: (index) => _tabNotifier.value = index,
                    items: [
                      NavSpec(
                        Icons.home_outlined,
                        Icons.home,
                        l10n?.tabHome ?? 'Inicio',
                      ),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
