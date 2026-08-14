import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NavSpec {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavSpec(this.icon, this.activeIcon, this.label);
}

/// Pill-shaped bottom nav bar with an oval highlight on the active tab.
/// Intended to be placed inside a [Positioned] at the bottom of a [Stack]
/// so that Scaffold layout mechanics do not interfere with positioning.
class LiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavSpec> items;

  const LiquidGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // viewPadding.bottom = physical system inset (gesture bar / nav buttons).
    // Adding it to the outer bottom padding places the pill above the system bar.
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(217, 217, 217, 0.5),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final item = items[i];
              final iconColor = AppColors.primaryBurgundy;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            selected
                                ? const Color.fromRGBO(217, 217, 217, 0.8)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            scale: selected ? 1.12 : 1.0,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutBack,
                            child: Icon(
                              selected ? item.activeIcon : item.icon,
                              size: 24,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w400,
                              color: iconColor,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
