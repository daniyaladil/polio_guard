import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_style.dart';
import '../controller/worker_controller.dart';
import '../screens/record_vaccinated_screen.dart';
import '../screens/record_absent_screen.dart';
import '../screens/record_refused_screen.dart';

class HouseActionSheet extends StatelessWidget {
  final HouseRow house;
  const HouseActionSheet({super.key, required this.house});

  static Future<void> show(HouseRow house) {
    return Get.bottomSheet<void>(
      HouseActionSheet(house: house),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WorkerController>();
    final color = c.colorFor(house.status);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.home_outlined,
                  color: AppColors.primaryColor, size: 22.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      house.familyName,
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 15.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      house.address,
                      style: AppTextStyles.regular.copyWith(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  c.labelFor(house.status),
                  style: AppTextStyles.semiBold.copyWith(
                    fontSize: 11.sp,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            'Record visit outcome',
            style: AppTextStyles.semiBold.copyWith(
              fontSize: 12.5.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 10.h),
          _ActionTile(
            color: const Color(0xFF34A853),
            icon: Icons.vaccines,
            title: 'Mark Vaccinated',
            subtitle: 'Enter children + record proof',
            onTap: () async {
              final result = await Get.to(
                    () => RecordVaccinatedScreen(house: house),
              );
              if (result is String) Get.back();
            },
          ),
          SizedBox(height: 10.h),
          _ActionTile(
            color: const Color(0xFFF5A623),
            icon: Icons.person_off_outlined,
            title: 'Mark Absent',
            subtitle: 'Take a live photo of empty house',
            onTap: () async {
              final result = await Get.to(
                    () => RecordAbsentScreen(house: house),
              );
              if (result is String) Get.back();
            },
          ),
          SizedBox(height: 10.h),
          _ActionTile(
            color: const Color(0xFFE53935),
            icon: Icons.block,
            title: 'Mark Refused',
            subtitle: 'Record refusal video',
            onTap: () async {
              final result = await Get.to(
                    () => RecordRefusedScreen(house: house),
              );
              if (result is String) Get.back();
            },
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.semiBold.copyWith(
                      fontSize: 13.5.sp,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.regular.copyWith(
                      fontSize: 11.5.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Colors.grey.shade400, size: 20.sp),
          ],
        ),
      ),
    );
  }
}