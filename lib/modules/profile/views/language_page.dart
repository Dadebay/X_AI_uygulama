import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';
import 'package:atlas/widgets/language_selection_tile.dart';
import 'package:hugeicons/hugeicons.dart';

class LanguagePage extends StatelessWidget {
  LanguagePage({super.key});
  final LanguageController languageController = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'language'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            fontFamily: 'Gilroy',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 24,
            color: Color(0xFF22B241),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const LanguageSelectionTile(
            title: 'Türkmen dili',
            iconPath: 'assets/icons/tmflag.svg',
            code: 'tk',
            goBack: true,
          ),
          const SizedBox(height: 12),
          const LanguageSelectionTile(
            title: 'Rus dili',
            iconPath: 'assets/icons/ruflag.svg',
            code: 'ru',
            goBack: true,
          ),
        ],
      ),
    );
  }
}
