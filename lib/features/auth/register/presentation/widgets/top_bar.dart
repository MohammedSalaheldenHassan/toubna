import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/directional_arrow.dart';
import 'package:get/get.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // يكبر مع شريط الحالة (النوتش) بدل ما المحتوى يتغطى
      constraints: const BoxConstraints(minHeight: 132),
      padding: EdgeInsets.fromLTRB(
        15,
        MediaQuery.paddingOf(context).top + 16,
        15,
        20,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        image: DecorationImage(
          image: AssetImage("assets/images/patterns/plum_weave_tile.png"),
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: DirectionalArrow(
                  back: true,
                  icon: true,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'إنشاء حساب جديد'.tr,
                  style: TextStyle(
                    fontFamily: 'ReemKufi',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'انضمي لتوبنا واحصلي على خصم 10٪ لأول طلب'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Image.asset('assets/images/logo/logo_mark.png', width: 52),
        ],
      ),
    );
  }
}
