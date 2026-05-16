import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class RoomDetailScreen extends StatelessWidget {
  final String hotelId;
  final String roomId;
  const RoomDetailScreen({super.key, required this.hotelId, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            iconTheme: const IconThemeData(color: AppColors.primaryBurgundy),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: AppColors.borderLight), 
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Habitación VIP', style: AppTextStyles.headingL),
                  const SizedBox(height: 8),
                  Text('California Suites • 4.8', style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  const Text('Acerca de la habitación', style: AppTextStyles.headingM),
                  const SizedBox(height: 8),
                  const Text(
                    'Habitación amplia, ideal para parejas. Cuenta con cama extra grande, baño privado y vista...',
                    style: AppTextStyles.bodyM,
                  ),
                  const SizedBox(height: 24),
                  const Text('Lo que ofrecemos', style: AppTextStyles.headingM),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildAmenityIcon(Icons.wifi, 'Wifi'),
                      _buildAmenityIcon(Icons.ac_unit, 'AC'),
                      _buildAmenityIcon(Icons.bed, 'King Bed'),
                    ],
                  ),
                  const SizedBox(height: 100), // Space for sticky bottom bar
                ],
              ),
            ),
          )
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Precio', style: AppTextStyles.bodyS),
                Text('\$50 / 3 Horas', style: AppTextStyles.price),
              ],
            ),
            ElevatedButton(
              onPressed: () => context.push('/reservation/$roomId'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBurgundy,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Text(
                'Reservar Ahora',
                style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundPink,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryBurgundyLight),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
