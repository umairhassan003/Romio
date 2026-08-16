import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Shared calendar used across the app (booking date selection, date of birth, …).
///
/// Monday-first grid with rounded day cells, burgundy selection and a tappable
/// month/year header that switches to a year picker for fast navigation.
///
/// Fully controlled: pass [selectedDate] and receive taps via [onDateSelected].
/// Selectable range is bounded by [firstDate] and [lastDate] (inclusive).
class AppCalendar extends StatefulWidget {
  const AppCalendar({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    this.selectedDate,
    this.initialMonth,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  /// Month shown on first render. Defaults to [selectedDate] or [lastDate].
  final DateTime? initialMonth;

  static const List<String> _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];
  static const List<String> _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late DateTime _visibleMonth;
  bool _yearSelection = false;

  @override
  void initState() {
    super.initState();
    final base = widget.initialMonth ?? widget.selectedDate ?? widget.lastDate;
    _visibleMonth = _clampMonth(DateTime(base.year, base.month));
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static int _monthIndex(DateTime d) => d.year * 12 + (d.month - 1);
  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _clampMonth(DateTime month) {
    final min = DateTime(widget.firstDate.year, widget.firstDate.month);
    final max = DateTime(widget.lastDate.year, widget.lastDate.month);
    if (month.isBefore(min)) return min;
    if (month.isAfter(max)) return max;
    return month;
  }

  bool get _canGoPrev =>
      _monthIndex(_visibleMonth) > _monthIndex(widget.firstDate);
  bool get _canGoNext =>
      _monthIndex(_visibleMonth) < _monthIndex(widget.lastDate);

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth =
          _clampMonth(DateTime(_visibleMonth.year, _visibleMonth.month + delta));
    });
  }

  bool _isSelectable(DateTime day) {
    if (day.month != _visibleMonth.month || day.year != _visibleMonth.year) {
      return false;
    }
    final d = _dateOnly(day);
    return !d.isBefore(_dateOnly(widget.firstDate)) &&
        !d.isAfter(_dateOnly(widget.lastDate));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderField),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          if (_yearSelection) _buildYearGrid() else _buildMonthGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _navButton(Icons.chevron_left, _canGoPrev ? () => _changeMonth(-1) : null),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _yearSelection = !_yearSelection),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${AppCalendar._months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                  style: AppTextStyles.headingM.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(width: 4),
                Icon(
                  _yearSelection ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
        _navButton(Icons.chevron_right, _canGoNext ? () => _changeMonth(1) : null),
      ],
    );
  }

  Widget _navButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          icon,
          size: 24,
          color: onTap == null ? AppColors.textTertiary : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMonthGrid() {
    final monthStart = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final leading = monthStart.weekday - DateTime.monday; // Monday = 0 leading
    final days = List.generate(
      42,
      (i) => DateTime(_visibleMonth.year, _visibleMonth.month, 1 - leading + i),
    );

    return Column(
      children: [
        Row(
          children: [
            for (final w in AppCalendar._weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: AppTextStyles.labelM.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemBuilder: (_, i) => _dayCell(days[i]),
        ),
      ],
    );
  }

  Widget _dayCell(DateTime day) {
    final selectable = _isSelectable(day);
    final selected = widget.selectedDate != null &&
        _sameDay(day, widget.selectedDate!);

    final Color bg;
    final Color fg;
    if (selected) {
      bg = AppColors.primaryBurgundy;
      fg = AppColors.textOnPrimary;
    } else if (selectable) {
      bg = const Color(0xFFF2F2F2);
      fg = AppColors.textPrimary;
    } else {
      bg = const Color(0xFFF7F7F7);
      fg = AppColors.textTertiary;
    }

    return GestureDetector(
      onTap: selectable ? () => widget.onDateSelected(_dateOnly(day)) : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${day.day}',
          style: AppTextStyles.bodyM.copyWith(
            color: fg,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildYearGrid() {
    final years = [
      for (int y = widget.firstDate.year; y <= widget.lastDate.year; y++) y,
    ];
    return SizedBox(
      height: 280,
      child: GridView.builder(
        itemCount: years.length,
        // Show most recent years first — handy for date of birth.
        reverse: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.2,
        ),
        itemBuilder: (_, i) {
          final year = years[i];
          final selected = year == _visibleMonth.year;
          return GestureDetector(
            onTap: () {
              setState(() {
                _visibleMonth = _clampMonth(DateTime(year, _visibleMonth.month));
                _yearSelection = false;
              });
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryBurgundy : const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$year',
                style: AppTextStyles.labelM.copyWith(
                  color: selected ? AppColors.textOnPrimary : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Shows [AppCalendar] as a modal bottom sheet that slides up from the bottom
/// and resolves with the picked date (or `null` if dismissed). Selecting a day
/// closes the sheet immediately.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderField,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            AppCalendar(
              firstDate: firstDate,
              lastDate: lastDate,
              selectedDate: initialDate,
              initialMonth: initialDate ?? lastDate,
              onDateSelected: (date) => Navigator.of(ctx).pop(date),
            ),
          ],
        ),
      ),
    ),
  );
}
