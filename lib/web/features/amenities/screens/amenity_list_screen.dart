import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/amenity.dart';
import '../../../core/widgets/romio_data_table.dart';
import '../../../core/widgets/confirm_dialog.dart';

class AmenityListScreen extends StatefulWidget {
  const AmenityListScreen({super.key});

  @override
  State<AmenityListScreen> createState() => _AmenityListScreenState();
}

class _AmenityListScreenState extends State<AmenityListScreen> {
  List<Amenity> _amenities = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAmenities();
  }

  Future<void> _loadAmenities() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await Supabase.instance.client
          .from('amenities')
          .select()
          .order('name');
      setState(() {
        _amenities = (response as List).map((j) => Amenity.fromJson(j)).toList();
      });
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      setState(() => _error = '${l.amenityLoadError}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showFormDialog({Amenity? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final iconCtrl = TextEditingController(text: existing?.iconKey ?? '');
    String appliesTo = existing?.appliesTo ?? 'hotel';
    final l = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing != null ? l.amenityEditTitle : l.amenityNewTitle),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: l.amenityName)),
            const SizedBox(height: 12),
            TextField(controller: iconCtrl, decoration: InputDecoration(labelText: l.amenityIconKey)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: appliesTo,
              decoration: InputDecoration(labelText: l.amenityAppliesTo),
              items: [
                DropdownMenuItem(value: 'hotel', child: Text(l.amenityHotel)),
                DropdownMenuItem(value: 'room', child: Text(l.amenityRoom)),
                DropdownMenuItem(value: 'both', child: Text(l.amenityBoth)),
              ],
              onChanged: (v) => setDialogState(() => appliesTo = v ?? 'hotel'),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.adminCancelButton)),
            ElevatedButton(
              onPressed: () async {
                final client = Supabase.instance.client;
                final data = {
                  'name': nameCtrl.text.trim(),
                  'icon_key': iconCtrl.text.trim().isEmpty ? null : iconCtrl.text.trim(),
                  'applies_to': appliesTo,
                };
                if (existing != null) {
                  await client.from('amenities').update(data).eq('id', existing.id);
                } else {
                  await client.from('amenities').insert(data);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _loadAmenities();
              },
              child: Text(existing != null ? l.amenityUpdate : l.amenityCreate),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAmenity(Amenity amenity) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l.amenityDeleteTitle,
      message: l.amenityDeleteMessage(amenity.name),
      isDangerous: true,
      confirmLabel: l.adminDeleteButton,
    );
    if (confirmed == true) {
      await Supabase.instance.client.from('amenities').delete().eq('id', amenity.id);
      _loadAmenities();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(l.amenityManagement, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
          ElevatedButton.icon(
            onPressed: () => _showFormDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: Text(l.adminNewAmenity),
          ),
        ]),
        const SizedBox(height: 16),
        Card(
          child: RomioDataTable(
            columns: [
              DataColumn(label: Text(l.amenityColName)),
              DataColumn(label: Text(l.amenityColIconKey)),
              DataColumn(label: Text(l.amenityColAppliesTo)),
              DataColumn(label: Text(l.amenityColActions)),
            ],
            rows: _amenities.map((a) => DataRow(cells: [
              DataCell(Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(a.iconKey ?? '—')),
              DataCell(Chip(label: Text(a.appliesTo, style: const TextStyle(fontSize: 12)), visualDensity: VisualDensity.compact)),
              DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showFormDialog(existing: a)),
                IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error), onPressed: () => _deleteAmenity(a)),
              ])),
            ])).toList(),
            totalCount: _amenities.length,
            isLoading: _isLoading,
            errorMessage: _error,
            onRetry: _loadAmenities,
            emptyMessage: l.amenityEmptyMessage,
            emptyIcon: Icons.wifi_outlined,
          ),
        ),
      ]),
    );
  }
}
