import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_style.dart';
import '../controller/worker_controller.dart';
import '../model/household_model.dart';
import '../widgets/house_bottomsheet.dart';
import '../widgets/household_tile.dart';

class AllHouseholdsScreen extends StatelessWidget {
  const AllHouseholdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WorkerController>();

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
          '${c.readableSector()} Households',
          style: AppTextStyles.bold
              .copyWith(fontSize: 16.sp, color: Colors.white),
        ),
      ),
      body: Obx(() {
        final houses = c.sectorHouses;

        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: houses.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1.h, color: Colors.grey.shade200),
          itemBuilder: (context, index) {
            final h = houses[index];
            final household = _toHousehold(h);
            return Container(
              color: Colors.white,
              child: HouseholdTile(
                household: household,
                onTap: () => HouseActionSheet.show(h),
              ),
            );
          },
        );
      }),
    );
  }

  Household _toHousehold(HouseRow h) {
    HouseholdStatus hs;
    switch (h.status) {
      case 'vaccinated':
        hs = HouseholdStatus.done;
        break;
      case 'refused':
        hs = HouseholdStatus.refused;
        break;
      case 'absent':
        hs = HouseholdStatus.absent;
        break;
      default:
        hs = HouseholdStatus.pending;
    }
    return Household(
      id: h.id,
      familyName: h.familyName,
      laneBlock: h.address,
      status: hs,
      houseAddress: h.address,
      ucTehsil: 'UC-32, Tehsil Islamabad',
      guardianCnic: '17301-0000000-0',
      headName: h.familyName,
      children: const [
        ChildInfo(
            name: 'Child A',
            age: '2 years',
            status: ChildVaccinationStatus.eligible),
        ChildInfo(
            name: 'Child B',
            age: '4 years',
            status: ChildVaccinationStatus.eligible),
      ],
    );
  }
}