import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/romio_data_table.dart';
import '../../../core/widgets/error_banner.dart';
import '../providers/user_admin_provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserAdminProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserAdminProvider>();
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(l.userManagement, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
          SizedBox(
            width: 280,
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l.userSearchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () { _searchCtrl.clear(); provider.search(''); }) : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (q) => provider.search(q),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        if (provider.error != null)
          ErrorBanner(message: provider.error!, onRetry: () => provider.loadUsers()),
        Card(
          child: RomioDataTable(
            columns: [
              DataColumn(label: Text(l.userColName)),
              DataColumn(label: Text(l.userColLanguage)),
              DataColumn(label: Text(l.userColRegistered)),
              DataColumn(label: Text(l.userColActions)),
            ],
            rows: provider.users.map((user) => DataRow(cells: [
              DataCell(InkWell(
                onTap: () => context.go('/admin/users/${user.id}'),
                child: Text(
                  '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().isEmpty ? l.userNoName : '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryBurgundy, decoration: TextDecoration.underline),
                ),
              )),
              DataCell(Text(user.preferredLanguage ?? 'es')),
              DataCell(Text(user.createdAt.toString().split(' ')[0])),
              DataCell(IconButton(
                icon: const Icon(Icons.visibility, size: 18),
                onPressed: () => context.go('/admin/users/${user.id}'),
                tooltip: l.userViewProfile,
              )),
            ])).toList(),
            totalCount: provider.totalCount,
            currentPage: provider.currentPage,
            pageSize: provider.pageSize,
            isLoading: provider.isLoading,
            emptyMessage: l.userEmptyMessage,
            emptyIcon: Icons.people_outlined,
            onPageChanged: (p) => provider.setPage(p),
          ),
        ),
      ]),
    );
  }
}
