import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/romio_data_table.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../providers/room_admin_provider.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomAdminProvider>().loadRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoomAdminProvider>();
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.roomManagement,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SegmentedButton<String?>(
                segments: [
                  ButtonSegment(value: null, label: Text(l.roomFilterAll)),
                  ButtonSegment(
                    value: 'available',
                    label: Text(l.roomFilterAvailable),
                  ),
                  ButtonSegment(
                    value: 'maintenance',
                    label: Text(l.roomFilterMaintenance),
                  ),
                ],
                selected: {provider.filterStatus},
                onSelectionChanged: (s) => provider.setFilterStatus(s.first),
                style: ButtonStyle(visualDensity: VisualDensity.compact),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => context.go('/admin/rooms/new'),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l.adminNewRoom),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.error != null)
            ErrorBanner(
              message: provider.error!,
              onRetry: () => provider.loadRooms(),
            ),
          Card(
            child: RomioDataTable(
              columns: [
                DataColumn(label: Text(l.roomColName)),
                DataColumn(label: Text(l.roomColHotel)),
                DataColumn(label: Text(l.roomColPrice)),
                DataColumn(label: Text(l.roomColRating)),
                DataColumn(label: Text(l.roomColStatus)),
                DataColumn(label: Text(l.roomColActions)),
              ],
              rows:
                  provider.rooms.map((room) {
                    return DataRow(
                      cells: [
                        DataCell(
                          InkWell(
                            onTap: () => context.go('/admin/rooms/${room.id}'),
                            child: Text(
                              room.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBurgundy,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(room.hotelId.substring(0, 8))),
                        DataCell(
                          Text('\$${room.pricePerHour.toStringAsFixed(2)}'),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.starRating,
                              ),
                              const SizedBox(width: 4),
                              Text(room.rating.toStringAsFixed(1)),
                            ],
                          ),
                        ),
                        DataCell(StatusBadge(status: room.status)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed:
                                    () => context.go(
                                      '/admin/rooms/${room.id}/edit',
                                    ),
                                tooltip: l.roomEditTooltip,
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 18),
                                onSelected:
                                    (status) =>
                                        provider.updateStatus(room.id, status),
                                itemBuilder:
                                    (_) => [
                                      PopupMenuItem(
                                        value: 'available',
                                        child: Text(l.roomStatusAvailable),
                                      ),
                                      PopupMenuItem(
                                        value: 'maintenance',
                                        child: Text(l.roomStatusMaintenance),
                                      ),
                                    ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                onPressed: () async {
                                  final confirmed = await ConfirmDialog.show(
                                    context: context,
                                    title: l.roomDeleteTitle,
                                    message: l.roomDeleteMessage,
                                    isDangerous: true,
                                    confirmLabel: l.adminDeleteButton,
                                  );
                                  if (confirmed == true)
                                    provider.deleteRoom(room.id);
                                },
                                tooltip: l.adminDeleteButton,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
              totalCount: provider.totalCount,
              currentPage: provider.currentPage,
              pageSize: provider.pageSize,
              isLoading: provider.isLoading,
              emptyMessage: l.roomEmptyMessage,
              emptyIcon: Icons.bed_outlined,
              onPageChanged: (p) => provider.setPage(p),
            ),
          ),
        ],
      ),
    );
  }
}
