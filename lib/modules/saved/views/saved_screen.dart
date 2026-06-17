import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/modules/auth/controllers/auth_controller.dart';
import 'package:atlas/modules/auth/views/login_screen.dart';
import 'package:atlas/modules/saved/controllers/saved_controller.dart';
import 'package:atlas/widgets/pulse/tweet_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    final auth = Get.find<AuthController>();
    return Obx(() {
      if (!auth.isLoggedIn) return _LoginPrompt(c: c);
      return _SavedList(c: c, auth: auth);
    });
  }
}

class _LoginPrompt extends StatelessWidget {
  final Tc c;
  const _LoginPrompt({required this.c});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'saved_title'.tr,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Lottie.asset(
                'assets/lottie/fav_home.json',
                width: 180,
                height: 180,
                repeat: true,
              ),
              const SizedBox(height: 20),
              Text(
                'saved_login_cta_title'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Gilroy',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'saved_login_cta_sub'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Gilroy',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Get.to(() => const LoginScreen(), transition: Transition.cupertino),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'sign_in'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedList extends StatelessWidget {
  final Tc c;
  final AuthController auth;
  const _SavedList({required this.c, required this.auth});

  @override
  Widget build(BuildContext context) {
    final saved = Get.find<SavedController>();
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'saved_title'.tr,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ),
                  // Kullanıcı avatarı + çıkış
                  GestureDetector(
                    onTap: () => _showSignOutDialog(context, c, auth),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: c.surfaceElevated,
                      backgroundImage: auth.photoUrl.isNotEmpty
                          ? NetworkImage(auth.photoUrl)
                          : null,
                      child: auth.photoUrl.isEmpty
                          ? Text(
                              auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (saved.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                  );
                }
                if (saved.savedTweets.isEmpty) {
                  return _EmptyState(c: c);
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: saved.savedTweets.length,
                  itemBuilder: (context, i) {
                    final t = saved.savedTweets[i];
                    return TweetCard(
                      username: t.username,
                      handle: t.handle,
                      avatarUrl: t.avatarUrl,
                      content: t.content,
                      timeAgo: t.timeAgo,
                      replies: t.replies,
                      retweets: t.retweets,
                      likes: t.likes,
                      tweetUrl: t.tweetUrl,
                      isVerified: t.isVerified,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, Tc c, AuthController auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          auth.displayName.isNotEmpty ? auth.displayName : auth.email,
          style: TextStyle(color: c.textPrimary, fontFamily: 'Gilroy', fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'sign_out_confirm'.tr,
          style: TextStyle(color: c.textSecondary, fontFamily: 'Gilroy', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: const TextStyle(color: AppColors.primary, fontFamily: 'Gilroy')),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              auth.signOut();
            },
            child: Text('sign_out'.tr, style: const TextStyle(color: AppColors.red, fontFamily: 'Gilroy')),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Tc c;
  const _EmptyState({required this.c});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/lottie/fav_home.json',
            width: 160,
            height: 160,
            repeat: true,
          ),
          const SizedBox(height: 12),
          Text(
            'saved_empty_title'.tr,
            style: TextStyle(
              color: c.textPrimary,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'saved_empty_sub'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textMuted,
              fontFamily: 'Gilroy',
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
