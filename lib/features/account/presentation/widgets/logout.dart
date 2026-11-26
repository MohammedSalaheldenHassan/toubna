import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/features/account/presentation/controllers/account_controller.dart';

class Logout extends GetView<AccountController> {
  const Logout({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xffEADFE3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: controller.confirmLogout,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/logout.png",
                color: const Color(0xffA61B1B),
                width: 30,
              ),
              Text(
                "تسجيل الخروج".tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xffA61B1B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
