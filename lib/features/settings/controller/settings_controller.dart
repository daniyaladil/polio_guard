import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_text_style.dart';
import '../../auth/screens/login_screen.dart';
import '../screens/terms_screen.dart';
import '../screens/privacy_screen.dart';

class SettingsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable user data
  var userName = 'Loading...'.obs;
  var userRole = 'Field Worker'.obs;
  var userEmail = ''.obs;
  var assignedSector = ''.obs;
  var isLoading = true.obs;

  // App info (static)
  final appVersion = '1.0.0'.obs;
  final buildNumber = '1'.obs;

  // Share link
  final String shareLink = 'https://polioguard.app/download';

  // Rating
  var selectedRating = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  // Load actual user data from Firebase
  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          userName.value = data['name'] ?? 'Unknown User';
          userEmail.value = data['email'] ?? user.email ?? '';

          final role = data['role'] ?? 'worker';
          userRole.value = role == 'admin' ? 'Administrator' : 'Field Worker';

          if (role == 'worker') {
            assignedSector.value = data['assignedSector'] ?? '';
            if (assignedSector.value.isNotEmpty) {
              userRole.value =
              'Field Worker · ${assignedSector.value.replaceAll('_', '/')}';
            }
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      userName.value = 'Unknown User';
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // SHARE APP (share_plus 13.x)
  // ============================================
  Future<void> shareApp() async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          text: '🛡️ PolioGuard - Polio Vaccination Monitoring System\n\n'
              'Help us eradicate polio from Pakistan! 🇵🇰\n\n'
              'Download the app:\n$shareLink\n\n'
              'Together we can protect our children. 💙',
          subject: 'PolioGuard - Join the Mission',
          title: 'Share PolioGuard',
        ),
      );

      if (result.status == ShareResultStatus.success) {
        Get.snackbar(
          'Shared!',
          'Thank you for spreading the word 💙',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1A5276),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Share error: $e');
      Get.snackbar(
        'Unable to Share',
        'Please try again later',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  // ============================================
  // RATE US (UI only)
  // ============================================
  void rateUs() {
    selectedRating.value = 0;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8E1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('⭐', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Enjoying PolioGuard?',
                style: AppTextStyles.bold.copyWith(
                  fontSize: 20,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your rating helps us improve and\nmotivates our team!',
                textAlign: TextAlign.center,
                style: AppTextStyles.regular.copyWith(
                  fontSize: 13.5,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  final isFilled = starIndex <= selectedRating.value;
                  return GestureDetector(
                    onTap: () => selectedRating.value = starIndex,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        isFilled
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isFilled
                            ? const Color(0xFFFFC107)
                            : Colors.grey.shade400,
                        size: isFilled ? 40 : 36,
                      ),
                    ),
                  );
                }),
              )),
              const SizedBox(height: 8),
              Obx(() {
                if (selectedRating.value == 0) {
                  return Text(
                    'Tap to rate',
                    style: AppTextStyles.regular.copyWith(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  );
                }
                return Text(
                  _getRatingText(selectedRating.value),
                  style: AppTextStyles.semiBold.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF1A5276),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.semiBold.copyWith(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: selectedRating.value == 0
                          ? null
                          : _submitRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A5276),
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Submit',
                        style: AppTextStyles.bold.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return '😞 Poor';
      case 2:
        return '😐 Fair';
      case 3:
        return '🙂 Good';
      case 4:
        return '😊 Very Good';
      case 5:
        return '🤩 Excellent!';
      default:
        return '';
    }
  }

  void _submitRating() {
    final rating = selectedRating.value;
    Get.back();

    Get.snackbar(
      'Thank You! 🎉',
      'You rated PolioGuard $rating star${rating > 1 ? "s" : ""}. '
          'Your feedback means a lot!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1A5276),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.favorite, color: Colors.white),
    );
  }

  // ============================================
  // TERMS & PRIVACY
  // ============================================
  void openTerms() => Get.to(() => const TermsScreen());
  void openPrivacyPolicy() => Get.to(() => const PrivacyScreen());

  // ============================================
  // PROFILE
  // ============================================
  void goToProfile() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF1A5276).withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xFF1A5276),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName.value,
                style: AppTextStyles.bold.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                userEmail.value,
                style: AppTextStyles.regular.copyWith(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5276).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  userRole.value,
                  style: AppTextStyles.semiBold.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF1A5276),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5276),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // LOGOUT
  // ============================================
  void confirmLogout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 32,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Log Out?',
                style: AppTextStyles.bold.copyWith(
                  fontSize: 20,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to log out of\nPolioGuard?',
                textAlign: TextAlign.center,
                style: AppTextStyles.regular.copyWith(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.semiBold.copyWith(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Log Out',
                        style: AppTextStyles.bold.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Get.back();
      Get.deleteAll();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not log out. Please try again.',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }
}