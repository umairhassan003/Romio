import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../domain/models/amenity.dart';
import '../../../core/theme/app_colors.dart';

class AmenityMultiSelect extends StatefulWidget {
  final List<Amenity> availableAmenities;
  final List<Amenity> initialSelectedAmenities;
  final void Function(List<Amenity>) onSelectionChanged;

  final String title;
  final String placeholder;

  const AmenityMultiSelect({
    super.key,
    required this.availableAmenities,
    this.initialSelectedAmenities = const [],
    required this.onSelectionChanged,
    required this.title,
    required this.placeholder,
  });

  @override
  State<AmenityMultiSelect> createState() => _AmenityMultiSelectState();
}

class _AmenityMultiSelectState extends State<AmenityMultiSelect> {
  late List<Amenity> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelectedAmenities);
  }

  Future<void> _showSelectionDialog() async {
    final l = AppLocalizations.of(context)!;
    final List<Amenity> tempSelected = List.from(_selected);

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(widget.title),
              content: SizedBox(
                width: 400,
                child: widget.availableAmenities.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No amenities available.'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.availableAmenities.length,
                        itemBuilder: (ctx, i) {
                          final a = widget.availableAmenities[i];
                          final isSelected = tempSelected.any((s) => s.id == a.id);
                          return CheckboxListTile(
                            title: Text(a.name),
                            value: isSelected,
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  tempSelected.add(a);
                                } else {
                                  tempSelected.removeWhere((s) => s.id == a.id);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l.adminCancelButton),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selected = tempSelected;
                    });
                    widget.onSelectionChanged(_selected);
                    Navigator.pop(ctx);
                  },
                  child: Text(l.adminSaveButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showSelectionDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: _selected.isEmpty
                  ? Text(
                      widget.placeholder,
                      style: TextStyle(color: Colors.grey.shade600),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selected.map((a) => Chip(
                        label: Text(a.name, style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.primaryBurgundy.withValues(alpha: 0.1),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() {
                            _selected.removeWhere((s) => s.id == a.id);
                          });
                          widget.onSelectionChanged(_selected);
                        },
                      )).toList(),
                    ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
