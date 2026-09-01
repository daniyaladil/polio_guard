import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_text_style.dart';
import '../model/household_model.dart';

class WardSummaryCard extends StatelessWidget {
  final String wardName;
  final int totalAssigned;
  final int doneCount;
  final int refusedCount;
  final int absentCount;
  final int pendingCount;

  const WardSummaryCard({
    super.key,
    required this.wardName,
    required this.totalAssigned,
    required this.doneCount,
    required this.refusedCount,
    required this.absentCount,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                wardName,
                style: AppTextStyles.bold.copyWith(
                  fontSize: 16.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                '$totalAssigned Households Assigned',
                style: AppTextStyles.regular.copyWith(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: [
              _LegendItem(status: HouseholdStatus.done, count: doneCount),
              _LegendItem(status: HouseholdStatus.refused, count: refusedCount),
              _LegendItem(status: HouseholdStatus.absent, count: absentCount),
              _LegendItem(status: HouseholdStatus.pending, count: pendingCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final HouseholdStatus status;
  final int count;

  const _LegendItem({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          '$count ${status.label}',
          style: AppTextStyles.medium.copyWith(
            fontSize: 12.sp,
            color: const Color(0xFF3A3A3A),
          ),
        ),
      ],
    );
  }
}