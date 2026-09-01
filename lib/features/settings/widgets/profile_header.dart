import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
class ProfileHeader extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback onTap;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 26.r,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, size: 26.sp, color: AppColors.primaryColor),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 15.sp,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    role,
                    style: AppTextStyles.regular.copyWith(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 22.sp, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}