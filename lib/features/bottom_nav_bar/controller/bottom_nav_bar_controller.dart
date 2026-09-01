import 'package:get/get.dart';

class BottomNavBarController extends GetxController {
  var currentIndex = 0.obs;

  void changeIndex(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
    }
  }

  void goToHome() {
    currentIndex.value = 0;
  }
}