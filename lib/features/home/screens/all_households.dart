import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../data/dummy_data.dart';
import '../widgets/household_tile.dart';
import 'household_detail_screen.dart';

class AllHouseholdsScreen extends StatelessWidget {
  final String sector;
  const AllHouseholdsScreen({super.key, required this.sector});

  @override
  Widget build(BuildContext context) {
    final households = WorkerMapData.householdsInSector(sector);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '${WorkerMapData.readableSector(sector)} Households',
          style: AppTextStyles.bold.copyWith(
            fontSize: 16.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: households.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1.h, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final h = households[index];
          return Container(
            color: Colors.white,
            child: HouseholdTile(
              household: h,
              onTap: () => Get.to(
                    () => HouseholdDetailScreen(household: h),
              ),
            ),
          );
        },
      ),
    );
  }
}