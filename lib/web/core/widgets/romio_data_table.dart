import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class RomioDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? errorMessage;
  final String? emptyMessage;
  final IconData emptyIcon;
  final VoidCallback? onRetry;
  final ValueChanged<int>? onPageChanged;
  final void Function(int columnIndex, bool ascending)? onSort;
  final int? sortColumnIndex;
  final bool sortAscending;

  const RomioDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.totalCount = 0,
    this.currentPage = 0,
    this.pageSize = 25,
    this.isLoading = false,
    this.errorMessage,
    this.emptyMessage,
    this.emptyIcon = Icons.search_off,
    this.onRetry,
    this.onPageChanged,
    this.onSort,
    this.sortColumnIndex,
    this.sortAscending = true,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (isLoading && rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(color: AppColors.primaryBurgundy),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(errorMessage!, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l.adminRetry),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(emptyIcon, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(emptyMessage ?? l.defaultEmptyMessage, style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    final totalPages = (totalCount / pageSize).ceil();
    final startRow = currentPage * pageSize + 1;
    final endRow = (startRow + rows.length - 1).clamp(0, totalCount);

    return Column(
      children: [
        if (isLoading) const LinearProgressIndicator(color: AppColors.primaryBurgundy),
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: columns,
              rows: rows,
              sortColumnIndex: sortColumnIndex,
              sortAscending: sortAscending,
              headingRowHeight: 48,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 56,
              columnSpacing: 24,
              horizontalMargin: 16,
              showCheckboxColumn: false,
            ),
          ),
        ),
        // Pagination
        if (totalCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$startRow–$endRow ${l.paginationOf} $totalCount',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: currentPage > 0 ? () => onPageChanged?.call(currentPage - 1) : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: currentPage < totalPages - 1 ? () => onPageChanged?.call(currentPage + 1) : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
