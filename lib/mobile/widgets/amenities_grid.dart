import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// One amenity to display: an icon + a label.
typedef AmenityItem = ({IconData icon, String label});

/// Displays amenities in a 4-column grid. When there are more than 4, only the
/// first row (4) is shown with a "See more" toggle; expanding reveals the full
/// grid, and "See less" collapses it again.
class AmenitiesGrid extends StatefulWidget {
  final List<AmenityItem> items;
  final String moreLabel;
  final String lessLabel;

  const AmenitiesGrid({
    super.key,
    required this.items,
    this.moreLabel = 'Ver más',
    this.lessLabel = 'Ver menos',
  });

  static const int _perRow = 4;

  @override
  State<AmenitiesGrid> createState() => _AmenitiesGridState();
}

class _AmenitiesGridState extends State<AmenitiesGrid> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final total = widget.items.length;
    final hasMore = total > AmenitiesGrid._perRow;
    // Collapsed shows just the first row of 4; expanded shows everything.
    final visible = (!_expanded && hasMore)
        ? widget.items.take(AmenitiesGrid._perRow).toList()
        : widget.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AmenitiesGrid._perRow,
            // Fixed, compact row height (no extra vertical whitespace per cell).
            mainAxisExtent: 82,
            mainAxisSpacing: 8,
            crossAxisSpacing: 4,
          ),
          itemCount: visible.length,
          itemBuilder: (_, i) => _AmenityCell(item: visible[i]),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _expanded ? widget.lessLabel : '${widget.moreLabel} (${total - AmenitiesGrid._perRow})',
                    style: AppTextStyles.labelM.copyWith(color: AppColors.primaryBurgundy),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20,
                    color: AppColors.primaryBurgundy,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AmenityCell extends StatelessWidget {
  final AmenityItem item;
  const _AmenityCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(item.icon, color: AppColors.primaryBurgundyLight, size: 24),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            item.label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
