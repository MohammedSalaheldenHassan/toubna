import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/features/account/presentation/controllers/account_controller.dart';
import 'package:toubna/features/account/presentation/widgets/account_info.dart';
import 'package:toubna/features/account/presentation/widgets/logout.dart';
import 'package:toubna/features/account/presentation/widgets/settings_section.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
          child: Column(
            children: [
              AccountInfo(),
              SizedBox(height: 20),
              SettingsSection(),
              SizedBox(height: 15),
              Logout(),
              SizedBox(height: 16),
              Text(
                'توبنا · الإصدار @p0'.trParams({
                  'p0': AccountController.appVersion,
                }),
                style: TextStyle(fontSize: 12, color: Color(0xFF6B5E66)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
