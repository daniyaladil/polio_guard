import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polio_guard/features/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:polio_guard/features/bottom_nav_bar/screen/custom_bottom_navigation_bar.dart';
import 'package:polio_guard/features/settings/screens/settings_screen.dart';
import 'package:polio_guard/features/worker/screens/worker_screen.dart';
import '../../home/screens/home_screen.dart';
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavBarController());

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeScreen(),
              SettingsScreen(),
            ],
          )),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() => CustomBottomNavigationBar(
              selectedIndex: controller.currentIndex.value,
              onTap: controller.changeIndex,
            )),
          ),
        ],
      ),
    );
  }
}