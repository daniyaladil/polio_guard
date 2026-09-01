import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../controller/settings_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16.w,
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'PolioGuard',
              style: AppTextStyles.bold.copyWith(
                fontSize: 17.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        children: [
          Obx(() => ProfileHeader(
            name: controller.userName.value,
            role: controller.userRole.value,
            onTap: controller.goToProfile,
          )),
          SizedBox(height: 20.h),

          _SectionLabel('General'),
          _SectionCard(
            children: [
              SettingsTile(
                icon: Icons.share_outlined,
                label: 'Share App',
                onTap: controller.shareApp,
              ),
              const _TileDivider(),
              SettingsTile(
                icon: Icons.feedback_outlined,
                label: 'Send Feedback',
                onTap: controller.sendFeedback,
              ),
              const _TileDivider(),
              SettingsTile(
                icon: Icons.star_outline,
                label: 'Rate Us',
                onTap: controller.rateUs,
              ),
            ],
          ),
          SizedBox(height: 20.h),

          _SectionLabel('Legal'),
          _SectionCard(
            children: [
              SettingsTile(
                icon: Icons.description_outlined,
                label: 'Terms & Conditions',
                onTap: controller.openTerms,
              ),
              const _TileDivider(),
              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: controller.openPrivacyPolicy,
              ),
            ],
          ),
          SizedBox(height: 20.h),

          _SectionLabel('About'),
          _SectionCard(
            children: [
              Obx(() => SettingsTile(
                icon: Icons.info_outline,
                label: 'App Version',
                trailing: Text(
                  'v${controller.appVersion.value} (${controller.buildNumber.value})',
                  style: AppTextStyles.medium.copyWith(
                    fontSize: 12.5.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              )),
            ],
          ),
          SizedBox(height: 28.h),

          _SectionCard(
            children: [
              SettingsTile(
                icon: Icons.logout,
                label: 'Log Out',
                iconColor: Colors.redAccent,
                labelColor: Colors.redAccent,
                onTap: controller.confirmLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        text,
        style: AppTextStyles.semiBold.copyWith(
          fontSize: 12.sp,
          color: Colors.grey.shade500,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 60.w, endIndent: 14.w, color: Colors.grey.shade200);
  }
}