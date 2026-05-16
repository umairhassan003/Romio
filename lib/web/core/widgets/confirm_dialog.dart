import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class ConfirmDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDangerous = false,
    Future<void> Function()? onConfirm,
  }) async {
    final l = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel ?? l.adminCancelButton),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? AppColors.error : AppColors.primaryBurgundy,
            ),
            onPressed: () async {
              if (onConfirm != null) await onConfirm();
              if (ctx.mounted) Navigator.of(ctx).pop(true);
            },
            child: Text(confirmLabel ?? l.confirmButton),
          ),
        ],
      ),
    );
  }
}
