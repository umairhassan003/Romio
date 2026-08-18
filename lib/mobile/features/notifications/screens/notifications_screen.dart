import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/models/app_notification.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/notifications_provider.dart';

/// Shows the signed-in user's in-app notifications (currently booking
/// confirmations). Text is rendered from each entry's structured data at build
/// time, so the list follows the app's selected language. Opening the screen
/// marks everything as read, clearing the home bell badge.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Make sure the stored notifications for this account are loaded before
      // we mark them read — the screen can be reached without the home screen
      // having loaded them yet.
      final profile = context.read<ProfileProvider>().profile;
      final provider = context.read<NotificationsProvider>();
      if (profile != null) {
        await provider.loadForUser(profile.id);
        if (!mounted) return;
      }
      provider.markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<NotificationsProvider>();
    final items = provider.items;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: back button + title ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryBurgundy,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    l10n?.notificationsTitle ?? 'Notifications',
                    style: AppTextStyles.headingM,
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? _EmptyState(l10n: l10n)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) =>
                              context.read<NotificationsProvider>().remove(
                                    item.id,
                                  ),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                          child: _NotificationCard(
                            notification: item,
                            l10n: l10n,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations? l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                color: AppColors.primaryBurgundyLight,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n?.notificationsEmptyTitle ?? 'No notifications yet',
              textAlign: TextAlign.center,
              style: AppTextStyles.headingS,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.notificationsEmptyBody ??
                  'Your booking confirmations and updates will appear here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final AppLocalizations? l10n;

  const _NotificationCard({required this.notification, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final title = _title(l10n);
    final body = _body(l10n, localeCode);
    final timeLabel = DateFormat.yMMMd(localeCode)
        .add_jm()
        .format(notification.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.read
            ? AppColors.surfaceLight
            : AppColors.primaryBurgundyVeryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: AppTextStyles.labelM),
                    ),
                    if (!notification.read)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8, top: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBurgundy,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _title(AppLocalizations? l10n) {
    switch (notification.type) {
      case AppNotificationType.bookingConfirmed:
        return l10n?.notificationBookingConfirmedTitle ?? 'Booking confirmed';
    }
  }

  String _body(AppLocalizations? l10n, String localeCode) {
    final data = notification.data;
    switch (notification.type) {
      case AppNotificationType.bookingConfirmed:
        final code = data['code'] ?? '';
        final hotel = data['hotel'] ?? data['room'] ?? '';
        final checkIn = data['checkIn'] ?? '';
        final dateIso = data['dateIso'];
        final date = dateIso != null
            ? DateFormat.yMMMMd(localeCode).format(DateTime.parse(dateIso))
            : '';
        return l10n?.notificationBookingConfirmedBody(
              code,
              hotel,
              date,
              checkIn,
            ) ??
            'Your reservation $code at $hotel is confirmed for $date at $checkIn.';
    }
  }
}
