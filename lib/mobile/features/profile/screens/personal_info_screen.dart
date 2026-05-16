import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      appBar: AppBar(
        title: const Text('Información personal', style: AppTextStyles.headingS),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBurgundy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTextField('Nombre inicial'),
            const SizedBox(height: 16),
            _buildTextField('Apellido'),
            const SizedBox(height: 16),
            _buildTextField('Correo electrónico'),
            const SizedBox(height: 16),
            _buildTextField('Número de teléfono'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBurgundy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Guardar cambios',
                  style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        filled: true,
        fillColor: AppColors.backgroundWhite,
      ),
    );
  }
}
