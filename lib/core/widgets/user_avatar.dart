import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/services/user_controller.dart';

/// صورة الملف الشخصي: الصورة المختارة، أو أول حرف من الاسم.
class UserAvatar extends StatelessWidget {
  final double size;
  final Color background;
  final Color foreground;

  const UserAvatar({
    super.key,
    required this.size,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final user = Get.find<UserController>();
    return Obx(() {
      final path = user.avatarPath.value;
      final file = path == null ? null : File(path);
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: file != null && file.existsSync()
            ? Image.file(file, width: size, height: size, fit: BoxFit.cover)
            : Text(
                user.initial,
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: foreground,
                ),
              ),
      );
    });
  }
}
