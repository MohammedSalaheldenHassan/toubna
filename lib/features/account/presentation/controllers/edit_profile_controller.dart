import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/services/connectivity_service.dart';
import 'package:toubna/core/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toubna/core/services/user_controller.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/utils/app_message.dart';

class EditProfileController extends GetxController {
  final UserController user = Get.find<UserController>();
  late final nameController = TextEditingController(text: user.name.value);

  String get phone => user.phone.value;
  String get email => user.email.value;

  String get initial {
    final name = nameController.text.trim();
    return name.isEmpty ? 'م'.tr : name.characters.first;
  }

  /// تغيير الصورة: من المعرض، الكاميرا، أو حذفها.
  Future<void> changePhoto() async {
    final source = await Get.bottomSheet<Object>(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text('اختاري من المعرض'.tr),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text('صوّري بالكاميرا'.tr),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              if (user.avatarPath.value != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.danger,
                  ),
                  title: Text(
                    'حذف الصورة'.tr,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                  onTap: () => Get.back(result: 'remove'),
                ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
    if (source == 'remove') {
      await user.setAvatar(null);
      showAppMessage('تم حذف الصورة'.tr);
      return;
    }
    if (source is! ImageSource) return;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 600,
        imageQuality: 85,
      );
      if (picked == null) return; // رجعت من غير ما تختار
      // هنا لاحقًا: ترفع الصورة للـ API وتحفظ الرابط
      await user.setAvatar(picked.path);
      showAppMessage('تم تحديث الصورة'.tr);
    } catch (_) {
      showAppMessage(
        'ما قدرنا نفتح الصور. اتأكدي من الصلاحيات وحاولي تاني.'.tr,
      );
    }
  }

  /// رقم الموبايل والبريد مربوطين بالحساب والتحقق، فما بيتغيروا من هنا.
  void explainLockedField() => showAppMessage(
    'رقم الموبايل والبريد مربوطين بحسابك. لتغييرهم تواصلي معنا.'.tr,
    actionLabel: 'تواصلي معنا'.tr,
    onAction: () => Get.toNamed(AppRoutes.contactUs),
  );

  void save() {
    final name = nameController.text.trim();
    if (name.length < 3) {
      showAppMessage('اكتبي اسمك الكامل'.tr);
      return;
    }
    if (!requireOnline()) return;
    // هنا لاحقًا: ترسل التعديلات للـ API
    user.updateName(name);
    Get.back();
    showAppMessage('تم حفظ التغييرات'.tr);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
