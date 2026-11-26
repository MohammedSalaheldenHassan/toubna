import 'package:get/get.dart';

class MainShellController extends GetxController {
  static const cartTab = 2;
  static const ordersTab = 3;

  final currentIndex = 0.obs;

  void changeTab(int index) => currentIndex.value = index;
}
