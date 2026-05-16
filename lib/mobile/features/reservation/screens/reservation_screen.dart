import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class ReservationScreen extends StatefulWidget {
  final String roomId;
  const ReservationScreen({super.key, required this.roomId});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  int _duration = 1;
  String _selectedTime = '14:00';

  final List<String> _times = [
    '14:00', '15:00', '16:00',
    '17:00', '18:00', '19:00',
    '20:00', '21:00', '22:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      appBar: AppBar(
        title: const Text('Reserva', style: AppTextStyles.headingM),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBurgundy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seleccionar fecha', style: AppTextStyles.headingM),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (date) {},
              ),
            ),
            const SizedBox(height: 24),
            const Text('Hora de entrada', style: AppTextStyles.headingM),
            const SizedBox(height: 16),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _times.length,
              itemBuilder: (context, index) {
                final time = _times[index];
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBurgundy : AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBurgundy : AppColors.borderLight,
                      ),
                    ),
                    child: Text(
                      time,
                      style: AppTextStyles.labelM.copyWith(
                        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Duración (horas)', style: AppTextStyles.headingM),
                Row(
                  children: [
                    IconButton(
                      onPressed: _duration > 1 ? () => setState(() => _duration--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primaryBurgundy,
                    ),
                    Text('$_duration', style: AppTextStyles.headingM),
                    IconButton(
                      onPressed: () => setState(() => _duration++),
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primaryBurgundy,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Recuerda que puedes cancelar hasta 24h antes del check in sin compromiso',
              style: AppTextStyles.bodyS,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total:', style: AppTextStyles.bodyS),
                Text('1 Habitación · \$${50 * _duration}', style: AppTextStyles.price),
              ],
            ),
            ElevatedButton(
              onPressed: () => context.push('/payment/res_123'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBurgundy,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Text('Continuar con el pago', style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary)),
            )
          ],
        ),
      ),
    );
  }
}
