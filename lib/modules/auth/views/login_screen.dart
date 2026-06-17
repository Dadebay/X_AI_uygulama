import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/modules/auth/controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    final ctrl = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo + başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 36),
                  const SizedBox(width: 8),
                  Text(
                    'Pulse',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'saved_login_title'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Gilroy',
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'saved_login_sub'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Gilroy',
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),
              // Özellikler
              _FeatureRow(c: c, icon: Icons.bookmark_rounded, text: 'saved_feature_1'.tr),
              const SizedBox(height: 12),
              _FeatureRow(c: c, icon: Icons.devices_rounded, text: 'saved_feature_2'.tr),
              const SizedBox(height: 12),
              _FeatureRow(c: c, icon: Icons.sync_rounded, text: 'saved_feature_3'.tr),
              const Spacer(flex: 3),
              // Google butonu
              Obx(() => _AuthButton(
                    onTap: ctrl.isLoading.value ? null : ctrl.signInWithGoogle,
                    bgColor: c.card,
                    border: c.divider,
                    isLoading: ctrl.isLoading.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/google_logo.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata_rounded, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'sign_in_google'.tr,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ],
                    ),
                  )),
              if (ctrl.isAppleAvailable) ...[
                const SizedBox(height: 12),
                Obx(() => _AuthButton(
                      onTap: ctrl.isLoading.value ? null : ctrl.signInWithApple,
                      bgColor: c.card,
                      border: c.divider,
                      isLoading: ctrl.isLoading.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.apple_rounded, color: c.textPrimary, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            'sign_in_apple'.tr,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
              const SizedBox(height: 16),
              Obx(() {
                if (ctrl.errorMsg.value.isEmpty) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    ctrl.errorMsg.value,
                    style: const TextStyle(color: AppColors.red, fontSize: 13, fontFamily: 'Gilroy'),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text(
                'login_privacy_note'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: c.textMuted, fontSize: 11, fontFamily: 'Gilroy', height: 1.4),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Color bgColor;
  final Color border;
  final bool isLoading;

  const _AuthButton({
    required this.onTap,
    required this.child,
    required this.bgColor,
    required this.border,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 0.5),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            : child,
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final Tc c;
  final IconData icon;
  final String text;
  const _FeatureRow({required this.c, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.lightPrimary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 14,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
