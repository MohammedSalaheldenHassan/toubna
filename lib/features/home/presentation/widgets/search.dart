import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/features/home/presentation/controllers/home_controller.dart';

/// شريط البحث (نفس الشكل) — يفتح صفحة البحث عند الضغط.
class Search extends GetView<HomeController> {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'بحث'.tr,
      child: Material(
        color: Colors.white,
        shape: const StadiumBorder(side: BorderSide(color: Color(0xffEADFE3))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: controller.openSearch,
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Image.asset(
                    "assets/icons/search.png",
                    color: const Color(0xff221A22),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "ابحثي عن توب، لون، أو خامة…".tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: Color(0xff221A22)),
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsetsDirectional.only(end: 5),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xffF3E4EB),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    "assets/icons/filter.png",
                    color: const Color(0xff7A1F4B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
