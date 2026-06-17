import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Nav {
  /// Push a new screen while keeping the bottom nav bar visible.
  /// Optionally provide a GetX [binding] whose [dependencies()] will be called
  /// before navigating (replaces the `binding:` param from Get.to).
  static Future<T?> push<T>(
    BuildContext context,
    Widget Function() page, {
    Bindings? binding,
  }) {
    binding?.dependencies();
    return PersistentNavBarNavigator.pushNewScreen<T>(
      context,
      screen: page(),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}
