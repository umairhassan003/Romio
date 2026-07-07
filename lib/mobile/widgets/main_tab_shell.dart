import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../features/home/screens/home_screen.dart';
import '../features/my_reservations/screens/my_reservations_screen.dart';
import '../features/profile/screens/profile_screen.dart';

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
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _LiquidGlassNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          _NavSpec(Icons.home_outlined, Icons.home, l10n?.tabHome ?? 'Inicio'),
          _NavSpec(Icons.calendar_today_outlined, Icons.calendar_today, l10n?.tabReservations ?? 'Reserva'),
          _NavSpec(Icons.account_circle_outlined, Icons.account_circle, l10n?.tabProfile ?? 'Perfil'),
        ],
      ),
    );
  }
}

class _NavSpec {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavSpec(this.icon, this.activeIcon, this.label);
}

/// A compact, frosted "liquid glass" pill nav bar. The active tab is a bright
/// white pill that *slides* smoothly to the selected tab (Instagram-style),
/// and the selected icon gives a little pop. No BackdropFilter blur — the
/// Impeller GLES backend crashes on blur during route transitions.
class _LiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavSpec> items;

  const _LiquidGlassNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  static const double _barHeight = 52;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                // More see-through so content behind is faintly visible.
                Colors.white.withValues(alpha: 0.58),
                const Color(0xFFEDE6EB).withValues(alpha: 0.46),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                height: _barHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / items.length;
                    return Stack(
                      children: [
                        // Sliding active-tab pill.
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          left: currentIndex * tabWidth + 4,
                          width: tabWidth - 8,
                          top: 2,
                          bottom: 2,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Tab items.
                        Row(
                          children: List.generate(items.length, (i) {
                            final selected = i == currentIndex;
                            final item = items[i];
                            final color = selected ? AppColors.textPrimary : AppColors.textSecondary;
                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => onTap(i),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedScale(
                                      scale: selected ? 1.12 : 1.0,
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOutBack,
                                      child: Icon(
                                        selected ? item.activeIcon : item.icon,
                                        size: 22,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                        color: color,
                                      ),
                                      child: Text(item.label),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
