import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_text_style.dart';
import '../model/household_model.dart';

class HouseholdTile extends StatelessWidget {
  final Household household;
  final VoidCallback onTap;

  const HouseholdTile({
    super.key,
    required this.household,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: household.status.color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${household.id} ${household.familyName}',
                    style: AppTextStyles.semiBold.copyWith(
                      fontSize: 13.5.sp,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    household.laneBlock,
                    style: AppTextStyles.regular.copyWith(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              household.status.label,
              style: AppTextStyles.semiBold.copyWith(
                fontSize: 12.5.sp,
                color: household.status.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}