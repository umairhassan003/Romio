import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<ProfileProvider>().loadProfile(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    final initial = profile?.firstName?.isNotEmpty == true ? profile!.firstName![0].toUpperCase() : 'U';
    final name = profile?.firstName != null ? '${profile!.firstName} ${profile.lastName ?? ''}' : 'Usuario';

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      appBar: AppBar(
        title: const Text('Perfil', style: AppTextStyles.headingM),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: authProvider.isLoading || profileProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primaryBurgundy,
                backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
                child: profile?.avatarUrl == null ? Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24)) : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.trim(), style: AppTextStyles.headingM),
                  const SizedBox(height: 4),
                  Text(authProvider.user?.email ?? 'Gestiona tu cuenta', style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
                ],
              )
            ],
          ),
          const SizedBox(height: 32),
          const Text('Cuenta', style: AppTextStyles.headingS),
          const SizedBox(height: 8),
          _buildListTile(context, Icons.person_outline, 'Información personal', '/profile/personal-info'),
          _buildListTile(context, Icons.payment_outlined, 'Método de pago', '/profile/payment-method'),
          _buildListTile(context, Icons.language_outlined, 'Idioma', '/profile/language'),
          const SizedBox(height: 32),
          const Text('Soporte', style: AppTextStyles.headingS),
          const SizedBox(height: 8),
          _buildListTile(context, Icons.help_outline, 'Contacto', null),
          _buildListTile(context, Icons.question_answer_outlined, 'FAQ', null),
          _buildListTile(context, Icons.description_outlined, 'Términos y Condiciones', null),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text('Cerrar Sesión', style: AppTextStyles.labelM.copyWith(color: AppColors.error)),
            onTap: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, String? route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBurgundy),
      title: Text(title, style: AppTextStyles.labelM),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      contentPadding: EdgeInsets.zero,
      onTap: route != null ? () => context.push(route) : null,
    );
  }
}
