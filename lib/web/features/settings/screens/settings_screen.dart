import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/admin_user.dart';
import '../../../core/widgets/romio_data_table.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/error_banner.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<AdminUser> _admins = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await Supabase.instance.client
          .from('admin_users')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _admins = (response as List).map((j) => AdminUser.fromJson(j)).toList();
      });
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      setState(() => _error = '${l.settingsAdminLoadError}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showInviteDialog() async {
    final emailCtrl = TextEditingController();
    String role = 'hotel_manager';
    final l = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l.settingsInviteTitle),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: l.settingsInviteEmail)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: role,
              decoration: InputDecoration(labelText: l.settingsInviteRole),
              items: [
                DropdownMenuItem(value: 'hotel_manager', child: Text(l.adminRoleHotelManager)),
                DropdownMenuItem(value: 'super_admin', child: Text(l.adminRoleSuperAdmin)),
              ],
              onChanged: (v) => setDialogState(() => role = v ?? 'hotel_manager'),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.adminCancelButton)),
            ElevatedButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.settingsInviteNote)),
                );
                Navigator.pop(ctx);
              },
              child: Text(l.settingsInviteButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAdminActive(AdminUser admin) async {
    try {
      await Supabase.instance.client
          .from('admin_users')
          .update({'is_active': !admin.isActive})
          .eq('id', admin.id);
      _loadAdmins();
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      setState(() => _error = '${l.settingsUpdateError}: $e');
    }
  }

  Future<void> _deleteAdmin(AdminUser admin) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l.settingsDeleteTitle,
      message: l.settingsDeleteMessage,
      isDangerous: true,
      confirmLabel: l.adminDeleteButton,
    );
    if (confirmed == true) {
      await Supabase.instance.client.from('admin_users').delete().eq('id', admin.id);
      _loadAdmins();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.settingsTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(l.settingsSubtitle, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        if (_error != null) ErrorBanner(message: _error!, onRetry: _loadAdmins),

        Row(children: [
          Expanded(child: SectionHeader(title: l.settingsAdmins)),
          ElevatedButton.icon(
            onPressed: _showInviteDialog,
            icon: const Icon(Icons.person_add, size: 18),
            label: Text(l.settingsInviteAdmin),
          ),
        ]),
        const SizedBox(height: 8),

        Card(
          child: RomioDataTable(
            columns: [
              DataColumn(label: Text(l.settingsColId)),
              DataColumn(label: Text(l.settingsColUserId)),
              DataColumn(label: Text(l.settingsColRole)),
              DataColumn(label: Text(l.settingsColStatus)),
              DataColumn(label: Text(l.settingsColCreated)),
              DataColumn(label: Text(l.settingsColActions)),
            ],
            rows: _admins.map((admin) => DataRow(cells: [
              DataCell(Text(admin.id.substring(0, 8), style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(admin.userId.substring(0, 8))),
              DataCell(Chip(
                label: Text(admin.role == 'super_admin' ? l.adminRoleSuperAdmin : l.adminRoleHotelManager, style: const TextStyle(fontSize: 12)),
                visualDensity: VisualDensity.compact,
                backgroundColor: admin.role == 'super_admin' ? AppColors.primaryBurgundy.withValues(alpha: 0.1) : AppColors.surfaceLight,
              )),
              DataCell(StatusBadge(status: admin.isActive ? 'active' : 'inactive')),
              DataCell(Text(admin.createdAt.toString().split(' ')[0])),
              DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  icon: Icon(admin.isActive ? Icons.block : Icons.check_circle_outline, size: 18),
                  onPressed: () => _toggleAdminActive(admin),
                  tooltip: admin.isActive ? l.settingsDeactivateTooltip : l.settingsActivateTooltip,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  onPressed: () => _deleteAdmin(admin),
                  tooltip: l.settingsDeleteTooltip,
                ),
              ])),
            ])).toList(),
            totalCount: _admins.length,
            isLoading: _isLoading,
            emptyMessage: l.settingsEmptyMessage,
            emptyIcon: Icons.admin_panel_settings_outlined,
          ),
        ),
      ]),
    );
  }
}
