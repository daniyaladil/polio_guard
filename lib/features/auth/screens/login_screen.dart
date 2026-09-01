import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../controller/auth_controller.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/primary_button.dart';
import '../widgets/role_selector.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller using GetX
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF1FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AuthLogo()),
                    SizedBox(height: 16.h),
                    Text(
                      'PolioGuard',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 26.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Polio vaccination field operations\nmanagement for Pakistan',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.regular.copyWith(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Show error message if any
                    Obx(() {
                      if (controller.errorMessage.value.isNotEmpty) {
                        return Container(
                          padding: EdgeInsets.all(12.w),
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700, size: 20.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: controller.clearError,
                                child: Icon(Icons.close, color: Colors.red.shade700, size: 16.sp),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    AuthTextField(
                      label: 'Email Address',
                      hint: 'you@example.com',
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: controller.validateEmail,
                    ),
                    SizedBox(height: 20.h),

                    // Use Obx to listen to obscurePassword changes
                    Obx(() => AuthTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: controller.passwordController,
                      obscureText: controller.obscurePassword.value, // Use .value
                      validator: controller.validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20.sp,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    )),
                    SizedBox(height: 24.h),

                    Text(
                      'Sign in as',
                      style: AppTextStyles.semiBold.copyWith(
                        fontSize: 13.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Use Obx to listen to selectedRole changes
                    Obx(() => RoleSelector(
                      selectedRole: controller.selectedRole.value, // Use .value
                      onChanged: controller.selectRole,
                    )),
                    SizedBox(height: 28.h),

                    // Use Obx to listen to isLoading changes
                    Obx(() => PrimaryButton(
                      label: 'Sign In',
                      isLoading: controller.isLoading.value, // Use .value
                      onPressed: controller.signIn,
                    )),
                    SizedBox(height: 14.h),

                    const SecureAccessNote(),
                    SizedBox(height: 20.h),

                    const AuthInfoBanner(
                      message:
                      'Ensure accurate credentials for reliable field '
                          'data sync. Contact your district coordinator if '
                          'you need access.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}