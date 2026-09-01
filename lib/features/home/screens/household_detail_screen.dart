import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../model/household_model.dart';
import '../widgets/child_tile.dart';

class HouseholdDetailScreen extends StatelessWidget {
  final Household household;

  const HouseholdDetailScreen({super.key, required this.household});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
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
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CircleAvatar(
              radius: 15.r,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: Icon(Icons.person_outline, color: Colors.white, size: 18.sp),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Household Detail',
                style: AppTextStyles.bold.copyWith(
                  fontSize: 18.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              if (household.visitedToday)
                Text(
                  'Visited Today',
                  style: AppTextStyles.semiBold.copyWith(
                    fontSize: 12.5.sp,
                    color: const Color(0xFF34A853),
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h),

          // Address card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined,
                    color: AppColors.primaryColor, size: 18.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        household.houseAddress,
                        style: AppTextStyles.semiBold.copyWith(
                          fontSize: 13.5.sp,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        household.ucTehsil,
                        style: AppTextStyles.regular.copyWith(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () {
                          // TODO: open location in maps
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map_outlined,
                                size: 14.sp, color: AppColors.primaryColor),
                            SizedBox(width: 4.w),
                            Text(
                              'View on Map',
                              style: AppTextStyles.semiBold.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Guardian / head info
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                _InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Guardian CNIC: ${household.guardianCnic}',
                ),
                SizedBox(height: 10.h),
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Head: ${household.headName}',
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Children (${household.children.length})',
                style: AppTextStyles.bold.copyWith(
                  fontSize: 14.5.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                '${household.eligibleCount} Eligible · ${household.vaccinatedCount} Vaccinated',
                style: AppTextStyles.semiBold.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          ...household.children.map((child) => ChildTile(child: child)),
          SizedBox(height: 8.h),

          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: wire up real vaccination recording flow
              },
              icon: Icon(Icons.vaccines, size: 18.sp, color: Colors.white),
              label: Text(
                'Record Vaccination',
                style: AppTextStyles.bold.copyWith(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: wire up real refusal recording flow
              },
              icon: Icon(Icons.circle_outlined, size: 16.sp, color: Colors.redAccent),
              label: Text(
                'Record Refusal',
                style: AppTextStyles.bold.copyWith(
                  fontSize: 14.sp,
                  color: Colors.redAccent,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey.shade600),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.regular.copyWith(
              fontSize: 13.sp,
              color: const Color(0xFF3A3A3A),
            ),
          ),
        ),
      ],
    );
  }
}