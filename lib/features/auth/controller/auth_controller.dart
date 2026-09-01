import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polio_guard/core/services/firebase_service.dart';
import 'package:polio_guard/features/bottom_nav_bar/screen/main_screen.dart';

enum UserRole { fieldWorker, supervisor }

class AuthController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var selectedRole = UserRole.fieldWorker.obs;
  var obscurePassword = true.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  void selectRole(UserRole role) {
    selectedRole.value = role;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Check if admin login (hardcoded)
      if (selectedRole.value == UserRole.supervisor) {
        // Admin login check
        if (email == FirebaseService.adminEmail &&
            password == FirebaseService.adminPassword) {
          // Navigate to admin dashboard
          Get.offAllNamed('/admin-dashboard');
          // Get.to(MainScreen());
          return;
        } else {
          errorMessage.value = 'Invalid admin credentials';
          isLoading.value = false;
          return;
        }
      }

      // Worker login - check Firebase
      final userCredential = await _firebaseService.signIn(email, password);
      final userData = await _firebaseService.getUserData(userCredential.user!.uid);

      if (userData == null || userData['role'] != 'worker') {
        await _firebaseService.signOut();
        errorMessage.value = 'Invalid worker account';
        isLoading.value = false;
        return;
      }

      // Navigate to worker dashboard
      // Get.offAllNamed('/worker-dashboard');
      Get.to(MainScreen());

    } catch (e) {
      errorMessage.value = 'Login failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}