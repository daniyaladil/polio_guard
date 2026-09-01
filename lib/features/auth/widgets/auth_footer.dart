import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_text_style.dart';

class SecureAccessNote extends StatelessWidget {
  const SecureAccessNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 13.sp, color: Colors.grey.shade500),
        SizedBox(width: 6.w),
        Text(
          'Secure access · Data encrypted end-to-end',
          style: AppTextStyles.regular.copyWith(
            fontSize: 11.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class AuthInfoBanner extends StatelessWidget {
  final String message;

  const AuthInfoBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F2FC),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 15.sp, color: Colors.grey.shade600),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.regular.copyWith(
                fontSize: 11.5.sp,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}