import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/widgets/page_header.dart';
import 'package:toubna/core/widgets/user_avatar.dart';
import 'package:toubna/features/account/presentation/widgets/delete_account_sheet.dart';
import 'package:toubna/features/account/presentation/controllers/edit_profile_controller.dart';

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              PageHeader(title: "الملف الشخصي".tr),
              const SizedBox(height: 20),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF3E4EB),
                        width: 6,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: const UserAvatar(
                      size: 104,
                      background: Color(0xFF7A1F4B),
                      foreground: Colors.white,
                    ),
                  ),
                  PositionedDirectional(
                    bottom: -2,
                    end: -2,
                    child: GestureDetector(
                      onTap: controller.changePhoto,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9A21B),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFBF7F4),
                            width: 3,
                          ),
                        ),
                        child: const Center(
                          child: ImageIcon(
                            AssetImage('assets/icons/camera.png'),
                            size: 18,
                            color: Color(0xFF221A22),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _label("الاسم الكامل".tr),
              const SizedBox(height: 10),
              _box(
                TextFormField(
                  controller: controller.nameController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _label("رقم الموبايل".tr),
              const SizedBox(height: 10),
              _box(_readOnlyField(controller.phone)),
              const SizedBox(height: 20),
              _label("البريد الإلكتروني".tr),
              const SizedBox(height: 10),
              _box(_readOnlyField(controller.email)),
              const SizedBox(height: 24),
              _box(
                InkWell(
                  onTap: DeleteAccountSheet.show,
                  child: Center(
                    child: Text(
                      "حذف الحساب".tr,
                      style: TextStyle(fontSize: 19, color: Color(0xffA61B1B)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEADFE3))),
          ),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: controller.save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A1F4B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'حفظ التغييرات'.tr,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Text(
      text,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
    ),
  );

  Widget _box(Widget child) => Container(
    width: double.infinity,
    height: 50,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xffEADFE3)),
      color: Colors.white,
    ),
    child: child,
  );

  Widget _readOnlyField(String value) => TextFormField(
    readOnly: true,
    initialValue: value,
    onTap: controller.explainLockedField,
    style: const TextStyle(fontSize: 15, color: Color(0xFF4A3F46)),
    decoration: const InputDecoration(
      fillColor: Color(0xffF6F1F3),
      filled: true,
      border: OutlineInputBorder(borderSide: BorderSide.none),
    ),
  );
}
