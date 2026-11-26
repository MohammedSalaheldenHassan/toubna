import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/features/home/presentation/controllers/home_controller.dart';

class HomeAppBar extends GetView<HomeController> {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "توبنا".tr,
                style: TextStyle(
                  fontSize: 35,
                  color: Color(0xff7A1F4B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "أصالة تليق بكل مناسبة".tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 17, color: Color(0xff6B5E66)),
              ),
            ],
          ),
        ),
        Obx(
          () => _iconBox(
            "assets/icons/bell.png",
            'الإشعارات'.tr,
            controller.openNotifications,
            dot: controller.notifications.unreadCount > 0,
          ),
        ),
        const SizedBox(width: 15),
        Obx(
          () => _iconBox(
            "assets/icons/heart.png",
            'المفضلة'.tr,
            controller.openFavorites,
            count: controller.favorites.count,
          ),
        ),
      ],
    );
  }

  Widget _iconBox(
    String icon,
    String tooltip,
    VoidCallback onTap, {
    bool dot = false,
    int count = 0,
  }) {
    return Tooltip(
      message: tooltip,
      child: Badge(
        isLabelVisible: dot || count > 0,
        smallSize: 10,
        label: count > 0 ? Text('$count') : null,
        backgroundColor: const Color(0xff7A1F4B),
        offset: const Offset(-4, -4),
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xffEADFE3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(icon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
