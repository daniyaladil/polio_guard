import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_text_style.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5276),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Privacy Policy',
          style: AppTextStyles.bold.copyWith(
            fontSize: 17.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A5276), Color(0xFF2874A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 48.sp,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Your Privacy Matters',
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 18.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'We are committed to protecting your\npersonal information',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.regular.copyWith(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            _buildSection(
              icon: Icons.info_outline,
              title: 'Information We Collect',
              content: '• Personal identification (name, email)\n'
                  '• GPS location data during field operations\n'
                  '• Video and audio recordings for verification\n'
                  '• Parent/Guardian CNIC information\n'
                  '• Device information and app usage data',
            ),

            _buildSection(
              icon: Icons.settings_outlined,
              title: 'How We Use Your Information',
              content: '• To verify vaccination activities\n'
                  '• To generate campaign reports and analytics\n'
                  '• To improve application performance\n'
                  '• To ensure accountability in field operations\n'
                  '• To communicate important updates',
            ),

            _buildSection(
              icon: Icons.lock_outline,
              title: 'Data Security',
              content: 'We implement industry-standard security measures:\n\n'
                  '• End-to-end encryption for all data transmission\n'
                  '• Secure Firebase cloud storage\n'
                  '• Encrypted local storage on devices\n'
                  '• Regular security audits and updates\n'
                  '• Role-based access control',
            ),

            _buildSection(
              icon: Icons.share_outlined,
              title: 'Information Sharing',
              content: 'We do NOT sell, trade, or rent your personal information. Data may be shared only with:\n\n'
                  '• Health authorities for polio eradication\n'
                  '• Authorized supervisors for monitoring\n'
                  '• Law enforcement when legally required',
            ),

            _buildSection(
              icon: Icons.schedule,
              title: 'Data Retention',
              content: 'Vaccination records are retained for the duration required by health authorities. Personal data is deleted upon request or when no longer needed for campaign purposes.',
            ),

            _buildSection(
              icon: Icons.person_outline,
              title: 'Your Rights',
              content: 'You have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Request corrections to inaccurate data\n'
                  '• Request deletion of your data\n'
                  '• Opt-out of non-essential communications\n'
                  '• Lodge complaints with authorities',
            ),

            _buildSection(
              icon: Icons.child_care,
              title: "Children's Privacy",
              content: 'We collect minimal information about children (name, age, vaccination status) solely for vaccination tracking purposes. This information is protected with the highest security standards.',
            ),

            _buildSection(
              icon: Icons.update,
              title: 'Policy Updates',
              content: 'We may update this Privacy Policy periodically. Users will be notified of significant changes through the application. Continued use constitutes acceptance of the updated policy.',
            ),

            // Contact Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF1A5276).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.contact_support,
                        color: const Color(0xFF1A5276),
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Contact Us',
                        style: AppTextStyles.bold.copyWith(
                          fontSize: 14.sp,
                          color: const Color(0xFF1A5276),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'For privacy concerns, contact:\n'
                        'privacy@polioguard.app\n\n'
                        'Department of Computer Science\n'
                        'Abbottabad University of Science & Technology',
                    style: AppTextStyles.regular.copyWith(
                      fontSize: 12.5.sp,
                      color: const Color(0xFF3A3A3A),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            Center(
              child: Text(
                '© 2026 PolioGuard. All rights reserved.',
                style: AppTextStyles.regular.copyWith(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5276).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 18.sp,
                  color: const Color(0xFF1A5276),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 14.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: AppTextStyles.regular.copyWith(
              fontSize: 13.sp,
              color: const Color(0xFF3A3A3A),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}