import 'package:flutter/material.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:hugeicons/hugeicons.dart';

String _friendlyError(String raw) {
  final r = raw.toLowerCase();
  if (r.contains('socketexception') || r.contains('network') || r.contains('connection')) {
    return 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
  }
  if (r.contains('timeout') || r.contains('timeoutexception')) {
    return 'Sunucuya ulaşmak çok uzun sürdü. Lütfen tekrar deneyin.';
  }
  if (r.contains('401') || r.contains('unauthorized')) {
    return 'Oturum süreniz doldu. Lütfen uygulamayı yeniden başlatın.';
  }
  if (r.contains('403') || r.contains('forbidden')) {
    return 'Bu içeriğe erişim izniniz yok.';
  }
  if (r.contains('429') || r.contains('rate limit') || r.contains('too many')) {
    return 'Çok fazla istek gönderildi. Lütfen bir süre bekleyip tekrar deneyin.';
  }
  if (r.contains('500') || r.contains('502') || r.contains('503') || r.contains('server')) {
    return 'Sunucu şu an yanıt vermiyor. Lütfen daha sonra tekrar deneyin.';
  }
  if (r.contains('dioexception') || r.contains('dioerror')) {
    return 'İçerikler yüklenemedi. Lütfen tekrar deneyin.';
  }
  return 'İçerikler yüklenemedi. Lütfen tekrar deneyin.';
}

class FeedEmptyState extends StatelessWidget {
  final String message;
  const FeedEmptyState({super.key, this.message = 'İçerik bulunamadı'});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(message, style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Gilroy')),
      ),
    );
  }
}

class FeedErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const FeedErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Icon(HugeIcons.strokeRoundedWifiNoSignal, color: c.textMuted, size: 36),
          const SizedBox(height: 12),
          Text('İçerik yüklenemedi', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Gilroy')),
          const SizedBox(height: 6),
          Text(_friendlyError(message), style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Gilroy'), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
              child: const Text('Tekrar Dene', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Gilroy')),
            ),
          ),
        ],
      ),
    );
  }
}

class FeedLoadMore extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const FeedLoadMore({super.key, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.divider, width: 0.5),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : const Text('Daha Fazla Göster', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Gilroy')),
          ),
        ),
      ),
    );
  }
}

const Widget kFeedLoading = Padding(
  padding: EdgeInsets.symmetric(vertical: 40),
  child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
);
