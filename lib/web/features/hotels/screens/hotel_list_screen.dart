import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/romio_data_table.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../providers/hotel_admin_provider.dart';

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelAdminProvider>().loadHotels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelAdminProvider>();
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Text(
                  l.hotelManagement,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              // Filter buttons
              SegmentedButton<bool?>(
                segments: [
                  ButtonSegment(value: null, label: Text(l.hotelFilterAll)),
                  ButtonSegment(value: true, label: Text(l.hotelFilterActive)),
                  ButtonSegment(value: false, label: Text(l.hotelFilterInactive)),
                ],
                selected: {provider.filterActive},
                onSelectionChanged: (s) => provider.setFilterActive(s.first),
                style: ButtonStyle(visualDensity: VisualDensity.compact),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => context.go('/admin/hotels/new'),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l.adminNewHotel),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (provider.error != null)
            ErrorBanner(
              message: provider.error!,
              onRetry: () => provider.loadHotels(),
            ),

          // Table
          Card(
            child: RomioDataTable(
              columns: [
                DataColumn(label: Text(l.hotelColName)),
                DataColumn(label: Text(l.hotelColCity)),
                DataColumn(label: Text(l.hotelColRooms)),
                DataColumn(label: Text(l.hotelColRating)),
                DataColumn(label: Text(l.hotelColPayOnProperty)),
                DataColumn(label: Text(l.hotelColStatus)),
                DataColumn(label: Text(l.hotelColActions)),
              ],
              rows: provider.hotels.map((hotel) {
                return DataRow(cells: [
                  DataCell(
                    InkWell(
                      onTap: () => context.go('/admin/hotels/${hotel.id}'),
                      child: Text(
                        hotel.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBurgundy,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(hotel.city ?? '—')),
                  DataCell(Text('${hotel.rooms?.length ?? 0}')),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: AppColors.starRating),
                      const SizedBox(width: 4),
                      Text(hotel.rating.toStringAsFixed(1)),
                    ],
                  )),
                  DataCell(StatusBadge(status: hotel.payOnProperty ? 'enabled' : 'disabled')),
                  DataCell(StatusBadge(status: hotel.isActive ? 'active' : 'inactive')),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => context.go('/admin/hotels/${hotel.id}/edit'),
                        tooltip: l.hotelEditTooltip,
                      ),
                      IconButton(
                        icon: Icon(
                          hotel.isActive ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                        ),
                        onPressed: () => provider.toggleActive(hotel.id, !hotel.isActive),
                        tooltip: hotel.isActive ? l.hotelDeactivateTooltip : l.hotelActivateTooltip,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        onPressed: () async {
                          final confirmed = await ConfirmDialog.show(
                            context: context,
                            title: l.hotelDeleteTitle,
                            message: l.hotelDeleteMessage(hotel.name),
                            isDangerous: true,
                            confirmLabel: l.adminDeleteButton,
                          );
                          if (confirmed == true) {
                            provider.deleteHotel(hotel.id);
                          }
                        },
                        tooltip: l.hotelDeleteTooltip,
                      ),
                    ],
                  )),
                ]);
              }).toList(),
              totalCount: provider.totalCount,
              currentPage: provider.currentPage,
              pageSize: provider.pageSize,
              isLoading: provider.isLoading,
              emptyMessage: l.hotelEmptyMessage,
              emptyIcon: Icons.hotel_outlined,
              onPageChanged: (p) => provider.setPage(p),
            ),
          ),
        ],
      ),
    );
  }
}
