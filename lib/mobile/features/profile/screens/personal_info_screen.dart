import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../widgets/success_sheet.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});
  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _emailBannerVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAndFill());
  }

  /// Fetches the profile from the DB (if not already cached) and fills the
  /// fields with the current values.
  Future<void> _loadAndFill() async {
    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();
    if (profileProvider.profile == null) {
      final userId = authProvider.user?.id;
      if (userId != null) {
        await profileProvider.loadProfile(userId);
      }
    }
    if (!mounted) return;

    final profile = profileProvider.profile;
    // Values entered at signup are stored in the auth user metadata; use them
    // as a fallback when the profiles row doesn't have them yet.
    final meta = authProvider.user?.userMetadata ?? const <String, dynamic>{};
    String pick(String? fromProfile, String metaKey) {
      if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
      final value = meta[metaKey];
      return value is String ? value : '';
    }

    _firstNameController.text = pick(profile?.firstName, 'first_name');
    _lastNameController.text = pick(profile?.lastName, 'last_name');
    _cityController.text = pick(profile?.city, 'city');
    _phoneController.text = pick(profile?.phone, 'phone');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<ProfileProvider>();
    final ok = await provider.updatePersonalInfo(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      city: _cityController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      _showSavedConfirmation(l10n);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.genericError ?? 'Ha ocurrido un error. Inténtalo de nuevo.',
          ),
        ),
      );
    }
  }

  Future<void> _showSavedConfirmation(AppLocalizations? l10n) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SuccessSheet(
        title: l10n?.personalInfoSaved ?? 'Cambios guardados',
        badgeTitle: l10n?.profileSavedBadgeTitle ?? 'Perfil actualizado',
        badgeBody: l10n?.profileSavedBadgeBody ??
            'Los datos se han guardado correctamente',
      ),
    );
    // Return to the profile menu once the confirmation is dismissed.
    if (mounted) Navigator.of(context).pop();
  }

  void _confirmDeleteAccount(AppLocalizations? l10n) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    l10n?.deleteAccountConfirmTitle ??
                        '¿Estás seguro que quieres eliminar la cuenta?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingS,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 110,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _deleteAccount(l10n);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBurgundy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n?.confirmSI ?? 'SI',
                            style: AppTextStyles.labelM.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 110,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBurgundy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n?.confirmNO ?? 'NO',
                            style: AppTextStyles.labelM.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Permanently deletes the account from the database, then signs out and
  /// routes back to login. Shows a blocking loader while it runs.
  Future<void> _deleteAccount(AppLocalizations? l10n) async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();

    // Blocking loading indicator.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBurgundy),
          ),
    );

    final ok = await profileProvider.deleteAccount();

    if (!mounted) return;
    // Dismiss the loader.
    Navigator.of(context, rootNavigator: true).pop();

    if (ok) {
      // Clear the (now invalid) local session and go to login.
      try {
        await authProvider.signOut();
      } catch (_) {
        /* session already invalid after deletion */
      }
      router.go('/login');
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.genericError ?? 'Ha ocurrido un error. Inténtalo de nuevo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ProfileProvider>();
    final email = context.read<AuthProvider>().user?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom header row
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
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
                  GestureDetector(
                    onTap: provider.isLoading ? null : _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child:
                          provider.isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryBurgundy,
                                ),
                              )
                              : Text(
                                l10n?.personalInfoSaveBtn ?? 'Guardar',
                                style: AppTextStyles.labelM,
                              ),
                    ),
                  ),
                ],
              ),
            ),

            // Page title
            const SizedBox(height: 16),
            Center(
              child: Text(
                l10n?.personalInfoTitle ?? 'Datos personales',
                style: AppTextStyles.headingXL.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email banner
                    if (_emailBannerVisible && email.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDECEC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF3B7B7)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8605A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.priority_high,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n?.personalInfoEmail ?? 'Email',
                                    style: AppTextStyles.labelM.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: AppTextStyles.bodyM.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  () => setState(
                                    () => _emailBannerVisible = false,
                                  ),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Fields card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _inlineField(
                            label: l10n?.personalInfoFirstName ?? 'Nombres',
                            controller: _firstNameController,
                          ),
                          _inlineField(
                            label: l10n?.personalInfoLastName ?? 'Apellidos',
                            controller: _lastNameController,
                          ),
                          _inlineField(
                            label: l10n?.personalInfoCity ?? 'Ciudad',
                            controller: _cityController,
                          ),
                          _inlineField(
                            label: l10n?.personalInfoPhone ?? 'Teléfono',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Fixed footer: full-width white bar, delete text centred at the bottom.
      bottomNavigationBar: GestureDetector(
        onTap: () => _confirmDeleteAccount(l10n),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: 90,
          color: AppColors.backgroundWhite,
          child: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  l10n?.personalInfoDeleteAccount ?? 'Eliminar cuenta',
                  style: AppTextStyles.labelM.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inlineField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyL.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.only(top: 6, bottom: 8),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE5E5E5)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE5E5E5)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryBurgundy),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
