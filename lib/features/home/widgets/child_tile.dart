import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_text_style.dart';
import '../model/household_model.dart';

class ChildTile extends StatelessWidget {
  final ChildInfo child;

  const ChildTile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final vaccinated = child.status == ChildVaccinationStatus.vaccinated;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: vaccinated
                ? const Color(0xFFE3F5E8)
                : const Color(0xFFFCEFE3),
            child: Icon(
              vaccinated ? Icons.check_circle : Icons.child_care,
              size: 18.sp,
              color: child.status.color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: AppTextStyles.semiBold.copyWith(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Age: ${child.age}',
                  style: AppTextStyles.regular.copyWith(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            child.status.label,
            style: AppTextStyles.semiBold.copyWith(
              fontSize: 12.5.sp,
              color: child.status.color,
            ),
          ),
        ],
      ),
    );
  }
}