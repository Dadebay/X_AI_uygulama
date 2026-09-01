import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/main/controllers/main_controller.dart';
import 'package:atlas/modules/home/views/home_screen.dart';
import 'package:atlas/modules/explore/views/explore_screen.dart';
import 'package:atlas/modules/saved/views/saved_screen.dart';
import 'package:atlas/modules/profile/views/profile_screen.dart';
import 'package:atlas/modules/auth/controllers/auth_controller.dart';
import 'package:atlas/widgets/pulse/bottom_banner_ad.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MainController>();
    final c = Tc.of(context);
    return Obx(() => Scaffold(
          backgroundColor: c.bg,
          body: _LazyIndexedStack(
            index: ctrl.currentIndex.value,
            children: _screens,
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomBannerAd(),
              _PulseNavBar(ctrl: ctrl),
            ],
          ),
        ));
  }
}

/// Normal IndexedStack tüm children'ı (görünmeyenler dahil) hemen build eder;
/// bu da her sekmenin controller'ını (ve onInit'teki network isteklerini) uygulama
/// açılır açılmaz tetikler. Bu widget her sekmeyi yalnızca ilk kez seçildiğinde
/// build eder, sonrasında IndexedStack gibi state'ini korur.
class _LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  const _LazyIndexedStack({required this.index, required this.children});

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  late final Set<int> _built = {widget.index};

  @override
  void didUpdateWidget(covariant _LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _built.add(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _built.contains(i) ? widget.children[i] : const SizedBox.shrink(),
      ],
    );
  }
}

class _PulseNavBar extends StatelessWidget {
  final MainController ctrl;
  const _PulseNavBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Obx(() {
      final idx = ctrl.currentIndex.value;
      final isPremium = Get.find<AuthController>().isPremium.value;
      return Container(
        decoration: BoxDecoration(
          color: c.card,
          border: Border(top: BorderSide(color: isPremium ? AppColors.yellow.withValues(alpha: 0.35) : c.divider, width: isPremium ? 1 : 0.5)),
          boxShadow: isPremium
              ? [BoxShadow(color: AppColors.yellow.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, -4))]
              : null,
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(icon: HugeIcons.strokeRoundedHome01, label: 'nav_home'.tr, index: 0, current: idx, onTap: ctrl.changeIndex, isPremium: isPremium),
                _NavItem(icon: HugeIcons.strokeRoundedCompass, label: 'nav_explore'.tr, index: 1, current: idx, onTap: ctrl.changeIndex, isPremium: isPremium),
                _NavItem(icon: HugeIcons.strokeRoundedBookmark01, label: 'nav_saved'.tr, index: 2, current: idx, onTap: ctrl.changeIndex, isPremium: isPremium),
                _NavItem(icon: HugeIcons.strokeRoundedUser, label: 'nav_profile'.tr, index: 3, current: idx, onTap: ctrl.changeIndex, isPremium: isPremium),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;
  final bool isPremium;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    final c = Tc.of(context);
    final accent = isPremium ? AppColors.yellow : AppColors.primary;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? accent : c.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? accent : c.textMuted,
                fontFamily: 'Gilroy',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
