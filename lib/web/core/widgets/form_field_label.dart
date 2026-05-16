import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FormFieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const FormFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          if (isRequired)
            const Text(' *', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
