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
          body: IndexedStack(
            index: ctrl.currentIndex.value,
            children: _screens,
          ),
          bottomNavigationBar: _PulseNavBar(ctrl: ctrl),
        ));
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
      return Container(
        decoration: BoxDecoration(
          color: c.card,
          border: Border(top: BorderSide(color: c.divider, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(icon: HugeIcons.strokeRoundedHome01, label: 'nav_home'.tr, index: 0, current: idx, onTap: ctrl.changeIndex),
                _NavItem(icon: HugeIcons.strokeRoundedCompass, label: 'nav_explore'.tr, index: 1, current: idx, onTap: ctrl.changeIndex),
                _NavItem(icon: HugeIcons.strokeRoundedBookmark01, label: 'nav_saved'.tr, index: 2, current: idx, onTap: ctrl.changeIndex),
                _NavItem(icon: HugeIcons.strokeRoundedUser, label: 'nav_profile'.tr, index: 3, current: idx, onTap: ctrl.changeIndex),
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

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    final c = Tc.of(context);
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
                color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? AppColors.primary : c.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppColors.primary : c.textMuted,
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
