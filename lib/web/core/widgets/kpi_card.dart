import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? deltaLabel;
  final bool? deltaPositive;
  final bool isLoading;

  const KpiCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.deltaLabel,
    this.deltaPositive,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (isLoading) {
            return const SizedBox(
              height: 80,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryBurgundy,
                ),
              ),
            );
          }

          // Adaptive sizes based on available height
          final availableHeight = constraints.maxHeight;
          final compact = availableHeight < 130;
          final iconSize = compact ? 32.0 : 40.0;
          final valueFontSize = compact ? 22.0 : 28.0;
          final labelFontSize = compact ? 11.0 : 13.0;
          final padding = compact ? 8.0 : 10.0;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBurgundy,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: Colors.white, size: iconSize * 0.5),
                    ),
                    const Spacer(),
                    if (deltaLabel != null)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                deltaPositive == true
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            deltaLabel!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color:
                                  deltaPositive == true
                                      ? AppColors.success
                                      : AppColors.error,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
