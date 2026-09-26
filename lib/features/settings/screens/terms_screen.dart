import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_text_style.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Terms & Conditions',
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
            // Last Updated Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1A5276).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF1A5276).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.update,
                    size: 18.sp,
                    color: const Color(0xFF1A5276),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Last Updated: January 2026',
                    style: AppTextStyles.semiBold.copyWith(
                      fontSize: 13.sp,
                      color: const Color(0xFF1A5276),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            _buildSection(
              '1. Acceptance of Terms',
              'By downloading, installing, or using PolioGuard, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you must not use the application.',
            ),

            _buildSection(
              '2. Purpose of the Application',
              'PolioGuard is designed to facilitate polio vaccination campaigns in Pakistan by providing digital tools for field workers, supervisors, and health administrators. The application enables vaccination recording, evidence collection, and real-time monitoring.',
            ),

            _buildSection(
              '3. User Responsibilities',
              '• Provide accurate and truthful vaccination data\n'
                  '• Record only genuine vaccination activities\n'
                  '• Respect the privacy of families and children\n'
                  '• Report any technical issues promptly\n'
                  '• Use the application only for its intended purpose',
            ),

            _buildSection(
              '4. Data Collection & Usage',
              'PolioGuard collects the following data:\n\n'
                  '• Vaccination records and status\n'
                  '• GPS coordinates of vaccination sites\n'
                  '• Video evidence of vaccinations\n'
                  '• Voice recordings of refusal reasons\n'
                  '• Parent/Guardian CNIC information\n\n'
                  'This data is used solely for polio eradication efforts and monitoring campaign effectiveness.',
            ),

            _buildSection(
              '5. Privacy & Confidentiality',
              'All personal information collected through the application is treated as confidential. We implement strict security measures to protect this data from unauthorized access, alteration, or disclosure.',
            ),

            _buildSection(
              '6. Intellectual Property',
              'PolioGuard and all its content, features, and functionality are owned by the development team and are protected by intellectual property laws. You may not reproduce, distribute, or create derivative works without explicit permission.',
            ),

            _buildSection(
              '7. Limitation of Liability',
              'While we strive for accuracy, PolioGuard is provided "as is" without warranties of any kind. We are not liable for any direct, indirect, or consequential damages arising from the use of this application.',
            ),

            _buildSection(
              '8. Modifications to Terms',
              'We reserve the right to modify these Terms and Conditions at any time. Users will be notified of significant changes through the application. Continued use after modifications constitutes acceptance of the updated terms.',
            ),

            _buildSection(
              '9. Termination',
              'We may terminate or suspend access to PolioGuard immediately, without prior notice, for any breach of these Terms and Conditions or for any conduct that we believe violates applicable laws or is harmful to other users.',
            ),

            _buildSection(
              '10. Contact Information',
              'For questions about these Terms and Conditions, please contact:\n\n'
                  'Email: legal@polioguard.app\n'
                  'Department of Computer Science\n'
                  'Abbottabad University of Science & Technology',
            ),

            SizedBox(height: 20.h),

            // Footer
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

  Widget _buildSection(String title, String content) {
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
          Text(
            title,
            style: AppTextStyles.bold.copyWith(
              fontSize: 14.sp,
              color: const Color(0xFF1A5276),
            ),
          ),
          SizedBox(height: 10.h),
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