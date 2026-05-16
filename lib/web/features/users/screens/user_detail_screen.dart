import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/kpi_card.dart';
import '../providers/user_admin_provider.dart';

class UserDetailScreen extends StatefulWidget {
  final String id;
  const UserDetailScreen({super.key, required this.id});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserAdminProvider>().loadUserById(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserAdminProvider>();
    final user = provider.selectedUser;
    final l = AppLocalizations.of(context)!;

    if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy));
    if (user == null) return Center(child: Text(provider.error ?? l.userNotFound));

    final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/admin/users')),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryBurgundy,
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null ? Text(fullName.isNotEmpty ? fullName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 20)) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fullName.isEmpty ? l.userNoName : fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            Text('ID: ${user.id.substring(0, 8)}...', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ])),
        ]),
        const SizedBox(height: 24),

        LayoutBuilder(builder: (ctx, constraints) {
          return GridView.count(
            crossAxisCount: constraints.maxWidth > 800 ? 3 : 2,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 2.2,
            children: [
              KpiCard(icon: Icons.calendar_today, label: l.userReservations, value: '${provider.userReservationCount}'),
              KpiCard(icon: Icons.attach_money, label: l.userTotalSpend, value: '\$${provider.userTotalSpend.toStringAsFixed(2)}'),
              KpiCard(icon: Icons.person_add, label: l.userRegistered, value: user.createdAt.toString().split(' ')[0]),
            ],
          );
        }),
        const SizedBox(height: 24),

        Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(title: l.userProfileInfo),
          _InfoRow(label: l.userFirstName, value: user.firstName ?? '—'),
          _InfoRow(label: l.userLastName, value: user.lastName ?? '—'),
          _InfoRow(label: l.userDateOfBirth, value: user.dateOfBirth?.toString().split(' ')[0] ?? '—'),
          _InfoRow(label: l.userBillingAddress, value: user.billingAddress ?? '—'),
          _InfoRow(label: l.userPreferredLanguage, value: user.preferredLanguage ?? 'es'),
          _InfoRow(label: l.userUpdated, value: user.updatedAt.toString().split('.')[0]),
        ]))),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 160, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
    ]));
  }
}
