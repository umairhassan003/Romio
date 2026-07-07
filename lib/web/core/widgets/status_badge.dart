import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  static const Map<String, Color> _statusColors = {
    'available': AppColors.success,
    'active': AppColors.success,
    'completed': AppColors.success,
    'enabled': AppColors.success,
    'paid': AppColors.success,
    'pending': AppColors.warning,
    'pay_at_property': AppColors.warning,
    'payment_pending': AppColors.warning,
    'maintenance': AppColors.warning,
    'confirmed': AppColors.info,
    'inactive': AppColors.error,
    'disabled': AppColors.textSecondary,
    'cancelled': AppColors.error,
    'failed': AppColors.error,
    'refunded': Color(0xFF9C27B0),
  };

  static String _getLabel(BuildContext context, String status) {
    final l = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'available': return l.adminStatusAvailable;
      case 'active': return l.adminStatusActive;
      case 'completed': return l.adminStatusCompleted;
      case 'enabled': return l.adminEnabled;
      case 'paid': return l.paymentStatusPaid;
      case 'pending': return l.adminStatusPending;
      case 'pay_at_property': return l.paymentStatusPayAtProperty;
      case 'payment_pending': return l.paymentStatusPending;
      case 'maintenance': return l.adminStatusMaintenance;
      case 'confirmed': return l.adminStatusConfirmed;
      case 'inactive': return l.adminStatusInactive;
      case 'disabled': return l.adminDisabled;
      case 'cancelled': return l.adminStatusCancelled;
      case 'failed': return l.adminPaymentFailed;
      case 'refunded': return l.adminPaymentRefunded;
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColors[status.toLowerCase()] ?? AppColors.textSecondary;
    final label = _getLabel(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
