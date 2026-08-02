import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/modules/admin/controllers/web_admin_controller.dart';
import 'package:atlas/modules/admin/views/web/admin_web_shell.dart';

class AdminWebApp extends StatefulWidget {
  const AdminWebApp({super.key});

  @override
  State<AdminWebApp> createState() => _AdminWebAppState();
}

class _AdminWebAppState extends State<AdminWebApp> {
  late WebAdminController _ctrl;
  final _pinCtrl = TextEditingController();
  bool _isChecking = false;
  bool _wrongPin = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(WebAdminController());
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isChecking) return;
    setState(() { _isChecking = true; _wrongPin = false; });
    final ok = await _ctrl.verifyPin(_pinCtrl.text.trim());
    if (!mounted) return;
    if (!ok) {
      _pinCtrl.clear();
      setState(() { _isChecking = false; _wrongPin = true; });
    } else {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_ctrl.isPinVerified.value) return const AdminWebShell();
      return _LoginPage(
        pinCtrl: _pinCtrl,
        isChecking: _isChecking,
        wrongPin: _wrongPin,
        onSubmit: _submit,
      );
    });
  }
}

class _LoginPage extends StatelessWidget {
  final TextEditingController pinCtrl;
  final bool isChecking;
  final bool wrongPin;
  final VoidCallback onSubmit;

  const _LoginPage({
    required this.pinCtrl,
    required this.isChecking,
    required this.wrongPin,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 40,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 30),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pulse Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Gilroy',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Admin panelinize giriş yapın',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 13,
                  fontFamily: 'Gilroy',
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 8,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Gilroy',
                  fontSize: 22,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '• • • •',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    letterSpacing: 8,
                    fontSize: 18,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF111111),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: wrongPin ? AppColors.red : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: wrongPin ? AppColors.red : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: wrongPin ? AppColors.red : AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (_) => onSubmit(),
              ),
              if (wrongPin) ...[
                const SizedBox(height: 8),
                const Text(
                  'Yanlış PIN. Tekrar deneyin.',
                  style: TextStyle(color: AppColors.red, fontSize: 12, fontFamily: 'Gilroy'),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isChecking ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Giriş Yap',
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
