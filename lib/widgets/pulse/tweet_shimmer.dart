import 'package:flutter/material.dart';
import 'package:atlas/themes/tc.dart';

/// Tweet kartlarının yüklenmesi sırasında gösterilen iskelet (shimmer) listesi.
/// Kategori değişimlerinde kullanıcıya net bir "yükleniyor" geri bildirimi verir.
class TweetShimmerList extends StatelessWidget {
  final int count;
  const TweetShimmerList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const _TweetShimmerCard()),
    );
  }
}

class _TweetShimmerCard extends StatefulWidget {
  const _TweetShimmerCard();

  @override
  State<_TweetShimmerCard> createState() => _TweetShimmerCardState();
}

class _TweetShimmerCardState extends State<_TweetShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [c.surface, c.surfaceElevated, c.surface],
              stops: const [0.3, 0.5, 0.7],
              transform: _SlidingGradient(_ctrl.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + isim/handle
            Row(
              children: [
                _bone(40, 40, radius: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bone(120, 12),
                    const SizedBox(height: 6),
                    _bone(80, 10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // İçerik satırları
            _bone(double.infinity, 11),
            const SizedBox(height: 8),
            _bone(double.infinity, 11),
            const SizedBox(height: 8),
            _bone(200, 11),
            const SizedBox(height: 12),
            // Medya bloğu
            _bone(double.infinity, 160, radius: 14),
            const SizedBox(height: 12),
            // Alt aksiyon çubuğu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bone(40, 12),
                _bone(40, 12),
                _bone(40, 12),
                _bone(60, 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bone(double w, double h, {double radius = 6}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Gradient'i her karede yatay kaydırarak parlama efektini oluşturur.
class _SlidingGradient extends GradientTransform {
  final double progress;
  const _SlidingGradient(this.progress);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // -1 → 1 aralığında soldan sağa süpürme
    final dx = bounds.width * (progress * 2 - 1);
    return Matrix4.translationValues(dx, 0, 0);
  }
}
