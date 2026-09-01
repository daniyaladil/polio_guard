import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_text_style.dart';
import '../../auth/screens/login_screen.dart';

/// Handles all Settings screen actions.
/// Most actions are stubs for now — wire up the real logic
/// (share_plus, url_launcher, in-app review, API calls) later.
class SettingsController extends GetxController {
  // Dummy profile data — replace with real user data later.
  final userName = 'Muhammad Ali'.obs;
  final userRole = 'Field Worker'.obs;

  final appVersion = '1.0.0'.obs;
  final buildNumber = '1'.obs;

  void goToProfile() {
    // TODO: navigate to a real ProfileScreen with editable fields
    Get.snackbar('Profile', 'Profile screen not implemented yet');
  }

  void shareApp() {
    // TODO: wire up share_plus, e.g. Share.share('Check out PolioGuard...')
    Get.snackbar('Share App', 'Share functionality coming soon');
  }

  void sendFeedback() {
    // TODO: open a feedback form screen, or launch a mailto: link via url_launcher
    Get.snackbar('Send Feedback', 'Feedback form coming soon');
  }

  void rateUs() {
    // TODO: wire up in_app_review or launch Play Store / App Store URL
    Get.snackbar('Rate Us', 'Store rating coming soon');
  }

  void openTerms() {
    // TODO: navigate to a real Terms & Conditions screen
    Get.snackbar('Terms & Conditions', 'Screen not implemented yet');
  }

  void openPrivacyPolicy() {
    // TODO: navigate to a real Privacy Policy screen
    Get.snackbar('Privacy Policy', 'Screen not implemented yet');
  }

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out', style: AppTextStyles.bold.copyWith(fontSize: 16)),
        content: Text(
          'Are you sure you want to log out of PolioGuard?',
          style: AppTextStyles.regular.copyWith(fontSize: 13.5, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: AppTextStyles.semiBold.copyWith(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: _logout,
            child: Text('Log Out', style: AppTextStyles.semiBold.copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Get.back(); // close dialog
    // TODO: clear stored auth token / session here before navigating away
    Get.offAll(() => const LoginScreen());
  }
}