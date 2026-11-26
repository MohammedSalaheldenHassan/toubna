import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/directional_arrow.dart';
import 'package:get/get.dart';
import 'package:toubna/features/account/presentation/controllers/account_controller.dart';

class SettingsSection extends GetView<AccountController> {
  const SettingsSection({super.key});

  static const _titleStyle = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: Colors.white,
        border: Border.all(color: const Color(0xffEADFE3)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            ListTile(
              onTap: controller.openLocations,
              title: Text("عناويني".tr, style: _titleStyle),
              // العنوان الافتراضي الحالي تحت العنوان
              subtitle: Obx(() {
                final address = controller.addresses.defaultAddress;
                return Text(
                  address == null ? 'ضيفي عنوان توصيل'.tr : address.shortText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B5E66),
                  ),
                );
              }),
              trailing: const DirectionalArrow(back: false),
              leading: _leading("assets/icons/location.png"),
            ),
            _divider(),
            ListTile(
              title: Text("الإشعارات".tr, style: _titleStyle),
              trailing: Obx(
                () => Switch(
                  value: controller.notificationsOn.value,
                  activeTrackColor: const Color(0xff7A1F4B),
                  activeThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFD8CDD2),
                  inactiveThumbColor: Colors.white,
                  trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                  onChanged: controller.toggleNotifications,
                ),
              ),
              leading: _leading("assets/icons/bell.png"),
            ),
            _divider(),
            ListTile(
              title: Text("اللغة".tr, style: _titleStyle),
              trailing: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E4EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(
                  () => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _langOption('العربية', 0),
                      _langOption('English', 1),
                    ],
                  ),
                ),
              ),
              leading: _leading("assets/icons/language.png"),
            ),
            _divider(),
            ListTile(
              onTap: controller.openContactUs,
              title: Text("تواصلي معنا".tr, style: _titleStyle),
              trailing: const DirectionalArrow(back: false),
              leading: _leading("assets/icons/phone.png"),
            ),
            _divider(),
            ListTile(
              onTap: controller.openTerms,
              title: Text("الشروط وسياسة الخصوصية".tr, style: _titleStyle),
              trailing: const DirectionalArrow(back: false),
              leading: _leading("assets/icons/orders.png"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _langOption(String label, int index) {
    final selected = controller.selectedLang == index;
    return GestureDetector(
      onTap: () => controller.selectLanguage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: selected ? const Color(0xFF7A1F4B) : const Color(0xFF6B5E66),
          ),
        ),
      ),
    );
  }

  Widget _leading(String icon) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: const Color(0xffF3E4EB),
    ),
    child: Image.asset(icon),
  );

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.0),
    child: Divider(),
  );
}
